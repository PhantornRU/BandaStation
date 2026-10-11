/// Display the same selected profile and variant that admission will use.
/datum/latejoin_menu/proc/get_job_character_data(datum/job/job, mob/dead/new_player/user)
	if(!user.client)
		return list("public_title" = job_title_ru(job.title))
	var/datum/preferences/preferences = user.client.prefs
	var/datum/job_character_selection/character = preferences.select_job_character(job, TRUE)
	var/public_title = job_title_ru(job.title)
	if(length(job.donor_variant_specs))
		var/list/variants = character.read_preference(/datum/preference/job_outfit_variants)
		var/datum/job_variant/variant = job.resolve_donor_variant(variants?[job.title])
		public_title = variant?.public_title || public_title
	var/profile_name = character.read_preference(/datum/preference/name/real_name)
	var/profile_description = character.error ? "Недоступный профиль" : "Профиль [character.slot]: [profile_name]"
	if(character.randomized)
		profile_description += ", случайные имя и внешность"
	var/list/data = list(
		"public_title" = public_title,
		"character_profile" = profile_description,
	)
	qdel(character)
	return data

/datum/latejoin_menu/proc/get_job_unavailable_reason(datum/job/job, mob/dead/new_player/user, availability)
	if(availability == JOB_AVAILABLE)
		return null
	if(availability == JOB_UNAVAILABLE_DONOR)
		return job.donor_lock_reason(user.client) || get_job_unavailable_error_message(availability, job.title)
	return get_job_unavailable_error_message(availability, job.title)
