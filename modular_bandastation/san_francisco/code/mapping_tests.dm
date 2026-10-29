#if defined(UNIT_TESTS)

/// An absent object must not shift breathable-air edits from its following turf onto an area.
/datum/unit_test/san_francisco_tgm_attribute_alignment/Run()
	var/datum/parsed_map/parsed = allocate(/datum/parsed_map)
	parsed.parsed_bounds = list()
	parsed.bounds = list()
	parsed.grid_models["a"] = "/obj/missing_tgm_alignment_test_type,\n/turf/open/floor/plating{\n\tinitial_gas_mix = \"o2=21;n2=79;TEMP=293.15\"\n\t},\n/area/station"
	parsed.grid_models["b"] = "/obj/missing_tgm_alignment_test_type{\n\tname = \"discarded variables\"\n\t},\n/obj/item/paper{\n\tname = \"kept note\"\n\t},\n/turf/open/floor/plating{\n\tinitial_gas_mix = \"o2=21;n2=79;TEMP=293.15\"\n\t},\n/area/station"
	var/list/bad_paths = list()
	var/list/cache = parsed.tgm_build_cache(FALSE, bad_paths)
	var/list/plain_model = cache["a"]
	var/list/plain_members = plain_model[1]
	var/list/plain_attributes = plain_model[2]
	TEST_ASSERT_EQUAL(plain_members.len, 2, "The nonexistent object was not skipped.")
	TEST_ASSERT_EQUAL(plain_attributes.len, plain_members.len, "Skipping an unknown object misaligned TGM attributes.")
	TEST_ASSERT_EQUAL(plain_members[1], /turf/open/floor/plating, "The valid turf was lost.")
	var/list/turf_attributes = plain_attributes[1]
	TEST_ASSERT_EQUAL(turf_attributes["initial_gas_mix"], "o2=21;n2=79;TEMP=293.15", "The turf lost its atmospheric overrides.")
	TEST_ASSERT_EQUAL(plain_attributes[2], GLOB.map_model_default, "Turf overrides leaked onto the following area.")

	var/list/edited_model = cache["b"]
	var/list/edited_members = edited_model[1]
	var/list/edited_attributes = edited_model[2]
	TEST_ASSERT_EQUAL(edited_members.len, 3, "The valid paper, turf and area were not retained.")
	TEST_ASSERT_EQUAL(edited_attributes.len, edited_members.len, "An unknown object with variable edits misaligned TGM attributes.")
	var/list/paper_attributes = edited_attributes[1]
	TEST_ASSERT_EQUAL(paper_attributes["name"], "kept note", "Variables from a missing object overwrote the following object.")
	turf_attributes = edited_attributes[2]
	TEST_ASSERT_EQUAL(turf_attributes["initial_gas_mix"], "o2=21;n2=79;TEMP=293.15", "The edited-object case lost the turf atmosphere.")
	TEST_ASSERT_EQUAL(edited_attributes[3], GLOB.map_model_default, "Variables leaked onto the area after an edited missing object.")
	var/list/reported_models = bad_paths["/obj/missing_tgm_alignment_test_type"]
	TEST_ASSERT_EQUAL(length(reported_models), 2, "The parser stopped reporting invalid paths in both models.")

#endif
