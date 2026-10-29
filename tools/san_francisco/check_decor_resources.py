"""Verify donor DMI bytes, PNG chunks and every imported static appearance."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import zlib
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
from import_common import donor_checkout

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", type=donor_checkout, help="Also compare bytes with the pinned donor checkout")
SOURCE = parser.parse_args().source
MODULE = ROOT / "modular_bandastation/san_francisco"
errors = []
count = 0
for filename in (MODULE / "icons").rglob("*.dmi"):
    raw = filename.read_bytes()
    if raw[:8] != b"\x89PNG\r\n\x1a\n":
        errors.append({"file": str(filename), "error": "Not a PNG-encoded DMI"})
        continue
    position = 8
    chunk_types = []
    while position < len(raw):
        length = struct.unpack(">I", raw[position:position + 4])[0]
        kind = raw[position + 4:position + 8]
        data = raw[position + 8:position + 8 + length]
        crc = struct.unpack(">I", raw[position + 8 + length:position + 12 + length])[0]
        if zlib.crc32(kind + data) & 0xFFFFFFFF != crc:
            errors.append({"file": str(filename), "error": "Bad PNG CRC", "chunk": kind.decode()})
        chunk_types.append(kind.decode())
        position += length + 12
    with Image.open(filename) as image:
        description = image.info.get("Description", "")
        if "# BEGIN DMI" not in description:
            errors.append({"file": str(filename), "error": "Missing native DMI Description metadata"})
    if not chunk_types or chunk_types[0] != "IHDR" or chunk_types[-1] != "IEND" or position != len(raw):
        errors.append({"file": str(filename), "error": "Invalid PNG chunk structure"})
    count += 1

verified_sources = 0
verified_hashes = 0
provenance = json.loads((MODULE / "icons/provenance.json").read_text(encoding="utf-8-sig"))
recorded = set()
for entry in provenance["files"]:
    relative = entry["destination"]
    destination = ROOT / relative
    if relative in recorded:
        errors.append({"file": relative, "error": "Duplicate provenance record"})
    recorded.add(relative)
    if not destination.is_file():
        errors.append({"file": relative, "error": "Missing imported DMI"})
        continue
    raw = destination.read_bytes()
    if hashlib.sha256(raw).hexdigest() != entry["sha256"] or len(raw) != entry["bytes"]:
        errors.append({"file": relative, "error": "Copied bytes differ from recorded provenance"})
    else:
        verified_hashes += 1
    if SOURCE:
        donor = SOURCE / entry["source"]
        if not donor.is_file() or donor.read_bytes() != raw:
            errors.append({"file": relative, "error": "Copied bytes differ from donor checkout"})
        else:
            verified_sources += 1
actual = {file.relative_to(ROOT).as_posix() for file in (MODULE / "icons").rglob("*.dmi")}
if actual != recorded or len(recorded) != provenance["file_count"]:
    errors.append({"error": "Incomplete provenance", "unlisted": sorted(actual - recorded), "missing": sorted(recorded - actual)})

checked_appearances = 0
for filename in (MODULE / "code/walls.dm", MODULE / "code/turfs.dm", MODULE / "code/decor.dm"):
    for block in re.split(r"\n\n+", filename.read_text(encoding="utf-8-sig")):
        icon = re.search(r"^\ticon = '([^']+\.dmi)'$", block, re.MULTILINE)
        state = re.search(r'^\ticon_state = "([^"]*)"$', block, re.MULTILINE)
        if not icon or not state:
            continue
        sprite = ROOT / icon[1]
        if not sprite.is_file():
            errors.append({"type": block.splitlines()[0], "error": "Missing sprite", "sprite": icon[1]})
            continue
        with Image.open(sprite) as image:
            states = re.findall(r'^state = "([^"]*)"$', image.info.get("Description", ""), re.MULTILINE)
        if state[1] not in states:
            errors.append({"type": block.splitlines()[0], "error": "Missing static icon state", "state": state[1], "sprite": icon[1]})
        checked_appearances += 1

result = {"dmi_files_with_valid_png_chunks": count, "provenance_hashes_verified": verified_hashes, "donor_hashes_verified": verified_sources, "static_appearances_checked": checked_appearances, "errors": errors}
print(json.dumps(result, ensure_ascii=False, indent=2))
raise SystemExit(bool(errors))
