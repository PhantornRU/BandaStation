#if defined(UNIT_TESTS) && defined(CITY_PORT_BUILD)

// Modular files are included after the upstream assertion macros have been cleaned up.
#define CITY_ASSERT(condition, message) if(!(condition)) { return Fail(message, __FILE__, __LINE__) }

/datum/unit_test/san_francisco
	abstract_type = /datum/unit_test/san_francisco
	test_flags = UNIT_TEST_MAP_TEST

/datum/unit_test/san_francisco/layout
	priority = TEST_PRE

/datum/unit_test/san_francisco/layout/Run()
	CITY_ASSERT(SSmapping.current_map.map_name == "San Francisco", "The direct-port tests loaded another map.")
	CITY_ASSERT(world.maxx >= 255 && world.maxy >= 255, "The original 255 by 255 map footprint was cropped.")
	var/list/city_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	CITY_ASSERT(length(city_levels) == 5, "The original city must contain all five levels.")
	for(var/index in 1 to length(city_levels))
		var/level = city_levels[index]
		var/turf/center = locate(128, 128, level)
		CITY_ASSERT(center, "City level [index] is missing.")
		if(index < length(city_levels))
			var/turf/above = get_step_multiz(center, UP)
			CITY_ASSERT(above && above.z == city_levels[index + 1], "City level [index] has an incorrect upward connection.")
		if(index > 1)
			var/turf/below = get_step_multiz(center, DOWN)
			CITY_ASSERT(below && below.z == city_levels[index - 1], "City level [index] has an incorrect downward connection.")
		var/found_floor = FALSE
		for(var/turf/open/floor/city_floor in Z_TURFS(level))
			if(istype(get_area(city_floor), /area/station/san_francisco))
				found_floor = TRUE
				break
		CITY_ASSERT(found_floor, "City level [index] has no playable city flooring.")
	for(var/area/station/san_francisco/district in GLOB.areas)
		if(district.has_contained_turfs())
			CITY_ASSERT(!district.requires_power, "[district.type] lost the donor's requires_power = FALSE setting.")
	// AI EDIT START - Catch imported off-grid collision that can suppress normal client gliding.
	var/checked_cars = 0
	for(var/obj/structure/san_francisco_parked_vehicle/city_car in world)
		if(!is_station_level(city_car.z))
			continue
		checked_cars++
		CITY_ASSERT(city_car.bound_width == ICON_SIZE_X && city_car.bound_height == ICON_SIZE_Y && city_car.bound_x == 0 && city_car.bound_y == 0, "[city_car.type] lost the donor's native tile collision at [AREACOORD(city_car)].")
		CITY_ASSERT(city_car.step_x == 0 && city_car.step_y == 0 && city_car.step_size == ICON_SIZE_X, "[city_car.type] enables pixel movement at [AREACOORD(city_car)].")
	CITY_ASSERT(checked_cars > 0, "No mapped parked cars were checked for native tile collision.")
	// AI EDIT END

/datum/unit_test/san_francisco/atmosphere/Run()
	var/checked = 0
	var/invalid = 0
	for(var/level in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/open/floor/city_floor in Z_TURFS(level))
			if(!istype(get_area(city_floor), /area/station/san_francisco))
				continue
			checked++
			if(!has_safe_air(city_floor))
				invalid++
				if(invalid <= 10)
					Fail("Unsafe city air at [AREACOORD(city_floor)] ([city_floor.type]).", __FILE__, __LINE__)
			CHECK_TICK
	CITY_ASSERT(checked > 0 && invalid == 0, "Unsafe floors: [invalid] of [checked] checked.")

/datum/unit_test/san_francisco/proc/has_safe_air(turf/open/city_floor)
	if(!istype(city_floor) || !city_floor.air)
		return FALSE
	var/datum/gas_mixture/air = city_floor.air
	if(air.volume <= 0 || (air.moles[/datum/gas/plasma] || 0) > 0.01 || (air.moles[/datum/gas/carbon_dioxide] || 0) > 0.5)
		return FALSE
	var/pressure = air.return_pressure()
	var/oxygen_pressure = (air.moles[/datum/gas/oxygen] || 0) * R_IDEAL_GAS_EQUATION * air.temperature / air.volume
	return pressure >= 80 && pressure <= 120 && oxygen_pressure >= 16 && oxygen_pressure <= 26 && air.temperature >= 280 && air.temperature <= 310

/datum/unit_test/san_francisco/spawns/Run()
	var/checked = 0
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(job.spawn_positions == 0)
			continue
		var/atom/spawn_point = job.get_default_roundstart_spawn_point()
		CITY_ASSERT(spawn_point, "Available job [job.title] has no city roundstart spawn.")
		check_spawn(get_turf(spawn_point), job.title)
		checked++
	CITY_ASSERT(checked > 0, "No available jobs were checked.")
	CITY_ASSERT(length(SSjob.latejoin_trackers) > 0, "There are no city latejoin destinations.")
	for(var/atom/latejoin as anything in SSjob.latejoin_trackers)
		check_spawn(get_turf(latejoin), "latejoin")

/datum/unit_test/san_francisco/proc/check_spawn(turf/open/spawn_turf, context)
	CITY_ASSERT(istype(spawn_turf) && !spawn_turf.density, "[context] is not on passable flooring.")
	CITY_ASSERT(!istype(spawn_turf, /turf/open/openspace) && !isspaceturf(spawn_turf), "[context] appears in a fall or vacuum at [AREACOORD(spawn_turf)].")
	CITY_ASSERT(istype(get_area(spawn_turf), /area/station/san_francisco) && is_station_level(spawn_turf.z), "[context] appears outside the primary city.")
	CITY_ASSERT(has_safe_air(spawn_turf), "[context] appears in unsafe air at [AREACOORD(spawn_turf)].")
	for(var/obj/blocker in spawn_turf)
		if(blocker.anchored && blocker.density && !(blocker.flags_1 & ON_BORDER_1))
			Fail("[context] is blocked by [blocker.type] at [AREACOORD(spawn_turf)].", __FILE__, __LINE__)

/datum/unit_test/san_francisco/doors/Run()
	var/mob/living/carbon/human/consistent/person = allocate(/mob/living/carbon/human/consistent)
	person.equipOutfit(/datum/outfit/job/assistant/consistent)
	var/obj/item/card/id/advanced/card = person.wear_id
	CITY_ASSERT(card, "The access-test character has no ID card.")
	var/turf/door_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/left_turf = get_step(door_turf, WEST)
	var/turf/right_turf = get_step(door_turf, EAST)
	var/left_density = left_turf.density
	var/right_density = right_turf.density
	for(var/door_type in typesof(/obj/machinery/door/san_francisco))
		var/obj/machinery/door/san_francisco/door = allocate(door_type, door_turf)
		door.req_access = list(ACCESS_MEDICAL)
		card.access = list()
		CITY_ASSERT(!door.try_to_activate_door(person) && door.density, "[door_type] accepted an ID without its required access.")
		card.access = list(ACCESS_MEDICAL)
		CITY_ASSERT(door.try_to_activate_door(person) && !door.density && !door.opacity, "[door_type] did not open with the required ID access.")
		CITY_ASSERT(icon_exists(door.icon, door.icon_state), "[door_type] has a missing open sprite [door.icon_state].")
		person.forceMove(door_turf)
		var/previous_health = person.health
		CITY_ASSERT(!door.close() && !door.density && person.health == previous_health, "[door_type] closed on or injured the person in its doorway.")
		person.forceMove(run_loc_floor_bottom_left)
		CITY_ASSERT(door.close() && door.density && door.opacity == initial(door.opacity), "[door_type] did not restore its original closed collision/opacity.")
		CITY_ASSERT(icon_exists(door.icon, door.icon_state), "[door_type] has a missing closed sprite [door.icon_state].")
		qdel(door)
		left_turf.set_density(left_density)
		right_turf.set_density(right_density)
	var/obj/machinery/door/airlock/san_francisco_elevator/elevator = allocate(/obj/machinery/door/airlock/san_francisco_elevator, door_turf)
	CITY_ASSERT(elevator.filler && length(elevator.locs) == 2, "The double elevator door lost its second collision tile.")
	CITY_ASSERT(elevator.open(BYPASS_DOOR_CHECKS) && !elevator.density && !elevator.filler.density, "The double elevator door did not open both tiles.")
	CITY_ASSERT(icon_exists(elevator.icon, elevator.icon_state), "The double elevator door has a missing open sprite.")
	CITY_ASSERT(elevator.close(BYPASS_DOOR_CHECKS) && elevator.density && elevator.filler.density, "The double elevator door did not close both tiles.")
	CITY_ASSERT(icon_exists(elevator.icon, elevator.icon_state), "The double elevator door has a missing closed sprite.")

// AI EDIT START - Exercise every mapped passage with a human, including outdoor terrain and rejected landings.
/datum/unit_test/san_francisco/passages/Run()
	var/list/city_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	CITY_ASSERT(length(city_levels) == 5, "Passage tests require all five city levels.")
	var/mob/living/carbon/human/consistent/person = allocate(/mob/living/carbon/human/consistent)
	var/checked = 0
	var/misc_landings = 0
	for(var/obj/structure/san_francisco_passage/passage in world)
		if(!is_station_level(passage.z))
			continue
		person.forceMove(run_loc_floor_bottom_left)
		var/turf/start
		for(var/direction in GLOB.cardinals)
			var/turf/candidate = get_step(passage, direction)
			if(isopenturf(candidate) && !isspaceturf(candidate) && !isopenspaceturf(candidate) && !candidate.is_blocked_turf())
				start = candidate
				break
		CITY_ASSERT(start, "Cannot approach passage at [AREACOORD(passage)].")
		CITY_ASSERT(isnum(passage.destination_level) && passage.destination_level >= 1 && passage.destination_level <= length(city_levels), "Passage at [AREACOORD(passage)] has no valid destination level.")
		var/turf/destination = locate(passage.destination_x, passage.destination_y, city_levels[passage.destination_level])
		var/obj/structure/san_francisco_passage/reverse = locate() in destination
		CITY_ASSERT(reverse, "Passage at [AREACOORD(passage)] has no paired return passage.")
		CITY_ASSERT(isnum(reverse.destination_level) && reverse.destination_level >= 1 && reverse.destination_level <= length(city_levels), "Return passage at [AREACOORD(reverse)] has no valid destination level.")
		CITY_ASSERT(reverse.destination_x == passage.x && reverse.destination_y == passage.y && city_levels[reverse.destination_level] == passage.z, "Passage at [AREACOORD(passage)] has an incorrect return destination.")
		person.forceMove(start)
		CITY_ASSERT(passage.use_passage(person), "A person could not use passage at [AREACOORD(passage)].")
		CITY_ASSERT(person.z == destination.z && get_dist(person, destination) == 1, "Passage at [AREACOORD(passage)] did not reach its paired exit.")
		CITY_ASSERT(has_safe_air(get_turf(person)), "Passage at [AREACOORD(passage)] landed in unsafe air.")
		if(istype(get_turf(person), /turf/open/misc))
			misc_landings++
		CITY_ASSERT(reverse.use_passage(person), "A person could not return from passage at [AREACOORD(reverse)].")
		CITY_ASSERT(person.z == passage.z && get_dist(person, passage) == 1, "Return passage at [AREACOORD(reverse)] reached an incorrect location.")
		CITY_ASSERT(has_safe_air(get_turf(person)), "Return passage at [AREACOORD(reverse)] landed in unsafe air.")
		checked++
	CITY_ASSERT(checked == 28, "Expected all 28 original passage endpoints; checked [checked].")
	CITY_ASSERT(misc_landings > 0, "No actual outdoor misc-terrain landing was exercised.")
	// The city's cordoned corner has no valid neighboring landing, and must leave the traveller in place.
	var/obj/structure/san_francisco_passage/blocked = allocate(/obj/structure/san_francisco_passage, run_loc_floor_bottom_left)
	blocked.destination_x = 1
	blocked.destination_y = 1
	blocked.destination_level = length(city_levels)
	var/turf/approach = get_step(run_loc_floor_bottom_left, EAST)
	person.forceMove(approach)
	CITY_ASSERT(!blocked.use_passage(person) && get_turf(person) == approach, "An invalid landing moved the traveller.")
// AI EDIT END

/// Check initialized visible appearances, including overlays, so dynamic sprite errors are not hidden by a static DMM audit.
/datum/unit_test/san_francisco/icons/Run()
	var/checked = 0
	var/invalid = 0
	var/list/audit = list(
		"file_states_checked" = 0,
		"dynamic_icons_skipped" = 0,
		"known_native_empty_overlays_skipped" = 0,
		"reported" = 0,
		"missing" = list(),
		"info" = list("known_native_empty_overlays" = list()),
	)
	for(var/level in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/city_turf in Z_TURFS(level))
			if(!istype(get_area(city_turf), /area/station/san_francisco))
				continue
			var/list/atoms = list(city_turf)
			atoms += city_turf.contents
			for(var/atom/thing as anything in atoms)
				if(thing.invisibility || thing.alpha <= 0)
					continue
				checked++
				invalid += check_sprite(thing.appearance, "[thing.type] at [AREACOORD(thing)]", audit, thing)
			CHECK_TICK
	audit["checked_atoms"] = checked
	audit["missing_file_states"] = invalid
	WRITE_FILE(file("data/city-icon-audit.json"), json_encode(audit))
	CITY_ASSERT(checked > 0 && invalid == 0, "Missing visible sprite states: [invalid] in [checked] initialized city appearances; the first twenty are reported.")

/datum/unit_test/san_francisco/proc/check_sprite(mutable_appearance/sprite, context, list/audit, atom/owner, is_overlay = FALSE)
	var/invalid = 0
	if(sprite.icon && length(sprite.icon_state))
		// As in get_icon_dimensions(), an unnamed runtime icon is not a file-backed DMI.
		// Bodypart/GAGS rendering retains the original icon_state after constructing a flattened /icon.
		if(!isfile(sprite.icon) || !length("[sprite.icon]"))
			audit["dynamic_icons_skipped"]++
		else
			audit["file_states_checked"]++
			if(!icon_exists(sprite.icon, sprite.icon_state))
				if(is_overlay && is_known_native_empty_overlay(sprite, owner))
					audit["known_native_empty_overlays_skipped"]++
					var/list/info = audit["info"]
					var/list/known_empty = info["known_native_empty_overlays"]
					known_empty += list(list("icon" = "[sprite.icon]", "state" = sprite.icon_state, "context" = context, "reason" = "Inherited optional empty child layer; donor and target resources are identical."))
				else
					invalid++
					var/list/missing = audit["missing"]
					missing += list(list("icon" = "[sprite.icon]", "state" = sprite.icon_state, "context" = context))
					if(audit["reported"] < 20)
						audit["reported"]++
						Fail("Missing sprite '[sprite.icon]' state '[sprite.icon_state]' on [context].", __FILE__, __LINE__)
	for(var/mutable_appearance/overlay as anything in sprite.overlays)
		invalid += check_sprite(overlay, context, audit, owner, TRUE)
	for(var/mutable_appearance/underlay as anything in sprite.underlays)
		invalid += check_sprite(underlay, context, audit, owner, FALSE)
	return invalid

/datum/unit_test/san_francisco/proc/is_known_native_empty_overlay(mutable_appearance/sprite, atom/owner)
	// Native blood.dm and blood.dmi blobs are identical in donor and target; these two optional states are absent in both.
	if(sprite.icon == 'icons/effects/blood.dmi' && (sprite.icon_state in list("gib3-overlay", "gib5-overlay")))
		return owner.type in list(/obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/up, /obj/effect/decal/cleanable/blood/gibs/down)
	if(sprite.icon == 'icons/effects/blood.dmi' && sprite.icon_state == "gibmid3-overlay")
		return owner.type == /obj/effect/decal/cleanable/blood/gibs/core
	// Filling sheet blob c60fa1c7d30fdb85b2b40ad6f4d5dd8fcd9673bc is shared unchanged.
	// These full-container layers are empty in both projects; icon_state, fill thresholds and volumes were compared per type.
	if(sprite.icon == 'icons/obj/medical/reagent_fillings.dmi')
		var/static/list/native_fill_owners = list(
			"beer90" = list(/obj/item/reagent_containers/cup/glass/bottle/beer),
			"winebottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/wine, /obj/item/reagent_containers/cup/glass/bottle/wine/unlabeled),
			"whiskeybottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/whiskey),
			"vodkabottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/vodka),
			"maltliquorbottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/maltliquor),
			"champagne_bottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/champagne),
			"curacao_bottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/curacao),
			"cognacbottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/cognac),
			"rumbottle_gold90" = list(/obj/item/reagent_containers/cup/glass/bottle/rum/aged),
			"herbal_liqueur_bottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/herbal_liqueur),
			"aperitivo_bottle90" = list(/obj/item/reagent_containers/cup/glass/bottle/aperitivo),
			"hotsauce100" = list(/obj/item/reagent_containers/condiment/hotsauce),
			"bbqsauce100" = list(/obj/item/reagent_containers/condiment/bbqsauce),
			"beer_blue90" = list(/obj/item/san_francisco_compat/item_reagent_containers_cup_glass_bottle_beer_vampire_blue_stripe),
		)
		var/list/allowed_owners = native_fill_owners[sprite.icon_state]
		return islist(allowed_owners) && (owner.type in allowed_owners)
	return FALSE

#undef CITY_ASSERT
#endif
