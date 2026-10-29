"""Reproducible San Francisco import. Run against the pinned Crimson Grid checkout.

The source map is never modified. Every replacement is recorded for review.
"""

from __future__ import annotations

import argparse
import collections
import contextlib
import hashlib
import io
import json
import pathlib
import re
import shutil

ROOT = pathlib.Path(__file__).resolve().parents[2]
SOURCE = None  # Set from the required --source argument before running a command.
MODULE = ROOT / "modular_bandastation/san_francisco"
BINDINGS = ROOT / "tools/san_francisco/bindings"
from import_common import SOURCE_MAP, donor_checkout, map_inventory
from mapmerge2.dmm import DMM
from UpdatePaths.__main__ import parse_rep_string, props_to_string, update_path


class TypeIndex:
    def __init__(self, root):
        self.root = root
        self.props = collections.defaultdict(dict)
        self.variables = collections.defaultdict(set)
        self.known = set()
        self.locations = {}
        for directory in ("code", "modular_bandastation", "modular_darkpack", "modular_vcg"):
            for filename in sorted((root / directory).rglob("*.dm")):
                relative_parts = filename.relative_to(root).parts
                if any(part in ("unit_tests", "tests") for part in relative_parts) or filename.stem.endswith(("_tests", "_test")) or filename.stem.startswith("test_"):
                    continue
                text = filename.read_text(encoding="utf-8-sig", errors="replace")
                text = re.sub(r"\\\r?\n[ \t]*", "", text)
                current = None
                for line in text.splitlines():
                    if line.startswith("/") and not line.startswith("//"):
                        match = re.match(r"^(/[\w/]+)\s*(?://.*)?$", line)
                        current = match[1] if match else None
                        if current:
                            self.locations[current] = filename.relative_to(root).as_posix()
                            path = current
                            while path:
                                self.known.add(path)
                                path = path.rsplit("/", 1)[0]
                    elif line and not line[0].isspace() and not line.startswith(("//", "#")):
                        current = None
                    elif current:
                        match = re.match(r"^\t([\w]+)\s*=\s*(.+?)\s*$", line)
                        if match:
                            self.props[current][match[1]] = match[2].split(" //", 1)[0]
                        declaration = re.match(r"^\tvar/(?:(?:\w+)/)*(\w+)(?:\s|$|=)", line)
                        if declaration and not line.startswith(("\tvar/static/", "\tvar/const/")):
                            self.variables[current].add(declaration[1])
                for match in re.finditer(r"MAPPING_DIRECTIONAL_HELPERS\((/[^,)\s]+)", text):
                    for direction in ("north", "south", "east", "west"):
                        self.known.add(match[1] + "/directional/" + direction)

    def inherited(self, path, seen=None):
        seen = seen or set()
        if path in seen:
            return {}
        seen.add(path)
        local = self.props.get(path, {})
        parent = local.get("parent_type", path.rsplit("/", 1)[0])
        props = self.inherited(parent, seen) if parent else {}
        props.update(local)
        return props

    def variable_names(self, path, seen=None):
        seen = seen or set()
        if not path or path in seen:
            return set()
        seen.add(path)
        local = self.props.get(path, {})
        parent = local.get("parent_type", path.rsplit("/", 1)[0])
        return self.variable_names(parent, seen) | self.variables.get(path, set()) | set(local)


def pick(index, *paths):
    return next((path for path in paths if path in index.known), None)


def normalized(path):
    return "/".join(part for part in path.split("/") if part not in ("vamp", "vampire", "darkpack"))


def clothing_parent(path, index):
    normal = normalized(path)
    if normal in index.known and normal.count("/") >= 5:
        return normal
    if "/under/" in path:
        if any(word in path for word in ("police", "sheriff", "guard", "bouncer")):
            return pick(index, "/obj/item/clothing/under/rank/security/officer", "/obj/item/clothing/under/color/darkblue")
        if "nurse" in path:
            return pick(index, "/obj/item/clothing/under/rank/medical/doctor/nurse", "/obj/item/clothing/under/rank/medical/doctor")
        if "janitor" in path:
            return "/obj/item/clothing/under/rank/civilian/janitor"
        return pick(index, "/obj/item/clothing/under/suit/black", "/obj/item/clothing/under/color/black")
    category = path.split("/")[4]
    parents = {
        "head": ("/obj/item/clothing/head/beret", "/obj/item/clothing/head/beanie/black"),
        "suit": ("/obj/item/clothing/suit/jacket", "/obj/item/clothing/suit/armor/vest"),
        "shoes": ("/obj/item/clothing/shoes/laceup", "/obj/item/clothing/shoes/sneakers/black"),
        "gloves": ("/obj/item/clothing/gloves/color/black",),
        "mask": ("/obj/item/clothing/mask/bandana/black", "/obj/item/clothing/mask/breath"),
        "glasses": ("/obj/item/clothing/glasses/sunglasses",),
        "neck": ("/obj/item/clothing/neck",),
    }
    return pick(index, *parents.get(category, ()))


APPEARANCE = ("icon", "icon_state", "worn_icon", "worn_icon_state", "inhand_icon_state", "lefthand_file", "righthand_file")


def source_branding(value):
    """Resolve the donor's literal brand constants without introducing target-setting names."""
    definitions = {}
    branding_file = SOURCE / "code/__DEFINES/~darkpack/branding.dm"
    for line in branding_file.read_text(encoding="utf-8").splitlines():
        match = re.match(r"#define\s+(\w+)\s+(.+?)(?:\s+//.*)?$", line)
        if match:
            definitions[match[1]] = match[2]
    token = re.compile(r'"(?:\\.|[^"\\])*"|\b[A-Z][A-Z0-9_]+\b')
    for _ in range(12):
        replaced = token.sub(lambda match: match[0] if match[0].startswith('"') else definitions.get(match[0], match[0]), value)
        if replaced == value:
            break
        value = replaced
    return value


def copy_resource(value, copies):
    match = re.fullmatch(r"'([^']+)'", value)
    if not match:
        return None
    relative = match[1]
    original = SOURCE / relative
    if not original.is_file():
        return None
    existing = ROOT / relative
    if existing.is_file() and existing.read_bytes() == original.read_bytes():
        return value
    filename = hashlib.sha256(relative.encode()).hexdigest()[:10] + "_" + original.name
    destination = MODULE / "icons/equipment" / filename
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(original, destination)
    copies[destination.relative_to(ROOT).as_posix()] = relative
    return "'" + destination.relative_to(ROOT).as_posix() + "'"


def equipment_binding(path, target):
    normal = normalized(path)
    if normal in target.known and normal != path:
        return normal
    if path.startswith("/obj/item/stack/dollar"):
        return pick(target, "/obj/item/stack/spacecash/c100", "/obj/item/stack/spacecash/c10")
    if path.startswith("/obj/item/vamp/keys"):
        return "/obj/item/card/id/advanced"
    if path.startswith("/obj/item/card/"):
        return "/obj/item/card/id/advanced"
    if path.startswith("/obj/item/smartphone"):
        return pick(target, "/obj/item/modular_computer/pda", "/obj/item/modular_computer/tablet/preset/cheap")
    if path.startswith("/obj/item/gun/"):
        if "/shotgun/" in path:
            return "/obj/item/gun/ballistic/shotgun/lethal"
        if "/revolver/" in path:
            return "/obj/item/gun/ballistic/revolver/c38"
        if "/pistol/" in path:
            return "/obj/item/gun/ballistic/automatic/pistol/m1911"
        if "uzi" in path:
            return "/obj/item/gun/ballistic/automatic/mini_uzi"
        if "thompson" in path:
            return "/obj/item/gun/ballistic/automatic/tommygun"
        if "sniper" in path or "huntrifle" in path:
            return pick(target, "/obj/item/gun/ballistic/rifle/boltaction", "/obj/item/gun/ballistic/automatic/battle_rifle")
        return "/obj/item/gun/ballistic/automatic/wt550"
    if path.startswith("/obj/item/ammo_box/"):
        if "12g" in path:
            return pick(target, "/obj/item/ammo_box/shotgun/buckshot", "/obj/item/storage/box/lethalshot")
        if "/magazine/" in path:
            if "45" in path or "1911" in path:
                return pick(target, "/obj/item/ammo_box/magazine/m45", "/obj/item/ammo_box/magazine/m1911")
            if "thompson" in path:
                return "/obj/item/ammo_box/magazine/tommygunm45"
            return "/obj/item/ammo_box/magazine/wt550m9"
        return pick(target, "/obj/item/ammo_box/c38", "/obj/item/ammo_box/c357")
    if path.startswith("/obj/item/storage/medkit/darkpack"):
        kind = path.rsplit("/", 1)[1]
        kind = {"standard": "regular", "ifak": "emergency", "doctor": "surgery", "burn": "fire", "oxy": "o2", "tox": "toxin"}.get(kind, kind)
        return pick(target, "/obj/item/storage/medkit/" + kind, "/obj/item/storage/medkit/regular")
    if path.startswith("/obj/item/reagent_containers/blood"):
        kind = path.rsplit("/", 1)[1]
        return pick(target, "/obj/item/reagent_containers/blood/" + kind, "/obj/item/reagent_containers/blood")
    if path.startswith("/obj/item/reagent_containers/cup/glass/drinkingglass/"):
        return "/obj/item/reagent_containers/cup/glass/drinkingglass"
    if path.startswith("/obj/item/reagent_containers/cup/glass/coffee/"):
        return "/obj/item/reagent_containers/cup/glass/coffee"
    if path.startswith("/obj/item/reagent_containers/cup/glass/baggie"):
        return pick(target, "/obj/item/reagent_containers/cup/glass/bottle/epinephrine", "/obj/item/reagent_containers/cup/beaker")
    if path.startswith("/obj/item/reagent_containers/cup/glass/vampirewater"):
        return "/obj/item/reagent_containers/cup/glass/waterbottle"
    if path.startswith("/obj/item/reagent_containers/cup/soda_cans/"):
        return "/obj/item/reagent_containers/cup/soda_cans/cola"
    if path.startswith("/obj/item/food/vampire/icecream"):
        return pick(target, "/obj/item/food/icecream", "/obj/item/food/icecream_sandwich")
    if path.startswith("/obj/item/kirbyplants/"):
        return pick(target, "/obj/item/kirbyplants/random", "/obj/item/kirbyplants/plant1")
    if path.startswith(("/obj/item/vampirebook", "/obj/item/ritual_tome", "/obj/item/sabbat_", "/obj/item/phone_book", "/obj/item/masquerade_contract", "/obj/item/blood_hunt")):
        return "/obj/item/book"
    if path.startswith("/obj/item/storage/box/ingredients/"):
        return pick(target, "/obj/item/storage/box/ingredients/" + path.rsplit("/", 1)[1], "/obj/item/storage/box/ingredients/italian")
    if path.startswith("/obj/item/melee/vamp/"):
        return pick(target, "/obj/item/crowbar", "/obj/item/melee/baseball_bat")
    return None


def build_equipment():
    target, source = TypeIndex(ROOT), TypeIndex(SOURCE)
    audit = map_inventory(SOURCE, target.known)
    bindings, unresolved, copies, definitions = {}, [], {}, []
    entries = list(audit["top_missing"])
    extra_clothing = BINDINGS / "required_mannequin_clothing.json"
    if extra_clothing.is_file():
        extra = json.loads(extra_clothing.read_text(encoding="utf-8-sig"))
        paths = extra if isinstance(extra, list) else extra.get("source_paths", extra.get("required_clothing", []))
        entries.extend({"path": path} for path in paths if isinstance(path, str))
    seen = set()
    for entry in entries:
        path = entry["path"]
        if path in seen:
            continue
        seen.add(path)
        if not path.startswith("/obj/item/") or path in target.known:
            continue
        if path.startswith("/obj/item/clothing/"):
            parent = clothing_parent(path, target)
            if not parent:
                unresolved.append(path)
                continue
            new_path = "/obj/item/clothing/san_francisco/" + path.removeprefix("/obj/item/clothing/").replace("/", "_")
            inherited = source.inherited(path)
            lines = [new_path, "\tparent_type = " + parent]
            if inherited.get("icon_state", "").startswith('"/obj/') and inherited.get("greyscale_config", "null") != "null":
                # Native GAGS clothing keeps its own rendered state; donor bitmap clothing must not inherit it.
                # This alias reuses its parent's map preview instead of adding a generated atlas entry.
                lines.append("\tflags_1 = IS_PLAYER_COLORABLE_1 | NO_NEW_GAGS_PREVIEW_1")
                if inherited.get("greyscale_colors"):
                    lines.append("\tgreyscale_colors = " + inherited["greyscale_colors"])
            else:
                lines.extend(["\tgreyscale_config = null", "\tgreyscale_config_worn = null",
                              "\tgreyscale_colors = null", "\tpost_init_icon_state = null"])
            lines.append("\tworn_icon_state = null")
            for property_name in ("name", "desc"):
                value = inherited.get(property_name)
                if value:
                    value = source_branding(value)
                    if value.startswith('"') and "[" not in value:
                        lines.append("\t" + property_name + " = " + value)
            for prop in APPEARANCE:
                value = inherited.get(prop)
                if not value:
                    continue
                if value.startswith("'"):
                    value = copy_resource(value, copies)
                elif not re.fullmatch(r'"[^"\[\]]*"|null', value):
                    continue
                if value:
                    lines.append("\t" + prop + " = " + value)
            definitions.append("\n".join(lines))
            bindings[path] = new_path
        else:
            replacement = equipment_binding(path, target)
            if replacement and replacement in target.known:
                bindings[path] = replacement
            else:
                unresolved.append(path)
    (MODULE / "code").mkdir(parents=True, exist_ok=True)
    (MODULE / "code/equipment.dm").write_text("/// City clothing: imported appearance on the build's existing clothing mechanics.\n\n" + "\n\n".join(definitions) + "\n", encoding="utf-8")
    BINDINGS.mkdir(parents=True, exist_ok=True)
    (BINDINGS / "equipment.json").write_text(json.dumps({"bindings": bindings, "unresolved": unresolved, "assets": copies}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"bindings": len(bindings), "clothing": len(definitions), "assets": len(copies), "unresolved": unresolved}, ensure_ascii=False, indent=2))


def load_bindings():
    result = {}
    for filename in sorted(BINDINGS.glob("*.json"), key=lambda file: (file.name == "core.json", file.name)):
        data = json.loads(filename.read_text(encoding="utf-8-sig"))
        for old, new in data.get("bindings", data).items():
            if old.startswith("/"):
                result[old] = new
    return result


def coverage():
    target = TypeIndex(ROOT)
    bindings = load_bindings()
    audit = map_inventory(SOURCE, target.known)
    unknown = [path for path in audit["all_types"] if path not in bindings and path not in target.known]
    print(json.dumps({"bindings": len(bindings), "unmapped": unknown}, ensure_ascii=False, indent=2))


SPAWNS = {
    "camarilla/prince": "captain", "camarilla/clerk": "head_of_personnel",
    "camarilla/sheriff": "lawyer", "camarilla/harpy": "lawyer",
    "hospital/clinic_director": "chief_medical_officer", "hospital/doctor": "medical_doctor",
    "hospital/clinic_guard": "security_officer", "law_enforcement/captain": "head_of_security",
    "law_enforcement/sergeant": "warden", "law_enforcement/dispatcher": "detective",
    "law_enforcement/fbi": "detective", "law_enforcement/officer": "security_officer",
    "supply/dealer": "quartermaster", "supply/tech": "cargo_technician",
    "pentex/lead": "chief_engineer", "pentex/employee": "station_engineer",
    "pentex/affairs": "lawyer", "pentex/sec": "security_officer",
    "pentex/executive": "research_director", "pentex/secchief": "warden",
    "chantry/regent": "research_director", "chantry/archivist": "scientist",
    "citizen/janitor": "janitor", "citizen/priest": "chaplain",
    "citizen/club_worker": "bartender", "citizen/citizen": "assistant",
    "forest_wolves/keeper": "botanist", "forest_wolves/warder": "station_engineer",
}


def build_core():
    target = TypeIndex(ROOT)
    audit = map_inventory(SOURCE, target.known)
    bindings = {}
    for path in audit["all_types"]:
        replacement = None
        if path.startswith("/obj/effect/landmark/start/darkpack/"):
            role = SPAWNS.get(path.split("/darkpack/", 1)[1], "assistant")
            replacement = "/obj/effect/landmark/start/" + role
        elif path.startswith("/obj/effect/landmark/npc") or path.startswith(("/obj/effect/vip_barrier", "/obj/effect/realistic_fog")):
            replacement = "@DELETE"
        elif path.startswith("/obj/effect/landmark/event_spawn/") or path.startswith("/obj/effect/landmark/bawn_entrance/"):
            replacement = "@DELETE"
        elif path.startswith("/obj/effect/spawner/random/occult/"):
            replacement = "@DELETE"
        elif path == "/obj/effect/landmark/latejoin_masquerade":
            replacement = "/obj/effect/landmark/latejoin"
        elif path.startswith("/obj/effect/mapping_helpers/door/"):
            # The converter transfers mapped access to the actual door before removing donor helpers.
            replacement = "@DELETE"
        elif path.startswith("/mob/living/carbon/human/npc/"):
            replacement = "@DELETE"
        elif path.startswith("/mob/living/basic/szlachta/"):
            replacement = "@DELETE"
        elif path.startswith("/mob/") and path not in target.known:
            replacement = "@DELETE"
        elif path.startswith("/obj/transfer_point_vamp/umbral"):
            replacement = "@DELETE"
        elif path.startswith("/obj/transfer_point_vamp"):
            replacement = "/obj/structure/san_francisco_passage" + ("/stairs" if path.endswith("/stairs") else "")
        elif path == "/obj/effect/spawner/random/stray_animal":
            replacement = "@DELETE"
        elif path == "/obj/effect/abstract/cargo_landing_spot":
            replacement = "@DELETE"
        elif path == "/obj/effect/decal/cleanable/blood/oil/slippery":
            replacement = "/obj/effect/decal/cleanable/blood/oil"
        elif path == "/obj/effect/mob_spawn/corpse/human/ciz4":
            replacement = "/obj/effect/mob_spawn/corpse/human/assistant"
        elif path == "/obj/machinery/door/poddoor/shutters/armory":
            replacement = "/obj/machinery/door/poddoor/shutters"
        elif path == "/obj/structure/aquarium/crab":
            replacement = pick(target, "/obj/structure/aquarium/prefilled", "/obj/structure/aquarium")
        if replacement:
            bindings[path] = replacement
    (BINDINGS / "core.json").write_text(json.dumps({"bindings": bindings}, ensure_ascii=False, indent=2), encoding="utf-8")
    print("Core bindings:", len(bindings))


COMMON_VARS = {"dir", "pixel_x", "pixel_y", "pixel_w", "pixel_z", "name", "desc", "color", "alpha", "anchored", "density", "opacity", "tag", "icon", "icon_state"}
TEXT_REPLACEMENTS = {}


def sanitize(atom, binding, source_path, target_index):
    path, props = parse_rep_string(atom)
    allowed = set(COMMON_VARS)
    if path == source_path:
        # Preserve shared native APIs, including lift IDs, instead of losing their map-specific settings.
        allowed |= target_index.variable_names(path)
    if path.startswith("/obj/structure/san_francisco_passage"):
        allowed |= {"destination_x", "destination_y", "destination_level"}
    if path.startswith("/obj/machinery"):
        allowed |= {"id", "id_tag", "network", "networks", "frequency", "req_access", "req_one_access", "on", "broadcasting", "listening"}
    if path.startswith("/obj/machinery/door"):
        allowed |= {"max_integrity", "damage_deflection", "transport_linked_id"}
    if path.startswith("/obj/machinery/light"):
        allowed |= {"brightness", "bulb_power", "bulb_colour", "light_range", "light_power", "light_color"}
    if path.startswith("/obj/structure/ladder"):
        allowed |= {"id", "height"}
    if path.startswith("/obj/machinery/computer"):
        allowed |= {"screen", "keyboard", "icon_keyboard", "icon_screen"}
    if path.startswith("/obj/machinery/button"):
        allowed |= {"id", "device_type"}
    if path.startswith("/obj/structure/chair"):
        allowed |= {"buildstacktype"}
    if path.startswith("/obj/effect/landmark/start"):
        # Job landmarks must retain the target job title, not a donor faction title.
        allowed -= {"name", "desc", "icon", "icon_state", "density", "opacity"}
    props = {key: value for key, value in props.items() if key in allowed}
    # Source job/loadout fields never travel through generic names or object IDs.
    for key in ("name", "desc"):
        if key in props:
            for old, new in TEXT_REPLACEMENTS.items():
                props[key] = props[key].replace(old, new)
    if "icon" in props:
        value = copy_resource(props["icon"], {})
        if value:
            props["icon"] = value
        else:
            del props["icon"]
    if isinstance(binding, dict):
        for key in binding.get("strip_vars", []):
            props.pop(key, None)
        props.update(binding.get("set_vars", binding.get("vars", {})))
    # AI EDIT START - Preserve donor words and floor artwork in forms accepted by maplint
    if path.startswith("/obj/machinery/door/") and re.search(r".*\s(?!of|and|to)[a-z].*", props.get("name", "")):
        props["name"] = re.sub(r'(?<=[ "\t])[a-z]', lambda match: match[0].upper(), props["name"])
    if path == "/turf/open/floor/san_francisco/plating/grate" and props.get("icon_state") == '"lattice_new_dirt"':
        path += "/dirty"
        del props["icon_state"]
    # AI EDIT END
    return path + (props_to_string(props) if props else "")


def access_for(tile):
    labels = []
    for atom in tile:
        path = atom.split("{", 1)[0]
        if path.startswith("/obj/effect/mapping_helpers/door/access/"):
            labels.append(path.rsplit("/", 1)[1])
    if not labels:
        return None
    joined = " ".join(labels)
    groups = (
        (("police_captain", "prince", "director", "bankboss"), "captain"),
        (("police", "federal", "dispatch", "npc"), "security"),
        (("clinic", "salubri"), "medical"),
        (("supply",), "cargo"),
        (("pentex", "wolftech"), "engineering"),
        (("chantry", "kiasyd"), "science"),
        (("cleaning", "laundromat"), "janitor"),
        (("church", "graveyard"), "chapel_office"),
        (("strip", "jazz_club", "theatre", "toreador"), "bar"),
        (("clerk", "camarilla"), "hop"),
    )
    for words, access in groups:
        if any(word in labels for word in words):
            return 'list("' + access + '")'
    return None


def add_job_spawns(city, target):
    """Only invisible compatibility landmarks are added; physical donor tiles stay intact."""
    available = []
    present = set()
    for coord, key in city.grid.items():
        tile = city.dictionary[key]
        for atom in tile[:-2]:
            path = atom.split("{", 1)[0]
            if path.startswith("/obj/effect/landmark/start/"):
                present.add(path)
        turf = tile[-2].split("{", 1)[0]
        if not turf.startswith(("/turf/open/floor/", "/turf/open/misc/")):
            continue
        blocked = any(target.inherited(atom.split("{", 1)[0]).get("density") in ("TRUE", "1") for atom in tile[:-2])
        if not blocked:
            available.append((coord, tile[-1].split("{",1)[0]))
    role_areas = {
        "atmospheric_technician":"endron", "roboticist":"clinic", "chemist":"clinic",
        "geneticist":"clinic", "coroner":"clinic", "paramedic":"clinic", "psychologist":"clinic",
        "librarian":"chantry", "cook":"cog", "clown":"theatre", "mime":"theatre",
        "prisoner":"police", "nanotrasen_representative":"camarilla", "blueshield":"camarilla",
        "magistrate":"camarilla", "spacepod_technician":"supply"
    }
    placed=[]
    used=set()
    for role, area_hint in role_areas.items():
        path="/obj/effect/landmark/start/"+role
        if path in present or path not in target.known:
            continue
        candidates=[coord for coord,area in available if area_hint in area.lower() and coord not in used]
        if not candidates:
            candidates=[coord for coord,area in available if "/interior" in area and coord not in used]
        if not candidates:
            raise RuntimeError("No safe native job spawn for "+role)
        coord=candidates[len(candidates)//2]
        tile=city.get_tile(coord)
        city.set_tile(coord,tuple(tile[:-2])+(path,)+tuple(tile[-2:]))
        used.add(coord)
        placed.append({"job":role,"coordinate":coord})
    (BINDINGS.parent/"spawn-compatibility.json").write_text(json.dumps(placed,indent=2),encoding="utf-8")




def write_config():
    traits = []
    for level in range(5):
        trait = {"Station": True, "Gravity": True, "No Parallax": True, "Linkage": None,
                 "Baseturf": "/turf/closed/indestructible/san_francisco_void" if level == 0 else "/turf/open/openspace"}
        if level < 4:
            trait["Up"] = True
        if level > 0:
            trait["Down"] = True
        traits.append(trait)
    config = {"version": 1, "exclude_from_ci": True, "map_name": "San Francisco", "fluff_name": "San Francisco",
              "map_path": "map_files/SanFrancisco", "map_file": "sanfrancisco.dmm",
              "planetary": True, "main_floor": 2, "height_autosetup": False,
              "space_ruin_levels": 0, "space_empty_levels": 0, "wilderness_levels": 0,
              "minetype": "none", "traits": traits,
              "job_changes": {title: {"spawn_positions": 0, "total_positions": 0}
                              for title in ("AI", "Cyborg", "Shaft Miner", "Explorer", "Bitrunner")}}
    filename = ROOT / "_maps/map_jsons/sanfrancisco.json"
    filename.write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def converted_map():
    build_core()
    bindings = load_bindings()
    target_index = TypeIndex(ROOT)
    city = DMM.from_file(str(SOURCE / SOURCE_MAP))
    unknown = sorted({atom.split("{", 1)[0] for tile in city.dictionary.values() for atom in tile if atom.split("{", 1)[0] not in target_index.known and atom.split("{", 1)[0] not in bindings})
    if unknown:
        raise RuntimeError(f"Unresolved types ({len(unknown)}): {unknown}")
    atom_cache = {}
    used_updates = set()
    converted = DMM(city.key_length, city.size)
    converted.header = city.header
    source_keys = {}
    for key, tile in city.dictionary.items():
        access = access_for(tile)
        output = []
        for atom in tile:
            old_path = atom.split("{", 1)[0]
            binding = bindings.get(old_path, old_path)
            new_path = binding.get("path", binding.get("target")) if isinstance(binding, dict) else binding
            if atom not in atom_cache:
                if new_path != old_path:
                    update = old_path + " : " + new_path + ("{@OLD}" if new_path != "@DELETE" else "")
                    scratch = DMM(3, (1, 1, 1))
                    scratch.dictionary[0] = (atom,)
                    scratch.grid[(1, 1, 1)] = 0
                    with contextlib.redirect_stdout(io.StringIO()):
                        update_path(scratch, update)
                    replaced = scratch.get_tile((1, 1, 1))
                    used_updates.add(update)
                else:
                    replaced = (atom,)
                atom_cache[atom] = tuple(sanitize(value, binding, old_path, target_index) for value in replaced)
            output.extend(atom_cache[atom])
        if access:
            for i, value in enumerate(output):
                if value.startswith("/obj/machinery/door/"):
                    path, props = parse_rep_string(value)
                    props["req_access"] = access
                    output[i] = path + props_to_string(props)
        # The city has a terrestrial atmosphere. Only outside tiles receive the planetary reservoir.
        area = output[-1].split("{", 1)[0]
        for i, value in enumerate(output):
            if value.startswith("/turf/open/") and not value.startswith("/turf/open/space"):
                path, props = parse_rep_string(value)
                props["initial_gas_mix"] = '"o2=21;n2=79;TEMP=293.15"'
                props["planetary_atmos"] = "1" if target_index.inherited(area).get("outdoors") in ("TRUE", "1") else "0"
                output[i] = path + props_to_string(props)
        source_keys[key] = converted.get_or_generate_key(tuple(output))
    converted.grid = {coord: source_keys[key] for coord, key in city.grid.items()}
    # Keep exact geometry; source region links are resolved to explicit destination coordinates.
    links = collections.defaultdict(list)
    for coord, key in city.grid.items():
        for atom in city.dictionary[key]:
            if atom.startswith("/obj/transfer_point_vamp") and "/umbral" not in atom:
                _, props = parse_rep_string(atom)
                links[props.get("id", "1")].append(coord)
    invalid_links = {link_id: coords for link_id, coords in links.items() if len(coords) != 2}
    if invalid_links:
        raise RuntimeError("Unpaired physical passages: " + repr(invalid_links))
    for coords in links.values():
        for source_coord, destination in ((coords[0], coords[1]), (coords[1], coords[0])):
            tile = list(converted.get_tile(source_coord))
            for i, atom in enumerate(tile):
                if atom.startswith("/obj/structure/san_francisco_passage"):
                    path, props = parse_rep_string(atom)
                    props.update(destination_x=str(destination[0]), destination_y=str(destination[1]), destination_level=str(destination[2]))
                    tile[i] = path + props_to_string(props)
            converted.set_tile(source_coord, tile)
    add_job_spawns(converted, target_index)
    write_config()
    map_folder = ROOT / "_maps/map_files/SanFrancisco"
    map_folder.mkdir(parents=True, exist_ok=True)
    converted.to_file(str(map_folder / "sanfrancisco.dmm"))
    # AI EDIT START - Prefix city update rules with their owning PR number
    (ROOT / "tools/UpdatePaths/Scripts/10_PrimeDream_sanfrancisco.txt").write_text("\n".join(sorted(used_updates)) + "\n", encoding="utf-8")
    # AI EDIT END
    print(json.dumps({"size": list(converted.size), "dictionary": len(converted.dictionary), "updates": len(used_updates), "passage_pairs": len(links)}, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("equipment", "coverage", "core", "convert"))
    parser.add_argument("--source", required=True, type=donor_checkout, help="Crimson Grid checkout at the pinned commit")
    args = parser.parse_args()
    SOURCE = args.source
    if args.command == "equipment":
        build_equipment()
    elif args.command == "coverage":
        coverage()
    elif args.command == "core":
        build_core()
    elif args.command == "convert":
        converted_map()
