"""Extract the city's visual type data onto existing PrimeDream behaviours.

Only literal appearance/collision properties are retained. Donor procs, economy,
clans, keys, roles and combat are deliberately outside this adapter.
"""

from __future__ import annotations

import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import shutil

from import_common import donor_checkout, map_inventory

TARGET = Path(__file__).resolve().parents[2]
MODULE = TARGET / "modular_bandastation/san_francisco"
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--source", required=True, type=donor_checkout, help="Crimson Grid checkout at the pinned commit")
SOURCE = parser.parse_args().source

TYPE = re.compile(r"^(/[\w/]+)\s*(?://.*)?$")
ASSIGN = re.compile(r"^\t([\w]+)\s*=\s*(.*?)\s*(?://.*)?$")
DIRECTIONAL = re.compile(r"^MAPPING_DIRECTIONAL_HELPERS\((/[^, ]+),\s*(.+)\)\s*(?://.*)?$", re.MULTILINE)
PROPS = {
    "name", "desc", "icon", "icon_state", "base_icon_state", "density", "opacity",
    "anchored", "layer", "plane", "pixel_x", "pixel_y", "pixel_z", "pixel_w",
    "dir", "color", "alpha", "mouse_opacity", "bound_width", "bound_height",
    "light_range", "light_power", "light_color", "max_integrity", "smoothing_flags",
    "smoothing_groups", "canSmoothWith", "can_flip", "has_armrest", "can_buckle",
    "brightness", "bulb_power", "bulb_colour", "nightshift_allowed", "no_low_power",
    "allow_break_on_init", "break_if_moved", "status", "base_state", "light_angle",
    "start_with_cell", "enable_door_overlay", "has_opened_overlay", "has_closed_overlay",
    "base_pixel_x", "base_pixel_y", "bound_x", "bound_y",
}
TARGET_MACROS = {"NORTH", "SOUTH", "EAST", "WEST", "NORTHEAST", "NORTHWEST", "SOUTHEAST", "SOUTHWEST", "TRUE", "FALSE", "null", "initial"}
SOURCE_STRING_MACROS = {}


def read_types(root: Path, folders: tuple[str, ...]):
    types = collections.defaultdict(dict)
    positions = {}
    macros = []
    light_macros = []
    init_lights = {}
    for folder in folders:
        for filename in sorted((root / folder).rglob("*.dm")):
            text = filename.read_text(encoding="utf-8-sig", errors="replace")
            code = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
            if root == SOURCE:
                for key, value in re.findall(r"^#define\s+(\w+)\s+([^\n]+)", code, re.MULTILINE):
                    if not value.rstrip().endswith("\\"):
                        SOURCE_STRING_MACROS[key] = re.sub(r"\s+//.*$", "", value).strip()
            current = None
            proc = None
            in_macro = False
            for line in code.splitlines():
                if in_macro:
                    in_macro = line.rstrip().endswith("\\")
                    continue
                if line.lstrip().startswith("#define"):
                    current = None
                    proc = None
                    in_macro = line.rstrip().endswith("\\")
                    continue
                declaration = TYPE.match(line)
                if declaration:
                    current = declaration.group(1)
                    proc = None
                    positions[current] = filename.relative_to(root).as_posix()
                    types[current]
                    continue
                if line.startswith("/"):
                    proc = line
                    current = None
                    proc_match = re.match(r"^(/[\w/]+)\(", line)
                    if proc_match:
                        implicit_type = proc_match.group(1).rsplit("/", 1)[0].removesuffix("/proc")
                        types[implicit_type]
                if current:
                    assignment = ASSIGN.match(line)
                    if assignment:
                        types[current][assignment.group(1)] = assignment.group(2)
                    pixel_macro = re.search(r"SET_BASE_PIXEL\(([^,]+),\s*([^,)]+)\)", line)
                    if pixel_macro:
                        types[current].update({"pixel_x": pixel_macro.group(1), "base_pixel_x": pixel_macro.group(1), "pixel_y": pixel_macro.group(2), "base_pixel_y": pixel_macro.group(2)})
                if proc and "/Initialize(" in proc:
                    call = re.search(r'set_light\((\d+(?:\.\d+)?),\s*(\d+(?:\.\d+)?),\s*("#[0-9a-fA-F]+")\)', line)
                    if call:
                        init_lights[proc.split("/Initialize(")[0]] = dict(zip(("light_range", "light_power", "light_color"), call.groups()))
            macros.extend(DIRECTIONAL.findall(code))
            light_macros.extend(re.findall(r"^LIGHTING_DIRECTIONAL_HELPERS\((/[^)]+)\)", code, re.MULTILINE))
            for helper in ("TRIMLINE_SUBTYPE_HELPER", "TILE_DECAL_SUBTYPE_HELPER"):
                declaration = re.search(r"^#define " + helper + r"\(path\)(.*?)(?=\n[^\t#\\/ ]|\n\n)", text, re.MULTILINE | re.DOTALL)
                if declaration:
                    suffixes = re.findall(r"(?:##)?path(/[a-zA-Z0-9_/]+)", declaration.group(1))
                    for generated_base in re.findall(helper + r"\((/[^)]+)\)", text):
                        for suffix in suffixes:
                            types[generated_base + suffix]
            if root == TARGET:
                TARGET_MACROS.update(re.findall(r"^#define\s+(\w+)", text, re.MULTILINE))
    for path, offset in macros:
        for direction, number, axis, sign in (("north", "NORTH", "y", ""), ("south", "SOUTH", "y", "-"), ("east", "EAST", "x", ""), ("west", "WEST", "x", "-")):
            types[path + "/directional/" + direction].update({"parent_type": path, "dir": number, "pixel_" + axis: sign + offset})
    for path in light_macros:
        for direction, number, axis, offset in (("north", "NORTH", "y", "20"), ("south", "SOUTH", "y", "16"), ("east", "EAST", "x", "0"), ("west", "WEST", "x", "0")):
            types[path + "/directional/" + direction].update({"parent_type": path, "dir": number, "pixel_" + axis: offset})
    for path, values in init_lights.items():
        types[path].update(values)
    return types, positions


target_types, _ = read_types(TARGET, ("code", "modular_bandastation"))
source_types, source_positions = read_types(SOURCE, ("code", "modular_darkpack", "modular_vcg"))

# Source colour macros create bench variants outside explicit declarations.
for textfile in (SOURCE / "modular_darkpack/modules/decor/code").glob("*.dm"):
    content = textfile.read_text(encoding="utf-8-sig", errors="replace")
    for path, colour_name, colour in re.findall(r"COLORED_BENCH\((/[^, ]+),\s*(\w+),\s*([^\n)]+)\)", content):
        for side in ("left", "middle", "right"):
            source_types[f"{path}/{side}/{colour_name}"].update({"parent_type": f"{path}/{side}" if side != "middle" else path, "color": colour})


def resolved(path: str, visited=None):
    visited = set() if visited is None else visited
    if path in visited or not path:
        return {}
    visited.add(path)
    local = source_types.get(path, {})
    parent = local.get("parent_type", path.rsplit("/", 1)[0])
    props = resolved(parent, visited)
    props.update({key: value for key, value in local.items() if key in PROPS})
    return props


def exists(path: str):
    return path in target_types


def select_parent(path: str):
    if path.startswith("/obj/structure/werewolf_totem"):
        return "/obj/structure/san_francisco_passive_totem"
    if path.startswith(("/obj/ritual_rune", "/obj/sabbatrune")):
        return "/obj/effect/decal/san_francisco_surface"
    if path == "/obj/effect/decal/cleanable/cardboard":
        return "/obj/effect/decal/cleanable/san_francisco_floating"
    if path.startswith("/obj/machinery/light/prince"):
        return "/obj/machinery/light/san_francisco_prince"
    if path.startswith(("/obj/effect/decal/shadow", "/obj/effect/decal/pallet", "/obj/effect/decal/graffiti", "/obj/effect/decal/support")):
        return "/obj/effect/decal/san_francisco_surface"
    if path.startswith("/obj/structure/sign/city"):
        return "/obj/structure/sign/san_francisco_city"
    if path.startswith("/obj/darkpack_car"):
        return "/obj/structure/san_francisco_parked_vehicle"
    if path.startswith("/obj/structure/ladder"):
        return "/obj/structure/ladder/san_francisco"
    if path.startswith("/obj/machinery/light/floor/lamppost"):
        return "/obj/machinery/light/floor/san_francisco_lamppost"
    if path.startswith("/obj/machinery/light"):
        # Keep working target bulbs/tubes, with donor colour and orientation.
        candidate = path.split("/directional/")[0]
        while not exists(candidate) and candidate != "/obj/machinery/light":
            candidate = candidate.rsplit("/", 1)[0]
        return candidate
    for prefix, fallback in (
        ("/obj/structure/table", "/obj/structure/table"),
        ("/obj/structure/chair", "/obj/structure/chair"),
        ("/obj/structure/rack", "/obj/structure/rack"),
        ("/obj/structure/railing", "/obj/structure/railing"),
        ("/obj/structure/sink", "/obj/structure/sink"),
        ("/obj/structure/mirror", "/obj/structure/mirror"),
        ("/obj/structure/lattice", "/obj/structure/lattice"),
        ("/obj/structure/closet/crate/dumpster", "/obj/structure/closet/crate"),
        ("/obj/structure/flora", "/obj/structure/flora"),
        ("/obj/structure/sign", "/obj/structure/sign"),
        ("/obj/effect/decal/cleanable", "/obj/effect/decal/cleanable"),
        ("/obj/effect/turf_decal", "/obj/effect/turf_decal"),
        ("/obj/effect/decal", "/obj/effect/decal"),
    ):
        if path.startswith(prefix):
            candidate = path.split("/directional/")[0]
            while candidate.startswith(prefix):
                if exists(candidate):
                    return candidate
                candidate = candidate.rsplit("/", 1)[0]
            return fallback
    # A compatible native ancestor keeps behaviour for storage, windows, fires,
    # and other furniture even when only its city-specific appearance is new.
    if path.startswith("/obj/structure/"):
        candidate = path.split("/directional/")[0]
        while candidate.startswith("/obj/structure/"):
            if exists(candidate):
                return candidate
            candidate = candidate.rsplit("/", 1)[0]
    return "/obj/structure"


def own_path(path: str):
    if path.startswith(("/obj/darkpack_car", "/obj/underplate", "/obj/vampgrave", "/obj/fake_sarcophagus", "/obj/ritual_rune", "/obj/sabbatrune")):
        return True
    if path.startswith(("/obj/effect/decal", "/obj/effect/turf_decal", "/obj/machinery/light")):
        return True
    if not path.startswith("/obj/structure/"):
        return False
    excluded = ("platform", "vampdoor", "vampgate", "vaultdoor", "secure_safe", "retail", "mannequin", "methlab", "reagent_dispensers", "cargo_take", "cargo_put")
    return path.split("/")[3] not in excluded


def neutral(path: str):
    return True


def source_string(value, visited=None):
    """Resolve donor branding constants without introducing replacement wording."""
    visited = set() if visited is None else visited
    quoted = r'"(?:[^"\\]|\\.)*"'
    if re.fullmatch(quoted, value):
        return value if "[" not in value else None
    tokens = re.findall(quoted + r"|\b[A-Za-z_]\w*\b", value)
    if not tokens or not re.fullmatch(r"\s*(?:" + quoted + r"|[A-Za-z_]\w*)(?:\s*\+\s*(?:" + quoted + r"|[A-Za-z_]\w*))*\s*", value):
        return None
    pieces = []
    for token in tokens:
        if token.startswith('"'):
            resolved_value = source_string(token, visited)
        elif token not in visited and token in SOURCE_STRING_MACROS:
            resolved_value = source_string(SOURCE_STRING_MACROS[token], visited | {token})
        else:
            return None
        if resolved_value is None:
            return None
        pieces.append(resolved_value[1:-1])
    return '"' + "".join(pieces) + '"'


assets = {}
missing_assets = set()
bindings = {}
definitions = []
skipped = {}
main_inventory = map_inventory(SOURCE, target_types)
current_missing = list(main_inventory["top_missing"])
# Keep existing furniture aliases stable even after the root's unmapped list clears.
present = {entry["path"] for entry in current_missing}
current_missing.extend({"path": path} for path in main_inventory["all_types"] if own_path(path) and path not in present)

manual_bindings = {
    "/obj/structure/decoration/bush/flowers_pp/style_random": "/obj/structure/flora/bush/flowers_pp/style_random",
    "/obj/structure/glowshroom/extreme": "/obj/structure/glowshroom",
}
manual_definitions = []
mannequin_source = (SOURCE / "modular_darkpack/modules/mannequin/code/mannequin_subtypes.dm").read_text(encoding="utf-8-sig")
outfits = {}
for style in ("napoleon", "conquistador", "cowboy", "soviet"):
    match = re.search(r"^/obj/structure/mannequin/plastic/" + style + r"\n\tstarting_items = list\((.*?)\n\t\)", mannequin_source, re.MULTILINE | re.DOTALL)
    outfits[style] = {"items": re.findall(r"/obj/item/clothing/[\w/]+", match.group(1))}
for style in ("fancy", "punk"):
    match = re.search(r"^/obj/structure/mannequin/plastic/" + style + r"/Initialize\(mapload\)(.*?)(?=\n/obj|\Z)", mannequin_source, re.MULTILINE | re.DOTALL)
    outfits[style] = {"random_probability": 75, "pool": re.findall(r"/obj/item/clothing/[\w/]+", match.group(1))}


def clothing_alias(path):
    if path in ("/obj/item/clothing/head/helmet/rus_ushanka", "/obj/item/clothing/under/costume/soviet", "/obj/item/clothing/suit/costume/soviet"):
        return path
    return "/obj/item/clothing/san_francisco/" + path.removeprefix("/obj/item/clothing/").replace("/", "_")


required_clothing = sorted({item for outfit in outfits.values() for item in outfit.get("items", outfit.get("pool", []))})
(TARGET / "tools/san_francisco/bindings").mkdir(parents=True, exist_ok=True)
(TARGET / "tools/san_francisco/bindings/required_mannequin_clothing.json").write_text(json.dumps({"source_paths": required_clothing, "outfits": outfits, "aliases": {path: clothing_alias(path) for path in required_clothing}}, ensure_ascii=False, indent=2), encoding="utf-8")
for style, outfit in outfits.items():
    new_type = "/obj/structure/mannequin/plastic/san_francisco_" + style
    manual_bindings["/obj/structure/mannequin/plastic/" + style] = new_type
    if "items" in outfit:
        manual_definitions.append(new_type + '\n\tstarting_items = list(' + ", ".join(clothing_alias(path) for path in outfit["items"]) + ')\n')
    else:
        manual_definitions.append(new_type + '/Initialize(mapload)\n\tif(prob(75))\n\t\tstarting_items += pick(list(' + ", ".join(clothing_alias(path) for path in outfit["pool"]) + '))\n\treturn ..()\n')


def safe_value(key, value):
    if ";" in value or "\\" in value and not value.startswith(('"', "'")):
        return False
    if key in ("name", "desc"):
        if not re.fullmatch(r'"(?:[^"\\]|\\.)*"', value):
            return False
        if "[" in value:
            return False
    if key in ("smoothing_groups", "canSmoothWith"):
        # Donor-only smoothing groups are assigned a separate city group below.
        return all(token in TARGET_MACROS for token in re.findall(r"\b[A-Z][A-Z0-9_]+\b", value))
    outside_strings = re.sub(r'"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'', "", value)
    if any(outside_strings.count(opening) != outside_strings.count(closing) for opening, closing in (("(", ")"), ("[", "]"), ("{", "}"))):
        return False
    tokens = re.findall(r"\b[A-Za-z_]\w*\b", outside_strings)
    return all(token in TARGET_MACROS or token in ("list", "rgb") for token in tokens)


def asset(value):
    match = re.fullmatch(r"'([^']+\.dmi)'", value)
    if not match:
        return None
    original = match.group(1)
    sourcefile = SOURCE / original
    targetfile = TARGET / original
    if not sourcefile.is_file():
        if targetfile.is_file():
            return value
        missing_assets.add(original)
        return None
    if targetfile.is_file() and sourcefile.read_bytes() == targetfile.read_bytes():
        return value
    digest = hashlib.sha256(sourcefile.read_bytes()).hexdigest()
    output = MODULE / "icons/decor" / (digest[:10] + "_" + sourcefile.name)
    output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(sourcefile, output)
    assets[original] = {"file": output.relative_to(TARGET).as_posix(), "source": original, "sha256": digest}
    return "'" + output.relative_to(TARGET).as_posix() + "'"


for entry in sorted(current_missing, key=lambda item: item["path"]):
    path = entry["path"]
    if path in manual_bindings:
        bindings[path] = manual_bindings[path]
        continue
    if not own_path(path):
        continue
    if path in target_types:
        bindings[path] = path
        continue
    if not neutral(path):
        skipped[path] = "Supernatural material: needs gameplay replacement or removal."
        continue
    properties = resolved(path)
    for text_prop in ("name", "desc"):
        if text_prop in properties:
            resolved_text = source_string(properties[text_prop])
            if resolved_text is not None:
                properties[text_prop] = resolved_text
    parent = select_parent(path)
    if "icon" not in properties or "icon_state" not in properties or properties["icon_state"] == "null":
        skipped[path] = "Missing explicit visible appearance; requires a deliberate replacement."
        continue
    icon = asset(properties["icon"])
    if not icon:
        skipped[path] = "Sprite not available yet."
        continue
    properties["icon"] = icon
    suffix = path.strip("/").replace("/", "_")
    newpath = "/obj/structure/san_francisco/decor/" + suffix
    if path.startswith("/obj/effect/turf_decal"):
        newpath = "/obj/effect/turf_decal/san_francisco/" + suffix
    elif path.startswith(("/obj/effect/decal", "/obj/ritual_rune", "/obj/sabbatrune")):
        newpath = "/obj/effect/decal/san_francisco/" + suffix
    elif path.startswith("/obj/machinery/light"):
        newpath = "/obj/machinery/light/san_francisco/" + suffix
    lines = [newpath, "\tparent_type = " + parent]
    for key, value in properties.items():
        if key not in PROPS or not safe_value(key, value):
            continue
        if key in ("can_flip",) and not path.startswith("/obj/structure/table"):
            continue
        if key in ("has_armrest", "can_buckle") and not path.startswith("/obj/structure/chair"):
            continue
        if key in ("enable_door_overlay", "has_opened_overlay", "has_closed_overlay") and not path.startswith("/obj/structure/closet"):
            continue
        lines.append(f"\t{key} = {value}")
    if path.startswith("/obj/structure/table"):
        if "no_smooth" in path:
            lines.extend(("\tsmoothing_flags = NONE", "\tsmoothing_groups = null", "\tcanSmoothWith = null"))
        elif not safe_value("smoothing_groups", properties.get("smoothing_groups", "NONE")):
            lines.extend(("\tsmoothing_groups = SMOOTH_GROUP_TABLES", "\tcanSmoothWith = SMOOTH_GROUP_TABLES"))
        lines.append("\tcan_flip = FALSE")
    if "/roofstuff/vent/autotiling" in path:
            lines.extend(("\tsmoothing_flags = SMOOTH_BITMASK", '\tsmoothing_groups = SMOOTH_GROUP_SAN_FRANCISCO_VENTS', '\tcanSmoothWith = SMOOTH_GROUP_SAN_FRANCISCO_VENTS'))
    elif "/roofstuff/vent_end" in path:
        lines.append('\tsmoothing_groups = SMOOTH_GROUP_SAN_FRANCISCO_VENTS')
    if "/chair/" in path:
        lines.append("\titem_chair = null")
    if "/wallpaper" in path:
        lines.append("\tparent_type = /obj/effect/decal/san_francisco_wallpaper")
    if "/rack/wide/" in path:
        lines.append("\tparent_type = /obj/structure/rack/san_francisco_wide")
    if "/lamppost/" in path:
        lines.extend(("\tbase_state = " + properties["icon_state"], "\tallow_break_on_init = FALSE", "\tbreak_if_moved = FALSE"))
    if path.startswith("/obj/darkpack_car"):
        lines.extend(("\tdensity = TRUE", "\tanchored = TRUE", "\tlight_range = 0", "\tlight_power = 0", "\tpixel_x = -32", "\tpixel_y = -32", "\tlayer = VEHICLE_LAYER"))
    # TG cleanable decals can preserve donor litter without donor trash spawners.
    # Keep one value per property when an adapted behaviour overrides the donor.
    final_lines = {line.split(" = ", 1)[0]: line for line in lines[1:]}
    definitions.append("\n".join([lines[0], *final_lines.values()]))
    bindings[path] = {"path": newpath, "vars": {}}

bindings["/obj/effect/decal/cleanable/garbage"] = "/obj/effect/decal/cleanable/garbage/san_francisco"

header = '''// City appearance adapters from Monkestation/crimson-grid, commit 483ef4772fe4957027c8e2f290cd1503b2b237f5.
// Existing PrimeDream parents own interaction, damage, seating, storage and power.

#define SMOOTH_GROUP_SAN_FRANCISCO_VENTS S_OBJ(9001)

/// Only the donor's carved appearance and light overlay are retained, without caern powers.
/obj/structure/san_francisco_passive_totem
\tparent_type = /obj/structure

/obj/structure/san_francisco_passive_totem/update_overlays()
\t. = ..()
\tvar/mutable_appearance/totem_light_overlay = mutable_appearance(icon, "[icon_state]_overlay")
\tSET_PLANE(totem_light_overlay, ABOVE_LIGHTING_PLANE, src)
\ttotem_light_overlay.color = light_color
\t. += totem_light_overlay

/// Donor fixtures have no prince emissive mask; their regular machinery still emits light.
/obj/machinery/light/san_francisco_prince
\tparent_type = /obj/machinery/light

/obj/machinery/light/san_francisco_prince/update_overlays()
\tSHOULD_CALL_PARENT(FALSE)
\treturn list()

/// These imported surface images intentionally cover walls or water in the city map.
/obj/effect/decal/san_francisco_surface
\tparent_type = /obj/effect/decal

/obj/effect/decal/san_francisco_surface/NeverShouldHaveComeHere(turf/here_turf)
\treturn FALSE

/// Floating litter is valid in the city's open sewer channels.
/obj/effect/decal/cleanable/garbage/san_francisco
\tparent_type = /obj/effect/decal/cleanable/garbage

/obj/effect/decal/cleanable/garbage/san_francisco/NeverShouldHaveComeHere(turf/here_turf)
\tif(istype(here_turf, /turf/open/water))
\t\treturn FALSE
\treturn ..()

/// Cardboard may float in sewer water while retaining ordinary floor cleanup rules.
/obj/effect/decal/cleanable/san_francisco_floating
\tparent_type = /obj/effect/decal/cleanable

/obj/effect/decal/cleanable/san_francisco_floating/NeverShouldHaveComeHere(turf/here_turf)
\tif(istype(here_turf, /turf/open/water))
\t\treturn FALSE
\treturn ..()

/// Imported wall coverings are offset onto the open tile in front of tall city walls.
/obj/effect/decal/san_francisco_wallpaper
\tparent_type = /obj/effect/decal

/obj/effect/decal/san_francisco_wallpaper/NeverShouldHaveComeHere(turf/here_turf)
\treturn FALSE

/obj/effect/decal/san_francisco_wallpaper/Initialize(mapload)
\t. = ..()
\tif(isclosedturf(loc))
\t\tforceMove(get_step(src, SOUTH))
\t\tpixel_y = 32

/// City signs can hang one tile in front of their supporting facade.
/obj/structure/sign/san_francisco_city
\tparent_type = /obj/structure/sign

/obj/structure/sign/san_francisco_city/get_turfs_to_mount_on()
\treturn list(get_step(src, dir), get_turf(src))

/// Wide shelves preserve their two-tile footprint when placed east or west.
/obj/structure/rack/san_francisco_wide
\tparent_type = /obj/structure/rack

/obj/structure/rack/san_francisco_wide/Initialize(mapload)
\t. = ..()
\tif(dir == EAST || dir == WEST)
\t\tbound_width = 32
\t\tbound_height = 64
\telse
\t\tbound_width = 64
\t\tbound_height = 32

/// City pole sprites stay visible while standard TG light machinery handles power.
/obj/machinery/light/floor/san_francisco_lamppost
\tparent_type = /obj/machinery/light/floor
\tallow_break_on_init = FALSE
\tbreak_if_moved = FALSE
\tnightshift_allowed = FALSE

// AI EDIT START - Preserve native light updates without station fixture artwork
/obj/machinery/light/floor/san_francisco_lamppost/update_icon_state()
\t. = ..()
\ticon_state = initial(icon_state)

/obj/machinery/light/floor/san_francisco_lamppost/update_overlays()
\tSHOULD_CALL_PARENT(FALSE)
\t// The donor frame already contains the entire pole and lamp.
\treturn list()
// AI EDIT END

/// Sewer access uses the existing ladder linking and travel checks.
/obj/structure/ladder/san_francisco
\tparent_type = /obj/structure/ladder

// AI EDIT START - Keep native ladder updates before restoring the donor frame
/obj/structure/ladder/san_francisco/update_icon_state()
\t. = ..()
\ticon_state = initial(icon_state)
// AI EDIT END

/// Preserve the donor hole alignment instead of lifting its manhole cover twelve pixels.
/obj/structure/ladder/san_francisco/make_base_transparent()
\tSHOULD_CALL_PARENT(FALSE)
\tif(!SSmapping.level_trait(z, ZTRAIT_DOWN))
\t\treturn
\tnew /obj/effect/abstract/ladder_hole/san_francisco(loc, src)

/obj/effect/abstract/ladder_hole/san_francisco/Initialize(mapload, obj/structure/ladder/new_ladder)
\t. = ..()
\tif(. == INITIALIZE_HINT_QDEL)
\t\treturn
\tUnregisterSignal(loc, COMSIG_ATOM_UPDATE_OVERLAYS)
\tRegisterSignal(loc, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_ladder_rim))
\tloc.modify_filter("ladder_[REF(ladder)]", list("y" = ladder.pixel_y + ladder.pixel_z + 8))
\tloc.update_appearance(UPDATE_OVERLAYS)

/// The original manhole sheet intentionally has no separate rim; its cover contains it.
// AI EDIT START - Inherit the native signal handler's no-sleep contract
/obj/effect/abstract/ladder_hole/san_francisco/add_ladder_rim(turf/source, list/overlays)
\tif(!icon_exists(ladder.icon, "[ladder.base_icon_state]_rim"))
\t\treturn
\treturn ..()
// AI EDIT END

// AI EDIT START - Preserve donor tile collision; off-grid bounds can disable legacy gliding.
/// Parked cars retain the donor's native 32 by 32 collision and original sprite offsets.
/obj/structure/san_francisco_parked_vehicle
\tparent_type = /obj/structure
\tdensity = TRUE
\tanchored = TRUE
\tmax_integrity = 400
// AI EDIT END
'''
(MODULE / "code").mkdir(parents=True, exist_ok=True)
(MODULE / "code/decor.dm").write_text(header + "\n\n" + "\n\n".join(definitions + manual_definitions) + "\n\n#undef SMOOTH_GROUP_SAN_FRANCISCO_VENTS\n", encoding="utf-8", newline="\n")

# Keep copied architecture wording from the donor, including technical base types.
architecture_bindings = json.loads((TARGET / "tools/san_francisco/bindings/architecture.json").read_text(encoding="utf-8-sig"))
presentation_pairs = [(old, new if isinstance(new, str) else new["path"]) for old, new in architecture_bindings.items()]
presentation_pairs.extend((
    ("/obj/effect/wall_frill", "/obj/effect/san_francisco_wall_frill"),
    ("/turf/closed/wall/vampwall", "/turf/closed/wall/san_francisco"),
    ("/obj/structure/platform/lowwall", "/obj/structure/platform/san_francisco"),
    ("/turf/open/floor", "/turf/open/floor/san_francisco"),
))
for filename in (MODULE / "code/walls.dm", MODULE / "code/turfs.dm"):
    content = filename.read_text(encoding="utf-8-sig")
    for old, new in presentation_pairs:
        properties = resolved(old)
        pattern = re.compile(r"(^" + re.escape(new) + r"\n)(.*?)(?=\n/|\Z)", re.MULTILINE | re.DOTALL)
        def replace_text(match):
            body = match.group(2)
            for key in ("name", "desc"):
                raw = properties.get(key)
                value = source_string(raw) if raw else None
                if value is None:
                    if key == "desc":
                        value = "null"
                    else:
                        continue
                line = "\t" + key + " = " + value
                field_pattern = re.compile(r"^\t" + key + r" = [^\n]*$", re.MULTILINE)
                if field_pattern.search(body):
                    body = field_pattern.sub(lambda unused: line, body)
                else:
                    body = body.rstrip() + "\n" + line + "\n\n"
            return match.group(1) + body
        content = pattern.sub(replace_text, content)
    filename.write_text(content, encoding="utf-8", newline="\n")
manifest = {
    "bindings": bindings,
    "strip_vars": ["zone_type", "gauntlet_rating", "snowy", "custom_street_name", "can_be_snowy", "internal_trash_chance", "external_trash_chance"],
    "notes": ["Directional helpers that already exist in PrimeDream are retained unchanged.", "Custom icon properties and generic map varedits remain valid; donor-only gameplay vars must be removed.", "Source branding, words, furniture and occult decoration appearances are preserved. No original art or new roleplay content is added."],
    "skipped": skipped,
    "missing_assets": sorted(missing_assets),
    "assets": list(assets.values()),
}
manifest["notes"].append("Donor vehicle sprites, names and descriptions are preserved as parked scenery with a solid footprint. Driving, fuel and keys are not imported.")
(TARGET / "tools/san_francisco/bindings").mkdir(parents=True, exist_ok=True)
(TARGET / "tools/san_francisco/bindings/decor.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
(MODULE / "icons/decor/attribution.json").write_text(json.dumps({"repository": "https://github.com/Monkestation/crimson-grid", "revision": "483ef4772fe4957027c8e2f290cd1503b2b237f5", "license": "CC BY-SA 3.0 unless separately indicated in upstream", "assets": list(assets.values())}, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps({"bindings": len(bindings), "new_types": len(definitions), "sprites": len(assets), "skipped": len(skipped), "missing_assets": sorted(missing_assets)}, ensure_ascii=False))
