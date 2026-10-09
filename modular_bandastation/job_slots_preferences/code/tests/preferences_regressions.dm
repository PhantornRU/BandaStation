/datum/unit_test/job_slot_preferences
	var/datum/preferences/preferences
	var/datum/preference_middleware/jobs/priority_ui
	var/datum/preference_middleware/pref_job_slots/slot_ui
	var/mob/dead/new_player/user
	var/datum/job/job
	var/other_job_title
	var/other_assignment = 3
	var/list/saved_characters = list()

/datum/unit_test/job_slot_preferences/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	preferences.default_slot = 1
	preferences.max_save_slots = 3
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.savefile.set_entry("character2", list("real_name" = "Saved Second", "age" = 44, "species" = SPECIES_HUMAN))
	preferences.savefile.set_entry("character3", list("real_name" = "Saved Third", "age" = 48, "species" = SPECIES_HUMAN))
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/name/real_name], "Current Character"), "Could not set the active name")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 36), "Could not set the active age")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN), "Could not set the active species")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("Actor" = "default")), "Could not set the active outfit preference")
	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], FALSE)
	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], FALSE)
	job = SSjob.get_job_type(/datum/job/cargo_technician)
	TEST_ASSERT_NOTNULL(job, "The native Cargo Technician job is not registered")
	var/datum/job/other_job = SSjob.get_job_type(/datum/job/assistant)
	TEST_ASSERT_NOTNULL(other_job, "The native Assistant job is not registered")
	other_job_title = other_job.title
	preferences.job_preferences = list("[job.title]" = JP_MEDIUM, "[other_job_title]" = JP_LOW)
	// The native character writer supplies its version without touching a disk savefile.
	preferences.path = "unit-test"
	TEST_ASSERT(preferences.save_character(), "Could not prepare the active saved character")
	preferences.path = null
	for(var/slot in 1 to 3)
		saved_characters["[slot]"] = json_encode(preferences.savefile.get_entry("character[slot]"))
	user = allocate(/mob/dead/new_player)
	user.mock_client = player
	player.mob = user
	priority_ui = allocate(/datum/preference_middleware/jobs, preferences)
	slot_ui = allocate(/datum/preference_middleware/pref_job_slots, preferences)
	TEST_ASSERT_NULL(priority_ui.action_delegations["set_job_to_profile"], "The removed profile action is still dispatched")

	preferences.pref_job_slots = list("[job.title]" = 2, "[other_job_title]" = other_assignment)
	check_assignment(2, 2, FALSE, "Saved assignment")
	var/reset_action = slot_ui.action_delegations["reset_job_slots"]
	var/set_action = slot_ui.action_delegations["set_job_slot"]
	TEST_ASSERT_NOTNULL(reset_action, "The real reset action is not registered")
	TEST_ASSERT_NOTNULL(set_action, "The real slot action is not registered")
	TEST_ASSERT(!call(slot_ui, reset_action)(list("edit_slot" = 2), user), "A stale UI reset the current character's assignments")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots[job.title], 2, "A rejected reset changed the assignment")
	var/mob/dead/new_player/foreign_user = allocate(/mob/dead/new_player)
	foreign_user.mock_client = allocate(/datum/client_interface)
	TEST_ASSERT(!call(slot_ui, reset_action)(list("edit_slot" = 1), foreign_user), "Another user's UI reset these assignments")
	TEST_ASSERT(call(slot_ui, reset_action)(list("edit_slot" = 1), user), "The real reset action failed")
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 0, "Reset retained assignments")
	other_assignment = null
	check_assignment(null, 1, FALSE, "Reset")
	// Replace the in-memory map so the native loader must read the saved reset.
	preferences.pref_job_slots = list("[job.title]" = 2, "[other_job_title]" = 3)
	TEST_ASSERT(preferences.load_preferences(), "Could not reload the saved reset")
	check_assignment(null, 1, FALSE, "Reload after reset")

	var/list/cases = list(
		list("slot" = 3, "stored" = 3, "effective" = 3),
		list("slot" = 2, "stored" = 2, "effective" = 2),
		list("slot" = 1, "stored" = 1, "effective" = 1),
		list("slot" = 0, "effective" = 1),
		list("slot" = -1, "stored" = -1, "effective" = 1, "randomized" = TRUE),
	)
	for(var/list/test_case as anything in cases)
		other_assignment = 3
		preferences.pref_job_slots = list("[job.title]" = 2, "[other_job_title]" = other_assignment)
		var/list/params = list("job" = job.title, "slot" = test_case["slot"], "edit_slot" = 2)
		var/scenario = json_encode(test_case)
		TEST_ASSERT(!call(slot_ui, set_action)(params, user), "Stale assignment UI was accepted: [scenario]")
		TEST_ASSERT(!call(slot_ui, set_action)(list("job" = job.title, "slot" = 2, "edit_slot" = 1), foreign_user), "Another user's UI changed these assignments")
		TEST_ASSERT_EQUAL(preferences.pref_job_slots[job.title], 2, "A rejected action changed the assignment")
		params["edit_slot"] = 1
		TEST_ASSERT(call(slot_ui, set_action)(params, user), "The real assignment action failed: [scenario]")
		var/stored = test_case["stored"]
		check_assignment(stored, test_case["effective"], test_case["randomized"] || FALSE, scenario)
		preferences.pref_job_slots = list()
		TEST_ASSERT(preferences.load_preferences(), "Could not reload the saved assignment: [scenario]")
		check_assignment(stored, test_case["effective"], test_case["randomized"] || FALSE, "Reload [scenario]")

	var/list/before_invalid = preferences.pref_job_slots.Copy()
	var/list/saved_assignments = preferences.savefile.get_entry("pref_job_slots")
	saved_assignments = saved_assignments.Copy()
	var/datum/job/unassigned_job = SSjob.get_job_type(/datum/job/unassigned)
	TEST_ASSERT_NOTNULL(unassigned_job, "The native Unassigned job is not registered")
	var/list/invalid_inputs = list(
		list("job" = null, "slot" = 2),
		list("job" = 1000, "slot" = 2),
		list("job" = "Not a canonical job", "slot" = 2),
		list("job" = unassigned_job.title, "slot" = 2),
		list("job" = job.title, "slot" = null),
		list("job" = job.title, "slot" = "2"),
		list("job" = job.title, "slot" = 2.5),
		list("job" = job.title, "slot" = -2),
		list("job" = job.title, "slot" = 4),
	)
	for(var/list/params as anything in invalid_inputs)
		params["edit_slot"] = 1
		TEST_ASSERT(!call(slot_ui, set_action)(params, user), "Invalid input was accepted: [json_encode(params)]")
		TEST_ASSERT_EQUAL(json_encode(preferences.pref_job_slots), json_encode(before_invalid), "Rejected input changed assignments")
		TEST_ASSERT_EQUAL(json_encode(preferences.savefile.get_entry("pref_job_slots")), json_encode(saved_assignments), "Rejected input was saved")
	var/list/second_profile = preferences.savefile.get_entry("character2")
	preferences.savefile.remove_entry("character2")
	TEST_ASSERT(!call(slot_ui, set_action)(list("job" = job.title, "slot" = 2, "edit_slot" = 1), user), "A missing saved profile was assigned")
	preferences.savefile.set_entry("character2", "corrupted profile")
	TEST_ASSERT(!call(slot_ui, set_action)(list("job" = job.title, "slot" = 2, "edit_slot" = 1), user), "A corrupted saved profile was assigned")
	preferences.savefile.set_entry("character2", second_profile)
	TEST_ASSERT_EQUAL(json_encode(preferences.pref_job_slots), json_encode(before_invalid), "Rejected missing/corrupted profiles changed assignments")
	preferences.pref_job_slots["Temporarily unavailable job"] = 4
	var/list/priority_data = priority_ui.get_ui_data(user)
	TEST_ASSERT_EQUAL(length(priority_data["job_preferences"]), 2, "A profile-only assignment added a priority row")

/datum/unit_test/job_slot_preferences/proc/check_assignment(stored, effective_slot, randomized, scenario)
	var/datum/job_character_selection/selection = preferences.select_job_character(job)
	allocated += selection
	TEST_ASSERT_NULL(selection.error, scenario)
	TEST_ASSERT_EQUAL(selection.slot, effective_slot, "Wrong effective profile: [scenario]")
	TEST_ASSERT_EQUAL(selection.randomized, randomized, "Wrong randomization: [scenario]")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots[job.title], stored, "Wrong stored assignment: [scenario]")
	var/list/slot_data = slot_ui.get_ui_data(user)
	TEST_ASSERT_EQUAL(slot_data["pref_job_slots"][job.title], stored, "Slot dropdown disagrees with selection: [scenario]")
	TEST_ASSERT_EQUAL(slot_data["job_character_profiles"][job.title]["slot"], effective_slot, "Profile tooltip disagrees with selection: [scenario]")
	TEST_ASSERT_EQUAL(slot_data["job_character_profiles"][job.title]["randomized"], randomized, "Profile tooltip disagrees with randomization: [scenario]")
	TEST_ASSERT_EQUAL(slot_data["pref_job_slots"][other_job_title], other_assignment, "Assignment changed another profession: [scenario]")
	var/list/priority_data = priority_ui.get_ui_data(user)
	var/list/job_preferences = priority_data["job_preferences"]
	TEST_ASSERT_EQUAL(length(job_preferences), 2, "Assignments changed unrelated priority rows: [scenario]")
	var/list/job_row
	var/list/other_job_row
	for(var/list/row as anything in job_preferences)
		TEST_ASSERT_EQUAL(length(row), 2, "The priority row carries data outside job and priority: [scenario]")
		if(row["job"] == job.title)
			job_row = row
		if(row["job"] == other_job_title)
			other_job_row = row
	TEST_ASSERT_NOTNULL(job_row, "The native UI lost the selected profession: [scenario]")
	TEST_ASSERT_NOTNULL(other_job_row, "The native UI lost another profession: [scenario]")
	TEST_ASSERT_EQUAL(job_row["priority"], JP_MEDIUM, "Assignment changed the job priority: [scenario]")
	TEST_ASSERT_EQUAL(other_job_row["priority"], JP_LOW, "Assignment changed another job's priority: [scenario]")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Assignment evaluation switched the active character: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/name/real_name), "Current Character", "Assignment changed the active name: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/numeric/age), 36, "Assignment changed the active age: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/choiced/species), /datum/species/human, "Assignment changed the active species: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/job_outfit_variants)["Actor"], "default", "Assignment changed the active outfit preference: [scenario]")
	for(var/slot in 1 to 3)
		TEST_ASSERT_EQUAL(json_encode(preferences.savefile.get_entry("character[slot]")), saved_characters["[slot]"], "Assignment changed saved character [slot]: [scenario]")

/datum/unit_test/job_slot_preferences/Destroy()
	release_job_player_fixtures()
	preferences = null
	priority_ui = null
	slot_ui = null
	user = null
	job = null
	return ..()

/datum/unit_test/job_slot_saved_format/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.max_save_slots = 3
	preferences.default_slot = 1
	TEST_ASSERT(preferences.save_preferences(), "Could not prepare the native save format")
	var/list/character = list("real_name" = "Saved Character", "age" = 44)
	preferences.savefile.set_entry("character2", character)
	preferences.savefile.set_entry("unrelated_setting", "keep")
	var/list/input = list(
		"Saved job" = 2,
		"Random job" = -1,
		"Current job" = 0,
		"Temporarily unavailable job" = 999,
		"" = 2,
		"Fractional job" = 1.5,
		"Negative job" = -2,
		"Text job" = "2",
		"Null job" = null,
	)
	preferences.savefile.set_entry("pref_job_slots", input)
	TEST_ASSERT(preferences.load_preferences(), "Could not load the job slot format through the native loader")
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 3, "The format loader retained malformed or current-slot entries")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots["Saved job"], 2, "The format loader lost a saved profile")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots["Random job"], -1, "The format loader lost randomization")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots["Temporarily unavailable job"], 999, "The format loader erased a temporarily unavailable job or slot")
	TEST_ASSERT(preferences.save_preferences(), "Could not save sanitized assignments")
	preferences.pref_job_slots = list()
	TEST_ASSERT(preferences.load_preferences(), "Could not reload sanitized assignments")
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 3, "Reload changed the sanitized assignment map")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots["Temporarily unavailable job"], 999, "Reload erased a temporarily unavailable assignment")
	TEST_ASSERT_EQUAL(json_encode(preferences.savefile.get_entry("character2")), json_encode(character), "Loading assignments changed a character section")
	TEST_ASSERT_EQUAL(preferences.savefile.get_entry("unrelated_setting"), "keep", "Loading assignments changed another setting")
	for(var/invalid_map in list(null, "not a map", 1000))
		preferences.savefile.set_entry("pref_job_slots", invalid_map)
		preferences.load_job_character_slots()
		TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 0, "A non-list saved value became assignments")
	preferences.savefile.set_entry("pref_job_slots", list(2, "Saved job"))
	preferences.load_job_character_slots()
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 0, "Plain list entries became assignments")
	preferences.savefile.remove_entry("pref_job_slots")
	preferences.load_job_character_slots()
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 0, "A missing assignment key retained old in-memory entries")

/datum/unit_test/job_slot_saved_format/Destroy()
	release_job_player_fixtures()
	return ..()
