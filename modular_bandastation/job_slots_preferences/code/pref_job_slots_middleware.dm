/datum/preference_middleware/pref_job_slots
	action_delegations = list(
			"set_job_slot" = PROC_REF(set_job_slot),
			"reset_job_slots" = PROC_REF(reset_job_slots),
		)

/datum/preference_middleware/pref_job_slots/get_ui_data(mob/user)
	var/list/data = list()

	data["pref_job_slots"] = preferences.pref_job_slots
	data["profile_index"] = preferences.get_slot_options()
	var/list/job_profiles = list()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(job.job_flags & JOB_LATEJOIN_ONLY)
			continue
		var/datum/job_character_selection/character = preferences.select_job_character(job)
		job_profiles[job.title] = list(
			"slot" = isnum(character.slot) ? character.slot : null,
			"randomized" = character.randomized,
			"error" = character.character_error(job, user.client, FALSE),
		)
		qdel(character)
	data["job_character_profiles"] = job_profiles

	return data

/datum/preference_middleware/pref_job_slots/proc/set_job_slot(list/params, mob/user)
	var/client/player = GET_CLIENT(user)
	if(player?.prefs != preferences || params["edit_slot"] != preferences.default_slot)
		return FALSE

	var/job_title = params["job"]
	var/slot_index = params["slot"]

	if(!istext(job_title) || !isnum(slot_index) || slot_index != round(slot_index))
		return FALSE
	if(slot_index < JOB_SLOT_RANDOMISED_SLOT || slot_index > preferences.max_save_slots)
		return FALSE

	var/datum/job/job = SSjob.get_job(job_title)
	if(!job || job.title != job_title || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		return FALSE
	if(slot_index > 0 && slot_index != preferences.default_slot)
		var/list/saved_profile = preferences.savefile.get_entry("character[slot_index]")
		if(!islist(saved_profile) || !saved_profile["real_name"])
			return FALSE

	preferences.set_job_character_slot(job_title, slot_index)
	return TRUE

/datum/preference_middleware/pref_job_slots/proc/reset_job_slots(list/params, mob/user)
	var/client/player = GET_CLIENT(user)
	if(player?.prefs != preferences || params["edit_slot"] != preferences.default_slot)
		return FALSE
	preferences.reset_job_slots()
	return TRUE

#undef JOB_SLOT_RANDOMISED_SLOT
#undef JOB_SLOT_CURRENT_SLOT
