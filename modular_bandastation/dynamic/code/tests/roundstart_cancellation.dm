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
	character_to_create = null
	return new_character

/datum/unit_test/dynamic_roundstart_cancellation
	var/list/queue_before
	var/list/prevented_before
	var/list/forced_before
	var/list/lobby_before
	var/list/spawns_before
	var/list/positions_before = list()

/datum/unit_test/dynamic_roundstart_cancellation/Run()
	queue_before = SSdynamic.queued_rulesets
	prevented_before = SSjob.prevented_occupations
	forced_before = SSjob.forced_occupations
	lobby_before = GLOB.new_player_list
	spawns_before = GLOB.jobspawn_overrides
	SSdynamic.queued_rulesets = list()
	SSjob.prevented_occupations = list()
	SSjob.forced_occupations = list()
	GLOB.new_player_list = list()
	GLOB.jobspawn_overrides = list()
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
	for(var/datum/job/job as anything in positions_before)
		job.current_positions = positions_before[job]
	release_job_player_fixtures()
	return ..()
