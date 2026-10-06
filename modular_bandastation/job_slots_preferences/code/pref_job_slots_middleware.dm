/datum/preference_middleware/pref_job_slots
	action_delegations = list(
			"set_job_slot" = PROC_REF(set_job_slot),
			"reset_job_slots" = PROC_REF(reset_job_slots),
		)

/datum/preference_middleware/pref_job_slots/get_ui_data(mob/user)
	var/list/data = list()

	data["pref_job_slots"] = preferences.pref_job_slots
	data["profile_index"] = preferences.get_slot_options()

	return data

/datum/preference_middleware/pref_job_slots/proc/set_job_slot(list/params, mob/user)
	if(user.client?.prefs != preferences || preferences.donor_entry_locked || params["edit_slot"] != preferences.default_slot)
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
	if(slot_index > 0 && slot_index != preferences.default_slot && !preferences.savefile.get_entry("character[slot_index]")?["real_name"])
		return FALSE

	preferences.pref_job_slots[job_title] = slot_index

	preferences.save_preferences()
	return TRUE

/datum/preference_middleware/pref_job_slots/proc/reset_job_slots(list/params, mob/user)
	if(user.client?.prefs != preferences || preferences.donor_entry_locked || params["edit_slot"] != preferences.default_slot)
		return FALSE
	preferences.reset_job_slots()
	return TRUE

#undef JOB_SLOT_RANDOMISED_SLOT
#undef JOB_SLOT_CURRENT_SLOT
