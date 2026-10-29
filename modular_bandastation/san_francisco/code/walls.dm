// Facade appearances adapted from Crimson Grid; construction and damage use BandaStation walls.
/obj/effect/san_francisco_wall_frill
	name = "wall frill"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	desc = "Hey how are you reading this."


/obj/effect/san_francisco_wall_frill/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_DEFAULT, perimeter_reset_timer = 24 HOURS)
	update_seethrough()

/obj/effect/san_francisco_wall_frill/proc/update_seethrough()
	var/turf/facade_turf = get_turf(src)
	var/datum/component/seethrough/transparency = GetComponent(/datum/component/seethrough)
	if(!transparency)
		return
	if(facade_turf.density)
		transparency.dismantle_perimeter()
	else if(!length(transparency.watched_turfs))
		transparency.setup_perimeter(src)

/turf/closed/wall/san_francisco
	parent_type = /turf/closed/wall/concrete
	name = "old brick wall"
	desc = "A huge chunk of old bricks used to separate rooms."
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_CONCRETE_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CONCRETE_WALLS
	baseturfs = /turf/open/floor/san_francisco/plating/concrete
	var/frill_icon
	var/obj/effect/san_francisco_wall_frill/wall_frill

/turf/closed/wall/san_francisco/set_smoothed_icon_state(new_junction)
	. = ..()
	var/hidden_junctions = NORTH_JUNCTION | EAST_JUNCTION | WEST_JUNCTION | NORTHWEST_JUNCTION | NORTHEAST_JUNCTION
	if((new_junction & hidden_junctions) == hidden_junctions)
		QDEL_NULL(wall_frill)
		return
	if(!wall_frill)
		var/turf/north = get_step(src, NORTH)
		if(!north || !frill_icon)
			return
		wall_frill = new(north)
		wall_frill.icon = frill_icon
		wall_frill.name = name
		wall_frill.desc = desc
	wall_frill.icon_state = icon_state
	wall_frill.update_seethrough()

/turf/closed/wall/san_francisco/Destroy()
	QDEL_NULL(wall_frill)
	return ..()

/turf/closed/wall/san_francisco/bar
	name = "dark brick wall"
	desc = "A huge chunk of bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/bar/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/bar/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/brick
	name = "brick wall"
	desc = "A huge chunk of bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/brick_old
	name = "old brick wall"
	desc = "A huge chunk of old bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick_old/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick_old/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/city
	name = "wall"
	desc = "A huge chunk of concrete and bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/city/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/city/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/green
	name = "green wall"
	desc = "A huge chunk of green metal used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/green/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/green/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/junk
	name = "junk brick wall"
	desc = "A huge chunk of dirty bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/junk/alt
	name = "junk brick wall"
	desc = "A huge chunk of dirty bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk_alt/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk_alt/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/market
	name = "concrete wall"
	desc = "A huge chunk of concrete used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/market/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/market/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/metal
	name = "metal wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/metal/alt
	name = "metal wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal_alt/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal_alt/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/metal/glass
	name = "metal wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal_glass/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal_glass/frill.dmi'
	opacity = FALSE

/turf/closed/wall/san_francisco/metal/reinforced
	name = "reinforced metal wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal_reinforced/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/metal_reinforced/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/old
	name = "old brick wall"
	desc = "A huge chunk of old bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/old/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/old/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/painted
	name = "painted brick wall"
	desc = "A huge chunk of painted bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/painted/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/painted/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/redbrick
	name = "red brick wall"
	desc = "A huge chunk of red bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/red_brick/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/red_brick/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/rich
	name = "rich-looking wall"
	desc = "A huge chunk of expensive bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/rich/old
	name = "old rich-looking wall"
	desc = "A huge chunk of old bricks used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich_old/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich_old/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/rock
	name = "rock wall"
	desc = "A huge chunk of rocks separating whole territory."
	icon = 'modular_bandastation/san_francisco/icons/architecture/rock_wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rock/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/rust
	name = "rusty wall"
	desc = "A huge chunk of rusty metal used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rust/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rust/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/rustbad
	name = "rusty wall"
	desc = "A huge chunk of rusty metal used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rustbad/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rustbad/frill.dmi'
	opacity = TRUE

/turf/closed/wall/san_francisco/wood
	name = "wood wall"
	desc = "A huge chunk of dirty logs used to separate rooms."
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/wood/wall.dmi'
	frill_icon = 'modular_bandastation/san_francisco/icons/architecture/walls/wood/frill.dmi'
	opacity = TRUE

// Low city facades retain native platform climbing, damage and deconstruction.
/obj/structure/platform/san_francisco
	// AI EDIT START - This iconless template is not a concrete low wall
	abstract_type = /obj/structure/platform/san_francisco
	// AI EDIT END
	name = "low wall"
	desc = "It's a lot like a wall, but lower."
	icon_state = "wall-0"
	base_icon_state = "wall"
	frame_icon = null
	max_integrity = 350
	smoothing_groups = SMOOTH_GROUP_PLATFORMS
	canSmoothWith = SMOOTH_GROUP_PLATFORMS
	var/window_type

/obj/structure/platform/san_francisco/Initialize(mapload)
	. = ..()
	if(window_type)
		new window_type(loc)

/obj/structure/platform/san_francisco/bar
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/bar/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/bar/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/bar/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/brick
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/brick/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/brick_old
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick_old/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/brick_old/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/brick_old/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/city
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/city/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/city/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/city/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


// AI EDIT START - Give the implicit junk-wall parent its donor atlas
/obj/structure/platform/san_francisco/junk
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk/low_wall.dmi'
// AI EDIT END

/obj/structure/platform/san_francisco/junk/alt
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk_alt/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/junk/alt/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk_alt/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/junk/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/junk/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/market
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/market/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/market/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/market/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/market/window/reinforced
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/market/low_wall.dmi'
	window_type = /obj/structure/window/reinforced/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/old
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/old/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/old/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/old/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/old/window/reinforced
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/old/low_wall.dmi'
	window_type = /obj/structure/window/reinforced/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/painted
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/painted/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/painted/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/painted/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/painted/window/reinforced
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/painted/low_wall.dmi'
	window_type = /obj/structure/window/reinforced/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/rich
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/rich/old
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich_old/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/rich/old/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich_old/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/rich/old/window/reinforced
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich_old/low_wall.dmi'
	window_type = /obj/structure/window/reinforced/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/rich/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/rich/window/reinforced
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/rich/low_wall.dmi'
	window_type = /obj/structure/window/reinforced/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/wood
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/wood/low_wall.dmi'
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/wood/window
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/wood/low_wall.dmi'
	window_type = /obj/structure/window/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."


/obj/structure/platform/san_francisco/wood/window/reinforced
	icon = 'modular_bandastation/san_francisco/icons/architecture/walls/wood/low_wall.dmi'
	window_type = /obj/structure/window/reinforced/fulltile
	name = "low wall"
	desc = "It's a lot like a wall, but lower."
