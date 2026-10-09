/datum/unit_test/donor_job_slot_preferences
	var/datum/preferences/preferences
	var/datum/preference_middleware/jobs/legacy_ui
	var/datum/preference_middleware/pref_job_slots/slot_ui
	var/mob/dead/new_player/user
	var/datum/job/job
	var/other_job_title
	var/other_assignment = 3
	var/list/saved_characters = list()

/datum/unit_test/donor_job_slot_preferences/Run()
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
	legacy_ui = allocate(/datum/preference_middleware/jobs, preferences)
	slot_ui = allocate(/datum/preference_middleware/pref_job_slots, preferences)

	preferences.pref_job_slots = list("[job.title]" = 2, "[other_job_title]" = other_assignment)
	preferences.job_assigned_profiles = list("[job.title]" = 3, "[other_job_title]" = other_assignment)
	check_assignment(2, 2, FALSE, "Conflicting saved assignments")
	var/reset_action = slot_ui.action_delegations["reset_job_slots"]
	TEST_ASSERT_NOTNULL(reset_action, "The real reset action is not registered")
	TEST_ASSERT(!call(slot_ui, reset_action)(list("edit_slot" = 2), user), "A stale UI reset the current character's assignments")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots[job.title], 2, "A rejected reset changed the new assignment")
	TEST_ASSERT_EQUAL(preferences.job_assigned_profiles[job.title], 3, "A rejected reset changed the legacy assignment")
	var/mob/dead/new_player/foreign_user = allocate(/mob/dead/new_player)
	foreign_user.mock_client = allocate(/datum/client_interface)
	TEST_ASSERT(!call(slot_ui, reset_action)(list("edit_slot" = 1), foreign_user), "Another user's UI reset these assignments")
	TEST_ASSERT(call(slot_ui, reset_action)(list("edit_slot" = 1), user), "The real reset action failed")
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 0, "Reset retained new assignments")
	TEST_ASSERT_EQUAL(length(preferences.job_assigned_profiles), 0, "Reset retained legacy assignments")
	other_assignment = null
	check_assignment(null, 1, FALSE, "Reset with conflicting legacy data")
	// Replace the in-memory maps to ensure the native loader reads the saved reset.
	preferences.pref_job_slots = list("[job.title]" = 2, "[other_job_title]" = 3)
	preferences.job_assigned_profiles = list("[job.title]" = 3, "[other_job_title]" = 3)
	TEST_ASSERT(preferences.load_preferences(), "Could not reload the saved reset")
	check_assignment(null, 1, FALSE, "Reload after reset")

	var/list/cases = list(
		list("action" = "set_job_to_profile", "profile" = 3, "stored" = 3, "slot" = 3),
		list("action" = "set_job_slot", "slot" = 2, "stored" = 2),
		list("action" = "set_job_slot", "slot" = 0, "stored" = 0, "effective" = 1),
		list("action" = "set_job_slot", "slot" = -1, "stored" = -1, "effective" = 1, "randomized" = TRUE),
		list("action" = "set_job_to_profile", "profile" = -1, "effective" = 1),
	)
	for(var/list/test_case as anything in cases)
		other_assignment = 3
		preferences.pref_job_slots = list("[job.title]" = 2, "[other_job_title]" = other_assignment)
		preferences.job_assigned_profiles = list("[job.title]" = 3, "[other_job_title]" = other_assignment)
		var/datum/preference_middleware/middleware = test_case["action"] == "set_job_slot" ? slot_ui : legacy_ui
		var/action = middleware.action_delegations[test_case["action"]]
		var/list/params = test_case.Copy()
		params["job"] = job.title
		params["edit_slot"] = 2
		var/scenario = json_encode(test_case)
		TEST_ASSERT(!call(middleware, action)(params, user), "Stale assignment UI was accepted: [scenario]")
		TEST_ASSERT(!call(middleware, action)(list("job" = job.title, "slot" = 2, "profile" = 2, "edit_slot" = 1), foreign_user), "Another user's UI changed these assignments")
		TEST_ASSERT_EQUAL(preferences.pref_job_slots[job.title], 2, "A rejected action changed the new assignment")
		TEST_ASSERT_EQUAL(preferences.job_assigned_profiles[job.title], 3, "A rejected action changed the legacy assignment")
		params["edit_slot"] = 1
		TEST_ASSERT(call(middleware, action)(params, user), "The real assignment action failed: [scenario]")
		var/stored = test_case["stored"]
		var/effective_slot = test_case["effective"] || test_case["slot"]
		TEST_ASSERT_EQUAL(preferences.pref_job_slots[job.title], stored, "The action did not replace the new assignment: [scenario]")
		TEST_ASSERT_EQUAL(LAZYACCESS(preferences.job_assigned_profiles, job.title), isnum(stored) && stored > 0 ? stored : null, "The action retained a conflicting legacy assignment: [scenario]")
		check_assignment(stored, effective_slot, test_case["randomized"] || FALSE, scenario)
		preferences.pref_job_slots = list()
		preferences.job_assigned_profiles = null
		TEST_ASSERT(preferences.load_preferences(), "Could not reload the saved assignment: [scenario]")
		check_assignment(stored, effective_slot, test_case["randomized"] || FALSE, "Reload [scenario]")

	// Legacy-only saves still resolve and display the assigned profile.
	preferences.pref_job_slots = list()
	preferences.job_assigned_profiles = list("[job.title]" = 3, "[other_job_title]" = other_assignment)
	check_assignment(3, 3, FALSE, "Legacy-only save")

/datum/unit_test/donor_job_slot_preferences/proc/check_assignment(stored, effective_slot, randomized, scenario)
	var/datum/job_character_selection/selection = preferences.select_job_character(job)
	allocated += selection
	TEST_ASSERT_NULL(selection.error, scenario)
	TEST_ASSERT_EQUAL(selection.slot, effective_slot, "Wrong effective profile: [scenario]")
	TEST_ASSERT_EQUAL(selection.randomized, randomized, "Wrong randomization: [scenario]")
	var/list/slot_data = slot_ui.get_ui_data(user)
	TEST_ASSERT_EQUAL(slot_data["pref_job_slots"][job.title], stored, "Slot dropdown disagrees with selection: [scenario]")
	TEST_ASSERT_EQUAL(slot_data["job_character_profiles"][job.title]["slot"], effective_slot, "Profile tooltip disagrees with selection: [scenario]")
	TEST_ASSERT_EQUAL(slot_data["job_character_profiles"][job.title]["randomized"], randomized, "Profile tooltip disagrees with randomization: [scenario]")
	TEST_ASSERT_EQUAL(slot_data["pref_job_slots"][other_job_title], other_assignment, "Assignment changed another profession: [scenario]")
	var/list/legacy_data = legacy_ui.get_ui_data(user)
	var/list/job_preferences = legacy_data["job_preferences"]
	TEST_ASSERT_EQUAL(length(job_preferences), 2, "Assignments changed unrelated priority rows: [scenario]")
	var/list/job_row
	var/list/other_job_row
	for(var/list/row as anything in job_preferences)
		if(row["job"] == job.title)
			job_row = row
		if(row["job"] == other_job_title)
			other_job_row = row
	TEST_ASSERT_NOTNULL(job_row, "The native UI lost the selected profession: [scenario]")
	TEST_ASSERT_NOTNULL(other_job_row, "The native UI lost another profession: [scenario]")
	TEST_ASSERT_EQUAL(job_row["assigned_profile_slot"], isnum(stored) && stored > 0 ? stored : null, "Native profile UI disagrees with selection: [scenario]")
	TEST_ASSERT_EQUAL(job_row["priority"], JP_MEDIUM, "Assignment changed the job priority: [scenario]")
	TEST_ASSERT_EQUAL(other_job_row["assigned_profile_slot"], other_assignment, "Assignment changed another profession's native UI: [scenario]")
	TEST_ASSERT_EQUAL(other_job_row["priority"], JP_LOW, "Assignment changed another job's priority: [scenario]")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Assignment evaluation switched the active character: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/name/real_name), "Current Character", "Assignment changed the active name: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/numeric/age), 36, "Assignment changed the active age: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/choiced/species), /datum/species/human, "Assignment changed the active species: [scenario]")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/job_outfit_variants)["Actor"], "default", "Assignment changed the active outfit preference: [scenario]")
	for(var/slot in 1 to 3)
		TEST_ASSERT_EQUAL(json_encode(preferences.savefile.get_entry("character[slot]")), saved_characters["[slot]"], "Assignment changed saved character [slot]: [scenario]")

/datum/unit_test/donor_job_slot_preferences/Destroy()
	release_donor_player_fixtures()
	preferences = null
	legacy_ui = null
	slot_ui = null
	user = null
	job = null
	return ..()

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
