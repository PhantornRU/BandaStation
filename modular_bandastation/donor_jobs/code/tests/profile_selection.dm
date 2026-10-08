/datum/unit_test/donor_job_character_selection/Run()
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
		list("slot" = 2, "age" = 44, "species" = /datum/species/lizard, "variant" = "title_6f18f1d35f"),
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
		preferences.job_assigned_profiles = list()
		preferences.job_assigned_profiles[job.title] = 2
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
	preferences.savefile.remove_entry("character2")
	var/datum/job_character_selection/missing_slot = preferences.select_job_character(job)
	allocated += missing_slot
	TEST_ASSERT(missing_slot.error, "A missing assigned character was silently replaced")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Rejecting a missing profile switched the active character")

/datum/unit_test/donor_entry_rollback
	var/datum/job/reserved_job
	var/datum/job/unassigned_job
	var/reserved_positions_before
	var/reserved_total_before
	var/unassigned_positions_before

/datum/unit_test/donor_entry_rollback/Run()
	reserved_job = SSjob.get_job_type(/datum/job/prisoner)
	unassigned_job = SSjob.get_job_type(/datum/job/unassigned)
	TEST_ASSERT_NOTNULL(reserved_job, "The native Prisoner job is not registered")
	TEST_ASSERT_NOTNULL(unassigned_job, "The native Unassigned job is not registered")
	reserved_positions_before = reserved_job.current_positions
	reserved_total_before = reserved_job.total_positions
	unassigned_positions_before = unassigned_job.current_positions
	reserved_job.current_positions = 2
	reserved_job.total_positions = 2

	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	player.mob = lobby
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	lobby.mind.set_assigned_role(reserved_job)
	lobby.assigned_character = allocate(/datum/job_character_selection)
	lobby.assigned_character.job_type = reserved_job.type
	lobby.spawning = TRUE
	var/mob/dead/new_player/retry = allocate(/mob/dead/new_player)
	TEST_ASSERT(retry.IsJobSlotUnavailable(reserved_job), "The occupied last slot was available before rollback")

	TEST_ASSERT_NULL(lobby.create_character(null), "An entry without a destination created a character")
	lobby.cancel_character_spawn()
	TEST_ASSERT_EQUAL(reserved_job.current_positions, 1, "The failed entry did not release exactly its own position")
	TEST_ASSERT_EQUAL(lobby.mind.assigned_role, unassigned_job, "The failed entry retained its assigned profession")
	TEST_ASSERT_EQUAL(lobby.mind.current, lobby, "The failed entry lost its lobby mind")
	TEST_ASSERT_NULL(lobby.new_character, "The failed entry retained a partial character")
	TEST_ASSERT(!lobby.spawning, "The failed entry retained its spawning state")
	TEST_ASSERT(!retry.IsJobSlotUnavailable(reserved_job), "Native slot admission did not see the released last position")

	TEST_ASSERT_NULL(lobby.create_character(null), "Retrying the failed entry created a character")
	lobby.cancel_character_spawn()
	TEST_ASSERT_EQUAL(reserved_job.current_positions, 1, "Retrying rollback released another player's occupied position")
	TEST_ASSERT(!retry.IsJobSlotUnavailable(reserved_job), "Retrying rollback lost the released position")

/datum/unit_test/donor_entry_rollback/Destroy()
	if(!isnull(reserved_positions_before))
		reserved_job.current_positions = reserved_positions_before
		reserved_job.total_positions = reserved_total_before
	if(!isnull(unassigned_positions_before))
		unassigned_job.current_positions = unassigned_positions_before
	return ..()

/datum/unit_test/donor_final_admission
	var/datum/job/prisoner/job
	var/positions_before
	var/total_before
	var/gate_before
	var/hard_cap_before
	var/extreme_cap_before

/datum/unit_test/donor_final_admission/Run()
	job = SSjob.get_job_type(/datum/job/prisoner)
	positions_before = job.current_positions
	total_before = job.total_positions
	gate_before = CONFIG_GET(flag/donor_prisoner_gate)
	hard_cap_before = CONFIG_GET(number/hard_popcap)
	extreme_cap_before = CONFIG_GET(number/extreme_popcap)
	CONFIG_SET(flag/donor_prisoner_gate, TRUE)
	CONFIG_SET(number/hard_popcap, 0)
	CONFIG_SET(number/extreme_popcap, 0)
	job.current_positions = 0
	job.total_positions = 1
	var/list/entrants = list()
	for(var/i in 1 to 2)
		var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
		var/datum/client_interface/player = allocate(/datum/client_interface)
		lobby.mock_client = player
		player.mob = lobby
		player.prefs = allocate(/datum/preferences, player)
		player.prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 40)
		player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
		lobby.mind = allocate(/datum/mind)
		lobby.mind.set_current(lobby)
		lobby.mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
		entrants += lobby
	var/mob/dead/new_player/first = entrants[1]
	var/mob/dead/new_player/second = entrants[2]
	var/datum/client_interface/first_player = first.mock_client
	var/datum/client_interface/second_player = second.mock_client
	TEST_ASSERT(!SSjob.assign_role(first, job, latejoin = TRUE, do_eligibility_checks = FALSE), "A prechecked caller bypassed the final tier gate")
	TEST_ASSERT_EQUAL(job.current_positions, 0, "A denied tier occupied a position")
	TEST_ASSERT_EQUAL(first.mind.assigned_role.type, /datum/job/unassigned, "A denied tier changed the canonical role")
	first_player.donator_level = MAX_DONATOR_LEVEL
	second_player.donator_level = DONATOR_TIER_1
	TEST_ASSERT(SSjob.assign_role(first, job, latejoin = TRUE, do_eligibility_checks = FALSE), "A cumulative higher tier could not take the last native position")
	TEST_ASSERT_EQUAL(job.current_positions, 1, "A successful assignment did not occupy exactly one native position")
	TEST_ASSERT(!SSjob.assign_role(second, job, latejoin = TRUE, do_eligibility_checks = FALSE), "A second prechecked entrant took an occupied last position")
	TEST_ASSERT_EQUAL(job.current_positions, 1, "The rejected competing entrant changed occupied positions")
	TEST_ASSERT_EQUAL(second.mind.assigned_role.type, /datum/job/unassigned, "The rejected competing entrant retained a role")
	first.spawning = TRUE
	CONFIG_SET(number/hard_popcap, living_player_count() + 1)
	TEST_ASSERT(SSjob.is_latejoin_population_full(), "An assigned native lobby character did not count toward the population cap")
	CONFIG_SET(number/hard_popcap, living_player_count() + 10)
	CONFIG_SET(number/extreme_popcap, living_player_count() + 1)
	TEST_ASSERT(SSjob.is_latejoin_population_full(), "The larger hard cap bypassed the native extreme cap")
	CONFIG_SET(number/hard_popcap, living_player_count() + 1)
	CONFIG_SET(number/extreme_popcap, living_player_count() + 10)
	TEST_ASSERT(SSjob.is_latejoin_population_full(), "The larger extreme cap bypassed the native hard cap")
	first.cancel_character_spawn()
	TEST_ASSERT(!SSjob.is_latejoin_population_full(), "A failed native entry retained population capacity")
	TEST_ASSERT_EQUAL(job.current_positions, 0, "Cancelling the assigned entry did not release its native position")
	first_player.donator_level = BASIC_DONATOR_LEVEL
	TEST_ASSERT(!SSjob.assign_role(first, job, do_eligibility_checks = FALSE), "An expired tier bypassed prechecked roundstart assignment")
	TEST_ASSERT_EQUAL(job.current_positions, 0, "An expired tier retained an occupation")

/datum/unit_test/donor_final_admission/Destroy()
	if(!isnull(positions_before))
		job.current_positions = positions_before
		job.total_positions = total_before
		CONFIG_SET(flag/donor_prisoner_gate, gate_before)
		CONFIG_SET(number/hard_popcap, hard_cap_before)
		CONFIG_SET(number/extreme_popcap, extreme_cap_before)
	return ..()

/datum/unit_test/native_offline_character_handover/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	lobby.spawning = TRUE
	lobby.PossessByPlayer(player.key)
	player.persistent_client.set_mob(lobby)
	lobby.mind = allocate(/datum/mind)
	lobby.mind.key = player.key
	lobby.mind.set_current(lobby)
	lobby.mind.active = FALSE
	lobby.mind.set_assigned_role(SSjob.get_job_type(/datum/job/cargo_technician))
	var/datum/mind/mind = lobby.mind
	mind.transfer_to(body)
	lobby.new_character = body
	lobby.assigned_character = allocate(/datum/job_character_selection)
	lobby.assigned_character.slot = 2
	TEST_ASSERT_EQUAL(lobby.transfer_character(), body, "The native offline handover did not return its created character")
	TEST_ASSERT_EQUAL(body.ckey, player.ckey, "Disconnect before handover left the character without the offline player's key")
	TEST_ASSERT_EQUAL(body.mind, mind, "The native offline handover lost the assigned mind")
	TEST_ASSERT_EQUAL(mind.current, body, "The native offline handover moved the mind away from its character")
	TEST_ASSERT("2" in player.persistent_client.joined_as_slots, "Offline handover did not record the effective profile")
	TEST_ASSERT_NULL(body.donor_spawn_context, "An ordinary native handover created a donor context")
	body.key = null

/mob/living/silicon/ai/entry_disconnect_test/apply_prefs_job(client/player_client, datum/job/job)
	// Disconnect at the same boundary as the yielding appearance-ban lookup.
	del(player_client)

/mob/living/carbon/human/entry_profile_change_test/apply_prefs_job(client/player_client, datum/job/job)
	. = ..()
	player_client.prefs.default_slot = 2

/datum/unit_test/native_spawn_admission_interruptions/Run()
	for(var/list/scenario as anything in list(
		list("job" = /datum/job/ai, "body" = /mob/living/silicon/ai/entry_disconnect_test),
		list("job" = /datum/job/cargo_technician, "body" = /mob/living/carbon/human/entry_profile_change_test),
	))
		var/datum/job/job = allocate(scenario["job"])
		job.spawn_type = scenario["body"]
		var/datum/client_interface/player = allocate(/datum/client_interface)
		player.prefs = allocate(/datum/preferences, player)
		player.prefs.default_slot = 1
		var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
		player.mob = lobby
		lobby.mock_client = player
		lobby.mind = allocate(/datum/mind)
		lobby.mind.set_current(lobby)
		lobby.mind.active = FALSE
		lobby.mind.set_assigned_role(job)
		var/datum/mind/mind = lobby.mind
		lobby.assigned_character = player.prefs.select_job_character(job)
		TEST_ASSERT_NULL(job.get_spawn_mob(player, run_loc_floor_bottom_left), "A disconnected or changed-profile attempt returned a partial character")
		TEST_ASSERT_EQUAL(lobby.mind, mind, "An interrupted native spawn lost the lobby mind")
		TEST_ASSERT_EQUAL(mind.current, lobby, "An interrupted native spawn retained its mind in a discarded body")
		TEST_ASSERT_EQUAL(mind.assigned_role, job, "An interrupted native spawn lost its canonical role before cancellation")
