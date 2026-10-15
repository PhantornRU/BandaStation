/// Roles requiring an explicit preference cannot become the automatic overflow assignment.
/datum/controller/subsystem/job/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = ispath(new_overflow_role) ? get_job_type(new_overflow_role) : get_job(new_overflow_role)
	if(new_overflow?.requires_explicit_preference())
		job_debug("SET_OVRFLW: Failed to set new overflow role: [new_overflow_role]")
		CRASH("set_overflow_role failed | new_overflow_role: [isnull(new_overflow_role) ? "null" : new_overflow_role]")
	. = ..()

/// Preserve native account, playtime and ban checks, then validate the current requester's selected profile.
/datum/controller/subsystem/job/check_job_eligibility(mob/dead/new_player/player, datum/job/possible_job, debug_prefix = "", add_job_to_log = FALSE, latejoin = FALSE)
	var/client/player_client = player ? GET_CLIENT(player) : null
	if(!player?.mind || !possible_job || !player_client)
		job_debug("[debug_prefix]: Player has no mind, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC
	. = ..(player, possible_job, debug_prefix, add_job_to_log)
	if(. != JOB_AVAILABLE)
		return
	// is_banned_from in the native parent can query the database and sleep.
	if(QDELETED(player) || GET_CLIENT(player) != player_client)
		job_debug("[debug_prefix]: Player is qdeleted, Player: [player][add_job_to_log ? ", Job: [possible_job]" : ""]")
		return JOB_UNAVAILABLE_GENERIC
	return check_job_character_eligibility(player, possible_job, latejoin)

/// Fix the selected profile before native assignment occupies the vacancy, including prechecked callers.
/datum/controller/subsystem/job/assign_role(mob/dead/new_player/player, datum/job/job, latejoin = FALSE, do_eligibility_checks = TRUE, is_debug_dummy = FALSE)
	if(!player?.mind || !job)
		return FALSE
	if(do_eligibility_checks && check_job_eligibility(player, job, "AR", add_job_to_log = TRUE, latejoin = latejoin) != JOB_AVAILABLE)
		return FALSE
	if(!prepare_job_assignment(player, job, latejoin, is_debug_dummy))
		return FALSE
	return ..(player, job, latejoin, FALSE)

/// Release cancelled selections before native role changes, including lobbies without a mind.
/datum/controller/subsystem/job/reset_occupations()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player?.assigned_character)
			QDEL_NULL(player.assigned_character)
	. = ..()

/// Check each fallback candidate before eligibility and again after its potentially yielding lookup.
/datum/controller/subsystem/job/proc/check_random_job_eligibility(mob/dead/new_player/player, datum/job/job, debug_prefix = "GRJ", add_job_to_log = TRUE)
	var/client/requester = player ? GET_CLIENT(player) : null
	if(job.requires_explicit_preference() && !requester?.prefs?.job_preferences[job.title])
		return JOB_UNAVAILABLE_GENERIC
	var/eligibility = check_job_eligibility(player, job, debug_prefix, add_job_to_log = add_job_to_log)
	if(eligibility != JOB_AVAILABLE)
		return eligibility
	if(QDELETED(player) || !requester?.prefs || GET_CLIENT(player) != requester)
		return JOB_UNAVAILABLE_GENERIC
	if(job.requires_explicit_preference() && !requester.prefs.job_preferences[job.title])
		return JOB_UNAVAILABLE_GENERIC
	return eligibility
