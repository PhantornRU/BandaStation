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
	release_job_player_fixtures()
	if(!isnull(reserved_positions_before))
		reserved_job.current_positions = reserved_positions_before
		reserved_job.total_positions = reserved_total_before
	if(!isnull(unassigned_positions_before))
		unassigned_job.current_positions = unassigned_positions_before
	return ..()

/datum/unit_test/donor_final_admission
	var/datum/job/prisoner/job
	var/turf/prisoner_turf
	var/area/prisoner_area_before
	var/list/prisoner_starts_before
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
	for(var/station_z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/open/floor/candidate in Z_TURFS(station_z))
			if(candidate.is_blocked_turf(TRUE))
				continue
			var/occupied = FALSE
			for(var/atom/movable/content as anything in candidate)
				if(!istype(content, /atom/movable/lighting_object))
					occupied = TRUE
					break
			if(occupied)
				continue
			prisoner_turf = candidate
			break
		if(prisoner_turf)
			break
	TEST_ASSERT_NOTNULL(prisoner_turf, "The map has no safe station turf for the native prisoner landmark")
	prisoner_area_before = get_area(prisoner_turf)
	prisoner_starts_before = GLOB.donor_prisoner_starts.Copy()
	var/area/prisoner_area = GLOB.areas_by_type[/area/station/security/prison]
	if(!prisoner_area)
		// allocate() passes a turf to atoms; an area constructor would also move that turf.
		prisoner_area = new /area/station/security/prison
		allocated += prisoner_area
	prisoner_turf.change_area(prisoner_area_before, prisoner_area)
	allocate(/obj/effect/landmark/start/prisoner, prisoner_turf)
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
	TEST_ASSERT(SSjob.assign_role(first, job, latejoin = TRUE, do_eligibility_checks = FALSE), "A cumulative higher tier could not take the last native position: [job.donor_lock_reason(first_player)]")
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
	release_job_player_fixtures()
	if(prisoner_area_before)
		prisoner_turf.change_area(get_area(prisoner_turf), prisoner_area_before)
		GLOB.donor_prisoner_starts = prisoner_starts_before
	if(!isnull(positions_before))
		job.current_positions = positions_before
		job.total_positions = total_before
		CONFIG_SET(flag/donor_prisoner_gate, gate_before)
		CONFIG_SET(number/hard_popcap, hard_cap_before)
		CONFIG_SET(number/extreme_popcap, extreme_cap_before)
	return ..()

/datum/client_interface/entry_admission_test
	var/datum/admins/holder

/mob/dead/new_player/entry_admission_change_test
	var/availability_calls = 0
	var/mob/dead/new_player/next_in_queue

/mob/dead/new_player/entry_admission_change_test/IsJobUnavailable(rank, latejoin = FALSE)
	if(++availability_calls == 2)
		if(next_in_queue)
			SSticker.queued_players = list(next_in_queue)
		else
			SSlag_switch.measures[DISABLE_NON_OBSJOBS] = TRUE
	return JOB_AVAILABLE

/datum/unit_test/native_latejoin_admission_recheck
	var/datum/job/job
	var/positions_before
	var/total_before
	var/role_changes = 0
	var/state_before
	var/list/queue_before
	var/lag_before
	var/undocked_before
	var/safe_before
	var/hard_cap_before
	var/extreme_cap_before

/datum/unit_test/native_latejoin_admission_recheck/Run()
	state_before = SSticker.current_state
	queue_before = SSticker.queued_players
	lag_before = SSlag_switch.measures[DISABLE_NON_OBSJOBS]
	undocked_before = CONFIG_GET(flag/arrivals_shuttle_require_undocked)
	safe_before = CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin)
	hard_cap_before = CONFIG_GET(number/hard_popcap)
	extreme_cap_before = CONFIG_GET(number/extreme_popcap)
	SSticker.current_state = GAME_STATE_PLAYING
	CONFIG_SET(flag/arrivals_shuttle_require_undocked, FALSE)
	CONFIG_SET(flag/arrivals_shuttle_require_safe_latejoin, FALSE)
	CONFIG_SET(number/hard_popcap, 0)
	CONFIG_SET(number/extreme_popcap, 0)
	job = SSjob.get_job_type(/datum/job/cargo_technician)
	positions_before = job.current_positions
	total_before = job.total_positions
	job.total_positions = -1
	for(var/queue_changes in list(FALSE, TRUE))
		SSlag_switch.measures[DISABLE_NON_OBSJOBS] = FALSE
		SSticker.queued_players = list()
		var/mob/dead/new_player/entry_admission_change_test/lobby = allocate(/mob/dead/new_player/entry_admission_change_test)
		var/datum/client_interface/player = allocate(/datum/client_interface/entry_admission_test)
		player.prefs = allocate(/datum/preferences, player)
		player.mob = lobby
		lobby.mock_client = player
		lobby.mind = allocate(/datum/mind)
		lobby.mind.set_current(lobby)
		RegisterSignal(lobby, COMSIG_MOB_MIND_SET_ROLE, PROC_REF(note_role_change))
		if(queue_changes)
			lobby.next_in_queue = allocate(/mob/dead/new_player)
		lobby.spawning = TRUE
		TEST_ASSERT(!lobby.AttemptLateSpawn(job.title), "A repeated request entered while the first request was spawning")
		TEST_ASSERT_EQUAL(lobby.availability_calls, 0, "A repeated request reached eligibility checks")
		lobby.spawning = FALSE
		TEST_ASSERT(!lobby.AttemptLateSpawn(job.title), "A changed queue or load restriction was ignored after eligibility recheck")
		TEST_ASSERT_EQUAL(lobby.availability_calls, 2, "The attempt did not reach the final eligibility boundary")
		TEST_ASSERT_EQUAL(role_changes, 0, "A rejected attempt assigned a job before cancelling its spawn")
		TEST_ASSERT(!lobby.spawning, "A rejected attempt retained its spawning state")
		TEST_ASSERT_NULL(lobby.new_character, "A rejected attempt created a partial character")
		TEST_ASSERT_EQUAL(job.current_positions, positions_before, "A rejected attempt occupied a native job position")
		TEST_ASSERT_EQUAL(lobby.mind.assigned_role.type, /datum/job/unassigned, "A rejected attempt changed the canonical role")

/datum/unit_test/native_latejoin_admission_recheck/proc/note_role_change(mob/source, datum/job/new_role)
	SIGNAL_HANDLER
	role_changes++

/datum/unit_test/native_latejoin_admission_recheck/Destroy()
	if(job)
		job.current_positions = positions_before
		job.total_positions = total_before
	if(!isnull(state_before))
		SSticker.current_state = state_before
		SSticker.queued_players = queue_before
		SSlag_switch.measures[DISABLE_NON_OBSJOBS] = lag_before
		CONFIG_SET(flag/arrivals_shuttle_require_undocked, undocked_before)
		CONFIG_SET(flag/arrivals_shuttle_require_safe_latejoin, safe_before)
		CONFIG_SET(number/hard_popcap, hard_cap_before)
		CONFIG_SET(number/extreme_popcap, extreme_cap_before)
	release_job_player_fixtures()
	return ..()

/datum/client_interface/assistant_overflow_test
	var/player_age = 30

/datum/unit_test/donor_assistant_overflow
	var/datum/job/assistant
	var/positions_before
	var/total_before
	var/list/joinable_before
	var/enabled_before
	var/hard_cap_before
	var/extreme_cap_before

/datum/unit_test/donor_assistant_overflow/Run()
	assistant = SSjob.get_job_type(/datum/job/assistant)
	positions_before = assistant.current_positions
	total_before = assistant.total_positions
	joinable_before = SSjob.joinable_occupations
	enabled_before = CONFIG_GET(flag/donor_jobs_enabled)
	hard_cap_before = CONFIG_GET(number/hard_popcap)
	extreme_cap_before = CONFIG_GET(number/extreme_popcap)
	CONFIG_SET(number/hard_popcap, 0)
	CONFIG_SET(number/extreme_popcap, 0)
	assistant.current_positions = 1
	assistant.total_positions = 1
	var/datum/job/ordinary = allocate(/datum/job/cargo_technician)
	ordinary.total_positions = 1
	ordinary.current_positions = 1
	var/datum/job/donor/alternative = allocate(/datum/job/donor/vip_guest)
	alternative.total_positions = -1
	SSjob.joinable_occupations = list(assistant, ordinary, alternative)
	var/datum/client_interface/assistant_overflow_test/player = allocate(/datum/client_interface/assistant_overflow_test)
	player.ban_cache = list()
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 35)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	lobby.mock_client = player
	player.mob = lobby
	lobby.key = player.key
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	for(var/list/scenario as anything in list(
		list("enabled" = TRUE, "tier" = 0, "age" = 30, "available" = TRUE),
		list("enabled" = TRUE, "tier" = DONATOR_TIER_5, "age" = 30, "available" = FALSE),
		list("enabled" = FALSE, "tier" = DONATOR_TIER_5, "age" = 30, "available" = TRUE),
		list("enabled" = TRUE, "tier" = DONATOR_TIER_5, "age" = 14, "available" = TRUE),
	))
		CONFIG_SET(flag/donor_jobs_enabled, scenario["enabled"])
		player.donator_level = scenario["tier"]
		player.player_age = scenario["age"]
		TEST_ASSERT_EQUAL(lobby.IsJobUnavailable(assistant.title, latejoin = TRUE), scenario["available"] ? JOB_AVAILABLE : JOB_UNAVAILABLE_SLOTFULL, "Assistant admission counted an unavailable donor alternative")
		TEST_ASSERT_EQUAL(SSjob.assign_role(lobby, assistant, latejoin = TRUE, do_eligibility_checks = FALSE), scenario["available"], "Final Assistant admission disagreed with the menu capacity check")
		if(scenario["available"])
			TEST_ASSERT_EQUAL(assistant.current_positions, 2, "Assistant admission did not use the native position counter")
			lobby.cancel_character_spawn()
		TEST_ASSERT_EQUAL(assistant.current_positions, 1, "Assistant rejection or cancellation changed another occupied position")

/datum/unit_test/donor_assistant_overflow/Destroy()
	if(assistant)
		assistant.current_positions = positions_before
		assistant.total_positions = total_before
		SSjob.joinable_occupations = joinable_before
		CONFIG_SET(flag/donor_jobs_enabled, enabled_before)
		CONFIG_SET(number/hard_popcap, hard_cap_before)
		CONFIG_SET(number/extreme_popcap, extreme_cap_before)
	release_job_player_fixtures()
	return ..()
