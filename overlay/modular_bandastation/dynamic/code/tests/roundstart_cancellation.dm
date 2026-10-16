/datum/client_interface/roundstart_selection_test/proc/get_remaining_days(days_needed)
	return 0

// Only construction is interrupted; selection, assignment, ticker and cancellation remain native.
/mob/dead/new_player/roundstart_cancellation_test
	var/mob/living/character_to_create

/mob/dead/new_player/roundstart_cancellation_test/create_character(atom/destination, forced_slot)
	if(!character_to_create)
		return null
	mind.transfer_to(character_to_create)
	new_character = character_to_create
	assigned_character.created_mind = new_character.mind
	assigned_character.created_body = new_character
	character_to_create = null
	return new_character

/datum/unit_test/dynamic_roundstart_cancellation
	var/list/queue_before
	var/list/prevented_before
	var/list/forced_before
	var/list/lobby_before
	var/list/spawns_before
	var/list/joined_before
	var/list/positions_before = list()
	var/datum/job/ai/fixture_ai

/datum/unit_test/dynamic_roundstart_cancellation/Run()
	allow_job_fixture_species(list(/datum/species/plasmaman))
	if(!SSjob.get_job_type(/datum/job/ai))
		fixture_ai = allocate(/datum/job/ai)
		SSjob.type_occupations[fixture_ai.type] = fixture_ai
		SSjob.name_occupations[fixture_ai.title] = fixture_ai
		SSjob.all_occupations += fixture_ai
		SSjob.joinable_occupations += fixture_ai
	queue_before = SSdynamic.queued_rulesets
	prevented_before = SSjob.prevented_occupations
	forced_before = SSjob.forced_occupations
	lobby_before = GLOB.new_player_list
	spawns_before = GLOB.jobspawn_overrides
	joined_before = GLOB.joined_player_list
	SSdynamic.queued_rulesets = list()
	SSjob.prevented_occupations = list()
	SSjob.forced_occupations = list()
	GLOB.new_player_list = list()
	GLOB.jobspawn_overrides = list()
	GLOB.joined_player_list = list()
	for(var/ruleset_type in list(/datum/dynamic_ruleset, /datum/dynamic_ruleset/midround, /datum/dynamic_ruleset/latejoin))
		var/datum/dynamic_ruleset/ruleset = allocate(ruleset_type)
		TEST_ASSERT(!("prepared_job_changes" in ruleset.vars), "[ruleset.type] stores a roundstart-only cancellation receipt")
	var/datum/dynamic_ruleset/roundstart/roundstart = allocate(/datum/dynamic_ruleset/roundstart/traitor)
	TEST_ASSERT(!roundstart.set_config_value("prepared_job_changes", list()), "Config can replace pending roundstart occupation changes")
	for(var/list/scenario as anything in list(
		list("ruleset" = /datum/dynamic_ruleset/roundstart/traitor, "job" = /datum/job/assistant, "count" = 2),
		list("ruleset" = /datum/dynamic_ruleset/roundstart/malf_ai, "job" = /datum/job/ai, "count" = 1),
		list("ruleset" = /datum/dynamic_ruleset/roundstart/blood_worm, "job" = /datum/job/assistant, "count" = 1, "body" = TRUE),
	))
		var/datum/dynamic_ruleset/roundstart/ruleset = allocate(scenario["ruleset"])
		ruleset.blacklisted_roles = list(JOB_CARGO_TECHNICIAN)
		ruleset.max_antag_cap = scenario["count"]
		SSdynamic.queued_rulesets = list(ruleset)
		var/datum/job/job = SSjob.get_job_type(scenario["job"])
		TEST_ASSERT_NOTNULL(job, "The scenario has no registered canonical job")
		if(!(job in positions_before))
			positions_before[job] = job.current_positions
		GLOB.jobspawn_overrides[job.title] = list(run_loc_floor_bottom_left)
		if(scenario["job"] == /datum/job/ai)
			allocate(/obj/effect/landmark/start/ai, run_loc_floor_bottom_left)
		var/list/candidates = list()
		for(var/index in 1 to scenario["count"])
			var/mob/dead/new_player/roundstart_cancellation_test/player = make_player(ruleset.pref_flag, job)
			candidates += player
		var/mob/dead/new_player/roundstart_cancellation_test/player = candidates[1]
		var/datum/mind/candidate = player.mind
		if(scenario["body"])
			var/datum/preferences/preferences = player.mock_client.prefs
			preferences.max_save_slots = 2
			preferences.pref_job_slots = list(job.title = 2)
			preferences.savefile.set_entry("character2", list("real_name" = "Saved Host", "age" = 35, "species" = SPECIES_PLASMAMAN))
			TEST_ASSERT(!ruleset.is_valid_candidate(player, player.mock_client), "Blood Worm accepted an assigned bloodless profile because the active profile was human")
			preferences.savefile.set_entry("character2", list("real_name" = "Saved Host", "age" = 35, "species" = SPECIES_HUMAN))
			TEST_ASSERT(ruleset.is_valid_candidate(player, player.mock_client), "Blood Worm rejected an assigned human host")
			TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Blood Worm candidate checks switched the active character")
		SSjob.prevented_occupations[candidate] = list(JOB_PRISONER)
		var/previous_forced = scenario["count"] > 1 ? /datum/job/cargo_technician : null
		LAZYSET(SSjob.forced_occupations, candidate, previous_forced)
		var/datum/mind/other_mind = allocate(/datum/mind)
		SSjob.prevented_occupations[other_mind] = list(JOB_MEDICAL_DOCTOR)
		TEST_ASSERT(ruleset.prepare_execution(scenario["count"], candidates.Copy()), "[ruleset.type] could not prepare the actual assignment")
		TEST_ASSERT(candidate in ruleset.selected_minds, "The candidate was not selected by prepare_execution")
		TEST_ASSERT(JOB_CARGO_TECHNICIAN in SSjob.prevented_occupations[candidate], "The prepared assignment did not restrict Cargo")
		if(scenario["job"] == /datum/job/ai)
			TEST_ASSERT_EQUAL(SSjob.forced_occupations[candidate], /datum/job/ai, "Malf preparation did not force AI")
		TEST_ASSERT(SSjob.assign_role(player, job, do_eligibility_checks = FALSE), "Could not reserve the native roundstart job")
		var/positions_with_player = job.current_positions
		if(scenario["body"])
			var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
			body.set_species(/datum/species/plasmaman)
			TEST_ASSERT(!CAN_HAVE_BLOOD(body), "The controlled body was not bloodless")
			player.character_to_create = body
		candidate.active = FALSE
		player.ready = PLAYER_READY_TO_PLAY
		GLOB.new_player_list = list(player)
		SSticker.create_characters()
		TEST_ASSERT_EQUAL(job.current_positions, positions_with_player - 1, "The rejected roundstart did not free exactly its own position")
		TEST_ASSERT_EQUAL(candidate.current, player, "The rejected body did not return its mind to the lobby")
		TEST_ASSERT_EQUAL(candidate.assigned_role.type, /datum/job/unassigned, "The rejected roundstart retained its assigned job")
		TEST_ASSERT_NULL(player.new_character, "The rejected roundstart kept a partial body")
		TEST_ASSERT(!(candidate in ruleset.selected_minds), "Dynamic retained the cancelled candidate")
		TEST_ASSERT(!(JOB_CARGO_TECHNICIAN in LAZYACCESS(SSjob.prevented_occupations, candidate)), "Dynamic left its prepared job restriction behind")
		TEST_ASSERT(JOB_PRISONER in LAZYACCESS(SSjob.prevented_occupations, candidate), "Dynamic removed a pre-existing restriction")
		TEST_ASSERT(JOB_MEDICAL_DOCTOR in LAZYACCESS(SSjob.prevented_occupations, other_mind), "Dynamic changed another mind's restriction")
		TEST_ASSERT_EQUAL(LAZYACCESS(SSjob.forced_occupations, candidate), previous_forced, "Dynamic retained its forced job or removed a pre-existing one")
		TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(player, SSjob.get_job_type(/datum/job/cargo_technician)), JOB_AVAILABLE, "The cancelled candidate could not retry Cargo")
		player.cancel_character_spawn()
		TEST_ASSERT_EQUAL(job.current_positions, positions_with_player - 1, "Repeated cancellation released another vacancy")
		if(scenario["count"] > 1)
			TEST_ASSERT(ruleset in SSdynamic.queued_rulesets, "Cancelling one candidate unqueued another candidate's ruleset")
			var/mob/dead/new_player/second = candidates[2]
			TEST_ASSERT(second.mind in ruleset.selected_minds, "Dynamic cancelled another selected candidate")
			TEST_ASSERT(JOB_CARGO_TECHNICIAN in LAZYACCESS(SSjob.prevented_occupations, second.mind), "Dynamic removed another candidate's preparation")
			TEST_ASSERT(SSdynamic.cancel_roundstart_assignment(second.mind), "Could not cancel the final selected candidate")
		TEST_ASSERT(!(ruleset in SSdynamic.queued_rulesets), "An empty cancelled ruleset remained queued for PostSetup")
		TEST_ASSERT(!(ruleset in SSdynamic.executed_rulesets), "An empty cancelled ruleset was marked executed")
		TEST_ASSERT(!SSdynamic.cancel_roundstart_assignment(candidate), "The cancelled selection was cancelled twice")
		GLOB.new_player_list = list()
	check_stale_roundstart_receipts()

/// Exercise the real receipt helpers; this headless fixture does not claim connected construction.
/datum/unit_test/dynamic_roundstart_cancellation/proc/check_stale_roundstart_receipts()
	var/datum/job/job = SSjob.get_job_type(/datum/job/assistant)
	TEST_ASSERT_NOTNULL(job, "The receipt fixture has no canonical Assistant job")
	if(!(job in positions_before))
		positions_before[job] = job.current_positions
	for(var/captured_state in list("replaced", "deleted"))
		for(var/new_state in list("assignment", "body"))
			var/datum/dynamic_ruleset/roundstart/traitor/ruleset = allocate(/datum/dynamic_ruleset/roundstart/traitor)
			ruleset.max_antag_cap = 1
			ruleset.blacklisted_roles = list(JOB_CARGO_TECHNICIAN)
			SSdynamic.queued_rulesets = list(ruleset)
			var/mob/dead/new_player/lobby = make_player(ruleset.pref_flag, job)
			var/datum/mind/candidate = lobby.mind
			TEST_ASSERT(ruleset.prepare_execution(1, list(lobby)), "The receipt fixture could not prepare its native Dynamic assignment")
			TEST_ASSERT(SSjob.assign_role(lobby, job, do_eligibility_checks = FALSE), "The receipt fixture could not reserve its native job")
			var/positions_reserved = job.current_positions
			// Model a manual role with no module snapshot, keeping the real native reservation.
			QDEL_NULL(lobby.assigned_character)
			TEST_ASSERT_NULL(lobby.assigned_character, "The initial-null setup retained a profile snapshot")
			GLOB.joined_player_list = list("previous player", lobby.ckey)
			var/datum/roundstart_character_attempt/attempt = SSticker.capture_roundstart_character(lobby)
			var/datum/job_character_selection/captured = lobby.assigned_character
			TEST_ASSERT_NOTNULL(captured, "Initial-null capture did not fix the manual role's profile")
			TEST_ASSERT_EQUAL(attempt.selection, captured, "The receipt did not capture the fixed selection")
			TEST_ASSERT_EQUAL(captured.job_type, job.type, "Capture selected a different canonical job")
			GLOB.joined_player_list += lobby.ckey // The single native append owned by this receipt.
			var/datum/job_character_selection/replacement = lobby.mock_client.prefs.select_job_character(job)
			replacement.created_mind = candidate
			lobby.assigned_character = replacement
			var/mob/living/body
			if(new_state == "body")
				body = allocate(/mob/living/basic)
				candidate.transfer_to(body)
				lobby.new_character = body
				replacement.created_body = body
			if(captured_state == "deleted")
				del(captured)
				TEST_ASSERT_NULL(attempt.selection, "Hard deletion did not clear the captured receipt reference")
			TEST_ASSERT(!SSticker.validate_roundstart_character(lobby, body, attempt), "A [captured_state] receipt accepted a newer [new_state]")
			TEST_ASSERT_EQUAL(lobby.assigned_character, replacement, "A [captured_state] receipt cancelled the newer profile")
			TEST_ASSERT_EQUAL(candidate.assigned_role, job, "A [captured_state] receipt cleared the newer role")
			TEST_ASSERT_EQUAL(job.current_positions, positions_reserved, "A [captured_state] receipt released the newer position")
			TEST_ASSERT(candidate in ruleset.selected_minds, "A [captured_state] receipt cancelled the newer Dynamic assignment")
			TEST_ASSERT(JOB_CARGO_TECHNICIAN in SSjob.prevented_occupations[candidate], "A stale receipt removed the active Dynamic restriction")
			TEST_ASSERT_EQUAL(lobby.new_character, body, "A stale receipt replaced or cleared the newer body")
			TEST_ASSERT_EQUAL(candidate.current, body || lobby, "A stale receipt moved the newer mind")
			if(body)
				TEST_ASSERT(!QDELETED(body), "A stale receipt deleted the newer body")
				TEST_ASSERT_EQUAL(body.mind, candidate, "A stale receipt removed the newer body's mind")
			TEST_ASSERT_EQUAL(length(GLOB.joined_player_list), 2, "Receipt rollback did not remove exactly its own append")
			TEST_ASSERT_EQUAL(GLOB.joined_player_list[1], "previous player", "Receipt rollback removed previous history")
			TEST_ASSERT_EQUAL(GLOB.joined_player_list[2], lobby.ckey, "Receipt rollback removed a pre-existing duplicate ckey")
			qdel(captured)

/datum/unit_test/dynamic_roundstart_cancellation/proc/make_player(antag_flag, datum/job/job)
	var/datum/client_interface/player = allocate(/datum/client_interface/roundstart_selection_test)
	player.ban_cache = list()
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.be_special = list(antag_flag)
	player.prefs.job_preferences = list(job.title = JP_HIGH)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/jobless_role], RETURNTOLOBBY)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 35)
	var/mob/dead/new_player/roundstart_cancellation_test/lobby = allocate(/mob/dead/new_player/roundstart_cancellation_test)
	lobby.mock_client = player
	player.mob = lobby
	lobby.key = player.key
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	return lobby

/datum/unit_test/dynamic_roundstart_cancellation/Destroy()
	if(queue_before)
		SSdynamic.queued_rulesets = queue_before
		SSjob.prevented_occupations = prevented_before
		SSjob.forced_occupations = forced_before
		GLOB.new_player_list = lobby_before
		GLOB.jobspawn_overrides = spawns_before
	if(joined_before)
		GLOB.joined_player_list = joined_before
	for(var/datum/job/job as anything in positions_before)
		job.current_positions = positions_before[job]
	release_job_player_fixtures()
	if(fixture_ai)
		SSjob.type_occupations -= fixture_ai.type
		SSjob.name_occupations -= fixture_ai.title
		SSjob.all_occupations -= fixture_ai
		SSjob.joinable_occupations -= fixture_ai
	return ..()
