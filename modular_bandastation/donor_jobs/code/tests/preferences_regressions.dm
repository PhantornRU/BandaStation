/datum/unit_test/donor_job_outfit_variants_validation/Run()
	var/datum/preference/job_outfit_variants/preference = GLOB.preference_entries[/datum/preference/job_outfit_variants]
	var/list/valid = list("Actor" = "default", "Barber" = "title_c198ec4f70")
	TEST_ASSERT(preference.is_valid(valid), "A valid associative variant map was rejected")
	TEST_ASSERT_EQUAL(json_encode(preference.deserialize(valid)), json_encode(valid), "A valid variant map changed during deserialization")
	for(var/list/input as anything in list(list("Actor", "Barber"), list(1000), list(-1), list(0)))
		TEST_ASSERT(!preference.is_valid(input), "A plain or numeric array was accepted as a variant map")
		TEST_ASSERT_EQUAL(length(preference.deserialize(input)), 0, "A plain or numeric array produced variant assignments")
	var/list/mixed = list(1000, -1, 0, "Actor" = "default", "plain array entry")
	TEST_ASSERT(!preference.is_valid(mixed), "A mixed variant list was accepted")
	var/list/sanitized = preference.deserialize(mixed)
	TEST_ASSERT_EQUAL(length(sanitized), 1, "Mixed input retained malformed entries or lost its valid entry")
	TEST_ASSERT_EQUAL(sanitized["Actor"], "default", "Mixed input lost its valid variant")
	for(var/input in list(null, 1000, "not a list"))
		TEST_ASSERT(!preference.is_valid(input), "Non-list variant data was accepted")
		TEST_ASSERT_EQUAL(length(preference.deserialize(input)), 0, "Non-list variant data produced assignments")
	var/list/at_limit = list()
	for(var/index in 1 to 128)
		at_limit["Job [index]"] = "default"
	TEST_ASSERT(preference.is_valid(at_limit), "A 128-entry map was rejected")
	TEST_ASSERT_EQUAL(length(preference.deserialize(at_limit)), 128, "The 128-entry limit was reduced")
	at_limit["Job 129"] = "default"
	TEST_ASSERT(!preference.is_valid(at_limit), "A map beyond the entry limit was accepted")
	var/list/truncated = preference.deserialize(at_limit)
	TEST_ASSERT_EQUAL(length(truncated), 128, "Deserialization exceeded its visit limit")
	TEST_ASSERT_NULL(truncated["Job 129"], "Deserialization visited the 129th entry")
	var/limit_text = repeat_string(128, "a")
	var/list/length_limit = list("[limit_text]" = limit_text)
	TEST_ASSERT(preference.is_valid(length_limit), "A 128-character key or value was rejected")
	TEST_ASSERT_EQUAL(length(preference.deserialize(length_limit)), 1, "The text length limit was reduced")
	for(var/list/input as anything in list(list("" = "default"), list("Actor" = ""), list("[limit_text]a" = "default"), list("Actor" = "[limit_text]a")))
		TEST_ASSERT(!preference.is_valid(input), "An empty or oversized key/value was accepted")
		TEST_ASSERT_EQUAL(length(preference.deserialize(input)), 0, "An empty or oversized key/value survived deserialization")

/datum/unit_test/donor_job_variant_action
	var/enabled_before
	var/datum/job/registered_before
	var/datum/job/job

/datum/unit_test/donor_job_variant_action/Run()
	enabled_before = CONFIG_GET(flag/donor_jobs_enabled)
	CONFIG_SET(flag/donor_jobs_enabled, TRUE)
	job = allocate(/datum/job/donor/vip_guest)
	registered_before = SSjob.name_occupations[job.title]
	// Use the real canonical datum and action even when startup has donor jobs disabled.
	SSjob.name_occupations[job.title] = job
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	preferences.default_slot = 1
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	var/datum/preference/preference = GLOB.preference_entries[/datum/preference/job_outfit_variants]
	TEST_ASSERT(preferences.write_preference(preference, list("[job.title]" = "default")), "Could not seed the saved variant")
	var/mob/dead/new_player/user = allocate(/mob/dead/new_player)
	user.mock_client = player
	player.mob = user
	var/datum/preference_middleware/donor_jobs/middleware = allocate(/datum/preference_middleware/donor_jobs, preferences)
	var/action = middleware.action_delegations["set_donor_job_variant"]
	TEST_ASSERT_NOTNULL(action, "The real variant action is not registered")
	var/list/params = list("job" = job.title, "variant" = "title_d99248469b", "slot" = 1)
	var/saved_before = json_encode(preferences.savefile.get_entry("character1"))
	var/updated_before = json_encode(preferences.recently_updated_keys)
	TEST_ASSERT(job.donor_lock_reason(player), "The T5 fixture is not locked for a free player")
	TEST_ASSERT(!call(middleware, action)(params, user), "A direct action edited a locked T5 variant")
	TEST_ASSERT_EQUAL(preferences.read_preference(preference.type)[job.title], "default", "A denied action changed the cached variant")
	TEST_ASSERT_EQUAL(json_encode(preferences.savefile.get_entry("character1")), saved_before, "A denied action changed saved character data")
	TEST_ASSERT_EQUAL(json_encode(preferences.recently_updated_keys), updated_before, "A denied action scheduled a preference write")
	player.donator_level = DONATOR_TIER_5
	TEST_ASSERT(call(middleware, action)(params, user), "An authorized T5 player could not edit the variant")
	TEST_ASSERT_EQUAL(preferences.read_preference(preference.type)[job.title], params["variant"], "The authorized action did not update the variant")
	player.donator_level = BASIC_DONATOR_LEVEL
	TEST_ASSERT_EQUAL(preferences.read_preference(preference.type)[job.title], params["variant"], "Reading an expired choice erased it")
	var/datum/job/cargo = SSjob.get_job_type(/datum/job/cargo_technician)
	TEST_ASSERT(call(middleware, action)(list("job" = cargo.title, "variant" = "title_c3e626e8a5", "slot" = 1), user), "A free player could not choose Deliverer through the server action")
	TEST_ASSERT_EQUAL(preferences.read_preference(preference.type)[cargo.title], "title_c3e626e8a5", "The free Deliverer choice was lost")
	var/selection_before = json_encode(preferences.read_preference(preference.type))
	for(var/list/invalid as anything in list(
		list("job" = cargo.title, "variant" = "default", "slot" = 2),
		list("job" = cargo.title, "variant" = "missing", "slot" = 1),
		list("job" = cargo.title, "variant" = 1, "slot" = 1),
		list("job" = "Not a canonical job", "variant" = "default", "slot" = 1),
	))
		TEST_ASSERT(!call(middleware, action)(invalid, user), "The action accepted invalid parameters: [json_encode(invalid)]")
	var/mob/dead/new_player/foreign_user = allocate(/mob/dead/new_player)
	foreign_user.mock_client = allocate(/datum/client_interface)
	TEST_ASSERT(!call(middleware, action)(params, foreign_user), "A foreign UI edited another player's variants")
	TEST_ASSERT_EQUAL(json_encode(preferences.read_preference(preference.type)), selection_before, "Rejected input changed the variant map")

/datum/unit_test/donor_job_variant_action/Destroy()
	if(job)
		if(registered_before)
			SSjob.name_occupations[job.title] = registered_before
		else
			SSjob.name_occupations -= job.title
		CONFIG_SET(flag/donor_jobs_enabled, enabled_before)
	release_job_player_fixtures()
	return ..()
