"""Read-only R15-R17 source audit; no generators, saves, Git writes or imports.

Run: py -3 -B ./source_invariants.py --repo ../BandaStation
Compares original PR declarations to current DM declarations, not the rename
scripts' output. The typepath policy below is explicit and independently checked.
This is a bounded source check, not a DM preprocessor or runtime substitute.
"""
from __future__ import annotations

import hashlib
import argparse
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path.cwd()
TASK = Path(__file__).resolve().parent
MIGRATION = TASK / "VARIANT_MIGRATION.json"
OLD = "d15909e7abab81a0dc4f21faf063b6bd1148706d"
DONOR = "modular_bandastation/donor_jobs/code/"
JOBS = "modular_bandastation/jobs/code/"
CLOWN_PARENT = "/datum/outfit/job/clown"
SECURITY_CLOWN = CLOWN_PARENT + "/security"
INHERITED_CLOWN_FIELDS = frozenset({
    "backpack", "satchel", "duffelbag", "shoes", "mask", "l_pocket", "belt",
})

# Deployment identifiers and sprite-state strings are deliberately not renamed.
STEMS = {
    "musican": "musician", "seclown": "security_clown",
    "bath": "bath_attendant", "casino": "croupier", "uncertain": "unemployed",
    "administrator": "service_administrator", "guard": "service_guard",
    "dealer": "merchant",
}
PATHS = {
    "/obj/item/gun/energy/donor_honk": "/obj/item/gun/energy/honk_rifle",
    "/obj/item/ammo_casing/energy/donor_honk": "/obj/item/ammo_casing/energy/snap_pop",
    "/obj/projectile/donor_honk": "/obj/projectile/snap_pop",
    "/obj/item/stock_parts/power_store/cell/donor_honk": "/obj/item/stock_parts/power_store/cell/honk_rifle",
    "/datum/outfit/job/donor/seclown": "/datum/outfit/job/clown/security",
    "/datum/outfit/job/cargo_tech/donor_deliverer": "/datum/outfit/job/cargo_tech/deliverer",
    "/datum/id_trim/job/cargo_technician/donor_deliverer": "/datum/id_trim/job/cargo_technician/deliverer",
    "/obj/item/clothing/under/rank/tsf/donor": "/obj/item/clothing/under/rank/tsf/classic",
    "/obj/item/clothing/suit/armor/donor_tsf_commander": "/obj/item/clothing/suit/armor/tsf_commander",
}
for prefix in (
    "/obj/item/clothing/suit/hooded/wintercoat/zipup/",
    "/obj/item/clothing/head/soft/", "/obj/item/clothing/head/beret/",
    "/obj/item/clothing/head/helmet/space/", "/obj/item/clothing/suit/space/",
):
    PATHS[prefix + "donor_tsf"] = prefix + "tsf"
for before, after in STEMS.items():
    for prefix in ("/datum/job/donor/", "/datum/id_trim/job/donor_",
                   "/obj/effect/landmark/start/donor/"):
        PATHS[prefix + before] = prefix + after
    if before != "seclown":
        PATHS["/datum/outfit/job/donor/" + before] = "/datum/outfit/job/donor/" + after


def git(*args: str) -> str:
    return subprocess.check_output(["git", "-C", str(ROOT), *args]).decode("utf-8-sig")


def renamed(value: str) -> str:
    for before, after in sorted(PATHS.items(), key=lambda pair: -len(pair[0])):
        if value == before or value.startswith(before + "/"):
            return after + value[len(before):]
    return value


# Keep quoted strings byte-for-byte, omit comments and insignificant whitespace.
# This deliberately distinguishes the hoodie DMI state from a real DM typepath.
TOKENS = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*[\s\S]*?\*/|/[A-Za-z_][\w/]*|\s+|.', re.M)


def normalized(value: str, ids: dict[str, str] | None = None) -> str:
    result = []
    for match in TOKENS.finditer(value):
        token = match[0]
        if token.isspace() or token.startswith(("//", "/*")):
            continue
        if ids and token.startswith('"') and token[1:-1] in ids:
            token = '"' + ids[token[1:-1]] + '"'
        if token.startswith("/") and not token.startswith(("//", "/*")):
            token = renamed(token)
        result.append(token)
    return "".join(result)


def declarations(source: str) -> dict[str, dict[str, str]]:
    """Top-level type declarations and their assigned fields; skip proc bodies."""
    result: dict[str, dict[str, str]] = {}
    current = None
    field = None
    for line in source.splitlines():
        if line.startswith("/") and not line.startswith(("//", "/*")):
            current = line.strip() if re.fullmatch(r"/[\w/]+", line.strip()) else None
            field = None
            if current:
                result.setdefault(current, {})
            continue
        if current is None:
            continue
        assignment = re.match(r"^\t([\w/]+)\s*=\s*(.*)$", line)
        if assignment:
            field, value = assignment.groups()
            result[current][field] = value
        elif field and (line.startswith("\t") or not line.strip()):
            result[current][field] += "\n" + line
    return result


def merge(sources: dict[str, str]) -> tuple[dict[str, dict[str, str]], dict[str, str]]:
    result, owners = {}, {}
    for path, source in sources.items():
        for typepath, fields in declarations(source).items():
            result.setdefault(typepath, {}).update(fields)
            owners.setdefault(typepath, path)
    return result, owners


def specs(value: str) -> dict[str, tuple[str, str]]:
    return {key: (normalized(title), outfit) for key, title, outfit in re.findall(
        r'^\s*"([^"]+)"\s*=\s*list\((.*?),\s*(/[\w/]+)\),?\s*$', value, re.M)}


def main() -> int:
    global ROOT, OLD, MIGRATION
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=ROOT)
    parser.add_argument("--migration", type=Path, default=MIGRATION)
    parser.add_argument("--old-ref", default=OLD)
    args = parser.parse_args()
    ROOT, OLD, MIGRATION = args.repo.resolve(), args.old_ref, args.migration.resolve()
    failures = []

    def check(condition: bool, message: str) -> None:
        if not condition:
            failures.append(message)

    old_paths = git("ls-tree", "-r", "--name-only", OLD, DONOR).splitlines()
    old_sources = {path: git("show", f"{OLD}:{path}") for path in old_paths
                   if path.endswith(".dm") and path[len(DONOR):].split("/")[0]
                   in {"jobs", "outfits", "items", "trims", "landmarks"}}
    new_sources = {path.relative_to(ROOT).as_posix(): path.read_text(encoding="utf-8-sig")
                   for folder in (ROOT / DONOR, ROOT / JOBS)
                   for path in folder.rglob("*.dm")}
    old, old_owners = merge(old_sources)
    new, new_owners = merge(new_sources)
    native_clown = declarations((ROOT / "code/modules/jobs/job_types/clown.dm")
                                .read_text(encoding="utf-8-sig")).get(CLOWN_PARENT, {})
    migration = json.loads(MIGRATION.read_text(encoding="utf-8"))
    expected = {}
    jobs = []
    property_count = 0
    preserved_icons = []
    property_differences = []
    inherited_fields = []
    for typepath, fields in old.items():
        current_path = renamed(typepath)
        check(current_path in new, f"Missing current type: {typepath} -> {current_path}")
        if current_path not in new:
            continue
        current = new[current_path]
        title = fields.get("title") or {"/datum/job/prisoner": "JOB_PRISONER",
            "/datum/job/cargo_technician": "JOB_CARGO_TECHNICIAN"}.get(typepath)
        legacy_specs = specs(fields.get("donor_variant_specs", ""))
        job_mapping = {row["old_id"]: row["new_id"] for row in migration
                       if row["job"] == title} if title else {}
        if legacy_specs:
            current_specs = specs(current.get("job_variant_specs", ""))
            check(len(current_specs) == len(legacy_specs), f"Variant count changed: {typepath}")
            for legacy_id, (public_title, outfit) in legacy_specs.items():
                new_id = job_mapping.get(legacy_id, legacy_id)
                wanted = (public_title, renamed(outfit))
                check(current_specs.get(new_id) == wanted,
                      f"Variant semantic change: {title}/{legacy_id} -> {new_id}")
                if legacy_id != "default":
                    expected[(title, legacy_id)] = {
                        "path": old_owners[typepath], "public_title": public_title,
                        "outfit": outfit, "new_id": new_id}
            check("default" in legacy_specs and "default" in current_specs,
                  f"Default variant missing: {typepath}")
        if title:
            jobs.append({"typepath": current_path, "canonical_title": title,
                         "config_tag": fields.get("config_tag"),
                         "variant_count": len(legacy_specs)})
        for name, value in fields.items():
            new_name = "job_variant_specs" if name == "donor_variant_specs" else name
            # The clown lexical parent now expresses precisely this former override.
            if (typepath == "/datum/outfit/job/donor/seclown" and name == "parent_type"
                    and normalized(value) == "/datum/outfit/job/clown"):
                check(current_path.rsplit("/", 1)[0] == normalized(value)
                      and "parent_type" not in current, "Security Clown parent changed")
                continue
            actual = current.get(new_name)
            expected_value = normalized(value, job_mapping if name == "donor_variant_specs" else None)
            if current_path == SECURITY_CLOWN and new_name in INHERITED_CLOWN_FIELDS:
                check(current_path.rsplit("/", 1)[0] == CLOWN_PARENT
                      and "parent_type" not in current, "Security Clown inheritance changed")
                check(actual is None, f"Redundant Security Clown field restored: {new_name}")
                check(new_name not in new.get(CLOWN_PARENT, {}),
                      f"Module overrides native Clown field: {new_name}")
                actual = native_clown.get(new_name)
                inherited_fields.append({"typepath": current_path, "field": new_name,
                                         "parent": CLOWN_PARENT,
                                         "value": normalized(actual) if actual is not None else None})
            check(actual is not None, f"Missing field: {current_path}.{new_name}")
            if actual is not None and normalized(actual) != expected_value:
                property_differences.append({"typepath": current_path, "field": new_name,
                                             "before": expected_value, "after": normalized(actual)})
            property_count += 1
            if name.endswith(("icon_state", "trim_state")) or name in {"soft_type", "greyscale_colors"}:
                preserved_icons.append({"typepath": current_path, "field": name, "value": value.strip()})
    check(not property_differences, f"{len(property_differences)} property values changed")
    check({item["field"] for item in inherited_fields} == INHERITED_CLOWN_FIELDS
          and len(inherited_fields) == 7, "Expected exactly seven inherited Security Clown fields")
    check(len(expected) == len(migration) == 129, "Expected exactly129 migrated old variants")
    seen = set()
    for row in migration:
        key = (row["job"], row["old_id"])
        check(key not in seen, f"Duplicate migration entry: {key}")
        seen.add(key)
        item = expected.get(key)
        check(item is not None, f"Migration has no original declaration: {key}")
        if item:
            for field in ("path", "outfit", "new_id"):
                check(row[field] == item[field], f"Migration metadata mismatch: {key}.{field}")
            check(normalized(json.dumps(row["public_title"], ensure_ascii=False)) == item["public_title"],
                  f"Migration public title mismatch: {key}")
        check(bool(re.fullmatch(r"[a-z][a-z0-9_]*", row["new_id"]))
              and not row["new_id"].startswith("title_") and row["new_id"] != "default",
              f"Nonsemantic migrated ID: {key}")
    check(seen == set(expected), "Original variant missing from migration table")
    runtime_source = new_sources[JOBS + "variants/legacy_variant_ids.dm"]
    runtime_mapping = {}
    current_job = None
    for line in runtime_source.splitlines():
        job_match = re.match(r'^\t("[^"]+"|JOB_\w+) = list\($', line)
        if job_match:
            current_job = job_match[1]
        id_match = re.match(r'^\t\t"([^"]+)" = "([^"]+)",$', line)
        if id_match:
            runtime_mapping[(current_job, id_match[1])] = id_match[2]
    check(runtime_mapping == {(row["job"], row["old_id"]): row["new_id"] for row in migration},
          "Persisted-value DM migration differs from verified old/current declarations")
    check("legacy_job_variant_ids" not in new_sources[JOBS + "variants/job_variants.dm"],
          "Runtime resolver must not contain legacy-ID fallback")
    # Changed declarations must not be aliases left beside their replacements.
    changed_paths = [{"before": path, "after": renamed(path), "old_file": old_owners[path],
                      "new_file": new_owners.get(renamed(path))}
                     for path in old if renamed(path) != path]
    for item in changed_paths:
        check(item["before"] not in new, f"Old type declaration retained: {item['before']}")
    # Scan real DM tokens in every affected module. String/icon literals are separate.
    stale = []
    for path, source in new_sources.items():
        for match in TOKENS.finditer(source):
            token = match[0]
            if token.startswith("/") and not token.startswith(("//", "/*")) and renamed(token) != token:
                stale.append({"path": path, "line": source.count("\n", 0, match.start()) + 1,
                              "typepath": token})
    check(not stale, "Old executable typepath references remain in jobs/donor modules")
    # rg locates actual old-path consumers across tracked and new product files.
    # Only those files are tokenized; maps do not need to be loaded wholesale.
    located = subprocess.run(["rg", "--files-with-matches", "--glob", "*.dm",
        "--glob", "*.dmm", "--glob", "*.dme", "(?:" + "|".join(
        re.escape(path) for path in PATHS) + ")", "."], cwd=ROOT,
        capture_output=True, text=True, encoding="utf-8")
    check(located.returncode in (0, 1), "Global old-typepath reference search failed")
    old_literals = []
    for relative in located.stdout.splitlines():
        path = ROOT / relative
        source = path.read_text(encoding="utf-8-sig")
        for match in TOKENS.finditer(source):
            token = match[0]
            if token.startswith(("//", "/*")):
                continue
            value = token[1:-1] if token.startswith(('"', "'")) else token
            if renamed(value) == value:
                continue
            item = {"path": path.relative_to(ROOT).as_posix(),
                    "line": source.count("\n", 0, match.start()) + 1, "value": value}
            if (item["path"] == DONOR + "items/tsf_clothing.dm"
                    and value == "/obj/item/clothing/suit/hooded/wintercoat/zipup/donor_tsf"
                    and "icon_state =" in source.splitlines()[item["line"] - 1]):
                old_literals.append(item)
            else:
                stale.append(item)
    check(not stale, "Old real typepath references remain in product source/maps/includes")
    # DMI bytes are unchanged, independent of DM icon_state comparisons.
    asset_paths = git("ls-tree", "-r", "--name-only", OLD,
                      "modular_bandastation/donor_jobs/icons").splitlines()
    for path in asset_paths:
        if path.endswith(".dmi"):
            old_hash = git("rev-parse", f"{OLD}:{path}").strip()
            check(git("hash-object", "--no-filters", path).strip() == old_hash,
                  f"DMI asset changed: {path}")
    # HONK's short impact body is part of its behavior, not just balance fields.
    old_honk = old_sources[DONOR + "items/honk.dm"]
    new_honk = new_sources[DONOR + "items/honk_rifle.dm"]
    check(normalized(old_honk) == normalized(new_honk), "HONK body/balance changed beyond exact typepaths")
    report = {
        "status": "PASS" if not failures else "FAIL", "original_head": OLD,
        "counts": {"original_types_checked": len(old), "field_values_checked": property_count,
                   "migrated_ids": len(migration), "jobs_with_variants": sum(bool(j["variant_count"]) for j in jobs),
                   "changed_declared_typepaths": len(changed_paths), "path_prefix_rules": len(PATHS),
                   "preserved_icon_state_fields": sum(item["field"].endswith(("icon_state", "trim_state")) for item in preserved_icons),
                   "preserved_sprite_state_and_palette_fields": len(preserved_icons),
                   "unchanged_dmi_assets": sum(p.endswith(".dmi") for p in asset_paths)},
        "canonical_jobs_and_config_tags": jobs, "changed_typepaths": changed_paths,
        "preserved_icon_states": preserved_icons, "property_differences": property_differences,
        "inherited_security_clown_fields": inherited_fields,
        "stale_typepath_tokens": stale, "retained_dmi_state_literals": old_literals,
        "failures": failures,
        "checked_current_source_sha256": hashlib.sha256("\n".join(
            path + "\0" + source for path, source in sorted(new_sources.items())).encode()).hexdigest(),
        "limits": "Bounded DM declaration/token check, no preprocessing, runtime, real saves or deployment data.",
    }
    # ASCII JSON stays UTF-8 compatible under Windows redirected stdout locales.
    print(json.dumps(report, ensure_ascii=True, indent=2))
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
