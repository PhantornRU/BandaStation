/obj/structure/san_francisco_passage
	name = "transfer point"
	desc = ""
	icon = 'modular_bandastation/san_francisco/icons/passages/transfer_point.dmi'
	icon_state = "matrix_go"
	anchored = TRUE
	density = TRUE
	var/destination_x
	var/destination_y
	/// One-based position in the city's five station Z levels, independent of CentCom offsets.
	var/destination_level

/obj/structure/san_francisco_passage/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!. && user.Adjacent(src))
		use_passage(user)

/obj/structure/san_francisco_passage/Bumped(atom/movable/arrived)
	. = ..()
	if(isliving(arrived))
		use_passage(arrived)

/obj/structure/san_francisco_passage/proc/use_passage(mob/living/traveller)
	if(QDELETED(traveller) || !traveller.Adjacent(src) || traveller.anchored || !(traveller.mobility_flags & MOBILITY_MOVE) || !traveller.can_perform_action(src, FORBID_TELEKINESIS_REACH|SILENT_ADJACENCY))
		return
	var/list/city_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!isnum(destination_level) || destination_level != round(destination_level) || destination_level < 1 || destination_level > length(city_levels))
		return
	var/turf/destination = locate(destination_x, destination_y, city_levels[destination_level])
	if(!destination)
		return
	for(var/direction in GLOB.cardinals)
		var/turf/landing = get_step(destination, direction)
		// AI EDIT START - Allow the donor's solid outdoor terrain without landing in space or a fall.
		if(!isopenturf(landing) || isspaceturf(landing) || isopenspaceturf(landing) || landing.is_blocked_turf())
			continue
		// AI EDIT END
		return traveller.zMove(target = landing, z_move_flags = ZMOVE_INCLUDE_PULLED|ZMOVE_CHECK_PULLS)
	balloon_alert(traveller, "проход загромождён")
	return FALSE

/obj/structure/san_francisco_passage/stairs
	name = "stairs"
	icon = 'modular_bandastation/san_francisco/icons/passages/stairs.dmi'
	icon_state = "stairs"
