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
		"job_outfit_variants" = list("Actor" = "title_6f18f1d35f"),
	))
	preferences.savefile.set_entry("character3", list(
		"real_name" = "Saved Artist",
		"age" = 22,
		"species" = SPECIES_HUMAN,
		"job_outfit_variants" = list("Actor" = "title_e639ea25de"),
	))
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/name/real_name], "Current Character"), "Could not set the current character's name")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 36), "Could not set the current character's age")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN), "Could not set the current character's species")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("Actor" = "default")), "Could not set the current character's variant")
	var/datum/job/job = allocate(/datum/job/donor/actor)
	job.required_character_age = 30
	var/list/cases = list(
		list("slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 2, "slot" = 2, "age" = 44, "species" = /datum/species/lizard, "variant" = "title_6f18f1d35f"),
		list("assigned" = 3, "slot" = 3, "age" = 22, "species" = /datum/species/human, "variant" = "title_e639ea25de", "unavailable" = TRUE),
		list("assigned" = 0, "slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = -1, "slot" = 1, "randomized" = TRUE, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 3, "current" = TRUE, "slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 3, "latejoin" = TRUE, "slot" = 3, "age" = 22, "species" = /datum/species/human, "variant" = "title_e639ea25de", "unavailable" = TRUE),
		list("assigned" = 3, "latejoin" = TRUE, "current" = TRUE, "slot" = 1, "age" = 36, "species" = /datum/species/human, "variant" = "default"),
		list("assigned" = 3, "current" = TRUE, "forced" = 2, "slot" = 2, "age" = 44, "species" = /datum/species/lizard, "variant" = "title_6f18f1d35f"),
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
