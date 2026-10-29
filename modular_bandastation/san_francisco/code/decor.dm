// City appearance adapters from Monkestation/crimson-grid, commit 483ef4772fe4957027c8e2f290cd1503b2b237f5.
// Existing PrimeDream parents own interaction, damage, seating, storage and power.

#define SMOOTH_GROUP_SAN_FRANCISCO_VENTS S_OBJ(9001)

/// Only the donor's carved appearance and light overlay are retained, without caern powers.
/obj/structure/san_francisco_passive_totem
	parent_type = /obj/structure

/obj/structure/san_francisco_passive_totem/update_overlays()
	. = ..()
	var/mutable_appearance/totem_light_overlay = mutable_appearance(icon, "[icon_state]_overlay")
	SET_PLANE(totem_light_overlay, ABOVE_LIGHTING_PLANE, src)
	totem_light_overlay.color = light_color
	. += totem_light_overlay

/// Donor fixtures have no prince emissive mask; their regular machinery still emits light.
/obj/machinery/light/san_francisco_prince
	parent_type = /obj/machinery/light

/obj/machinery/light/san_francisco_prince/update_overlays()
	SHOULD_CALL_PARENT(FALSE)
	return list()

/// These imported surface images intentionally cover walls or water in the city map.
/obj/effect/decal/san_francisco_surface
	parent_type = /obj/effect/decal

/obj/effect/decal/san_francisco_surface/NeverShouldHaveComeHere(turf/here_turf)
	return FALSE

/// Floating litter is valid in the city's open sewer channels.
/obj/effect/decal/cleanable/garbage/san_francisco
	parent_type = /obj/effect/decal/cleanable/garbage

/obj/effect/decal/cleanable/garbage/san_francisco/NeverShouldHaveComeHere(turf/here_turf)
	if(istype(here_turf, /turf/open/water))
		return FALSE
	return ..()

/// Cardboard may float in sewer water while retaining ordinary floor cleanup rules.
/obj/effect/decal/cleanable/san_francisco_floating
	parent_type = /obj/effect/decal/cleanable

/obj/effect/decal/cleanable/san_francisco_floating/NeverShouldHaveComeHere(turf/here_turf)
	if(istype(here_turf, /turf/open/water))
		return FALSE
	return ..()

/// Imported wall coverings are offset onto the open tile in front of tall city walls.
/obj/effect/decal/san_francisco_wallpaper
	parent_type = /obj/effect/decal

/obj/effect/decal/san_francisco_wallpaper/NeverShouldHaveComeHere(turf/here_turf)
	return FALSE

/obj/effect/decal/san_francisco_wallpaper/Initialize(mapload)
	. = ..()
	if(isclosedturf(loc))
		forceMove(get_step(src, SOUTH))
		pixel_y = 32

/// City signs can hang one tile in front of their supporting facade.
/obj/structure/sign/san_francisco_city
	parent_type = /obj/structure/sign

/obj/structure/sign/san_francisco_city/get_turfs_to_mount_on()
	return list(get_step(src, dir), get_turf(src))

/// Wide shelves preserve their two-tile footprint when placed east or west.
/obj/structure/rack/san_francisco_wide
	parent_type = /obj/structure/rack

/obj/structure/rack/san_francisco_wide/Initialize(mapload)
	. = ..()
	if(dir == EAST || dir == WEST)
		bound_width = 32
		bound_height = 64
	else
		bound_width = 64
		bound_height = 32

/// City pole sprites stay visible while standard TG light machinery handles power.
/obj/machinery/light/floor/san_francisco_lamppost
	parent_type = /obj/machinery/light/floor
	allow_break_on_init = FALSE
	break_if_moved = FALSE
	nightshift_allowed = FALSE

// AI EDIT START - Preserve native light updates without station fixture artwork
/obj/machinery/light/floor/san_francisco_lamppost/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)

/obj/machinery/light/floor/san_francisco_lamppost/update_overlays()
	SHOULD_CALL_PARENT(FALSE)
	// The donor frame already contains the entire pole and lamp.
	return list()
// AI EDIT END

/// Sewer access uses the existing ladder linking and travel checks.
/obj/structure/ladder/san_francisco
	parent_type = /obj/structure/ladder

// AI EDIT START - Keep native ladder updates before restoring the donor frame
/obj/structure/ladder/san_francisco/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
// AI EDIT END

/// Preserve the donor hole alignment instead of lifting its manhole cover twelve pixels.
/obj/structure/ladder/san_francisco/make_base_transparent()
	SHOULD_CALL_PARENT(FALSE)
	if(!SSmapping.level_trait(z, ZTRAIT_DOWN))
		return
	new /obj/effect/abstract/ladder_hole/san_francisco(loc, src)

/obj/effect/abstract/ladder_hole/san_francisco/Initialize(mapload, obj/structure/ladder/new_ladder)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	UnregisterSignal(loc, COMSIG_ATOM_UPDATE_OVERLAYS)
	RegisterSignal(loc, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_ladder_rim))
	loc.modify_filter("ladder_[REF(ladder)]", list("y" = ladder.pixel_y + ladder.pixel_z + 8))
	loc.update_appearance(UPDATE_OVERLAYS)

/// The original manhole sheet intentionally has no separate rim; its cover contains it.
// AI EDIT START - Inherit the native signal handler's no-sleep contract
/obj/effect/abstract/ladder_hole/san_francisco/add_ladder_rim(turf/source, list/overlays)
	if(!icon_exists(ladder.icon, "[ladder.base_icon_state]_rim"))
		return
	return ..()
// AI EDIT END

// AI EDIT START - Preserve donor tile collision; off-grid bounds can disable legacy gliding.
/// Parked cars retain the donor's native 32 by 32 collision and original sprite offsets.
/obj/structure/san_francisco_parked_vehicle
	parent_type = /obj/structure
	density = TRUE
	anchored = TRUE
	max_integrity = 400
// AI EDIT END


/obj/structure/san_francisco/decor/obj_darkpack_car_endroncar
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "endron"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_endrontruck
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "endrontruck"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_limousine_camarilla
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "limo"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_limousine_giovanni
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "giolimo"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_police
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "police"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_police_ranger
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "ranger"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_police_unmarked
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "unmarked"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_rand
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "4"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_rand_anarch
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "4"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_rand_camarilla
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "4"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_retro_rand
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "3"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_retro_rand_anarch
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "3"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_retro_rand_camarilla
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "3"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_retro_rand_clinic
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "3"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_taxi
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "taxi"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_track
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "track"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_track_ambulance
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "ambulance"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/structure/san_francisco/decor/obj_darkpack_car_track_volkswagen
	parent_type = /obj/structure/san_francisco_parked_vehicle
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "volkswagen"
	icon = 'modular_bandastation/san_francisco/icons/decor/0cfa58127e_cars.dmi'
	anchored = TRUE
	density = TRUE
	light_color = COLOR_LIGHT_ORANGE
	light_range = 0
	light_power = 0
	max_integrity = 400
	dir = WEST
	pixel_x = -32
	pixel_y = -32
	layer = VEHICLE_LAYER

/obj/effect/decal/san_francisco/obj_effect_decal_carpet
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/f351fb97ef_rugs64x64.dmi'
	name = "carpet"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	pixel_w = -16
	pixel_z = -16
	icon_state = "kover"

/obj/effect/decal/san_francisco/obj_effect_decal_cleanable_cardboard
	parent_type = /obj/effect/decal/cleanable/san_francisco_floating
	icon = 'modular_bandastation/san_francisco/icons/decor/7ed1d1d646_trash.dmi'
	name = "cardboard"
	layer = CLEANABLE_FLOOR_OBJECT_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "cardboard1"

/obj/effect/decal/san_francisco/obj_effect_decal_cleanable_gasoline
	parent_type = /obj/effect/decal/cleanable
	icon = 'modular_bandastation/san_francisco/icons/decor/4c407bbd27_water.dmi'
	name = "gasoline"
	layer = CLEANABLE_FLOOR_OBJECT_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	desc = "I HOPE YOU DIE IN A FIRE!!!"
	icon_state = "water"
	base_icon_state = "water"
	smoothing_flags = SMOOTH_BITMASK
	alpha = 64
	color = "#c6845b"

/obj/effect/decal/san_francisco/obj_effect_decal_cleanable_litter
	parent_type = /obj/effect/decal/cleanable
	icon = 'modular_bandastation/san_francisco/icons/decor/7ed1d1d646_trash.dmi'
	name = "litter"
	layer = CLEANABLE_FLOOR_OBJECT_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "paper1"

/obj/effect/decal/san_francisco/obj_effect_decal_cleanable_trash
	parent_type = /obj/effect/decal/cleanable
	icon = 'modular_bandastation/san_francisco/icons/decor/7ed1d1d646_trash.dmi'
	name = "trash"
	layer = CLEANABLE_FLOOR_OBJECT_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "trash1"
	base_icon_state = "trash"

/obj/effect/decal/san_francisco/obj_effect_decal_cleanable_trash_big
	parent_type = /obj/effect/decal/cleanable
	icon = 'modular_bandastation/san_francisco/icons/decor/7ed1d1d646_trash.dmi'
	name = "trash"
	layer = CLEANABLE_FLOOR_OBJECT_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "bigtrash1"
	base_icon_state = "bigtrash"

/obj/effect/decal/san_francisco/obj_effect_decal_coastline
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	name = "water"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "coastline"

/obj/effect/decal/san_francisco/obj_effect_decal_coastline_corner
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	name = "water"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "coastline_corner"

/obj/effect/decal/san_francisco/obj_effect_decal_garou_glyph_conceal
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/29590da889_glyphs.dmi'
	name = "mysterious glyph"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	desc = "An odd collection of symbols drawn in what seems to be charcoal."
	icon_state = "conceal"

/obj/effect/decal/san_francisco/obj_effect_decal_garou_glyph_dancers
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/29590da889_glyphs.dmi'
	name = "alien glyph"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	desc = "An odd collection of symbols drawn in what seems to be charcoal."
	icon_state = "black_spiral_dancers"

/obj/effect/decal/san_francisco/obj_effect_decal_garou_glyph_hive
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/29590da889_glyphs.dmi'
	name = "outlandish glyph"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	desc = "An odd collection of symbols drawn in what seems to be charcoal."
	icon_state = "hive"

/obj/effect/decal/san_francisco/obj_effect_decal_garou_glyph_wyrm
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/29590da889_glyphs.dmi'
	name = "creepy glyph"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	desc = "An odd collection of symbols drawn in what seems to be charcoal."
	icon_state = "wyrm"

/obj/effect/decal/san_francisco/obj_effect_decal_graffiti
	parent_type = /obj/effect/decal/san_francisco_surface
	icon = 'modular_bandastation/san_francisco/icons/decor/f880952cb5_32x48.dmi'
	name = "graffiti"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "graffiti1"
	pixel_z = 32

/obj/effect/decal/san_francisco/obj_effect_decal_graffiti_large
	parent_type = /obj/effect/decal/san_francisco_surface
	icon = 'modular_bandastation/san_francisco/icons/decor/295dc1e8de_64x64.dmi'
	name = "graffiti"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "graffiti1"
	pixel_z = 32
	pixel_w = -16

/obj/effect/decal/san_francisco/obj_effect_decal_gut_floor
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/06c3509841_floors.dmi'
	name = "gut floor"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "tzimisce_floor"

/obj/effect/decal/san_francisco/obj_effect_decal_kopatich
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/f351fb97ef_rugs64x64.dmi'
	name = "hide carpet"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	pixel_w = -16
	pixel_z = -16
	icon_state = "kopatich"

/obj/effect/decal/san_francisco/obj_effect_decal_painting
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/fe6d2520b6_paintings.dmi'
	name = "painting"
	layer = SIGN_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "painting1"

/obj/effect/decal/san_francisco/obj_effect_decal_painting_second
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/fe6d2520b6_paintings.dmi'
	name = "painting"
	layer = SIGN_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "painting2"

/obj/effect/decal/san_francisco/obj_effect_decal_painting_third
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/fe6d2520b6_paintings.dmi'
	name = "painting"
	layer = SIGN_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "painting3"

/obj/effect/decal/san_francisco/obj_effect_decal_painting_yankovic
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e65c1a28da_paintings.dmi'
	name = "albert"
	layer = SIGN_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "yankovic"
	desc = "Do not let this man in."

/obj/effect/decal/san_francisco/obj_effect_decal_pallet
	parent_type = /obj/effect/decal/san_francisco_surface
	icon = 'modular_bandastation/san_francisco/icons/decor/338fbf8612_alleyway.dmi'
	name = "pallet"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "under1"

/obj/effect/decal/san_francisco/obj_effect_decal_rugs
	parent_type = /obj/effect/decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	name = "rugs"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "rugs"

/obj/effect/decal/san_francisco/obj_effect_decal_shadow
	parent_type = /obj/effect/decal/san_francisco_surface
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	name = "shadow"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "shadow"

/obj/effect/decal/san_francisco/obj_effect_decal_support
	parent_type = /obj/effect/decal/san_francisco_surface
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	name = "support"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	icon_state = "support"

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_blue
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-club"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_blue_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-club_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_gold
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-gold"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_gold_alt
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-gold_alt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_gold_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-gold_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_grey
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-grey"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_grey_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-grey_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_light
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-light"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paint
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "paint-white"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paint_gray
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "paint-gray"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paint_yellow
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "paint-yellow"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-cheap"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_darkgreen
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-dgreen"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_darkgreen_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-dgreen_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_darkred
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-dred"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_darkred_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-dred_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_fancy_red
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-redfancy"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_fancy_red_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-redfancy_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_fancy_stripe
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-stripesfancy"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_fancy_stripe_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-stripesfancy_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_green
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-green"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_green_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-green_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-cheap_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_purple
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-dpurple"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_rich
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-rich"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_rich_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-rich_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_stripe
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-stripe"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_paper_stripe_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wallpapers"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-stripe_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_papers_five
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "papers"
	layer = SIGN_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpapers_5"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_papers_random
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "papers"
	layer = SIGN_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpapers_1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_red
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-asylum"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_red_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-asylum_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_stone
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall decoration"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-stone"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_stone_low
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall decoration"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-stone_low"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_stone_low_tilt
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall decoration"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "wallpaper-stone_low_tilt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_stripes
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "stripesgreen"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/san_francisco/obj_effect_decal_wallpaper_trim_green
	parent_type = /obj/effect/decal/san_francisco_wallpaper
	icon = 'modular_bandastation/san_francisco/icons/decor/9f88d16986_wallpaper.dmi'
	name = "wall paint"
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	icon_state = "trimgreen"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphalt
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "decal1"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "line"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_alt
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "line_alt"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_alt_white
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "line_alt_white"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_arrow
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "arrow"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_arrow_left
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "arrow_l"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_arrow_right
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "arrow_r"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_ped
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "ped"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_stop
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "stop"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_xing
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "xing"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_asphaltline_yellow
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/e52f7d19c7_decals.dmi'
	icon_state = "line_yellow"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_bordur
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "border"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "sidewalk"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_bordur_corner
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "border_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "sidewalk"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_bordur_corner_inverse
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "border_corner_inverse"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "sidewalk"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_bordur_end
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "border_end"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "sidewalk"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_bordur_inverse
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "border_inverse"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "sidewalk"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_crosswalk
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "crosswalk1"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "asphalt"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_cave
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "cave_side"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_cave_corner
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "cave_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_dirt
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "vampdirt_side"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_dirt_corner
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "vampdirt_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_grass
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "vampgrass_side"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_grass_corner
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "vampgrass_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_rough
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "rough_side"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_rough_corner
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "rough_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_sand
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "vampbeach_side"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_darkpack_sand_corner
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/d4a1277a04_natural_turf_borders.dmi'
	icon_state = "vampbeach_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "detail"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_beige
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#6e635a"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_dark_brown
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#463227"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_dark_brown_corner
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#463227"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_dark_brown_end
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain_end"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#463227"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_dark_brown_inner_corner
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain_corner_inner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#463227"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_grey
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#636363"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_grey_corner
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#636363"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_grey_end
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain_end"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#636363"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_grey_inner_corner
	parent_type = /obj/effect/turf_decal/siding
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_plain_corner_inner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#636363"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wideplating_blue
	parent_type = /obj/effect/turf_decal/siding/wideplating
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wideplating"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#39537f"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wideplating_green
	parent_type = /obj/effect/turf_decal/siding/wideplating
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wideplating"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#004136"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wideplating_red
	parent_type = /obj/effect/turf_decal/siding/wideplating
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wideplating"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#802d29"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wideplating_red_corner
	parent_type = /obj/effect/turf_decal/siding/wideplating
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wideplating_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#802d29"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_dark
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#4a3925"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_dark_corner
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#4a3925"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_dark_end
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood_end"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#4a3925"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_light
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#9a704a"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_light_corner
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#9a704a"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_light_end
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood_end"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#9a704a"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_rough
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#665136"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_siding_wood_rough_corner
	parent_type = /obj/effect/turf_decal/siding/wood
	icon = 'icons/turf/decals.dmi'
	icon_state = "siding_wood_corner"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	color = "#665136"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_stock
	parent_type = /obj/effect/turf_decal
	icon = 'modular_bandastation/san_francisco/icons/decor/de0be6f13e_decals.dmi'
	icon_state = "stock"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE
	name = "stock"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_stripes
	parent_type = /obj/effect/turf_decal
	icon = 'icons/turf/decals.dmi'
	icon_state = "warningline"
	plane = FLOOR_PLANE
	layer = TURF_DECAL_LAYER
	anchored = TRUE

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_arrow_ccw
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_arrow_cw
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_corner
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_filled
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_filled_corner
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_filled_end
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_filled_line
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_filled_warning
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/effect/turf_decal/san_francisco/obj_effect_turf_decal_trimline_dark_green_warning
	parent_type = /obj/effect/turf_decal/trimline/dark_green
	icon = 'icons/turf/decals.dmi'
	icon_state = "trimline_box"
	plane = FLOOR_PLANE
	layer = TURF_PLATING_DECAL_LAYER
	anchored = TRUE
	alpha = 110
	color = "#439C1E"

/obj/structure/san_francisco/decor/obj_fake_sarcophagus_voivode
	parent_type = /obj/structure
	name = "\improper Voivode-in-Waiting's Sarcophagus"
	desc = "The Voivode-in-Waiting lies here."
	icon = 'modular_bandastation/san_francisco/icons/decor/97583414f2_sarcophagus.dmi'
	icon_state = "b_sarcophagus"
	density = TRUE
	anchored = TRUE
	pixel_w = -8

/obj/machinery/light/san_francisco/obj_machinery_light_floor_lamppost_one
	parent_type = /obj/machinery/light/floor/san_francisco_lamppost
	name = "lamppost"
	icon = 'modular_bandastation/san_francisco/icons/decor/cadaa6b836_lamppost.dmi'
	desc = "Gives some light to the streets."
	max_integrity = 100
	layer = SPACEVINE_LAYER
	anchored = TRUE
	icon_state = "one"
	light_angle = 360
	base_state = "one"
	brightness = 8
	plane = GAME_PLANE
	bulb_colour = "#ffde9b"
	allow_break_on_init = FALSE
	pixel_w = -32
	density = FALSE
	break_if_moved = FALSE

/obj/machinery/light/san_francisco/obj_machinery_light_floor_lamppost_sidewalk
	parent_type = /obj/machinery/light/floor/san_francisco_lamppost
	name = "lamppost"
	icon = 'modular_bandastation/san_francisco/icons/decor/cadaa6b836_lamppost.dmi'
	desc = "Gives some light to the streets."
	max_integrity = 100
	layer = SPACEVINE_LAYER
	anchored = TRUE
	icon_state = "civ"
	light_angle = 360
	base_state = "civ"
	brightness = 8
	plane = GAME_PLANE
	bulb_colour = "#ffde9b"
	allow_break_on_init = FALSE
	pixel_w = -32
	density = FALSE
	break_if_moved = FALSE

/obj/machinery/light/san_francisco/obj_machinery_light_floor_lamppost_sidewalk_chinese
	parent_type = /obj/machinery/light/floor/san_francisco_lamppost
	name = "lamppost"
	icon = 'modular_bandastation/san_francisco/icons/decor/cadaa6b836_lamppost.dmi'
	desc = "Gives some light to the streets."
	max_integrity = 100
	layer = SPACEVINE_LAYER
	anchored = TRUE
	icon_state = "chinese"
	light_angle = 360
	base_state = "chinese"
	brightness = 8
	plane = GAME_PLANE
	bulb_colour = "#ffde9b"
	allow_break_on_init = FALSE
	pixel_w = -32
	density = FALSE
	break_if_moved = FALSE

/obj/machinery/light/san_francisco/obj_machinery_light_floor_lamppost_three
	parent_type = /obj/machinery/light/floor/san_francisco_lamppost
	name = "lamppost"
	icon = 'modular_bandastation/san_francisco/icons/decor/cadaa6b836_lamppost.dmi'
	desc = "Gives some light to the streets."
	max_integrity = 100
	layer = SPACEVINE_LAYER
	anchored = TRUE
	icon_state = "three"
	light_angle = 360
	base_state = "three"
	brightness = 8
	plane = GAME_PLANE
	bulb_colour = "#ffde9b"
	allow_break_on_init = FALSE
	pixel_w = -32
	density = FALSE
	break_if_moved = FALSE

/obj/machinery/light/san_francisco/obj_machinery_light_floor_lamppost_two
	parent_type = /obj/machinery/light/floor/san_francisco_lamppost
	name = "lamppost"
	icon = 'modular_bandastation/san_francisco/icons/decor/cadaa6b836_lamppost.dmi'
	desc = "Gives some light to the streets."
	max_integrity = 100
	layer = SPACEVINE_LAYER
	anchored = TRUE
	icon_state = "two"
	light_angle = 360
	base_state = "two"
	brightness = 8
	plane = GAME_PLANE
	bulb_colour = "#ffde9b"
	allow_break_on_init = FALSE
	pixel_w = -32
	density = FALSE
	break_if_moved = FALSE

/obj/machinery/light/san_francisco/obj_machinery_light_prince_broken_directional_east
	parent_type = /obj/machinery/light/san_francisco_prince
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "prince-broken"
	light_angle = 170
	base_state = "prince"
	status = LIGHT_BROKEN
	dir = EAST
	pixel_x = 0

/obj/machinery/light/san_francisco/obj_machinery_light_prince_broken_directional_north
	parent_type = /obj/machinery/light/san_francisco_prince
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "prince-broken"
	light_angle = 170
	base_state = "prince"
	status = LIGHT_BROKEN
	dir = NORTH
	pixel_y = 20

/obj/machinery/light/san_francisco/obj_machinery_light_prince_broken_directional_south
	parent_type = /obj/machinery/light/san_francisco_prince
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "prince-broken"
	light_angle = 170
	base_state = "prince"
	status = LIGHT_BROKEN
	dir = SOUTH
	pixel_y = 16

/obj/machinery/light/san_francisco/obj_machinery_light_prince_directional_east
	parent_type = /obj/machinery/light/san_francisco_prince
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "prince"
	light_angle = 170
	base_state = "prince"
	dir = EAST
	pixel_x = 0

/obj/machinery/light/san_francisco/obj_machinery_light_prince_directional_north
	parent_type = /obj/machinery/light/san_francisco_prince
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "prince"
	light_angle = 170
	base_state = "prince"
	dir = NORTH
	pixel_y = 20

/obj/machinery/light/san_francisco/obj_machinery_light_prince_directional_south
	parent_type = /obj/machinery/light/san_francisco_prince
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "prince"
	light_angle = 170
	base_state = "prince"
	dir = SOUTH
	pixel_y = 16

/obj/machinery/light/san_francisco/obj_machinery_light_prince_directional_west
	parent_type = /obj/machinery/light/san_francisco_prince
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "prince"
	light_angle = 170
	base_state = "prince"
	dir = WEST
	pixel_x = 0

/obj/machinery/light/san_francisco/obj_machinery_light_small_pink
	parent_type = /obj/machinery/light/small
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A small lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "bulb"
	light_angle = 170
	base_state = "bulb"
	brightness = 4
	bulb_colour = "#e26ed2"
	no_low_power = TRUE
	nightshift_allowed = FALSE

/obj/machinery/light/san_francisco/obj_machinery_light_small_pink_directional_east
	parent_type = /obj/machinery/light/small
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A small lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "bulb"
	light_angle = 170
	base_state = "bulb"
	brightness = 4
	bulb_colour = "#e26ed2"
	no_low_power = TRUE
	nightshift_allowed = FALSE
	dir = EAST
	pixel_x = 0

/obj/machinery/light/san_francisco/obj_machinery_light_small_pink_directional_north
	parent_type = /obj/machinery/light/small
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A small lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "bulb"
	light_angle = 170
	base_state = "bulb"
	brightness = 4
	bulb_colour = "#e26ed2"
	no_low_power = TRUE
	nightshift_allowed = FALSE
	dir = NORTH
	pixel_y = 20

/obj/machinery/light/san_francisco/obj_machinery_light_small_pink_directional_south
	parent_type = /obj/machinery/light/small
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A small lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "bulb"
	light_angle = 170
	base_state = "bulb"
	brightness = 4
	bulb_colour = "#e26ed2"
	no_low_power = TRUE
	nightshift_allowed = FALSE
	dir = SOUTH
	pixel_y = 16

/obj/machinery/light/san_francisco/obj_machinery_light_small_pink_directional_west
	parent_type = /obj/machinery/light/small
	name = "light fixture"
	icon = 'modular_bandastation/san_francisco/icons/decor/d88e4ce2cc_lighting.dmi'
	desc = "A small lighting fixture."
	max_integrity = 100
	layer = WALL_OBJ_LAYER
	anchored = TRUE
	icon_state = "bulb"
	light_angle = 170
	base_state = "bulb"
	brightness = 4
	bulb_colour = "#e26ed2"
	no_low_power = TRUE
	nightshift_allowed = FALSE
	dir = WEST
	pixel_x = 0

/obj/effect/decal/san_francisco/obj_ritual_rune_abyss_heart_that_beats_in_silence
	parent_type = /obj/effect/decal/san_francisco_surface
	name = "the heart that beats in silence"
	desc = "Creates a shadowy abomination to protect the Lasombra and his domain."
	icon = 'modular_bandastation/san_francisco/icons/decor/d8e946f63b_icons.dmi'
	icon_state = "rune1"
	anchored = TRUE
	color = rgb(0, 0, 0)

/obj/effect/decal/san_francisco/obj_ritual_rune_thaumaturgy_selfgib
	parent_type = /obj/effect/decal/san_francisco_surface
	name = "self destruction"
	desc = "Meet the Final Death."
	icon = 'modular_bandastation/san_francisco/icons/decor/d8e946f63b_icons.dmi'
	icon_state = "rune2"
	anchored = TRUE
	color = rgb(128, 0, 0)

/obj/effect/decal/san_francisco/obj_sabbatrune
	parent_type = /obj/effect/decal/san_francisco_surface
	name = "Monomacy Rune"
	desc = "Monomacy is the rite of resolving disputes among pack mates. Challenge that curr to a duel!"
	icon = 'modular_bandastation/san_francisco/icons/decor/d8e946f63b_icons.dmi'
	icon_state = "rune9"
	color = rgb(64, 64, 64)
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_arc
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/2ee9655359_chinatown.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "chinatown arc"
	desc = "Cool chinese architecture."
	icon_state = "ark1"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_arc_add
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/2ee9655359_chinatown.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "chinatown arc"
	desc = "Cool chinese architecture."
	icon_state = "ark2"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_barrels
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/122168447a_barrels.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "barrel"
	desc = "Store some liquids."
	icon_state = "barrel1"
	base_icon_state = "barrel"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_barrels_plural
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/122168447a_barrels.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "barrels"
	desc = "Store some liquids."
	icon_state = "barrels1"
	base_icon_state = "barrels"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_barrels_rand
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/122168447a_barrels.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "barrel"
	desc = "Store some liquids."
	icon_state = "barrel2"
	base_icon_state = "barrel"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_barrels_rand_plural
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/122168447a_barrels.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "barrel"
	desc = "Store some liquids."
	icon_state = "barrels2"
	base_icon_state = "barrels"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_barrels_rusty
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/122168447a_barrels.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "barrels"
	desc = "Used to store some liquids."
	icon_state = "rustybarrels1"
	base_icon_state = "rustybarrels"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_bath
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/fe47213249_bathroom.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "bath"
	desc = "Not big enough for hiding in."
	icon_state = "tub"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_bath_sabbatbath
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/fe47213249_bathroom.dmi'
	max_integrity = 300
	layer = BELOW_MOB_LAYER
	name = "sabbat bath"
	desc = "A large ceremonial bath, commonly used in Sabbat rituals. It appears to be designed to hold blood."
	icon_state = "tub"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_billboard_darkpack_endron
	parent_type = /obj/structure/billboard
	icon = 'modular_bandastation/san_francisco/icons/decor/01435f31b2_billboards.dmi'
	max_integrity = 1000
	layer = BELOW_OBJ_LAYER
	name = "billboard"
	desc = "A billboard advertising Endron, an oil and gas company founded in 1916. Endron, for a greener tomorrow."
	icon_state = "billboard_2"
	plane = ABOVE_GAME_PLANE
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_bonfire_fire_barrel
	parent_type = /obj/structure/bonfire
	icon = 'modular_bandastation/san_francisco/icons/decor/0496583a93_fires.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon_state = "fire_barrel"
	base_icon_state = "fire_barrel"
	light_color = LIGHT_COLOR_FIRE
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_bonfire_prelit_alt
	parent_type = /obj/structure/bonfire/prelit
	icon = 'modular_bandastation/san_francisco/icons/decor/0496583a93_fires.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon_state = "campfire_on_fire"
	base_icon_state = "campfire"
	light_color = LIGHT_COLOR_FIRE
	density = FALSE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_bonfire_prelit_alt2
	parent_type = /obj/structure/bonfire/prelit
	icon = 'modular_bandastation/san_francisco/icons/decor/0496583a93_fires.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon_state = "campfire_alt_on_fire"
	base_icon_state = "campfire_alt"
	light_color = LIGHT_COLOR_FIRE
	density = FALSE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_bookcase_random_kindred
	parent_type = /obj/structure/bookcase/random
	icon = 'icons/obj/service/library.dmi'
	max_integrity = 200
	layer = BELOW_OBJ_LAYER
	name = "bookcase (Kindred)"
	icon_state = "random_bookcase"
	desc = "A great place for storing knowledge."
	anchored = FALSE
	density = TRUE
	opacity = FALSE

/obj/structure/san_francisco/decor/obj_structure_brazier
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/3870b5edec_brazier.dmi'
	max_integrity = 300
	name = "brazier"
	desc = "A metal pan atop stone brick, meant to hold fire. It is gas-powered, with a strange insignia around the gas knob center."
	icon_state = "brazier"
	anchored = TRUE
	density = TRUE
	light_range = 0
	light_power = 0
	light_color = "null"

/obj/structure/san_francisco/decor/obj_structure_bricks
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/338fbf8612_alleyway.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "bricks"
	desc = "Building material."
	icon_state = "bricks"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_bury_pit
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/a7c5c33c12_bury_pit.dmi'
	max_integrity = 300
	layer = ABOVE_OPEN_TURF_LAYER
	name = "bury pit"
	desc = "You can bury someone here."
	icon_state = "pit0"
	plane = FLOOR_PLANE
	anchored = TRUE
	density = FALSE

/obj/structure/san_francisco/decor/obj_structure_chair_comfy_darkpack
	parent_type = /obj/structure/chair/comfy
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 70
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfy"
	anchored = TRUE
	can_buckle = TRUE
	color = rgb(255, 255, 255)
	has_armrest = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_comfy_darkpack_dark
	parent_type = /obj/structure/chair/comfy
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 70
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfy_dark"
	anchored = TRUE
	can_buckle = TRUE
	color = rgb(255, 255, 255)
	has_armrest = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_comfy_darkpack_darkblue
	parent_type = /obj/structure/chair/comfy
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 70
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfy"
	anchored = TRUE
	can_buckle = TRUE
	color = "#36454F"
	has_armrest = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_comfy_darkpack_green
	parent_type = /obj/structure/chair/comfy
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 70
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfy_green"
	anchored = TRUE
	can_buckle = TRUE
	color = rgb(255, 255, 255)
	has_armrest = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_darkpack
	parent_type = /obj/structure/chair
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_darkpack_blue
	parent_type = /obj/structure/chair
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair_blue"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_darkpack_green
	parent_type = /obj/structure/chair
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair_green"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_darkpack_red
	parent_type = /obj/structure/chair
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "chair_red"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_office_darkpack
	parent_type = /obj/structure/chair/office
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "office chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "officechair"
	anchored = FALSE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_office_darkpack_black
	parent_type = /obj/structure/chair/office
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "office chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "officechair_black"
	anchored = FALSE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_office_darkpack_blue
	parent_type = /obj/structure/chair/office
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "office chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "officechair_blue"
	anchored = FALSE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_office_darkpack_green
	parent_type = /obj/structure/chair/office
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "office chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "officechair_green"
	anchored = FALSE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_office_darkpack_red
	parent_type = /obj/structure/chair/office
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 100
	name = "office chair"
	desc = "You sit in this. Either by will or force."
	icon_state = "officechair_red"
	anchored = FALSE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_old_tzimisce
	parent_type = /obj/structure/chair/old
	icon = 'modular_bandastation/san_francisco/icons/decor/53d9b88180_flesh_objects.dmi'
	max_integrity = 100
	name = "strange chair"
	desc = "You sit in this. Either by will or force. Looks REALLY uncomfortable."
	icon_state = "tzimisce_stool"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_plastic_darkpack
	parent_type = /obj/structure/chair/plastic
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 70
	name = "plastic chair"
	desc = "No matter how much you squirm, it'll still be uncomfortable."
	icon_state = "plastic_chair"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_sofa_city_bench_metal
	parent_type = /obj/structure/chair/sofa
	icon = 'modular_bandastation/san_francisco/icons/decor/c00f9ee0d7_bench.dmi'
	max_integrity = 100
	name = "metal bench"
	desc = "An uncomfortable metal bench."
	icon_state = "metal"
	anchored = TRUE
	can_buckle = TRUE
	has_armrest = FALSE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_sofa_city_bench_metal_left_black
	parent_type = /obj/structure/chair/sofa
	icon = 'modular_bandastation/san_francisco/icons/decor/c00f9ee0d7_bench.dmi'
	max_integrity = 100
	name = "metal bench"
	desc = "An uncomfortable metal bench."
	icon_state = "metal_left"
	anchored = TRUE
	can_buckle = TRUE
	has_armrest = FALSE
	color = COLOR_DARK
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_sofa_city_bench_metal_right_black
	parent_type = /obj/structure/chair/sofa
	icon = 'modular_bandastation/san_francisco/icons/decor/c00f9ee0d7_bench.dmi'
	max_integrity = 100
	name = "metal bench"
	desc = "An uncomfortable metal bench."
	icon_state = "metal_right"
	anchored = TRUE
	can_buckle = TRUE
	has_armrest = FALSE
	color = COLOR_DARK
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_sofa_city_bench_wood_left
	parent_type = /obj/structure/chair/sofa
	icon = 'modular_bandastation/san_francisco/icons/decor/c00f9ee0d7_bench.dmi'
	max_integrity = 100
	name = "bench"
	desc = "A comfy wooden bench."
	icon_state = "wood_left"
	anchored = TRUE
	can_buckle = TRUE
	has_armrest = FALSE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_sofa_city_bench_wood_right
	parent_type = /obj/structure/chair/sofa
	icon = 'modular_bandastation/san_francisco/icons/decor/c00f9ee0d7_bench.dmi'
	max_integrity = 100
	name = "bench"
	desc = "A comfy wooden bench."
	icon_state = "wood_right"
	anchored = TRUE
	can_buckle = TRUE
	has_armrest = FALSE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_stool_bar_darkpack_black
	parent_type = /obj/structure/chair/stool/bar
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 300
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar_black"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_stool_bar_darkpack_blue
	parent_type = /obj/structure/chair/stool/bar
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 300
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar_blue"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_stool_bar_darkpack_red
	parent_type = /obj/structure/chair/stool/bar
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 300
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar_red"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_wood_darkpack
	parent_type = /obj/structure/chair/wood
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 40
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	icon_state = "wooden_chair"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_chair_wood_darkpack_red
	parent_type = /obj/structure/chair/wood
	icon = 'modular_bandastation/san_francisco/icons/decor/a651c68aa9_chairs.dmi'
	max_integrity = 40
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	icon_state = "wooden_chair_red"
	anchored = TRUE
	can_buckle = TRUE
	item_chair = null

/obj/structure/san_francisco/decor/obj_structure_city_map
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/d4fa934fce_city_map.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "\improper map"
	desc = "Locate yourself now."
	icon_state = "map"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_closet_crate_dumpster
	parent_type = /obj/structure/closet/crate
	icon = 'modular_bandastation/san_francisco/icons/decor/b52c0d86e4_crates32x32.dmi'
	max_integrity = 200
	layer = BELOW_OBJ_LAYER
	name = "dumpster"
	desc = "Holds garbage inside."
	icon_state = "garbage"
	density = TRUE
	base_icon_state = "garbage"

/obj/structure/san_francisco/decor/obj_structure_closet_secure_closet_freezer_commercial
	parent_type = /obj/structure/closet/secure_closet/freezer
	icon = 'modular_bandastation/san_francisco/icons/decor/d580e33a5c_closet32x32.dmi'
	max_integrity = 250
	layer = BELOW_OBJ_LAYER
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	icon_state = "commercial"
	density = TRUE
	base_icon_state = "commercial"
	enable_door_overlay = FALSE
	has_opened_overlay = FALSE
	has_closed_overlay = FALSE

/obj/structure/san_francisco/decor/obj_structure_closet_secure_closet_weapons
	parent_type = /obj/structure/closet/secure_closet
	icon = 'icons/obj/storage/closet.dmi'
	max_integrity = 250
	layer = BELOW_OBJ_LAYER
	name = "armory weapon locker"
	desc = "It's a card-locked storage unit."
	icon_state = "tac"
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_coclock
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/e8aebf72e0_clock.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "clock"
	desc = "See the time."
	icon_state = "clock"
	anchored = TRUE
	pixel_z = 32

/obj/structure/san_francisco/decor/obj_structure_coclock_grandpa
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/b20224199f_grandpa_cock.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "clock"
	desc = "See the time."
	icon_state = "cock"
	anchored = TRUE
	pixel_z = 0
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_curtain_cloth_fancy_mechanical_luxurious
	parent_type = /obj/structure/curtain/cloth/fancy/mechanical
	icon = 'icons/obj/watercloset.dmi'
	max_integrity = 300
	layer = SIGN_LAYER
	name = "curtain"
	desc = "Contains less than 1% mercury."
	icon_state = "bounty-open"
	color = null
	alpha = 255
	anchored = TRUE
	opacity = FALSE
	density = FALSE

/obj/structure/san_francisco/decor/obj_structure_flora_bush_redflower_style_3
	parent_type = /obj/structure/flora/bush
	icon = 'modular_bandastation/san_francisco/icons/decor/738f310d49_flora32x48.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "bush"
	desc = "Some type of shrubbery. Known for causing considerable economic stress on designers."
	anchored = TRUE
	icon_state = "redplant_3"

/obj/structure/san_francisco/decor/obj_structure_flora_darkpack_flower_bluestar
	parent_type = /obj/structure/flora
	icon = 'modular_bandastation/san_francisco/icons/decor/9532d16ea9_flowers.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "wooly bluestar"
	desc = "A common wildflower."
	anchored = TRUE
	icon_state = "wooly_bluestar"

/obj/structure/san_francisco/decor/obj_structure_flora_darkpack_flower_flax
	parent_type = /obj/structure/flora
	icon = 'modular_bandastation/san_francisco/icons/decor/9532d16ea9_flowers.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "prairie flax"
	desc = "A common wildflower."
	anchored = TRUE
	icon_state = "prairie_flax"

/obj/structure/san_francisco/decor/obj_structure_flora_darkpack_flower_marigold
	parent_type = /obj/structure/flora
	icon = 'modular_bandastation/san_francisco/icons/decor/9532d16ea9_flowers.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "marigold"
	desc = "A common wildflower."
	anchored = TRUE
	icon_state = "marigold"

/obj/structure/san_francisco/decor/obj_structure_flora_darkpack_flower_paintbrush
	parent_type = /obj/structure/flora
	icon = 'modular_bandastation/san_francisco/icons/decor/9532d16ea9_flowers.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "indian paintbrush"
	desc = "A common wildflower."
	anchored = TRUE
	icon_state = "indian_paintbrush"

/obj/structure/san_francisco/decor/obj_structure_flora_darkpack_flower_primrose
	parent_type = /obj/structure/flora
	icon = 'modular_bandastation/san_francisco/icons/decor/9532d16ea9_flowers.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "evening primrose"
	desc = "A common wildflower."
	anchored = TRUE
	icon_state = "evening_primrose"

/obj/structure/san_francisco/decor/obj_structure_flora_darkpack_flower_turtleback
	parent_type = /obj/structure/flora
	icon = 'modular_bandastation/san_francisco/icons/decor/9532d16ea9_flowers.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "velvet turtleback"
	desc = "A common wildflower."
	anchored = TRUE
	icon_state = "velvet_turtleback"

/obj/structure/san_francisco/decor/obj_structure_flora_darkpack_flower_yerba
	parent_type = /obj/structure/flora
	icon = 'modular_bandastation/san_francisco/icons/decor/9532d16ea9_flowers.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "yerba mansa"
	desc = "A common wildflower."
	anchored = TRUE
	icon_state = "yerba_mansa"

/obj/structure/san_francisco/decor/obj_structure_flora_grass_short_style_random
	parent_type = /obj/structure/flora/grass
	icon = 'modular_bandastation/san_francisco/icons/decor/738f310d49_flora32x48.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "grass"
	desc = "A patch of overgrown grass."
	anchored = TRUE
	icon_state = "grass_1"

/obj/structure/san_francisco/decor/obj_structure_flora_grass_tall_style_2
	parent_type = /obj/structure/flora/grass
	icon = 'modular_bandastation/san_francisco/icons/decor/738f310d49_flora32x48.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "grass"
	desc = "A patch of overgrown grass."
	anchored = TRUE
	icon_state = "tallgrass_2"

/obj/structure/san_francisco/decor/obj_structure_flora_grass_tall_style_random
	parent_type = /obj/structure/flora/grass
	icon = 'modular_bandastation/san_francisco/icons/decor/738f310d49_flora32x48.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "grass"
	desc = "A patch of overgrown grass."
	anchored = TRUE
	icon_state = "tallgrass_1"

/obj/structure/san_francisco/decor/obj_structure_flora_rock_darkpack
	parent_type = /obj/structure/flora/rock
	icon = 'modular_bandastation/san_francisco/icons/decor/2540438a16_flora.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "large rock"
	desc = "A volcanic rock. Pioneers used to ride these babies for miles."
	anchored = TRUE
	icon_state = "rock1"
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_flora_rock_darkpack_big
	parent_type = /obj/structure/flora/rock
	icon = 'modular_bandastation/san_francisco/icons/decor/d2ad403207_flora64x64.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "large rock"
	desc = "A volcanic rock. Pioneers used to ride these babies for miles."
	anchored = TRUE
	icon_state = "rock1"
	density = TRUE
	pixel_w = -16

/obj/structure/san_francisco/decor/obj_structure_flora_rock_pile_darkpack
	parent_type = /obj/structure/flora/rock/pile
	icon = 'modular_bandastation/san_francisco/icons/decor/2540438a16_flora.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "rock pile"
	desc = "A pile of rocks."
	anchored = TRUE
	icon_state = "smallrock1"
	density = FALSE

/obj/structure/san_francisco/decor/obj_structure_flora_rock_stalagmite
	parent_type = /obj/structure/flora/rock
	icon = 'modular_bandastation/san_francisco/icons/decor/d2ad403207_flora64x64.dmi'
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	name = "large rock"
	desc = "A volcanic rock. Pioneers used to ride these babies for miles."
	anchored = TRUE
	icon_state = "stalagmite1"
	density = TRUE
	pixel_w = -16

/obj/structure/san_francisco/decor/obj_structure_flora_tree_vamp
	parent_type = /obj/structure/flora/tree
	icon = 'modular_bandastation/san_francisco/icons/decor/6accfbe687_trees.dmi'
	max_integrity = 150
	name = "tree"
	desc = "Cute and tall flora."
	anchored = TRUE
	density = TRUE
	pixel_x = -32
	plane = ABOVE_GAME_PLANE
	icon_state = "tree1"
	base_pixel_x = -32
	pixel_y = 0
	base_pixel_y = 0

/obj/structure/san_francisco/decor/obj_structure_flora_tree_vamp_pine
	parent_type = /obj/structure/flora/tree
	icon = 'modular_bandastation/san_francisco/icons/decor/a04c3f0a2b_pines.dmi'
	max_integrity = 150
	name = "pine"
	desc = "Cute and tall flora."
	anchored = TRUE
	density = TRUE
	pixel_x = -32
	plane = ABOVE_GAME_PLANE
	icon_state = "pine1"
	base_pixel_x = -32
	pixel_y = 0
	base_pixel_y = 0

/obj/structure/san_francisco/decor/obj_structure_fluff_grate_drain
	parent_type = /obj/structure/fluff
	icon = 'modular_bandastation/san_francisco/icons/decor/a5ee446e29_grate.dmi'
	max_integrity = 300
	layer = BELOW_CATWALK_LAYER
	name = "drain"
	desc = "Shiny. Is that a hairball?"
	icon_state = "grate_small"
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	plane = FLOOR_PLANE

/obj/structure/san_francisco/decor/obj_structure_fluff_grate_drain_rusty
	parent_type = /obj/structure/fluff
	icon = 'modular_bandastation/san_francisco/icons/decor/a5ee446e29_grate.dmi'
	max_integrity = 300
	layer = BELOW_CATWALK_LAYER
	name = "drain"
	desc = "Rusty. Is that a hairball?"
	icon_state = "grate_small-rust"
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	plane = FLOOR_PLANE

/obj/structure/san_francisco/decor/obj_structure_fluff_tv
	parent_type = /obj/structure/fluff
	icon = 'modular_bandastation/san_francisco/icons/decor/de97b3dd3e_television.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "\improper TV"
	desc = "A slightly battered looking TV. It's off"
	icon_state = "tv_off"
	anchored = TRUE
	density = TRUE
	opacity = FALSE

/obj/structure/san_francisco/decor/obj_structure_fluff_tv_order_four
	parent_type = /obj/structure/fluff
	icon = 'modular_bandastation/san_francisco/icons/decor/a038c798cd_restaurant.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "order screen"
	desc = "A slightly battered looking TV. It shows a menu to order from."
	icon_state = "order4"
	anchored = TRUE
	density = TRUE
	opacity = FALSE

/obj/structure/san_francisco/decor/obj_structure_fluff_tv_order_one
	parent_type = /obj/structure/fluff
	icon = 'modular_bandastation/san_francisco/icons/decor/a038c798cd_restaurant.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "order screen"
	desc = "A slightly battered looking TV. It shows a menu to order from."
	icon_state = "order1"
	anchored = TRUE
	density = TRUE
	opacity = FALSE

/obj/structure/san_francisco/decor/obj_structure_fluff_tv_order_three
	parent_type = /obj/structure/fluff
	icon = 'modular_bandastation/san_francisco/icons/decor/a038c798cd_restaurant.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "order screen"
	desc = "A slightly battered looking TV. It shows a menu to order from."
	icon_state = "order3"
	anchored = TRUE
	density = TRUE
	opacity = FALSE

/obj/structure/san_francisco/decor/obj_structure_fluff_tv_order_two
	parent_type = /obj/structure/fluff
	icon = 'modular_bandastation/san_francisco/icons/decor/a038c798cd_restaurant.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "order screen"
	desc = "A slightly battered looking TV. It shows a menu to order from."
	icon_state = "order2"
	anchored = TRUE
	density = TRUE
	opacity = FALSE

/obj/structure/san_francisco/decor/obj_structure_food_cart
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/11663e3043_food_cart.dmi'
	max_integrity = 300
	layer = ABOVE_MOB_LAYER
	name = "food cart"
	desc = "Ding-aling ding dong. Get your cholesterine!"
	icon_state = "vat1"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_fuelstation
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/16fb645976_props.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "fuel station"
	desc = "Fuel your car here. 50 dollars per 1000 units."
	icon_state = "fuelstation"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_gargoyle
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/f880952cb5_32x48.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper gargoyle"
	desc = "Some kind of gothic architecture."
	icon_state = "gargoyle"
	pixel_z = 8
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_hotelbanner
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "banner"
	desc = "It says H O T E L."
	icon_state = "banner"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_hydrant
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/0018560535_hydrant.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "hydrant"
	desc = "Used for firefighting."
	icon_state = "hydrant"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_jesuscross
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/295dc1e8de_64x64.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "Jesus Christ on a cross"
	desc = "Jesus said, “Father, forgive them, for they do not know what they are doing.” And they divided up his clothes by casting lots (Luke 23:34)."
	icon_state = "cross"
	anchored = TRUE
	density = TRUE
	pixel_w = -16

/obj/structure/san_francisco/decor/obj_structure_ladder_manhole_down
	parent_type = /obj/structure/ladder/san_francisco
	icon = 'modular_bandastation/san_francisco/icons/decor/58f14c97ee_ladders.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "manhole"
	desc = "A sturdy metal ladder."
	icon_state = "manhole_closed"
	base_icon_state = "manhole"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_ladder_manhole_up
	parent_type = /obj/structure/ladder/san_francisco
	icon = 'modular_bandastation/san_francisco/icons/decor/58f14c97ee_ladders.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon_state = "ladder10"
	base_icon_state = "ladder"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_lattice_pentex
	parent_type = /obj/structure/lattice
	icon = 'modular_bandastation/san_francisco/icons/decor/0cbb2fa240_catwalk_pentex_opaque.dmi'
	max_integrity = 50
	layer = LATTICE_LAYER
	name = "lattice"
	desc = "Looks sturdy enough and made of advanced materials."
	icon_state = "lattice-255"
	base_icon_state = "lattice"
	density = FALSE
	anchored = TRUE
	plane = FLOOR_PLANE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_LATTICE
	canSmoothWith = SMOOTH_GROUP_LATTICE + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_OPEN_FLOOR

/obj/structure/san_francisco/decor/obj_structure_marketplace
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/aa76796675_stonks.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "stock market"
	desc = "Recent stocks visualization."
	icon_state = "marketplace"
	anchored = TRUE
	density = TRUE
	pixel_w = -24

/obj/structure/san_francisco/decor/obj_structure_pole
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/295dc1e8de_64x64.dmi'
	max_integrity = 300
	layer = 4
	name = "stripper pole"
	desc = "A pole fastened to the ceiling and floor, used to show of ones goods to company."
	icon_state = "pole"
	density = FALSE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_clothing
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/e3fce4655a_rack.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "clothing rack"
	desc = "Have some clothes."
	icon_state = "rack"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_clothing_rand
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/e3fce4655a_rack.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "clothing rack"
	desc = "Have some clothes."
	icon_state = "rack2"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_clothing_hanger
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/e3fce4655a_rack.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "clothing hanger"
	desc = "Have some clothes."
	icon_state = "hanger1"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_clothing_hanger_rand
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/e3fce4655a_rack.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "clothing hanger"
	desc = "Have some clothes."
	icon_state = "hanger2"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_food
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/295dc1e8de_64x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "food rack"
	desc = "Have some food."
	icon_state = "rack1"
	density = TRUE
	anchored = TRUE
	pixel_w = -16

/obj/structure/san_francisco/decor/obj_structure_rack_food_rand
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/295dc1e8de_64x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "food rack"
	desc = "Have some food."
	icon_state = "rack2"
	density = TRUE
	anchored = TRUE
	pixel_w = -16

/obj/structure/san_francisco/decor/obj_structure_rack_fruit_stand
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/e3fce4655a_rack.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "frust stand"
	desc = "Different from the Middle Ages version."
	icon_state = "fruit_stand"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_tall_metal_shelf
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/7bff5f79df_rack32x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "metal_shelf"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_tall_store_shelf_metal
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/7bff5f79df_rack32x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "store_shelf_metal"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_tall_wood_shelf
	parent_type = /obj/structure/rack
	icon = 'modular_bandastation/san_francisco/icons/decor/7bff5f79df_rack32x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "wood_shelf"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_wide_med_shelf
	parent_type = /obj/structure/rack/san_francisco_wide
	icon = 'modular_bandastation/san_francisco/icons/decor/c5c062de5c_rack64x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "med_shelf"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_wide_metal_shelf
	parent_type = /obj/structure/rack/san_francisco_wide
	icon = 'modular_bandastation/san_francisco/icons/decor/c5c062de5c_rack64x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "metal_shelf"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_wide_store_shelf
	parent_type = /obj/structure/rack/san_francisco_wide
	icon = 'modular_bandastation/san_francisco/icons/decor/c5c062de5c_rack64x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "store_shelf"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_wide_wood_shelf
	parent_type = /obj/structure/rack/san_francisco_wide
	icon = 'modular_bandastation/san_francisco/icons/decor/c5c062de5c_rack64x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "wood_shelf"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_rack_wide_wood_shelf_alt
	parent_type = /obj/structure/rack/san_francisco_wide
	icon = 'modular_bandastation/san_francisco/icons/decor/c5c062de5c_rack64x64.dmi'
	max_integrity = 20
	layer = TABLE_LAYER
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon_state = "wood_shelf-alt"
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_railing_darkpack_metal
	parent_type = /obj/structure/railing
	icon = 'modular_bandastation/san_francisco/icons/decor/792ae3c39e_railings.dmi'
	max_integrity = 25
	layer = ABOVE_TREE_LAYER
	name = "guard rail"
	desc = "A sturdy rail setup with multiple functions, including but not limited to: ensuring you dont fly off the top of a four story tall building"
	icon_state = "civ_full"
	density = TRUE
	anchored = TRUE
	plane = ABOVE_GAME_PLANE

/obj/structure/san_francisco/decor/obj_structure_railing_darkpack_metal_industrial
	parent_type = /obj/structure/railing
	icon = 'modular_bandastation/san_francisco/icons/decor/792ae3c39e_railings.dmi'
	max_integrity = 25
	layer = ABOVE_TREE_LAYER
	name = "guard rail"
	desc = "A sturdy rail setup with multiple functions, including but not limited to: ensuring you dont fly off the top of a four story tall building. It's got a slick orange taint, so you know it's to workplace regulations."
	icon_state = "indus_full"
	density = TRUE
	anchored = TRUE
	plane = ABOVE_GAME_PLANE

/obj/structure/san_francisco/decor/obj_structure_railing_darkpack_metal_industrial_solo
	parent_type = /obj/structure/railing
	icon = 'modular_bandastation/san_francisco/icons/decor/792ae3c39e_railings.dmi'
	max_integrity = 25
	layer = ABOVE_TREE_LAYER
	name = "guard rail"
	desc = "A sturdy rail setup with multiple functions, including but not limited to: ensuring you dont fly off the top of a four story tall building. It's got a slick orange taint, so you know it's to workplace regulations."
	icon_state = "indus_solo"
	density = TRUE
	anchored = TRUE
	plane = ABOVE_GAME_PLANE

/obj/structure/san_francisco/decor/obj_structure_roadblock
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/66e2be6daa_barriers.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "\improper road block"
	desc = "Protects places from walking in."
	icon_state = "roadblock"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadblock_alt
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/66e2be6daa_barriers.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "\improper road block"
	desc = "Protects places from walking in."
	icon_state = "barrier"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "stop"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_busstop
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "bus stop sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "busstop"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_crosswalk
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "crosswalk sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "crosswalk"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_fourway
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "4way"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_noparking
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "no parking sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "noparking"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_nopedestrian
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "no pedestrian sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "nopedestrian"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_noturnback
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "noturnback"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_noturnleft
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "noturnleft"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_noturnright
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "noturnright"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_onewayright
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "onewayright"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_parking
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "parking sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "parking"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_speedlimit
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "speed limit sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "speed50"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_speedlimit25
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "speed limit sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "speed25"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_speedlimit40
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "speed limit sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "speed40"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_stop
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "stop sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "stop"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_street
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "street sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "street"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_warningdeer
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "warningdeer"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_warningpedestrian
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "pedestrian warning sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "warningpedestrian"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_warningtrafficlight
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "traffic light warning sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "warningtrafficlight"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roadsign_wrongway
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/ecd2716653_road_signs.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "road sign"
	desc = "Do not drive your car cluelessly."
	icon_state = "wrongway"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_roofstuff
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/71b23ba7a8_vents.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "roof ventilation"
	desc = "Air to inside."
	icon_state = "roof1"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_roofstuff_alt1
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/71b23ba7a8_vents.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "roof ventilation"
	desc = "Air to inside."
	icon_state = "roof2"
	anchored = TRUE
	density = FALSE

/obj/structure/san_francisco/decor/obj_structure_roofstuff_alt2
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/71b23ba7a8_vents.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "roof ventilation"
	desc = "Air to inside."
	icon_state = "roof3"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_roofstuff_vent
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/71b23ba7a8_vents.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "roof ventilation"
	desc = "Air to inside."
	icon_state = "vent-0"
	anchored = TRUE
	density = TRUE
	base_icon_state = "vent"

/obj/structure/san_francisco/decor/obj_structure_roofstuff_vent_autotiling
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/71b23ba7a8_vents.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "roof ventilation"
	desc = "Air to inside."
	icon_state = "vent-0"
	anchored = TRUE
	density = TRUE
	base_icon_state = "vent"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SAN_FRANCISCO_VENTS
	canSmoothWith = SMOOTH_GROUP_SAN_FRANCISCO_VENTS

/obj/structure/san_francisco/decor/obj_structure_roofstuff_vent_end
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/71b23ba7a8_vents.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "roof ventilation"
	desc = "Air to inside."
	icon_state = "roof4"
	anchored = TRUE
	density = TRUE
	smoothing_groups = SMOOTH_GROUP_SAN_FRANCISCO_VENTS

/obj/structure/san_francisco/decor/obj_structure_shipping_container_darkpack_endron
	parent_type = /obj/structure/shipping_container
	icon = 'modular_bandastation/san_francisco/icons/decor/593cbc2fb8_smallcontainers.dmi'
	max_integrity = 1000
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper Endron shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is marked with Endron branding."
	icon_state = "endron1"
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE
	plane = ABOVE_GAME_PLANE

/obj/structure/san_francisco/decor/obj_structure_shipping_container_darkpack_endron_alt
	parent_type = /obj/structure/shipping_container
	icon = 'modular_bandastation/san_francisco/icons/decor/593cbc2fb8_smallcontainers.dmi'
	max_integrity = 1000
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper Endron shipping container"
	desc = "A standard-measure shipping container for bulk transport of goods. This one is marked with Endron branding."
	icon_state = "endron2"
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE
	plane = ABOVE_GAME_PLANE

/obj/structure/san_francisco/decor/obj_structure_shipping_container_darkpack_endron_gas
	parent_type = /obj/structure/shipping_container
	icon = 'modular_bandastation/san_francisco/icons/decor/593cbc2fb8_smallcontainers.dmi'
	max_integrity = 1000
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper Endron bulk gas tank"
	desc = "A standard-measure gas tank for bulk transport of gases. This one is marked with Endron branding, but no indication of what gas it holds."
	icon_state = "endron3"
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE
	plane = ABOVE_GAME_PLANE

/obj/structure/san_francisco/decor/obj_structure_sign_city_anarch
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "It says B A R."
	icon_state = "bar"
	dir = WEST
	light_range = 3
	light_power = 3
	light_color = "#ffffff"

/obj/structure/san_francisco/decor/obj_structure_sign_city_cabaret_sign_directional_north
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/9eda0fc3a4_cabaret.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "cabaret"
	desc = "An enticing pair of legs... I wonder what's inside?"
	icon_state = "cabar"
	light_range = 3
	light_power = 2
	light_color = "#d98aec"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_city_cabaret_sign_two_directional_north
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/9eda0fc3a4_cabaret.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "cabaret"
	desc = "An enticing pair of legs... I wonder what's inside?"
	icon_state = "et"
	light_range = 3
	light_power = 2
	light_color = "#d98aec"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_city_chinese_alt_directional_east
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "雨天和血的机会."
	icon_state = "chinese2"
	dir = EAST
	pixel_x = 0

/obj/structure/san_francisco/decor/obj_structure_sign_city_chinese_alt_directional_west
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "雨天和血的机会."
	icon_state = "chinese2"
	dir = WEST
	pixel_x = -0

/obj/structure/san_francisco/decor/obj_structure_sign_city_chinese_alt5_directional_east
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "雨天和血的机会."
	icon_state = "chinese6"
	dir = EAST
	pixel_x = 0

/obj/structure/san_francisco/decor/obj_structure_sign_city_chinese_directional_east
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "雨天和血的机会."
	icon_state = "chinese1"
	dir = EAST
	pixel_x = 0

/obj/structure/san_francisco/decor/obj_structure_sign_city_chinese_directional_west
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "雨天和血的机会."
	icon_state = "chinese1"
	dir = WEST
	pixel_x = -0

/obj/structure/san_francisco/decor/obj_structure_sign_city_hotel
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "It says H O T E L."
	icon_state = "hotel"
	light_range = 3
	light_power = 3
	light_color = "#8e509e"

/obj/structure/san_francisco/decor/obj_structure_sign_city_millenium
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "It says M I L L E N I U M."
	icon_state = "millenium1"
	dir = NORTH
	pixel_y = 32
	light_range = 3
	light_power = 3
	light_color = "#4299bb"

/obj/structure/san_francisco/decor/obj_structure_sign_city_order
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "order sign"
	icon_state = "order"

/obj/structure/san_francisco/decor/obj_structure_sign_city_order_directional_west
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "order sign"
	icon_state = "order"
	dir = WEST
	pixel_x = -32

/obj/structure/san_francisco/decor/obj_structure_sign_city_police_department
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "\improper San Francisco Police Department sign"
	desc = "Stop right there you criminal scum! Nobody can break the law on my watch!!"
	icon_state = "police1"
	pixel_z = 4

/obj/structure/san_francisco/decor/obj_structure_sign_city_police_department_directional_north
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b048096403_city_sign.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "\improper San Francisco Police Department sign"
	desc = "Stop right there you criminal scum! Nobody can break the law on my watch!!"
	icon_state = "police1"
	pixel_z = 4
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_city_store_bacotell_directional_north
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b4d124ec11_store_sign.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	icon_state = "bacotell"
	pixel_w = -16
	name = "Baco Tell"
	desc = "Eat some precious tacos and pizza!"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_city_store_bubway_directional_north
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b4d124ec11_store_sign.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	icon_state = "bubway"
	pixel_w = -16
	name = "BubWay"
	desc = "Eat some precious burgers and pizza!"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_city_store_gummaguts_directional_north
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b4d124ec11_store_sign.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	icon_state = "gummaguts"
	pixel_w = -16
	name = "Gumma Guts"
	desc = "Eat some precious chicken nuggets and donuts!"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_city_strip_club_directional_north
	parent_type = /obj/structure/sign/san_francisco_city
	icon = 'modular_bandastation/san_francisco/icons/decor/b46315bd85_48x48.dmi'
	max_integrity = 100
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "sign"
	desc = "It says DO RA. Maybe it's some kind of strip club..."
	icon_state = "dora"
	pixel_w = -8
	light_range = 3
	light_power = 2
	light_color = "#8e509e"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_flag_britain
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of Great Britain"
	desc = "The flag of the United Kingdom of Great Britain and Northern Ireland. Dieu et mon droit!"
	icon_state = "flag_britain"

/obj/structure/san_francisco/decor/obj_structure_sign_flag_california
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of California"
	desc = "The flag of the great State of California. Eureka!"
	icon_state = "flag_california"

/obj/structure/san_francisco/decor/obj_structure_sign_flag_china_directional_north
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of China"
	desc = "The flag of the People's Republic of China."
	icon_state = "flag_china"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_flag_france
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of France"
	desc = "The flag of the French Republic. Liberte, egalite, fraternite!"
	icon_state = "flag_france"

/obj/structure/san_francisco/decor/obj_structure_sign_flag_soviet
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of the Soviet Union"
	desc = "The flag of the Union of Socialist Soviet Republics. Workers of the world, unite!"
	icon_state = "flag_soviet"

/obj/structure/san_francisco/decor/obj_structure_sign_flag_spain
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of Spain"
	desc = "The flag of the Kingdom of Spain. Plus ultra!"
	icon_state = "flag_spain"

/obj/structure/san_francisco/decor/obj_structure_sign_flag_usa
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of the United States"
	desc = "The flag of the United States of America. In God we trust!"
	icon_state = "flag_usa"

/obj/structure/san_francisco/decor/obj_structure_sign_flag_usa_directional_north
	parent_type = /obj/structure/sign/flag
	icon = 'modular_bandastation/san_francisco/icons/decor/427a107cc6_flags.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "flag of the United States"
	desc = "The flag of the United States of America. In God we trust!"
	icon_state = "flag_usa"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sign_poster_city_kish_directional_north
	parent_type = /obj/structure/sign/poster
	icon = 'modular_bandastation/san_francisco/icons/decor/77877f06da_poster.dmi'
	max_integrity = 100
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	name = "King and Jester"
	desc = "An interesting movie poster."
	icon_state = "poster_16"
	dir = NORTH
	pixel_y = 32

/obj/structure/san_francisco/decor/obj_structure_sink_basin
	parent_type = /obj/structure/sink
	icon = 'modular_bandastation/san_francisco/icons/decor/c254c01a44_watercloset.dmi'
	max_integrity = 300
	layer = ABOVE_OBJ_LAYER
	name = "sink"
	icon_state = "basin"
	desc = "A sink used for washing one's hands and face. Passively reclaims water over time."
	anchored = TRUE
	pixel_z = 0

/obj/structure/san_francisco/decor/obj_structure_sink_basin_directional_east
	parent_type = /obj/structure/sink
	icon = 'modular_bandastation/san_francisco/icons/decor/c254c01a44_watercloset.dmi'
	max_integrity = 300
	layer = ABOVE_OBJ_LAYER
	name = "sink"
	icon_state = "basin"
	desc = "A sink used for washing one's hands and face. Passively reclaims water over time."
	anchored = TRUE
	pixel_z = 0
	dir = EAST
	pixel_x = (0)

/obj/structure/san_francisco/decor/obj_structure_sink_basin_directional_south
	parent_type = /obj/structure/sink
	icon = 'modular_bandastation/san_francisco/icons/decor/c254c01a44_watercloset.dmi'
	max_integrity = 300
	layer = ABOVE_OBJ_LAYER
	name = "sink"
	icon_state = "basin"
	desc = "A sink used for washing one's hands and face. Passively reclaims water over time."
	anchored = TRUE
	pixel_z = 0
	dir = SOUTH
	pixel_y = -(0)

/obj/structure/san_francisco/decor/obj_structure_table_countertop
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/ddde79bc8f_bubway_table.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "countertop"
	desc = "A countertop with a solid base."
	icon_state = "bubway_table-0"
	base_icon_state = "bubway_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_countertop_bacotell
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/7280898d6a_bacotell_table.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "countertop"
	desc = "A corperate countertop for serving food."
	icon_state = "bacotell_table-0"
	base_icon_state = "bacotell_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	can_flip = FALSE
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES

/obj/structure/san_francisco/decor/obj_structure_table_countertop_black
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/207bb51ef0_blacktop_table.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "countertop"
	desc = "A countertop with a solid base."
	icon_state = "blacktop_table-0"
	base_icon_state = "blacktop_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	can_flip = FALSE
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES

/obj/structure/san_francisco/decor/obj_structure_table_countertop_bubway
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/ddde79bc8f_bubway_table.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "countertop"
	desc = "A corperate countertop for serving food."
	icon_state = "bubway_table-0"
	base_icon_state = "bubway_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	can_flip = FALSE
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES

/obj/structure/san_francisco/decor/obj_structure_table_countertop_green
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/918969f8b4_greentop_table.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "countertop"
	desc = "A countertop with a solid base."
	icon_state = "greentop_table-0"
	base_icon_state = "greentop_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	can_flip = FALSE
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES

/obj/structure/san_francisco/decor/obj_structure_table_countertop_purple
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/34740d4d3c_purpletop_table.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "countertop"
	desc = "A countertop with a solid base."
	icon_state = "purpletop_table-0"
	base_icon_state = "purpletop_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	can_flip = FALSE
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES

/obj/structure/san_francisco/decor/obj_structure_table_countertop_teal
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/93927286ff_tealtop_table.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "countertop"
	desc = "A countertop with a solid base."
	icon_state = "tealtop_table-0"
	base_icon_state = "tealtop_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	can_flip = FALSE
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES

/obj/structure/san_francisco/decor/obj_structure_table_modern
	parent_type = /obj/structure/table
	icon = 'icons/obj/smooth_structures/alien_table.dmi'
	max_integrity = 100
	layer = TABLE_LAYER
	name = "modern table"
	desc = "Obnoxious fiberglass table."
	icon_state = "alien_table-0"
	base_icon_state = "alien_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_TABLES
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_TABLES
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_large_metal
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/ace0ea2fb6_64x64_large_tables.dmi'
	max_integrity = 300
	layer = TABLE_LAYER
	name = "metal table"
	desc = "A solid, wide metal table. Nothing about it stands out in particular."
	icon_state = "table_metal_wide"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_large_metal_desk
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/ace0ea2fb6_64x64_large_tables.dmi'
	max_integrity = 300
	layer = TABLE_LAYER
	name = "metal desk"
	desc = "A solid, wide metal table. Nothing about it stands out in particular."
	icon_state = "desk_metal"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_large_metal_desk_alt
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/ace0ea2fb6_64x64_large_tables.dmi'
	max_integrity = 300
	layer = TABLE_LAYER
	name = "metal desk"
	desc = "A compact metal desk, used by people whose work would be far easier if you weren't there."
	icon_state = "desk_metal_small"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_large_wood_stand_alt
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/ace0ea2fb6_64x64_large_tables.dmi'
	max_integrity = 200
	layer = TABLE_LAYER
	name = "wood console"
	desc = "A smooth IDEA-branded console. Mostly just looks good in a room."
	icon_state = "stand_wood_small"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_modular_desk
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/4b88daa3d6_modular_tables.dmi'
	max_integrity = 100
	layer = TABLE_LAYER
	name = "wood desk"
	desc = "A compact wood desk, used by a wide variety of business-inclined individuals."
	icon_state = "desk_wood_mid"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_modular_desk_corner
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/4b88daa3d6_modular_tables.dmi'
	max_integrity = 100
	layer = TABLE_LAYER
	name = "wood desk"
	desc = "A compact wood desk, used by a wide variety of business-inclined individuals."
	icon_state = "desk_wood_corner"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_modular_desk_left
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/4b88daa3d6_modular_tables.dmi'
	max_integrity = 100
	layer = TABLE_LAYER
	name = "wood desk"
	desc = "A compact wood desk, used by a wide variety of business-inclined individuals."
	icon_state = "desk_wood_left"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_modular_desk_right
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/4b88daa3d6_modular_tables.dmi'
	max_integrity = 100
	layer = TABLE_LAYER
	name = "wood desk"
	desc = "A compact wood desk, used by a wide variety of business-inclined individuals."
	icon_state = "desk_wood_right"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_wood
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/e57cc56f05_standalone_tables.dmi'
	max_integrity = 150
	layer = TABLE_LAYER
	name = "wood table"
	desc = "A simple round wooden table. You wish you could make something this nice."
	icon_state = "table_wood_round"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_wood_cablereel
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/e57cc56f05_standalone_tables.dmi'
	max_integrity = 150
	layer = TABLE_LAYER
	name = "cable reel"
	desc = "Once it held copper cable, now it holds all sorts of stuff."
	icon_state = "cable_reel"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_wood_low
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/e57cc56f05_standalone_tables.dmi'
	max_integrity = 150
	layer = TABLE_LAYER
	name = "coffee table"
	desc = "A table that is relatively low to the ground, designed to prop things up on while you sit on your sofa."
	icon_state = "table_wood_low"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_no_smooth_wood_square
	parent_type = /obj/structure/table
	icon = 'modular_bandastation/san_francisco/icons/decor/e57cc56f05_standalone_tables.dmi'
	max_integrity = 150
	layer = TABLE_LAYER
	name = "wood table"
	desc = "A simple squared wooden table. You wish you could make something this nice."
	icon_state = "table_wood_square"
	base_icon_state = "table_wood_stand"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_wood_bar
	parent_type = /obj/structure/table/wood
	icon = 'modular_bandastation/san_francisco/icons/decor/d215750a50_table_wood_bar.dmi'
	max_integrity = 70
	layer = TABLE_LAYER
	name = "wooden table"
	desc = "A somewhat fancy table used at restauraunts. Featuring a simplistic anchored leg design, wow!"
	icon_state = "table-0"
	base_icon_state = "table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WOOD_TABLES
	canSmoothWith = SMOOTH_GROUP_WOOD_TABLES
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_table_wood_billiard
	parent_type = /obj/structure/table/wood
	icon = 'modular_bandastation/san_francisco/icons/decor/6a823ce518_32x48.dmi'
	max_integrity = 70
	layer = TABLE_LAYER
	name = "billiard table"
	desc = "Come here, play some BALLS. I know you want it so much..."
	icon_state = "billiard1"
	base_icon_state = "wood_table"
	density = TRUE
	anchored = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	pixel_y = -16
	can_flip = FALSE

/obj/structure/san_francisco/decor/obj_structure_tire
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/338fbf8612_alleyway.dmi'
	max_integrity = 300
	layer = BELOW_OBJ_LAYER
	name = "tire"
	desc = "It's a tire."
	icon_state = "tire"
	anchored = TRUE
	density = FALSE

/obj/structure/san_francisco/decor/obj_structure_trad
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/2ee9655359_chinatown.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "traditional lamp"
	desc = "Cool chinese lamp."
	icon_state = "trad"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_trafficlight
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/cadaa6b836_lamppost.dmi'
	max_integrity = 300
	layer = SPACEVINE_LAYER
	name = "traffic light"
	desc = "Shows when road is free or not."
	icon_state = "traffic"
	pixel_w = -32
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampfence
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/434a4fa9f6_fence.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper fence"
	desc = "Protects places from walking in."
	icon_state = "fence"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampfence_corner
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/434a4fa9f6_fence.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper fence"
	desc = "Protects places from walking in."
	icon_state = "fence_corner"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampfence_corner_rich
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/f880952cb5_32x48.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper fence"
	desc = "Protects places from walking in."
	icon_state = "fence_corner"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampfence_rich
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/f880952cb5_32x48.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "\improper fence"
	desc = "Protects places from walking in."
	icon_state = "fence"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampipe
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/39151df6f7_pipes.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "pipes"
	icon_state = "piping1"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampstatue
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/c1130a05ee_32x64.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "statue"
	desc = "A cloaked figure forgotten to the ages."
	icon_state = "statue"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampstatue_angel
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/295dc1e8de_64x64.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "angel statue"
	desc = "An angel stands before you. You're glad it's only stone."
	icon_state = "angelstatue"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_vampstatue_cloaked
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/f880952cb5_32x48.dmi'
	max_integrity = 300
	layer = ABOVE_ALL_MOB_LAYER
	name = "cloaked figure"
	desc = "He appears to be sitting."
	icon_state = "cloakedstatue"
	anchored = TRUE
	density = TRUE

/obj/structure/san_francisco/decor/obj_structure_werewolf_totem_bone_gnawer
	parent_type = /obj/structure/san_francisco_passive_totem
	icon = 'modular_bandastation/san_francisco/icons/decor/b674b102b4_totems.dmi'
	max_integrity = 500
	layer = BELOW_OBJ_LAYER
	name = "\improper Bone Gnawers totem"
	desc = "Gives power to all Garou of that tribe."
	icon_state = "wendigo"
	base_icon_state = "wendigo"
	anchored = TRUE
	density = TRUE
	light_range = 3
	light_power = 0.5
	light_color = "#FFA500"

/obj/structure/san_francisco/decor/obj_structure_werewolf_totem_generic_gaia
	parent_type = /obj/structure/san_francisco_passive_totem
	icon = 'modular_bandastation/san_francisco/icons/decor/b674b102b4_totems.dmi'
	max_integrity = 500
	layer = BELOW_OBJ_LAYER
	name = "tribe totem"
	desc = "Gives power to all Garou of that tribe."
	icon_state = "wendigo"
	base_icon_state = "wendigo"
	anchored = TRUE
	density = TRUE
	light_range = 3
	light_power = 0.5
	light_color = "#81ff4f"

/obj/structure/san_francisco/decor/obj_structure_werewolf_totem_generic_weaver
	parent_type = /obj/structure/san_francisco_passive_totem
	icon = 'modular_bandastation/san_francisco/icons/decor/b674b102b4_totems.dmi'
	max_integrity = 500
	layer = BELOW_OBJ_LAYER
	name = "tribe totem"
	desc = "Gives power to all Garou of that tribe."
	icon_state = "glassw"
	base_icon_state = "glassw"
	anchored = TRUE
	density = TRUE
	light_range = 3
	light_power = 0.5
	light_color = "#35b0ff"

/obj/structure/san_francisco/decor/obj_structure_werewolf_totem_generic_wyld
	parent_type = /obj/structure/san_francisco_passive_totem
	icon = 'modular_bandastation/san_francisco/icons/decor/b674b102b4_totems.dmi'
	max_integrity = 500
	layer = BELOW_OBJ_LAYER
	name = "tribe totem"
	desc = "Gives power to all Garou of that tribe."
	icon_state = "wendigo"
	base_icon_state = "wendigo"
	anchored = TRUE
	density = TRUE
	light_range = 3
	light_power = 0.5
	light_color = "#81ff4f"

/obj/structure/san_francisco/decor/obj_structure_werewolf_totem_generic_wyrm
	parent_type = /obj/structure/san_francisco_passive_totem
	icon = 'modular_bandastation/san_francisco/icons/decor/3eb90e4270_spiral_totem.dmi'
	max_integrity = 500
	layer = BELOW_OBJ_LAYER
	name = "tribe totem"
	desc = "Gives power to all Garou of that tribe."
	icon_state = "spiral"
	base_icon_state = "spiral"
	anchored = TRUE
	density = TRUE
	light_range = 3
	light_power = 0.5
	light_color = "#ff5235"

/obj/structure/san_francisco/decor/obj_underplate
	parent_type = /obj/structure
	name = "underplate"
	icon = 'modular_bandastation/san_francisco/icons/decor/a038c798cd_restaurant.dmi'
	icon_state = "underplate"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_underplate_stuff
	parent_type = /obj/structure
	name = "underplate"
	icon = 'modular_bandastation/san_francisco/icons/decor/a038c798cd_restaurant.dmi'
	icon_state = "stuff"
	anchored = TRUE

/obj/structure/san_francisco/decor/obj_vampgrave
	parent_type = /obj/structure
	icon = 'modular_bandastation/san_francisco/icons/decor/3f21e5ff00_graves.dmi'
	icon_state = "grave1"
	name = "grave"
	plane = GAME_PLANE
	layer = ABOVE_NORMAL_TURF_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/mannequin/plastic/san_francisco_napoleon
	starting_items = list(/obj/item/clothing/san_francisco/head_vampire_napoleon, /obj/item/clothing/san_francisco/under_vampire_napoleon, /obj/item/clothing/san_francisco/shoes_vampire_jackboots_high)


/obj/structure/mannequin/plastic/san_francisco_conquistador
	starting_items = list(/obj/item/clothing/san_francisco/head_vampire_helmet_spain, /obj/item/clothing/san_francisco/shoes_vampire_jackboots_work, /obj/item/clothing/san_francisco/under_vampire_tremere, /obj/item/clothing/san_francisco/suit_vampire_vest_medieval)


/obj/structure/mannequin/plastic/san_francisco_cowboy
	starting_items = list(/obj/item/clothing/san_francisco/head_vampire_cowboy, /obj/item/clothing/san_francisco/shoes_vampire_brown, /obj/item/clothing/san_francisco/under_vampire_bouncer, /obj/item/clothing/san_francisco/suit_vampire_trench_alt)


/obj/structure/mannequin/plastic/san_francisco_soviet
	starting_items = list(/obj/item/clothing/head/helmet/rus_ushanka, /obj/item/clothing/san_francisco/shoes_vampire_jackboots_high, /obj/item/clothing/under/costume/soviet, /obj/item/clothing/suit/costume/soviet)


/obj/structure/mannequin/plastic/san_francisco_fancy/Initialize(mapload)
	if(prob(75))
		starting_items += pick(list(/obj/item/clothing/san_francisco/under_vampire_ventrue, /obj/item/clothing/san_francisco/under_vampire_ventrue_female, /obj/item/clothing/san_francisco/under_vampire_fancy_gray, /obj/item/clothing/san_francisco/under_vampire_fancy_red, /obj/item/clothing/san_francisco/under_vampire_leatherpants))
	return ..()


/obj/structure/mannequin/plastic/san_francisco_punk/Initialize(mapload)
	if(prob(75))
		starting_items += pick(list(/obj/item/clothing/san_francisco/under_vampire_punk, /obj/item/clothing/san_francisco/under_vampire_black, /obj/item/clothing/san_francisco/under_vampire_red, /obj/item/clothing/san_francisco/under_vampire_gothic, /obj/item/clothing/san_francisco/under_vampire_brujah, /obj/item/clothing/san_francisco/under_vampire_brujah_female, /obj/item/clothing/san_francisco/under_vampire_gangrel, /obj/item/clothing/san_francisco/under_vampire_gangrel_female))
	return ..()


#undef SMOOTH_GROUP_SAN_FRANCISCO_VENTS
