"""Pinned donor input and map inventory shared by the city import tools."""

import argparse
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
SOURCE_COMMIT = "483ef4772fe4957027c8e2f290cd1503b2b237f5"
SOURCE_MAP = "_maps/map_files/Vampire/san_fangsisco/sanfangsisco.dmm"

# Dependencies are installed from tools/requirements.txt; mapmerge2 is part of this repository.
sys.path.insert(0, str(ROOT / "tools"))


def donor_checkout(value):
    """Reject another donor revision before a generator can write anything."""
    source = Path(value).expanduser().resolve()
    try:
        revision = subprocess.run(
            ["git", "-C", str(source), "rev-parse", "HEAD"],
            check=True, capture_output=True, encoding="utf-8", errors="replace",
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError) as error:
        detail = error.stderr.strip() if isinstance(error, subprocess.CalledProcessError) else str(error)
        raise argparse.ArgumentTypeError(f"Cannot read donor Git revision: {detail}") from error
    if revision != SOURCE_COMMIT:
        raise argparse.ArgumentTypeError(f"Expected donor commit {SOURCE_COMMIT}, found {revision}")
    if not (source / SOURCE_MAP).is_file():
        raise argparse.ArgumentTypeError(f"Missing donor map: {SOURCE_MAP}")
    return source


def map_inventory(source, known_paths):
    """Read every model used by the converter, without an external audit snapshot."""
    from mapmerge2.dmm import DMM

    city = DMM.from_file(str(source / SOURCE_MAP))
    paths = sorted({atom.split("{", 1)[0].strip() for tile in city.dictionary.values() for atom in tile})
    return {
        "all_types": paths,
        "top_missing": [{"path": path} for path in paths if path not in known_paths],
    }
