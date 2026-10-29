// Ground appearances imported from Crimson Grid with native BandaStation floor and water behavior.
/turf/open/floor/san_francisco
	name = "floor"
	desc = null
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	floor_tile = null
	smoothing_flags = NONE
	footstep = FOOTSTEP_CONCRETE
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	var/texture_prefix
	var/texture_variants = 0

/turf/open/floor/san_francisco/Initialize(mapload)
	. = ..()
	if(texture_variants && icon_state == initial(icon_state))
		icon_state = "[texture_prefix][rand(1, texture_variants)]"

/turf/open/floor/san_francisco/carpet/ornate
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/redgoldcarpet.dmi'
	icon_state = "redgoldcarpet-255"
	base_icon_state = "redgoldcarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET
	canSmoothWith = SMOOTH_GROUP_CARPET

/turf/open/floor/san_francisco/carpet/ornate/blackgold
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/blackgoldcarpet.dmi'
	icon_state = "blackgoldcarpet-255"
	base_icon_state = "blackgoldcarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLACK

/turf/open/floor/san_francisco/carpet/ornate/blacksilver
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/blacksilvercarpet.dmi'
	icon_state = "blacksilvercarpet-255"
	base_icon_state = "blacksilvercarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_BLACK

/turf/open/floor/san_francisco/carpet/ornate/bluegold
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/bluegoldcarpet.dmi'
	icon_state = "bluegoldcarpet-255"
	base_icon_state = "bluegoldcarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLUE

/turf/open/floor/san_francisco/carpet/ornate/bluesilver
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/bluesilvercarpet.dmi'
	icon_state = "bluesilvercarpet-255"
	base_icon_state = "bluesilvercarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_BLUE

/turf/open/floor/san_francisco/carpet/ornate/cyan
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/cyancarpet.dmi'
	icon_state = "cyancarpet-255"
	base_icon_state = "cyancarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_CYAN
	canSmoothWith = SMOOTH_GROUP_CARPET_CYAN

/turf/open/floor/san_francisco/carpet/ornate/greengold
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/greengoldcarpet.dmi'
	icon_state = "greengoldcarpet-255"
	base_icon_state = "greengoldcarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_GREEN
	canSmoothWith = SMOOTH_GROUP_CARPET_GREEN

/turf/open/floor/san_francisco/carpet/ornate/hotel
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/orangehotelcarpet.dmi'
	icon_state = "orangehotelcarpet-255"
	base_icon_state = "orangehotelcarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_DONK
	canSmoothWith = SMOOTH_GROUP_CARPET_DONK

/turf/open/floor/san_francisco/carpet/ornate/old
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "carpet_black"
	base_icon_state = "redgoldcarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = NONE

/turf/open/floor/san_francisco/carpet/ornate/purplegold
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/purplegoldcarpet.dmi'
	icon_state = "purplegoldcarpet-255"
	base_icon_state = "purplegoldcarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_PURPLE
	canSmoothWith = SMOOTH_GROUP_CARPET_PURPLE

/turf/open/floor/san_francisco/carpet/ornate/redsilver
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'modular_bandastation/san_francisco/icons/architecture/carpets/redsilvercarpet.dmi'
	icon_state = "redsilvercarpet-255"
	base_icon_state = "redsilvercarpet"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_RED
	canSmoothWith = SMOOTH_GROUP_CARPET_RED

/turf/open/floor/san_francisco/city/bacotell
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "bacotell1"
	base_icon_state = "bacotell"
	texture_prefix = "bacotell"
	texture_variants = 4
	desc = null


/turf/open/floor/san_francisco/city/church
	name = "fancy plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "church1"
	base_icon_state = "floor"
	texture_prefix = "church"
	texture_variants = 4
	desc = null


/turf/open/floor/san_francisco/city/circled
	name = "fancy plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "circle1"
	base_icon_state = "floor"
	texture_prefix = "circle"
	texture_variants = 8
	desc = null


/turf/open/floor/san_francisco/city/circled/large
	name = "fancy plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "circle_large"
	base_icon_state = "floor"
	texture_variants = 0
	desc = null


/turf/open/floor/san_francisco/city/clinic
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "clinic1"
	base_icon_state = "floor"
	texture_prefix = "clinic"
	texture_variants = 9
	desc = null


/turf/open/floor/san_francisco/city/factory
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "factory1"
	base_icon_state = "floor"
	texture_prefix = "factory"
	texture_variants = 9
	desc = null


/turf/open/floor/san_francisco/city/gummaguts
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "gummaguts"
	base_icon_state = "gummaguts"
	texture_prefix = "gummaguts"
	texture_variants = 4
	desc = null


/turf/open/floor/san_francisco/city/industrial
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "industrial1"
	base_icon_state = "floor"
	texture_prefix = "industrial"
	texture_variants = 9
	desc = null


/turf/open/floor/san_francisco/city/industrial/large
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "industrial_large1"
	base_icon_state = "floor"
	texture_prefix = "industrial_large"
	texture_variants = 9
	desc = null


/turf/open/floor/san_francisco/city/plating
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "plating"
	base_icon_state = "floor"
	desc = null


/turf/open/floor/san_francisco/city/plating_mono
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "plating-mono"
	base_icon_state = "floor"
	desc = null


/turf/open/floor/san_francisco/city/plating_stone
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "plating-stone"
	base_icon_state = "floor"
	desc = null


/turf/open/floor/san_francisco/city/saint
	name = "fancy plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "saint1"
	base_icon_state = "floor"
	texture_prefix = "saint"
	texture_variants = 2
	desc = null


/turf/open/floor/san_francisco/city/toilet
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "toilet1"
	base_icon_state = "floor"
	texture_prefix = "toilet"
	texture_variants = 9
	desc = null


/turf/open/floor/san_francisco/city/toilet/large
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "toilet_large1"
	base_icon_state = "floor"
	texture_prefix = "toilet_large"
	texture_variants = 9
	desc = null


/turf/open/floor/san_francisco/iron/stairs/black
	name = "floor"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "stairs_black"
	base_icon_state = "stairs_black"
	desc = null


/turf/open/floor/san_francisco/iron/stairs/black/left
	name = "floor"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "stairs_black-l"
	base_icon_state = "stairs_black-l"
	desc = null


/turf/open/floor/san_francisco/iron/stairs/black/medium
	name = "floor"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "stairs_black-m"
	base_icon_state = "stairs_black-m"
	desc = null


/turf/open/floor/san_francisco/iron/stairs/black/right
	name = "floor"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "stairs_black-r"
	base_icon_state = "stairs_black-r"
	desc = null


/turf/open/floor/san_francisco/plating/asphalt
	name = "asphalt"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "asphalt1"
	base_icon_state = "plating"
	texture_prefix = "asphalt"
	texture_variants = 3
	desc = null


/turf/open/floor/san_francisco/plating/canal
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "canal1"
	base_icon_state = "plating"
	texture_prefix = "canal"
	texture_variants = 3
	desc = null


/turf/open/floor/san_francisco/plating/canalplating
	name = "plating"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "canal_plating1"
	base_icon_state = "plating"
	texture_prefix = "canal_plating"
	texture_variants = 4
	desc = null


/turf/open/floor/san_francisco/plating/concrete
	name = "concrete"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "concrete1"
	base_icon_state = "plating"
	texture_prefix = "concrete"
	texture_variants = 4
	desc = null


/turf/open/floor/san_francisco/plating/granite
	name = "granite"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "granite"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/granite/black
	name = "granite"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "granite-black"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/grate
	name = "grate"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "lattice_new"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/grate/dirty
	name = "grate"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "lattice_new_dirt"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/roofwalk
	name = "roof"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "roof"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/roofwalk/cobblestones
	name = "cobblestones"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "roof"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/rough
	name = "rough floor"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "rough"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/rough/cave
	name = "rough floor"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "cave1"
	base_icon_state = "plating"
	texture_prefix = "cave"
	texture_variants = 7
	desc = null


/turf/open/floor/san_francisco/plating/sidewalk
	name = "sidewalk"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "sidewalk1"
	base_icon_state = "sidewalk"
	texture_prefix = "sidewalk"
	texture_variants = 3
	desc = null


/turf/open/floor/san_francisco/plating/sidewalk/old
	name = "sidewalk"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "sidewalk_old1"
	base_icon_state = "sidewalk_old"
	texture_prefix = "sidewalk_old"
	texture_variants = 4
	desc = null


/turf/open/floor/san_francisco/plating/sidewalk/poor
	name = "sidewalk"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "sidewalk_poor1"
	base_icon_state = "sidewalk_poor"
	texture_prefix = "sidewalk_poor"
	texture_variants = 3
	desc = null


/turf/open/floor/san_francisco/plating/sidewalk/rich
	name = "sidewalk"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "sidewalk_rich1"
	base_icon_state = "sidewalk_rich"
	texture_prefix = "sidewalk_rich"
	texture_variants = 6
	desc = null


/turf/open/floor/san_francisco/plating/sidewalkalt
	name = "sidewalk"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "sidewalk_alt"
	base_icon_state = "plating"
	desc = null


/turf/open/floor/san_francisco/plating/stone
	name = "rough floor"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "stone1"
	base_icon_state = "plating"
	texture_prefix = "stone"
	texture_variants = 7
	desc = null


/turf/open/floor/san_francisco/wood/herring
	name = "fancy wood flooring"
	desc = "Stylish wood."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "woodd1"
	base_icon_state = "woodd"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	texture_prefix = "woodd"
	texture_variants = 12

/turf/open/floor/san_francisco/wood/old
	name = "floor"
	desc = "Stylish wood."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "wood_old"
	base_icon_state = "floor"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT

/turf/open/floor/san_francisco/wood/ornate
	name = "floor"
	desc = "Stylish wood."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "wood_ornate"
	base_icon_state = "floor"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT

/turf/open/floor/san_francisco/wood/rough
	name = "wood flooring"
	desc = "Stylish wood."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "wood1"
	base_icon_state = "wood"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	texture_prefix = "wood"
	texture_variants = 12

/turf/open/floor/san_francisco/wood/smooth
	name = "floor"
	desc = "Stylish wood."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "wood_smooth"
	base_icon_state = "floor"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT

/turf/open/floor/san_francisco/wood/smooth/old
	name = "floor"
	desc = "Stylish wood."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "wood_smooth_old"
	base_icon_state = "floor"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT

/turf/open/floor/san_francisco/sand
	name = "sand"
	desc = "Sandy."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "sand1"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	texture_prefix = "sand"
	texture_variants = 4

/turf/open/floor/san_francisco/chinese_roof/red
	name = "chinese roof"
	desc = "report on GitHub please"
	icon = 'modular_bandastation/san_francisco/icons/architecture/chinese_roofs.dmi'
	icon_state = "cn_roof_red"

/turf/open/floor/san_francisco/rail_bed
	name = "rails"
	desc = "Upon closer examination, it's still dirt."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "dirt_rails"
	base_icon_state = "dirt"

/turf/open/water/san_francisco
	name = "bay water"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	fishing_datum = /datum/fish_source/river

/turf/open/water/san_francisco/acid
	name = "goop"
	desc = "highly acidic goop. Please dont stand in this."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "acid"
	immerse_overlay = "immerse"
	is_swimming_tile = FALSE
	light_color = "#1b7c4c"
	light_range = 1
	light_power = 0.5
	baseturfs = /turf/open/water/san_francisco/acid
	fishing_datum = null
	reagent_to_extract = /datum/reagent/toxin/acid

/turf/open/water/san_francisco/bay
	name = "ocean"
	desc = "Come on in, it's great!"
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "ocean"
	immerse_overlay = "immerse"
	is_swimming_tile = FALSE
	baseturfs = /turf/open/water/san_francisco/bay

/turf/open/water/san_francisco/bay/deep
	name = "deep water"
	desc = "Don't forget your life jacket."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "ocean"
	color = "#979797"
	immerse_overlay = "immerse_deep"
	is_swimming_tile = TRUE
	baseturfs = /turf/open/water/san_francisco/bay/deep

/turf/open/water/san_francisco/contaminated
	name = "blood"
	desc = "Shallow water."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "blood"
	immerse_overlay = "immerse_deep"
	is_swimming_tile = TRUE
	light_color = COLOR_MAROON
	light_range = 1
	light_power = 0.5
	baseturfs = /turf/open/water/san_francisco/contaminated
	fishing_datum = null
	reagent_to_extract = null

/turf/open/water/san_francisco/river
	name = "river"
	desc = "Shallow water."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "ocean"
	immerse_overlay = "immerse"
	is_swimming_tile = FALSE
	baseturfs = /turf/open/water/san_francisco/river

/turf/open/water/san_francisco/sewage
	name = "sewage"
	desc = "Shallow water."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "shit"
	immerse_overlay = "immerse"
	is_swimming_tile = FALSE
	baseturfs = /turf/open/water/san_francisco/sewage
	fishing_datum = null

/turf/open/water/san_francisco/sewage/border
	name = "sewage"
	desc = "Shallow water."
	icon = 'modular_bandastation/san_francisco/icons/architecture/floors.dmi'
	icon_state = "shit_border"
	immerse_overlay = "immerse"
	is_swimming_tile = FALSE
	baseturfs = /turf/open/water/san_francisco/sewage/border
	fishing_datum = null

// Industrial effluent uses ordinary burn/toxin damage; no World of Darkness damage or spreading flood logic.
/turf/open/water/san_francisco/acid/Entered(atom/movable/arrived, atom/oldloc, list/old_locs)
	. = ..()
	if(isliving(arrived))
		START_PROCESSING(SSobj, src)

/turf/open/water/san_francisco/acid/process(seconds_per_tick)
	var/has_occupants = FALSE
	for(var/mob/living/occupant in src)
		has_occupants = TRUE
		if(occupant.movement_type & FLYING || !HAS_TRAIT(occupant, TRAIT_IMMERSED))
			continue
		occupant.adjust_fire_loss(2 * seconds_per_tick)
		occupant.adjust_tox_loss(2 * seconds_per_tick)
	if(!has_occupants)
		return PROCESS_KILL

/turf/open/water/san_francisco/acid/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

// Upstream umbra tiles delimit the physical city. Keep them solid rather than exposing unbuilt levels.
/turf/closed/indestructible/san_francisco_void
	name = "nothing"
	desc = null
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	opacity = FALSE
	smoothing_flags = NONE

/turf/closed/indestructible/san_francisco_datawall
	name = "matrix"
	desc = "Suicide is no exit..."
	icon = 'modular_bandastation/san_francisco/icons/architecture/matrix.dmi'
	icon_state = "matrix"

/turf/open/misc/grass/san_francisco_plain
	smoothing_flags = NONE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	name = "grass"
	desc = "A patch of grass."
