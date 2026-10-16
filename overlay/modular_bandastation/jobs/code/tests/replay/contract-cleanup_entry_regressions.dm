// External TEMP overlay only. Calls the actual public native entrypoints.
// Clientless fixtures replace only construction/admission seams, never the native algorithm.
/datum/job/contract_entry_fixture
	title = "Contract entry fixture"
	job_flags = NONE
	total_positions = -1
	var/atom/fixture_destination
	var/mob/living/fixture_body
	var/construction_calls = 0
	var/equipment_calls = 0
	var/latejoin_calls = 0

/datum/job/contract_entry_fixture/config_check()
	return FALSE

/datum/job/contract_entry_fixture/get_latejoin_spawn_point()
	return fixture_destination

// Represents a specialized constructor that does not call base get_spawn_mob.
/datum/job/contract_entry_fixture/get_spawn_mob(client/player_client, atom/spawn_point)
	construction_calls++
	return fixture_body

/datum/job/contract_entry_fixture/after_spawn(mob/living/body, client/player_client)
	equipment_calls++
	return ..()

/datum/job/contract_entry_fixture/after_latejoin_spawn(mob/living/body)
	latejoin_calls++
	return ..()

/mob/dead/new_player/contract_create_fixture
	var/allow_profile = FALSE
	var/prepare_calls = 0
	var/validation_calls = 0

// No real BYOND client is available; supply a profile to reach the native constructor.
/mob/dead/new_player/contract_create_fixture/prepare_character_profile(atom/destination, forced_slot)
	prepare_calls++
	if(!allow_profile)
		return null
	assigned_character = new
	assigned_character.job_type = mind.assigned_role.type
	return assigned_character

/mob/dead/new_player/contract_create_fixture/validate_created_character(mob/living/body, datum/mind/spawning_mind, datum/job/spawning_job, datum/job_character_selection/context)
	validation_calls++
	return ..()

/datum/unit_test/contract_public_create_character/Run()
	var/mob/dead/new_player/contract_create_fixture/lobby = allocate(/mob/dead/new_player/contract_create_fixture)
	var/datum/job/contract_entry_fixture/job = allocate(/datum/job/contract_entry_fixture)
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	lobby.mind.set_assigned_role(job)
	lobby.mind.active = TRUE
	var/datum/mind/original_mind = lobby.mind
	TEST_ASSERT_NULL(lobby.create_character(run_loc_floor_bottom_left), "Public create_character ignored profile rejection")
	TEST_ASSERT_EQUAL(lobby.prepare_calls, 1, "Public create_character did not call profile preparation once")
	TEST_ASSERT_EQUAL(job.construction_calls, 0, "A rejected profile reached construction")
	TEST_ASSERT(lobby.mind.active, "Profile rejection occurred after native mind deactivation")
	lobby.allow_profile = TRUE
	job.fixture_body = allocate(/mob/living/basic)
	TEST_ASSERT_NULL(lobby.create_character(run_loc_floor_bottom_left), "A disconnected specialized body passed admission")
	TEST_ASSERT_EQUAL(lobby.prepare_calls, 2, "Public create_character did not prepare the second request")
	TEST_ASSERT_EQUAL(job.construction_calls, 1, "The public entrypoint did not reach its constructor exactly once")
	TEST_ASSERT_EQUAL(lobby.validation_calls, 1, "A specialized constructor bypassed final player validation")
	TEST_ASSERT(QDELETED(job.fixture_body), "A rejected specialized body was retained")
	TEST_ASSERT_EQUAL(lobby.mind, original_mind, "Rejected construction transferred the lobby mind")
	TEST_ASSERT_EQUAL(original_mind.current, lobby, "Rejected construction changed the mind owner")
	TEST_ASSERT_NULL(lobby.new_character, "A rejected body was committed for handover")

/datum/unit_test/contract_public_create_character/Destroy()
	release_job_player_fixtures()
	return ..()

// The public admission reads /client.holder; the shared mock omits that field.
/datum/client_interface/contract_latejoin_client
	var/datum/admins/holder = null

/mob/dead/new_player/contract_attempt_fixture
	var/failure_stage
	var/begin_calls = 0
	var/validation_calls = 0
	var/availability_calls = 0
	var/creation_calls = 0
	var/handover_calls = 0
	var/received_forced_slot
	var/mob/living/fixture_body

/mob/dead/new_player/contract_attempt_fixture/begin_latejoin_attempt(rank, client/requester)
	begin_calls++
	if(failure_stage == "begin")
		return null
	return ..()

/mob/dead/new_player/contract_attempt_fixture/IsJobUnavailable(rank, latejoin = FALSE)
	availability_calls++
	return JOB_AVAILABLE

/mob/dead/new_player/contract_attempt_fixture/validate_latejoin(rank, client/requester, datum/latejoin_profile_snapshot/context)
	validation_calls++
	if(failure_stage == "validation")
		return reject_late_spawn()
	return ..()

/mob/dead/new_player/contract_attempt_fixture/create_character(atom/destination, forced_slot)
	creation_calls++
	received_forced_slot = forced_slot
	if(failure_stage == "creation")
		return null
	mind.active = FALSE
	mind.transfer_to(fixture_body)
	new_character = fixture_body
	return fixture_body

/mob/dead/new_player/contract_attempt_fixture/transfer_character()
	handover_calls++
	if(failure_stage == "handover")
		return null
	return ..()

/datum/unit_test/contract_public_latejoin
	var/datum/job/contract_entry_fixture/job
	var/state_before
	var/list/queue_before
	var/queue_delay_before
	var/list/minds_before
	var/list/joined_before
	var/lag_before
	var/undocked_before
	var/safe_before
	var/hard_cap_before
	var/extreme_cap_before

/datum/unit_test/contract_public_latejoin/Run()
	job = allocate(/datum/job/contract_entry_fixture)
	job.fixture_destination = run_loc_floor_bottom_left
	SSjob.type_occupations[job.type] = job
	SSjob.name_occupations[job.title] = job
	state_before = SSticker.current_state
	queue_before = SSticker.queued_players
	queue_delay_before = SSticker.queue_delay
	minds_before = SSticker.minds
	joined_before = GLOB.joined_player_list
	lag_before = SSlag_switch.measures[DISABLE_NON_OBSJOBS]
	undocked_before = CONFIG_GET(flag/arrivals_shuttle_require_undocked)
	safe_before = CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin)
	hard_cap_before = CONFIG_GET(number/hard_popcap)
	extreme_cap_before = CONFIG_GET(number/extreme_popcap)
	SSticker.current_state = GAME_STATE_PLAYING
	SSticker.minds = minds_before.Copy()
	GLOB.joined_player_list = joined_before.Copy()
	SSlag_switch.measures[DISABLE_NON_OBSJOBS] = FALSE
	CONFIG_SET(flag/arrivals_shuttle_require_undocked, FALSE)
	CONFIG_SET(flag/arrivals_shuttle_require_safe_latejoin, FALSE)
	CONFIG_SET(number/hard_popcap, 0)
	CONFIG_SET(number/extreme_popcap, 0)
	for(var/stage in list("begin", "validation", "creation", "handover", "success"))
		job.current_positions = 0
		job.equipment_calls = 0
		job.latejoin_calls = 0
		SSticker.queued_players = list()
		var/mob/dead/new_player/contract_attempt_fixture/lobby = allocate(/mob/dead/new_player/contract_attempt_fixture)
		var/datum/client_interface/contract_latejoin_client/player = allocate(/datum/client_interface/contract_latejoin_client)
		player.prefs = allocate(/datum/preferences, player)
		player.prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 40)
		player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
		player.mob = lobby
		lobby.mock_client = player
		player.persistent_client.set_mob(lobby)
		lobby.mind = allocate(/datum/mind)
		lobby.mind.set_current(lobby)
		lobby.fixture_body = allocate(/mob/living/basic)
		lobby.failure_stage = stage
		var/success = stage == "success"
		TEST_ASSERT_EQUAL(lobby.AttemptLateSpawn(job.title), success, "Incorrect public latejoin result at [stage]")
		TEST_ASSERT_EQUAL(lobby.begin_calls, 1, "Native entry did not prepare exactly one request at [stage]")
		TEST_ASSERT_EQUAL(lobby.validation_calls, stage == "begin" ? 0 : 1, "Final admission ran at the wrong phase: [stage]")
		TEST_ASSERT_EQUAL(lobby.creation_calls, (stage in list("creation", "handover", "success")) ? 1 : 0, "Construction ran at the wrong phase: [stage]")
		TEST_ASSERT_EQUAL(lobby.handover_calls, (stage in list("handover", "success")) ? 1 : 0, "Handover ran at the wrong phase: [stage]")
		TEST_ASSERT_EQUAL(job.equipment_calls, success ? 1 : 0, "Native equipment did not run exactly once after handover: [stage]")
		TEST_ASSERT_EQUAL(job.latejoin_calls, success ? 1 : 0, "Native post-spawn bookkeeping was skipped or duplicated: [stage]")
		TEST_ASSERT_NULL(lobby.received_forced_slot, "The replaced current-profile prelude still forced the editing slot")
		TEST_ASSERT_EQUAL(job.current_positions, success ? 1 : 0, "Public entry leaked or double-freed a vacancy: [stage]")
		if(success)
			TEST_ASSERT(QDELETED(lobby), "The complete native tail did not survive actual lobby destruction")
			TEST_ASSERT_EQUAL(length(player.persistent_client.joined_as_slots), 1, "Successful native handover did not record the profile once")

/datum/unit_test/contract_public_latejoin/Destroy()
	if(job)
		SSjob.type_occupations -= job.type
		SSjob.name_occupations -= job.title
		SSticker.current_state = state_before
		SSticker.queued_players = queue_before
		SSticker.queue_delay = queue_delay_before
		SSticker.minds = minds_before
		GLOB.joined_player_list = joined_before
		SSlag_switch.measures[DISABLE_NON_OBSJOBS] = lag_before
		CONFIG_SET(flag/arrivals_shuttle_require_undocked, undocked_before)
		CONFIG_SET(flag/arrivals_shuttle_require_safe_latejoin, safe_before)
		CONFIG_SET(number/hard_popcap, hard_cap_before)
		CONFIG_SET(number/extreme_popcap, extreme_cap_before)
	release_job_player_fixtures()
	return ..()

/datum/unit_test/contract_spawn_cancellation_ownership/Run()
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	var/datum/job/job = SSjob.get_job_type(/datum/job/cargo_technician)
	var/positions_before = job.current_positions
	var/datum/mind/captured_mind = allocate(/datum/mind)
	captured_mind.set_current(lobby)
	captured_mind.set_assigned_role(job)
	lobby.mind = captured_mind
	var/datum/job_character_selection/captured_selection = allocate(/datum/job_character_selection)
	captured_selection.job_type = job.type
	var/datum/job_character_selection/later_selection = allocate(/datum/job_character_selection)
	later_selection.job_type = job.type
	lobby.assigned_character = later_selection
	lobby.spawning = TRUE
	lobby.new_character = allocate(/mob/living/basic)
	TEST_ASSERT(!lobby.cancel_character_spawn(captured_selection, captured_mind), "An old attempt cancelled a newer selection")
	TEST_ASSERT_EQUAL(lobby.assigned_character, later_selection, "An old attempt deleted the newer selection")
	TEST_ASSERT(!QDELETED(lobby.new_character), "An old attempt deleted another caller's body")
	TEST_ASSERT(lobby.spawning, "An old attempt reset another caller's spawning state")
	TEST_ASSERT(!lobby.reject_late_spawn(), "Unowned early rejection returned success")
	TEST_ASSERT(!QDELETED(lobby), "A pre-assignment rejection deleted an assigned offline lobby")
	TEST_ASSERT(lobby.spawning, "A pre-assignment rejection reset another caller's spawning state")
	var/datum/mind/later_mind = allocate(/datum/mind)
	later_mind.set_assigned_role(job)
	lobby.mind = later_mind
	TEST_ASSERT(!lobby.cancel_character_spawn(later_selection, captured_mind), "An old attempt cancelled a newer mind")
	TEST_ASSERT_EQUAL(lobby.mind, later_mind, "An old attempt replaced the newer lobby mind")
	TEST_ASSERT_EQUAL(job.current_positions, positions_before, "An old attempt released another caller's vacancy")

/datum/unit_test/contract_spawn_cancellation_ownership/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/dynamic_ruleset/roundstart/contract_constraints_fixture
	var/fixture_forced_job

/datum/dynamic_ruleset/roundstart/contract_constraints_fixture/get_blacklisted_roles()
	return blacklisted_roles

/datum/dynamic_ruleset/roundstart/contract_constraints_fixture/prepare_for_role(datum/mind/candidate)
	LAZYSET(SSjob.forced_occupations, candidate, fixture_forced_job)

/datum/unit_test/contract_roundstart_changes
	var/list/prevented_before
	var/list/forced_before
	var/list/queued_before

/datum/unit_test/contract_roundstart_changes/Run()
	prevented_before = SSjob.prevented_occupations
	forced_before = SSjob.forced_occupations
	queued_before = SSdynamic.queued_rulesets
	SSjob.prevented_occupations = list()
	SSjob.forced_occupations = list()
	SSdynamic.queued_rulesets = list()
	var/datum/mind/candidate = allocate(/datum/mind)
	var/mob/dead/new_player/player = allocate(/mob/dead/new_player)
	candidate.set_current(player)
	player.mind = candidate
	var/datum/dynamic_ruleset/roundstart/contract_constraints_fixture/first = allocate(/datum/dynamic_ruleset/roundstart/contract_constraints_fixture)
	var/datum/dynamic_ruleset/roundstart/contract_constraints_fixture/second = allocate(/datum/dynamic_ruleset/roundstart/contract_constraints_fixture)
	first.blacklisted_roles = list(JOB_CARGO_TECHNICIAN)
	second.blacklisted_roles = list(JOB_MEDICAL_DOCTOR)
	first.fixture_forced_job = /datum/job/ai
	second.fixture_forced_job = /datum/job/doctor
	SSjob.prevented_occupations[candidate] = list(JOB_PRISONER)
	first.prepare_job_constraints(candidate)
	first.selected_minds += candidate
	SSdynamic.queued_rulesets += first
	TEST_ASSERT(!second.is_valid_candidate(player, null), "The normal queue admitted the same mind to two roundstart rulesets")
	// Bypass candidate selection only to verify that rollback preserves a later independent writer.
	second.prepare_job_constraints(candidate)
	second.selected_minds += candidate
	TEST_ASSERT(first.cancel_assignment(candidate), "The first prepared assignment could not cancel")
	TEST_ASSERT(!(JOB_CARGO_TECHNICIAN in SSjob.prevented_occupations[candidate]), "Cancellation retained its own added blocker")
	TEST_ASSERT(JOB_MEDICAL_DOCTOR in SSjob.prevented_occupations[candidate], "Cancellation removed a later independent blocker")
	TEST_ASSERT(JOB_PRISONER in SSjob.prevented_occupations[candidate], "Cancellation removed a pre-existing blocker")
	TEST_ASSERT_EQUAL(SSjob.forced_occupations[candidate], /datum/job/doctor, "Cancellation restored its previous force over a later writer")

/datum/unit_test/contract_roundstart_changes/Destroy()
	if(prevented_before)
		SSjob.prevented_occupations = prevented_before
		SSjob.forced_occupations = forced_before
		SSdynamic.queued_rulesets = queued_before
	release_job_player_fixtures()
	return ..()
