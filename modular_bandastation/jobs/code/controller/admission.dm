/// Final admission fixes the selected profile before native role assignment occupies the vacancy.
/datum/controller/subsystem/job/proc/prepare_job_assignment(mob/dead/new_player/player, datum/job/job, latejoin)
	var/client/requester = GET_CLIENT(player)
	if(QDELETED(player) || !requester || !player.mind || job.donor_lock_reason(requester))
		return FALSE
	var/datum/job_character_selection/selection = requester.prefs.select_job_character(job, latejoin)
	if(selection.character_error(job, requester, latejoin) || (latejoin && (player.IsJobSlotUnavailable(job) || (!(ckey(player.key) in GLOB.admin_datums) && is_latejoin_population_full()))))
		qdel(selection)
		return FALSE
	QDEL_NULL(player.assigned_character)
	player.assigned_character = selection
	return TRUE

/datum/controller/subsystem/job/proc/check_job_character_eligibility(mob/dead/new_player/player, datum/job/job, latejoin)
	var/client/requester = GET_CLIENT(player)
	if(QDELETED(player) || !requester || !player.mind)
		return JOB_UNAVAILABLE_GENERIC
	if(job.donor_lock_reason(requester))
		return JOB_UNAVAILABLE_DONOR
	var/datum/job_character_selection/selection = requester.prefs.select_job_character(job, latejoin)
	var/too_young = isnum(job.required_character_age) && selection.age < job.required_character_age
	var/profile_error = selection.character_error(job, requester, latejoin)
	qdel(selection)
	if(too_young)
		return JOB_UNAVAILABLE_AGE
	return profile_error ? JOB_UNAVAILABLE_CHARACTER_PROFILE : JOB_AVAILABLE

/// Preserve native Assistant overflow, excluding alternatives unavailable under the server gate.
/mob/dead/new_player/proc/IsJobSlotUnavailable(datum/job/job)
	if(job.total_positions < 0 || job.current_positions < job.total_positions)
		return FALSE
	if(!is_assistant_job(job))
		return TRUE
	var/client/requester = GET_CLIENT(src)
	if(isnum(requester?.player_age) && requester.player_age <= 14)
		return FALSE
	for(var/datum/job/other_job as anything in SSjob.joinable_occupations)
		if(other_job != job && !other_job.donor_lock_reason(requester) && (other_job.total_positions < 0 || other_job.current_positions < other_job.total_positions))
			return TRUE
	return FALSE

/// An assigned lobby character occupies capacity until native handover makes it a living player.
/datum/controller/subsystem/job/proc/is_latejoin_population_full()
	var/hard_cap = CONFIG_GET(number/hard_popcap)
	var/extreme_cap = CONFIG_GET(number/extreme_popcap)
	var/popcap = hard_cap && extreme_cap ? min(hard_cap, extreme_cap) : max(hard_cap, extreme_cap)
	if(!popcap)
		return FALSE
	var/occupants = living_player_count()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player.spawning || !player.assigned_character || isliving(player.client?.mob) || player.new_character?.client)
			continue
		var/datum/job/assigned_job = player.mind?.assigned_role || player.new_character?.mind?.assigned_role
		if(assigned_job && !is_unassigned_job(assigned_job))
			occupants++
	return occupants >= popcap

/// Dynamic and normal occupation selection share native eligibility and canonical preferences.
/mob/dead/new_player/proc/has_eligible_crew_preference(list/blacklisted_roles)
	var/client/requester = GET_CLIENT(src)
	if(!requester)
		return FALSE
	var/random_fallback = requester.prefs.read_preference(/datum/preference/choiced/jobless_role) != RETURNTOLOBBY
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(QDELETED(src) || !requester || GET_CLIENT(src) != requester)
			return FALSE
		if((job.title in blacklisted_roles) || !job.spawn_positions || (job.job_flags & JOB_LATEJOIN_ONLY))
			continue
		if(!requester.prefs.job_preferences[job.title] && (!random_fallback || job.requires_explicit_preference()))
			continue
		var/availability = SSjob.check_job_eligibility(src, job, "Candidate admission")
		if(QDELETED(src) || !requester || GET_CLIENT(src) != requester)
			return FALSE
		if(availability != JOB_AVAILABLE)
			continue
		return TRUE
	return FALSE
