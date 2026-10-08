/datum/preference/name/clown/is_relevant_to_job(datum/job/job)
	return ..() || istype(job, /datum/job/donor/seclown)
