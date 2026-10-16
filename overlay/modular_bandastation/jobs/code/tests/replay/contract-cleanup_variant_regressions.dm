/datum/unit_test/job_variant_legacy_save_migration/Run()
	var/datum/preference/job_outfit_variants/preference = new
	var/converted = 0
	for(var/job_title in GLOB.legacy_job_variant_ids)
		var/list/legacy_ids = GLOB.legacy_job_variant_ids[job_title]
		for(var/old_id in legacy_ids)
			var/new_id = legacy_ids[old_id]
			var/list/legacy = list()
			legacy[job_title] = old_id
			var/list/restored = preference.deserialize(legacy)
			TEST_ASSERT_EQUAL(restored[job_title], new_id, "Legacy ID must restore the same job-scoped variant")
			var/list/roundtrip = preference.deserialize(preference.serialize(restored))
			TEST_ASSERT_EQUAL(roundtrip[job_title], new_id, "Semantic ID must survive save/load without a second conversion")
			converted++
	TEST_ASSERT_EQUAL(converted, 129, "Every previously declared non-default ID needs a migration")
	var/list/unknown = preference.deserialize(list("Future Job" = "title_fa2ad154cb", "Acolyte" = "future_id"))
	TEST_ASSERT_EQUAL(unknown["Future Job"], "title_fa2ad154cb", "A hash from another job must not select a known role")
	TEST_ASSERT_EQUAL(unknown["Acolyte"], "future_id", "Unknown IDs must survive temporary content unavailability")
	qdel(preference)
