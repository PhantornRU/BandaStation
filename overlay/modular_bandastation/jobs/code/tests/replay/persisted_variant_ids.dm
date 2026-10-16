// External replay: saved hashed IDs convert once; the runtime accepts semantic declarations only.
/datum/unit_test/job_variant_persisted_id_migration/Run()
	var/datum/preference/job_outfit_variants/preference = GLOB.preference_entries[/datum/preference/job_outfit_variants]
	var/list/cases = list(
		list("Actor", "title_6f18f1d35f", "painter"),
		list(JOB_CARGO_TECHNICIAN, "title_c3e626e8a5", "deliverer"),
		list("VIP Corporate Guest", "title_d99248469b", "vip_guest"),
	)
	for(var/list/row as anything in cases)
		var/list/legacy = list(row[1] = row[2])
		var/before = json_encode(legacy)
		var/list/current = preference.deserialize(legacy)
		TEST_ASSERT_EQUAL(current[row[1]], row[3], "Saved legacy ID did not convert for [row[1]]/[row[2]]")
		TEST_ASSERT_EQUAL(json_encode(legacy), before, "Deserialization mutated its saved input")
		TEST_ASSERT_EQUAL(json_encode(preference.deserialize(current)), json_encode(current), "Saved ID conversion was not idempotent")
	var/list/unknown = list("Unknown canonical job" = "title_unknown", "Actor" = "title_unknown")
	TEST_ASSERT_EQUAL(json_encode(preference.deserialize(unknown)), json_encode(unknown), "Migration erased an unknown saved job or ID")
	var/list/scoped = preference.deserialize(list(JOB_CARGO_TECHNICIAN = "title_6f18f1d35f"))
	TEST_ASSERT_EQUAL(scoped[JOB_CARGO_TECHNICIAN], "title_6f18f1d35f", "Migration applied Actor ID conversion to another canonical job")
