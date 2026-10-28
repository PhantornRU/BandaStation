/// Ensures wallmouted objects prioritize walls over other mountable objects like tables
/datum/unit_test/wallmount

/datum/unit_test/wallmount/Run()
	//Test 1 light must priotize wall and not table
	var/obj/structure/table/test_table = EASY_ALLOCATE()
	var/obj/machinery/light/directional/south/test_light = EASY_ALLOCATE()
	test_light.find_and_mount_on_atom()

	var/datum/component/atom_mounted/wallmount_component = test_light.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_NOTNULL(wallmount_component, "[test_light.type] failed to mount")
	TEST_ASSERT_NOTEQUAL(wallmount_component.hanging_support_atom, test_table, "[test_light.type] failed to mount on wall!")

	//Test 2 button must mount on table not wall
	var/obj/machinery/button/test_button = EASY_ALLOCATE()
	test_button.find_and_mount_on_atom()

	wallmount_component = test_button.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_NOTNULL(wallmount_component, "[test_button.type] 0 offsets failed to mount!")
	TEST_ASSERT_EQUAL(wallmount_component.hanging_support_atom, test_table, "[test_button.type] 0 offsets failed to mount on table!")

	//Test 3 button must mount on wall not table because it now uses offsets
	test_button = allocate(/obj/machinery/button, run_loc_floor_top_right)
	test_button.pixel_y = 24
	test_button.find_and_mount_on_atom()

	wallmount_component = test_button.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_NOTNULL(wallmount_component, "[test_button.type] 24y offsets failed to mount!")
	TEST_ASSERT(isindestructiblewall(wallmount_component.hanging_support_atom), "[test_button.type] 24y offsets failed to mount on wall!")

// BANDASTATION ADDITION START - Runtime light deconstruction must preserve mapping diagnostics
/datum/unit_test/wallmount_light_deconstruction
	var/datum/space_level/test_level
	var/list/original_level_traits
	var/mapload_log_index
	var/expected_mapload_log

/datum/unit_test/wallmount_light_deconstruction/Run()
	// log_mapping only collects station/mining diagnostics, so temporarily enable the uncached mining trait.
	test_level = SSmapping.get_level(run_loc_floor_bottom_left.z)
	original_level_traits = test_level.traits
	test_level.traits = original_level_traits.Copy()
	test_level.traits[ZTRAIT_MINING] = TRUE
	var/turf/light_turf = run_loc_floor_bottom_left
	var/turf/support_turf = get_step(light_turf, EAST)
	var/obj/structure/window/reinforced/shuttle/support = allocate(/obj/structure/window/reinforced/shuttle, support_turf)
	var/obj/machinery/light/small/directional/east/fixture = allocate(/obj/machinery/light/small/directional/east, light_turf)
	TEST_ASSERT(fixture.find_and_mount_on_atom(), "The light could not mount on its intact window.")
	var/datum/component/atom_mounted/mount = fixture.GetComponent(/datum/component/atom_mounted)
	TEST_ASSERT_EQUAL(mount?.hanging_support_atom, support, "The light did not use the window as its support.")
	var/log_count = length(GLOB.unit_test_mapping_logs)

	qdel(support)
	TEST_ASSERT(QDELETED(fixture), "Deleting the support did not deconstruct the mounted light.")
	var/obj/structure/light_construct/small/frame = locate() in light_turf
	TEST_ASSERT_NOTNULL(frame, "Support removal did not leave a small light frame.")
	TEST_ASSERT_EQUAL(length(GLOB.unit_test_mapping_logs), log_count, "Ordinary support removal was reported as a mapping error.")

	TEST_ASSERT(!frame.find_and_mount_on_atom(mark_for_late_init = TRUE), "The unsupported frame unexpectedly found a mount.")
	TEST_ASSERT_EQUAL(length(GLOB.unit_test_mapping_logs), log_count, "The first mapload pass did not defer its diagnostic.")
	var/report_expected = PERFORM_ALL_TESTS(maptest_log_mapping)
	if(report_expected)
		mapload_log_index = log_count + 1
		var/area/location = get_area(frame)
		expected_mapload_log = "[frame.type] Could not find attachable object at [location.type] ([support_turf.x],[support_turf.y],[support_turf.z]) "
	TEST_ASSERT(!frame.find_and_mount_on_atom(late_init = TRUE), "The late mapload pass unexpectedly found a mount.")
	TEST_ASSERT_EQUAL(length(GLOB.unit_test_mapping_logs), log_count + report_expected, "The final mapload pass lost its missing-support diagnostic.")
	if(report_expected)
		TEST_ASSERT_EQUAL(GLOB.unit_test_mapping_logs[mapload_log_index], expected_mapload_log, "The mapload diagnostic did not identify the unsupported frame and its missing support.")

/datum/unit_test/wallmount_light_deconstruction/Destroy()
	if(test_level)
		test_level.traits = original_level_traits
		test_level = null
	original_level_traits = null
	if(mapload_log_index && length(GLOB.unit_test_mapping_logs) >= mapload_log_index && GLOB.unit_test_mapping_logs[mapload_log_index] == expected_mapload_log)
		GLOB.unit_test_mapping_logs.Cut(mapload_log_index, mapload_log_index + 1)
	return ..()
// BANDASTATION ADDITION END
