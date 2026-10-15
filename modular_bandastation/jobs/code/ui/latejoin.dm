/// Display the same selected profile and variant that admission will use.
/datum/latejoin_menu/proc/get_job_character_data(datum/job/job, mob/dead/new_player/user)
	if(!user.client)
		return list("public_title" = job_title_ru(job.title))
	var/datum/preferences/preferences = user.client.prefs
	var/datum/job_character_selection/character = preferences.select_job_character(job, TRUE)
	var/public_title = job.get_character_job_title(character)
	var/profile_name = character.read_preference(/datum/preference/name/real_name)
	var/profile_description = character.error ? "Недоступный профиль" : "Профиль [character.slot]: [profile_name]"
	if(character.randomized)
		profile_description += ", случайные имя и внешность"
	var/list/data = list(
		"public_title" = public_title,
		"character_profile" = profile_description,
		"job_icon" = icon2base64(job.get_character_job_icon(character)),
	)
	qdel(character)
	return data

/datum/latejoin_menu/proc/get_job_unavailable_reason(datum/job/job, mob/dead/new_player/user, availability)
	if(availability == JOB_AVAILABLE)
		return null
	if(availability == JOB_UNAVAILABLE_JOB_LOCK)
		return job.get_join_lock_reason(user.client) || get_job_unavailable_error_message(availability, job.title)
	return get_job_unavailable_error_message(availability, job.title)

/// Keep the fallback label tied to a canonical job, even when public titles collide.
/datum/latejoin_menu/proc/get_job_choice_label(datum/job/job, mob/dead/new_player/user, availability, list/choices)
	var/list/character_data = get_job_character_data(job, user)
	var/label = "[character_data["public_title"]] ([character_data["character_profile"]])"
	var/reason = get_job_unavailable_reason(job, user, availability)
	if(reason)
		label += " — [reason]"
	if(choices[label])
		label += " ([job.title])"
	return label

/// Enrich only native dynamic rows: hidden jobs stay hidden and eligibility is not repeated.
/datum/latejoin_menu/ui_data(mob/user)
	var/client/requester = user.client
	var/editing_slot = requester?.prefs.default_slot
	var/list/job_slots = requester?.prefs.pref_job_slots
	job_slots = islist(job_slots) ? job_slots.Copy() : list()
	var/always_current_slot = requester ? requester.prefs.read_preference(/datum/preference/toggle/late_join_always_current_slot) : null
	. = ..()
	if(QDELETED(user) || !requester || user.client != requester || requester.prefs.default_slot != editing_slot)
		return list()
	var/list/current_job_slots = requester.prefs.pref_job_slots
	current_job_slots = islist(current_job_slots) ? current_job_slots : list()
	if(length(current_job_slots) != length(job_slots) || requester.prefs.read_preference(/datum/preference/toggle/late_join_always_current_slot) != always_current_slot)
		return list()
	for(var/job_title in job_slots)
		if(!(job_title in current_job_slots) || current_job_slots[job_title] != job_slots[job_title])
			return list()
	var/list/data = .
	data["edit_slot"] = editing_slot
	var/list/departments = data["departments"]
	for(var/department_name in departments)
		var/list/department_data = departments[department_name]
		department_data["open_slots"] = 0
		var/list/department_jobs = department_data["jobs"]
		for(var/job_title in department_jobs)
			extend_job_character_data(SSjob.get_job(job_title), user, department_jobs[job_title], department_data)

/// Extend one completed row and count only vacancies available to this player.
/datum/latejoin_menu/proc/extend_job_character_data(datum/job/job, mob/dead/new_player/user, list/job_data, list/department_data)
	job_data += get_job_character_data(job, user)
	var/unavailable_reason = job_data["unavailable_reason"]
	if(unavailable_reason)
		if(unavailable_reason == get_job_unavailable_error_message(JOB_UNAVAILABLE_JOB_LOCK, job.title))
			job_data["unavailable_reason"] = job.get_join_lock_reason(user.client) || unavailable_reason
		return
	if(job.total_positions < 0)
		department_data["open_slots"] = "∞"
	if(department_data["open_slots"] != "∞")
		if(job.total_positions - job.current_positions > 0)
			department_data["open_slots"] += job.total_positions - job.current_positions

/// A modal random choice may yield; stale selections must not enter as another profile.
/datum/latejoin_menu/proc/select_character_job(mob/dead/new_player/owner, list/params)
	var/client/requester = owner.client
	var/editing_slot = requester.prefs.default_slot
	if(params["edit_slot"] != editing_slot)
		return TRUE
	if(params["job"] == "Random")
		var/job = get_random_job(owner)
		if(!job)
			return TRUE
		params["job"] = job
	if(QDELETED(owner) || owner.client != requester || requester.mob != owner)
		return TRUE
	if(requester.prefs.default_slot != editing_slot)
		return TRUE
	owner.AttemptLateSpawn(params["job"])
