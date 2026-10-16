/// Exercises native landmark registration/movement/Destroy against the gated Prisoner getters.
/// The reservation is a controlled fixture, not evidence of production DMM placement.
/datum/unit_test/donor_prisoner_override_lifecycle
	var/list/starts_before
	var/list/overrides_before
	var/list/prisoner_starts_before
	var/list/areas_before = list()
	var/list/created_points = list()
	var/datum/space_level/test_level
	var/list/level_traits_before
	var/list/station_levels_before
	var/list/station_cache_before
	var/gate_before

/datum/unit_test/donor_prisoner_override_lifecycle/Run()
	starts_before = GLOB.start_landmarks_list
	overrides_before = GLOB.jobspawn_overrides
	prisoner_starts_before = GLOB.donor_prisoner_starts
	gate_before = CONFIG_GET(flag/donor_prisoner_gate)
	GLOB.start_landmarks_list = list()
	GLOB.jobspawn_overrides = list()
	GLOB.donor_prisoner_starts = list()
	CONFIG_SET(flag/donor_prisoner_gate, TRUE)

	var/datum/job/prisoner/job = allocate(/datum/job/prisoner)
	job.random_spawns_possible = FALSE
	var/turf/ordinary_turf = run_loc_floor_bottom_left
	var/turf/override_turf = get_step(ordinary_turf, EAST)
	var/turf/moved_turf = get_step(ordinary_turf, NORTH)
	var/turf/outside_prison = get_step(override_turf, EAST)
	TEST_ASSERT(!istype(get_area(outside_prison), /area/station/security/prison), "The negative fixture must be outside the prison")
	test_level = SSmapping.z_list[ordinary_turf.z]
	level_traits_before = test_level.traits
	station_levels_before = SSmapping.z_trait_levels[ZTRAIT_STATION]
	station_cache_before = GLOB.station_levels_cache
	test_level.traits = test_level.traits.Copy()
	test_level.traits[ZTRAIT_STATION] = TRUE
	SSmapping.z_trait_levels[ZTRAIT_STATION] = SSmapping.levels_by_trait(ZTRAIT_STATION) | list(ordinary_turf.z)
	GLOB.station_levels_cache = list()
	var/area/prison = GLOB.areas_by_type[/area/station/security/prison]
	if(!prison)
		prison = new /area/station/security/prison
		allocated += prison
	for(var/turf/location as anything in list(ordinary_turf, override_turf, moved_turf))
		areas_before[location] = get_area(location)
		location.change_area(get_area(location), prison)
		TEST_ASSERT(!location.is_blocked_turf(TRUE), "The positive prison fixture is blocked")

	var/obj/effect/landmark/start/prisoner/ordinary_point = allocate(/obj/effect/landmark/start/prisoner, ordinary_turf)
	created_points += ordinary_point
	TEST_ASSERT_EQUAL(job.get_latejoin_spawn_point(), ordinary_turf, "An ordinary mapped start was not available")
	TEST_ASSERT(ordinary_point.delete_after_roundstart, "The fixture no longer represents a normal roundstart landmark")
	// after_round_start intentionally skips qdel in UNIT_TESTS; call the same native Destroy path.
	qdel(ordinary_point)
	TEST_ASSERT(!(ordinary_point in GLOB.start_landmarks_list), "Native Destroy retained the ordinary landmark")
	TEST_ASSERT_EQUAL(job.get_latejoin_spawn_point(), ordinary_turf, "Normal roundstart cleanup lost the latejoin turf cache")

	var/obj/effect/landmark/start/prisoner/latejoin/override_point = allocate(/obj/effect/landmark/start/prisoner/latejoin, override_turf)
	created_points += override_point
	TEST_ASSERT(!override_point.delete_after_roundstart, "The override would disappear after roundstart")
	TEST_ASSERT(override_point in GLOB.jobspawn_overrides[job.title], "Native Initialize did not register the override")
	var/list/locations = job.get_safe_prisoner_turfs()
	TEST_ASSERT_EQUAL(length(locations), 1, "An active override was mixed with an ordinary cached start")
	TEST_ASSERT(override_turf in locations, "The mapped override turf is missing")
	TEST_ASSERT_EQUAL(job.get_roundstart_spawn_point(), override_turf, "Gated roundstart did not prioritize the override")
	TEST_ASSERT_EQUAL(job.get_latejoin_spawn_point(), override_turf, "Gated latejoin did not prioritize the override")

	override_point.forceMove(moved_turf)
	locations = job.get_safe_prisoner_turfs()
	TEST_ASSERT_EQUAL(length(locations), 1, "Moving an override retained a stale turf or an ordinary fallback")
	TEST_ASSERT(moved_turf in locations, "Override selection did not read the live landmark location")
	TEST_ASSERT_EQUAL(job.get_latejoin_spawn_point(), moved_turf, "Latejoin ignored the moved native override")

	override_point.forceMove(outside_prison)
	TEST_ASSERT_EQUAL(length(job.get_safe_prisoner_turfs()), 0, "An unsafe active override fell back to the safe ordinary start")
	TEST_ASSERT_NULL(job.get_roundstart_spawn_point(), "Unsafe active overrides did not deny gated roundstart")
	TEST_ASSERT_NULL(job.get_latejoin_spawn_point(), "Unsafe active overrides did not deny gated latejoin")
	CONFIG_SET(flag/donor_prisoner_gate, FALSE)
	TEST_ASSERT_EQUAL(job.get_roundstart_spawn_point(), override_point, "Gate OFF changed native roundstart override behavior")
	TEST_ASSERT_EQUAL(job.get_latejoin_spawn_point(), override_point, "Gate OFF changed native latejoin override behavior")
	CONFIG_SET(flag/donor_prisoner_gate, TRUE)

	override_point.forceMove(override_turf)
	qdel(override_point)
	TEST_ASSERT(!length(GLOB.jobspawn_overrides?[job.title]), "Native Destroy retained the deleted override")
	locations = job.get_safe_prisoner_turfs()
	TEST_ASSERT_EQUAL(length(locations), 1, "Deleting the override retained its cached turf")
	TEST_ASSERT(ordinary_turf in locations, "Removing all overrides did not restore the ordinary cached start")
	TEST_ASSERT_EQUAL(job.get_roundstart_spawn_point(), ordinary_turf, "Gated roundstart did not restore ordinary starts")
	TEST_ASSERT_EQUAL(job.get_latejoin_spawn_point(), ordinary_turf, "Gated latejoin did not restore ordinary starts")

/datum/unit_test/donor_prisoner_override_lifecycle/Destroy()
	// Destroy our landmarks while the isolated registries still own them.
	QDEL_LIST(created_points)
	for(var/turf/location as anything in areas_before)
		location.change_area(get_area(location), areas_before[location])
	if(test_level)
		test_level.traits = level_traits_before
		SSmapping.z_trait_levels[ZTRAIT_STATION] = station_levels_before
		GLOB.station_levels_cache = station_cache_before
	GLOB.start_landmarks_list = starts_before
	GLOB.jobspawn_overrides = overrides_before
	GLOB.donor_prisoner_starts = prisoner_starts_before
	if(!isnull(gate_before))
		CONFIG_SET(flag/donor_prisoner_gate, gate_before)
	return ..()
