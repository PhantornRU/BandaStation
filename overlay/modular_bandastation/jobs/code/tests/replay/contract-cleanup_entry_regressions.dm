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
	var/selection_type = /datum/job_character_selection
	var/datum/job_character_creation/last_creation

// No real BYOND client is available; supply a profile to reach the native constructor.
/mob/dead/new_player/contract_create_fixture/prepare_character_profile(atom/destination, forced_slot)
	prepare_calls++
	if(!allow_profile)
		return null
	assigned_character = new selection_type
	assigned_character.job_type = mind.assigned_role.type
	return assigned_character

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
	// Only four audited TEMP input reads accept this mock. Native constructor and
	// final connected-client checks remain unchanged and must reject the body.
	var/datum/client_interface/requester = allocate(/datum/client_interface)
	requester.prefs = allocate(/datum/preferences, requester)
	requester.mob = lobby
	lobby.mock_client = requester
	lobby.allow_profile = TRUE
	job.fixture_body = allocate(/mob/living/basic)
	TEST_ASSERT_NULL(lobby.create_character(run_loc_floor_bottom_left), "A disconnected specialized body passed admission")
	TEST_ASSERT_EQUAL(lobby.prepare_calls, 2, "Public create_character did not prepare the second request")
	TEST_ASSERT_EQUAL(job.construction_calls, 1, "The public entrypoint did not reach its constructor exactly once")
	TEST_ASSERT_EQUAL(lobby.validation_calls, 1, "A specialized constructor bypassed final player validation")
	TEST_ASSERT(QDELETED(lobby.last_creation), "The public constructor retained its consumed context")
	TEST_ASSERT(QDELETED(job.fixture_body), "A rejected specialized body was retained")
	TEST_ASSERT_EQUAL(lobby.mind, original_mind, "Rejected construction transferred the lobby mind")
	TEST_ASSERT_EQUAL(original_mind.current, lobby, "Rejected construction changed the mind owner")
	TEST_ASSERT_NULL(lobby.new_character, "A rejected body was committed for handover")

/datum/unit_test/contract_public_create_character/Destroy()
	release_job_player_fixtures()
	return ..()

// External TEMP-only constructor interruptions. No real client is supplied:
// these prove captured ownership, rollback and cleanup, not connected admission.
/datum/job_character_selection/contract_creation_harddelete/Destroy(force)
	. = ..()
	return QDEL_HINT_HARDDEL_NOW

/mob/dead/new_player/contract_create_fixture/interruptions
	selection_type = /datum/job_character_selection/contract_creation_harddelete

/mob/dead/new_player/contract_create_fixture/interruptions/Destroy(force)
	. = ..()
	return QDEL_HINT_HARDDEL_NOW

/datum/job/contract_creation_interrupt_fixture
	parent_type = /datum/job/contract_entry_fixture
	var/datum/unit_test/contract_public_creation_context/fixture_test
	var/mob/dead/new_player/contract_create_fixture/interruptions/fixture_owner
	var/mode
	var/datum/mind/foreign_mind
	var/datum/job_character_selection/replacement_assignment
	var/datum/job_character_creation/last_creation
	var/datum/mind/captured_mind
	var/datum/job_character_selection/captured_assignment
	var/validation_calls = 0
	var/reentrant_result
	var/reentrant_creation_in_progress

/datum/job/contract_creation_interrupt_fixture/get_spawn_mob(client/player_client, atom/spawn_point)
	construction_calls++
	var/mob/dead/new_player/contract_create_fixture/interruptions/owner = fixture_owner
	if(mode == "reentrant")
		reentrant_result = owner.create_character(spawn_point)
		reentrant_creation_in_progress = owner.character_creation_in_progress
	if(foreign_mind)
		fixture_body = fixture_test.allocate(/mob/living/basic)
		foreign_mind.transfer_to(fixture_body)
	else
		// Use real AI initialization to move the captured mind before interruption.
		fixture_body = fixture_test.allocate(/mob/living/silicon/ai, spawn_point, owner, null, null, TRUE)
	if(mode == "replace_owned" || mode == "replace_foreign")
		qdel(owner.assigned_character)
		replacement_assignment = fixture_test.allocate(/datum/job_character_selection)
		replacement_assignment.job_type = type
		owner.assigned_character = replacement_assignment
	if(mode == "delete_owned" || mode == "delete_foreign")
		qdel(owner)
	return fixture_body

/datum/unit_test/contract_public_creation_context/Run()
	for(var/mode in list("replace_owned", "replace_foreign", "delete_owned", "delete_foreign", "reentrant"))
		var/mob/dead/new_player/contract_create_fixture/interruptions/lobby = allocate(/mob/dead/new_player/contract_create_fixture/interruptions)
		var/datum/job/contract_creation_interrupt_fixture/job = allocate(/datum/job/contract_creation_interrupt_fixture)
		job.fixture_test = src
		job.fixture_owner = lobby
		job.mode = mode
		lobby.mind = allocate(/datum/mind)
		lobby.mind.set_current(lobby)
		lobby.mind.set_assigned_role(job)
		var/datum/mind/original_mind = lobby.mind
		var/datum/client_interface/requester = allocate(/datum/client_interface)
		requester.prefs = allocate(/datum/preferences, requester)
		requester.prefs.load_and_save = FALSE
		requester.prefs.path = null
		requester.mob = lobby
		lobby.mock_client = requester
		lobby.allow_profile = TRUE
		if(mode == "replace_foreign" || mode == "delete_foreign")
			job.foreign_mind = allocate(/datum/mind)
			job.foreign_mind.set_assigned_role(job)
		TEST_ASSERT_NULL(lobby.create_character(run_loc_floor_bottom_left), "The [mode] interrupted public constructor accepted its body")
		TEST_ASSERT_EQUAL(job.construction_calls, 1, "The [mode] public constructor repeated or skipped body creation")
		TEST_ASSERT_EQUAL(job.validation_calls, 1, "The [mode] constructor bypassed final native validation")
		TEST_ASSERT_NOTNULL(job.last_creation, "The [mode] validator did not receive the per-call context")
		TEST_ASSERT(QDELETED(job.last_creation), "The [mode] validator retained its consumed context")
		TEST_ASSERT_EQUAL(job.captured_mind, original_mind, "The [mode] context reread its mind after construction")
		TEST_ASSERT_EQUAL(length(requester.persistent_client.joined_as_slots), 0, "The [mode] failure appended respawn history")
		if(job.foreign_mind)
			TEST_ASSERT(!QDELETED(job.fixture_body), "The [mode] validator deleted a foreign mind's body")
			TEST_ASSERT_EQUAL(job.fixture_body.mind, job.foreign_mind, "The [mode] validator stole a foreign mind's body")
			TEST_ASSERT_EQUAL(job.foreign_mind.current, job.fixture_body, "The [mode] validator detached a foreign mind")
		else
			TEST_ASSERT(QDELETED(job.fixture_body), "The [mode] validator retained its own rejected AI body")
		if(mode == "delete_owned" || mode == "delete_foreign")
			TEST_ASSERT_NULL(lobby, "The [mode] constructor did not actually hard-delete the lobby")
			TEST_ASSERT(!GLOB.new_player_list.Find(null), "The [mode] hard deletion left a null lobby registry entry")
		else
			TEST_ASSERT_NULL(lobby.new_character, "The [mode] failure committed a body for handover")
			TEST_ASSERT_EQUAL(lobby.mind, original_mind, "The [mode] failure lost the captured lobby mind")
			TEST_ASSERT_EQUAL(original_mind.current, lobby, "The [mode] failure retained its mind in a discarded body")
			TEST_ASSERT(!lobby.character_creation_in_progress, "The [mode] failure left creation locked")
		if(mode == "replace_owned" || mode == "replace_foreign")
			TEST_ASSERT_NULL(job.captured_assignment, "The [mode] context followed a replacement assignment")
			TEST_ASSERT_EQUAL(lobby.assigned_character, job.replacement_assignment, "The [mode] rejection cleared a newer assignment")
			TEST_ASSERT(!QDELETED(job.replacement_assignment), "The [mode] rejection deleted a newer assignment")
		if(mode == "reentrant")
			TEST_ASSERT_NULL(job.reentrant_result, "A reentrant construction was accepted")
			TEST_ASSERT(job.reentrant_creation_in_progress, "A nested rejection cleared the outer construction lock")
			TEST_ASSERT_EQUAL(lobby.prepare_calls, 1, "A reentrant construction prepared another profile")

/datum/unit_test/contract_public_creation_context/Destroy()
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

/mob/dead/new_player/contract_attempt_fixture/capture_latejoin_request(rank)
	begin_calls++
	if(failure_stage == "begin")
		return null
	return ..()

/mob/dead/new_player/contract_attempt_fixture/IsJobUnavailable(rank, latejoin = FALSE)
	availability_calls++
	return JOB_AVAILABLE

/mob/dead/new_player/contract_attempt_fixture/validate_latejoin_request(rank, check_queue = TRUE)
	validation_calls++
	if(failure_stage == "validation")
		return reject_late_spawn()
	return ..()

/mob/dead/new_player/contract_attempt_fixture/create_character(atom/destination, forced_slot)
	creation_calls++
	received_forced_slot = forced_slot
	if(failure_stage == "creation")
		assigned_character.spawn_rejection = "Controlled profile rejection"
		return null
	mind.active = FALSE
	mind.transfer_to(fixture_body)
	new_character = fixture_body
	assigned_character.created_body = fixture_body
	assigned_character.created_mind = fixture_body.mind
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
		lobby.PossessByPlayer(player.key)
		player.persistent_client.set_mob(lobby)
		lobby.mind = allocate(/datum/mind)
		lobby.mind.key = player.key
		lobby.mind.set_current(lobby)
		lobby.fixture_body = allocate(/mob/living/basic)
		lobby.failure_stage = stage
		var/success = stage == "success"
		TEST_ASSERT_EQUAL(lobby.AttemptLateSpawn(job.title), success, "Incorrect public latejoin result at [stage]")
		TEST_ASSERT_EQUAL(lobby.begin_calls, 1, "Native entry did not prepare exactly one request at [stage]")
		TEST_ASSERT_EQUAL(lobby.validation_calls, stage == "begin" ? 0 : (stage == "validation" ? 1 : 2), "Wait/assignment request checks ran at the wrong phase: [stage]")
		TEST_ASSERT_EQUAL(lobby.creation_calls, (stage in list("creation", "handover", "success")) ? 1 : 0, "Construction ran at the wrong phase: [stage]")
		TEST_ASSERT_EQUAL(lobby.handover_calls, (stage in list("handover", "success")) ? 1 : 0, "Handover ran at the wrong phase: [stage]")
		TEST_ASSERT_EQUAL(job.equipment_calls, success ? 1 : 0, "Native equipment did not run exactly once after handover: [stage]")
		TEST_ASSERT_EQUAL(job.latejoin_calls, success ? 1 : 0, "Native post-spawn bookkeeping was skipped or duplicated: [stage]")
		if(lobby.creation_calls)
			TEST_ASSERT_EQUAL(lobby.received_forced_slot, 1, "Native create did not receive the committed selected slot")
		TEST_ASSERT_EQUAL(job.current_positions, success ? 1 : 0, "Public entry leaked or double-freed a vacancy: [stage]")
		if(success)
			TEST_ASSERT(QDELETED(lobby), "The complete native tail did not survive actual lobby destruction")
			TEST_ASSERT_EQUAL(length(player.persistent_client.joined_as_slots), 0, "The latejoin caller duplicated history owned by the constructor seam")

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
	var/datum/job/job = SSjob.get_job_type(/datum/job/assistant)
	var/datum/client_interface/requester = allocate(/datum/client_interface/roundstart_selection_test)
	requester.ban_cache = list()
	requester.prefs = allocate(/datum/preferences, requester)
	requester.prefs.job_preferences = list(job.title = JP_HIGH)
	requester.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/jobless_role], RETURNTOLOBBY)
	requester.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
	requester.prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 35)
	player.mock_client = requester
	requester.mob = player
	player.key = requester.key
	var/datum/dynamic_ruleset/roundstart/contract_constraints_fixture/first = allocate(/datum/dynamic_ruleset/roundstart/contract_constraints_fixture)
	var/datum/dynamic_ruleset/roundstart/contract_constraints_fixture/second = allocate(/datum/dynamic_ruleset/roundstart/contract_constraints_fixture)
	first.max_antag_cap = 1
	second.max_antag_cap = 1
	first.blacklisted_roles = list(JOB_CARGO_TECHNICIAN)
	second.blacklisted_roles = list(JOB_MEDICAL_DOCTOR)
	first.fixture_forced_job = /datum/job/ai
	second.fixture_forced_job = /datum/job/doctor
	SSjob.prevented_occupations[candidate] = list(JOB_PRISONER)
	TEST_ASSERT(first.prepare_execution(1, list(player)), "Native preparation could not select the first assignment")
	TEST_ASSERT(candidate in first.selected_minds, "Native preparation did not select the candidate")
	TEST_ASSERT(JOB_CARGO_TECHNICIAN in SSjob.prevented_occupations[candidate], "The original native blocker operation did not run")
	TEST_ASSERT_EQUAL(SSjob.forced_occupations[candidate], /datum/job/ai, "The native prepare_for_role operation did not run")
	SSdynamic.queued_rulesets += first
	TEST_ASSERT(!second.prepare_execution(1, list(player)), "The native queue admitted the same mind to two roundstart rulesets")
	TEST_ASSERT_EQUAL(length(second.selected_minds), 0, "A native queued-mind veto still prepared an assignment")
	// Model a later independent writer outside the queue, using the same native caller.
	SSdynamic.queued_rulesets = list()
	TEST_ASSERT(second.prepare_execution(1, list(player)), "Native preparation could not perform the later independent write")
	TEST_ASSERT(candidate in second.selected_minds, "The independent writer was not selected by the native caller")
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
