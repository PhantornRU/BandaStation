/// Load the assignment format without erasing temporarily unavailable jobs or slots.
/datum/preferences/proc/load_job_character_slots()
	pref_job_slots = list()
	var/list/saved_slots = savefile.get_entry("pref_job_slots")
	if(!islist(saved_slots))
		return
	for(var/job_title in saved_slots)
		if(!istext(job_title) || !length(job_title))
			continue
		var/slot_index = saved_slots[job_title]
		if(!isnum(slot_index) || round(slot_index) != slot_index || slot_index < JOB_SLOT_RANDOMISED_SLOT)
			continue
		if(slot_index != JOB_SLOT_CURRENT_SLOT)
			pref_job_slots[job_title] = slot_index

/datum/preferences/proc/save_job_character_slots()
	savefile.set_entry("pref_job_slots", pref_job_slots)
