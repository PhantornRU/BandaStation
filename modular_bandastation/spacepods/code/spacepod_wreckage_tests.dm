/datum/unit_test/spacepod_vacuum/proc/get_wreckage()
	var/list/debris = list()
	for(var/turf/tile as anything in vacuum_block.reserved_turfs)
		for(var/obj/effect/decal/remains/robot/spacepod/fragment in tile)
			if(!QDELETED(fragment))
				debris += fragment
	return debris

/// Real blast processing must leave floating debris; cleanup and repeated callbacks must not create it.
/datum/unit_test/spacepod_vacuum/wreckage/Run()
	TEST_ASSERT_NOTNULL(vacuum_origin, "Could not reserve open space for the wreckage test.")
	var/obj/vehicle/sealed/spacepod/civilian/pod = allocate(__IMPLIED_TYPE__, vacuum_origin)
	qdel(pod)
	sleep(1 TICKS)
	TEST_ASSERT_EQUAL(length(get_wreckage()), 0, "Administrative deletion created explosion wreckage.")
	pod = allocate(/obj/vehicle/sealed/spacepod/civilian, vacuum_origin)
	var/list/turf/footprint = pod.locs.Copy()
	var/explosions_before = SSexplosions.explosion_index
	explosion(vacuum_origin, devastation_range = 1, adminlog = FALSE, silent = TRUE)
	var/deadline = world.time + 6 SECONDS
	var/list/debris
	while(world.time < deadline)
		debris = get_wreckage()
		if(QDELETED(pod) && !SSexplosions.is_exploding() && length(debris) == 4)
			break
		stoplag(1)
	allocated |= debris
	TEST_ASSERT(QDELETED(pod), "The real devastating explosion did not destroy the cabin.")
	TEST_ASSERT(!SSexplosions.is_exploding(), "The real wreckage test blast did not drain its native queue.")
	TEST_ASSERT_EQUAL(SSexplosions.explosion_index, explosions_before + 1, "External devastation triggered an additional pod core blast.")
	TEST_ASSERT_EQUAL(length(debris), 4, "The destroyed 2x2 cabin must leave exactly four pieces of mechanical debris.")
	for(var/obj/effect/decal/remains/robot/spacepod/fragment as anything in debris)
		TEST_ASSERT(fragment.loc in footprint, "A debris fragment appeared outside the destroyed cabin's footprint.")
		TEST_ASSERT_EQUAL(fragment.icon_state, "remainsrobot", "Mechanical wreckage does not use the native robot-debris sprite.")
		TEST_ASSERT(fragment.icon_state in icon_states(fragment.icon), "The wreckage sprite is missing.")
		TEST_ASSERT_EQUAL(fragment.plane, GAME_PLANE, "Floating wreckage is hidden in the floor plane.")
	pod.ex_act(EXPLODE_DEVASTATE)
	pod.detonate()
	sleep(1 TICKS)
	TEST_ASSERT_EQUAL(length(get_wreckage()), 4, "Repeated destruction callbacks duplicated the debris.")
	TEST_ASSERT_EQUAL(SSexplosions.explosion_index, explosions_before + 1, "A deleted cabin detonated again.")
	var/obj/vehicle/sealed/spacepod/nullspace_pod = allocate(__IMPLIED_TYPE__, vacuum_origin)
	nullspace_pod.moveToNullspace()
	nullspace_pod.ex_act(EXPLODE_DEVASTATE)
	sleep(1 TICKS)
	TEST_ASSERT(QDELETED(nullspace_pod), "A devastating hit did not dispose of a cabin without a turf.")
	TEST_ASSERT_EQUAL(length(get_wreckage()), 4, "A cabin without a turf spawned stray debris.")
