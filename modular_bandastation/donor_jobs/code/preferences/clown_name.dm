/datum/preference_middleware/names/get_name_to_use()
	if(istype(preferences.get_highest_priority_job(), /datum/job/donor/seclown))
		return "clown_name"
	return ..()
