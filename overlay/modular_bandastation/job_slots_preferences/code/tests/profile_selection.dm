/datum/unit_test/job_character_selection/Run()
	allow_job_fixture_species(list(/datum/species/lizard))
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	preferences.default_slot = 1
	preferences.max_save_slots = 3
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.savefile.set_entry("character1", list("real_name" = "Current Character"))
	preferences.savefile.set_entry("character2", list(
		"real_name" = "Saved Painter",
		"age" = 44,
		"species" = SPECIES_LIZARD,
		"job_outfit_variants" = list("Actor" = "painter"),
	))
	preferences.savefile.set_entry("character3", list(
		"real_name" = "Saved Artist",
		"age" = 22,
		"species" = SPECIES_HUMAN,
		"job_outfit_variants" = list("Actor" = "artist"),
	))
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/name/real_name], "Current Character"), "Could not set the current character's name")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 36), "Could not set the current character's age")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN), "Could not set the current character's species")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("Actor" = "default")), "Could not set the current character's variant")
	var/datum/job/job = allocate(/datum/job/donor/actor)
	job.required_character_age = 30
	var/list/cases = list(
		list("slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 2, "slot" = 2, "age" = 44, "species" = /datum/species/lizard, "variant" = "painter"),
		list("assigned" = 3, "slot" = 3, "age" = 22, "species" = /datum/species/human, "variant" = "artist", "unavailable" = TRUE),
		list("assigned" = 0, "slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = -1, "slot" = 1, "randomized" = TRUE, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 3, "current" = TRUE, "slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 3, "latejoin" = TRUE, "slot" = 3, "age" = 22, "species" = /datum/species/human, "variant" = "artist", "unavailable" = TRUE),
		list("assigned" = 3, "latejoin" = TRUE, "current" = TRUE, "slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 3, "current" = TRUE, "forced" = 2, "slot" = 2, "age" = 44, "species" = /datum/species/lizard, "variant" = "painter"),
	)
	for(var/list/test_case as anything in cases)
		preferences.pref_job_slots = list()
		if("assigned" in test_case)
			preferences.pref_job_slots[job.title] = test_case["assigned"]
		preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], test_case["current"] || FALSE)
		preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], test_case["current"] || FALSE)
		var/datum/job_character_selection/selection = preferences.select_job_character(job, test_case["latejoin"] || FALSE, test_case["forced"])
		allocated += selection
		var/scenario = json_encode(test_case)
		TEST_ASSERT_NULL(selection.error, scenario)
		TEST_ASSERT_EQUAL(selection.slot, test_case["slot"], scenario)
		TEST_ASSERT_EQUAL(selection.randomized, test_case["randomized"] || FALSE, scenario)
		TEST_ASSERT_EQUAL(selection.age, test_case["age"], scenario)
		TEST_ASSERT_EQUAL(selection.species, test_case["species"], scenario)
		TEST_ASSERT_EQUAL(selection.read_preference(/datum/preference/job_outfit_variants)[job.title], test_case["variant"], scenario)
		TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Candidate evaluation switched the active character")
		TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/name/real_name), "Current Character", "Candidate evaluation changed the active name")
		TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/numeric/age), 36, "Candidate evaluation changed the active age")
		TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/choiced/species), /datum/species/human, "Candidate evaluation changed the active species")
		TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/job_outfit_variants)[job.title], "default", "Candidate evaluation changed the active variant")
		if(test_case["unavailable"])
			TEST_ASSERT(selection.character_error(job, null, FALSE), "The saved young profile bypassed the age requirement")
		else
			TEST_ASSERT_NULL(selection.character_error(job, null, FALSE), "The saved adult profile inherited the current character's restrictions")

	preferences.pref_job_slots[job.title] = 2
	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], FALSE)
	var/list/saved_profile = preferences.savefile.get_entry("character2")
	saved_profile -= "age"
	preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 90)
	var/datum/job_character_selection/missing_age = preferences.select_job_character(job)
	allocated += missing_age
	TEST_ASSERT_NULL(missing_age.error, "An old profile with native defaults was rejected")
	TEST_ASSERT(missing_age.age >= 21 && missing_age.age <= 50, "The old profile inherited the current character age instead of its native default")
	// Populate the save version through the native writer without writing a disk savefile.
	preferences.path = "unit-test"
	TEST_ASSERT(preferences.save_character(), "Could not prepare the current saved profile")
	preferences.path = null
	var/list/current_profile = preferences.savefile.get_entry("character1")
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	lobby.mock_client = player
	player.mob = lobby
	for(var/invalid_age in list(null, "invalid", 1000))
		saved_profile["version"] = current_profile["version"]
		saved_profile["age"] = invalid_age
		preferences.savefile.set_entry("character2", saved_profile.Copy())
		lobby.assigned_character = preferences.select_job_character(job)
		var/datum/job_character_selection/selection = lobby.assigned_character
		var/selected_variant = selection.read_preference(/datum/preference/job_outfit_variants)[job.title]
		TEST_ASSERT(lobby.load_assigned_job_character(), "Could not load a profile with a native default for invalid age")
		TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/numeric/age), selection.age, "Loading regenerated the age used for assignment")
		TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/choiced/species), selection.species, "Loading changed the inspected species")
		TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/job_outfit_variants)[job.title], selected_variant, "Loading changed the inspected variant")
		QDEL_NULL(lobby.assigned_character)
		TEST_ASSERT(preferences.load_character(1), "Could not restore the current profile")
	preferences.savefile.set_entry("character2", "corrupted profile")
	var/datum/job_character_selection/corrupted_slot = preferences.select_job_character(job)
	allocated += corrupted_slot
	TEST_ASSERT(corrupted_slot.error, "A non-list assigned profile was silently replaced")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Rejecting a corrupted profile switched the active character")
	preferences.savefile.remove_entry("character2")
	var/datum/job_character_selection/missing_slot = preferences.select_job_character(job)
	allocated += missing_slot
	TEST_ASSERT(missing_slot.error, "A missing assigned character was silently replaced")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Rejecting a missing profile switched the active character")

/datum/unit_test/job_character_selection/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/client_interface/respawn_policy_test
	var/localhost_connection = FALSE

/datum/client_interface/respawn_policy_test/is_localhost()
	return localhost_connection

/datum/unit_test/job_character_respawn_policy
	var/respawn_before
	var/state_before

/datum/unit_test/job_character_respawn_policy/Run()
	respawn_before = CONFIG_GET(flag/allow_respawn)
	state_before = SSticker.current_state
	CONFIG_SET(flag/allow_respawn, RESPAWN_FLAG_NEW_CHARACTER)
	SSticker.current_state = GAME_STATE_PLAYING
	var/datum/client_interface/respawn_policy_test/player = allocate(/datum/client_interface/respawn_policy_test)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	preferences.default_slot = 1
	preferences.max_save_slots = 2
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.savefile.set_entry("character2", list("real_name" = "Assigned Character", "age" = 40, "species" = SPECIES_HUMAN))
	preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 40)
	preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], FALSE)
	var/datum/job/job = SSjob.get_job_type(/datum/job/cargo_technician)
	preferences.pref_job_slots[job.title] = 2
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	lobby.mock_client = player
	player.mob = lobby
	player.persistent_client.set_mob(lobby)
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	player.persistent_client.joined_as_slots = list("2")
	TEST_ASSERT_EQUAL(SSjob.check_character_eligibility(lobby, job, latejoin = TRUE), expected_character_profile_error(), "An already played assigned slot bypassed respawn because the current slot was unused")
	player.persistent_client.joined_as_slots = list("1")
	TEST_ASSERT_EQUAL(SSjob.check_character_eligibility(lobby, job, latejoin = TRUE), JOB_AVAILABLE, "The unused assigned slot inherited the current slot's respawn restriction")
	player.persistent_client.joined_as_slots = list("2")
	TEST_ASSERT_EQUAL(SSjob.check_character_eligibility(lobby, job, latejoin = FALSE), JOB_AVAILABLE, "A latejoin restriction affected roundstart evaluation")
	player.localhost_connection = TRUE
	var/logs_before = length(GLOB.admin_activities)
	for(var/query in 1 to 3)
		TEST_ASSERT_EQUAL(SSjob.check_character_eligibility(lobby, job, latejoin = TRUE), JOB_AVAILABLE, "Localhost did not bypass the assigned-slot respawn restriction")
	TEST_ASSERT_EQUAL(length(GLOB.admin_activities), logs_before, "Candidate/menu eligibility produced localhost admin logs")
	lobby.spawning = TRUE
	TEST_ASSERT(!lobby.AttemptLateSpawn("Not a canonical job"), "A repeated latejoin request entered the spawn path")
	TEST_ASSERT(lobby.spawning, "A repeated request released the first attempt's guard")
	TEST_ASSERT_EQUAL(length(GLOB.admin_activities), logs_before, "A repeated request produced another localhost notification")
	lobby.spawning = FALSE
	// The native client?.is_localhost() branch needs a real BYOND client: NOT COVERED by this headless fixture.
	// The eligibility assertions above exercise mock localhost policy; actual attempts below exercise clientless preflight.
	// A separate source contract checks the native localhost branch and its respawn-mode guard against BASE.
	TEST_ASSERT_NULL(lobby.client, "The headless notification assertions require an actual clientless lobby")
	TEST_ASSERT(!lobby.AttemptLateSpawn("Not a canonical job"), "An invalid job spawned a character")
	TEST_ASSERT_EQUAL(length(GLOB.admin_activities), logs_before, "A clientless attempt treated mock localhost as a native client")
	player.persistent_client.joined_as_slots = list()
	TEST_ASSERT(!lobby.AttemptLateSpawn("Not a canonical job"), "An invalid job with an unused profile spawned")
	TEST_ASSERT_EQUAL(length(GLOB.admin_activities), logs_before, "A clientless unused-slot attempt produced a localhost admin log")
	player.localhost_connection = FALSE
	TEST_ASSERT(!lobby.AttemptLateSpawn("Not a canonical job"), "An invalid headless attempt with remote mock policy spawned")
	TEST_ASSERT_EQUAL(length(GLOB.admin_activities), logs_before, "A clientless attempt with remote mock policy produced a localhost admin log")
	player.localhost_connection = TRUE
	CONFIG_SET(flag/allow_respawn, RESPAWN_FLAG_FREE)
	TEST_ASSERT(!lobby.AttemptLateSpawn("Not a canonical job"), "An invalid attempt in another respawn mode spawned")
	TEST_ASSERT_EQUAL(length(GLOB.admin_activities), logs_before, "Another respawn mode produced a localhost exception log")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Respawn eligibility changed the current profile")

/datum/unit_test/job_character_respawn_policy/Destroy()
	if(!isnull(respawn_before))
		CONFIG_SET(flag/allow_respawn, respawn_before)
		SSticker.current_state = state_before
	release_job_player_fixtures()
	return ..()
