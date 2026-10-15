/// Native messages stay native; only module-specific rejection codes reach this fallback.
/proc/get_extended_job_unavailable_error_message(retval, jobtitle)
	switch(retval)
		if(JOB_UNAVAILABLE_JOB_LOCK)
			return "Профессия недоступна по дополнительным условиям входа."
		if(JOB_UNAVAILABLE_CHARACTER_PROFILE)
			return "Назначенный персонаж не проходит условия профессии. Проверьте слот, возраст, вид и повторный вход."
	return GENERIC_JOB_UNAVAILABLE_ERROR

/// Keep metadata for vacancies that can reopen; ui_data owns live visibility without static SQL.
/datum/latejoin_menu/proc/uses_dynamic_job_visibility()
	return TRUE

/// The fallback menu shares canonical admission and selected-character labels with TGUI.
/datum/latejoin_menu/fallback_ui(mob/dead/new_player/user)
	var/client/requester = user.client
	if(!requester || requester.interviewee)
		return
	var/list/profile_context = requester.prefs.capture_latejoin_profile()
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/availability = user.IsJobUnavailable(job.title, latejoin = TRUE)
		if(QDELETED(user) || !requester || user.client != requester || requester.mob != user || !requester.prefs.is_latejoin_profile_current(null, profile_context))
			return
		if(availability != JOB_AVAILABLE && (job.job_flags & JOB_HIDE_WHEN_EMPTY))
			continue
		var/label = get_job_choice_label(job, user, availability, jobs)
		jobs[label] = job.title
	var/input_contents = input(user, "Выберите профессию:", "Поздний вход") as null|anything in jobs
	if(!input_contents || QDELETED(user) || !requester || user.client != requester || requester.mob != user)
		return
	if(!requester.prefs.is_latejoin_profile_current(null, profile_context))
		return
	user.AttemptLateSpawn(jobs[input_contents])

/// Random admission excludes roles requiring an explicit preference and rejects stale modal replies.
/datum/latejoin_menu/get_random_job(mob/dead/new_player/owner)
	var/client/requester = owner.client
	if(!requester)
		return
	var/list/profile_context = requester.prefs.capture_latejoin_profile()
	var/list/candidates = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		for(var/datum/job/job as anything in department.department_jobs)
			if(job.requires_explicit_preference() && !requester.prefs.job_preferences[job.title])
				continue
			var/availability = owner.IsJobUnavailable(job.title, latejoin = TRUE)
			if(QDELETED(owner) || !requester || owner.client != requester || requester.mob != owner || !requester.prefs.is_latejoin_profile_current(null, profile_context))
				return
			if(job.requires_explicit_preference() && !requester.prefs.job_preferences[job.title])
				continue
			if(availability == JOB_AVAILABLE)
				candidates += job.title
	if(!length(candidates))
		tgui_alert(owner, "В данный момент для вас нет случайной профессии. Обратитесь в ahelp за помощью.", "О нет!")
		return
	while(length(candidates))
		var/job_title = pick_n_take(candidates)
		var/datum/job/job = SSjob.get_job(job_title)
		if(job.requires_explicit_preference() && !requester.prefs.job_preferences[job_title])
			continue
		var/list/character_data = get_job_character_data(job, owner)
		var/choice = tgui_alert(owner, "[character_data["public_title"]]?", "Случайная должность", list("Yes", "Reroll", "Cancel"))
		if(QDELETED(owner) || !requester || owner.client != requester || requester.mob != owner || !requester.prefs.is_latejoin_profile_current(null, profile_context))
			return
		if(choice == "Cancel")
			return
		if(choice == "Yes")
			if(job.requires_explicit_preference() && !requester.prefs.job_preferences[job_title])
				return
			return job_title
	tgui_alert(owner, "В данный момент нет доступных для вас случайных профессий!", "О нет!")

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
	if(!requester)
		return list()
	var/list/profile_context = requester.prefs.capture_latejoin_profile()
	. = ..()
	if(QDELETED(user) || !requester || user.client != requester || !requester.prefs.is_latejoin_profile_current(null, profile_context))
		return list()
	var/list/data = .
	data["edit_slot"] = profile_context["editing_slot"]
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

/// Selected jobs use module admission; other interactive actions retain the native menu.
/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "select_job")
		return select_character_job(ui.user, params)
	return handle_native_ui_action(action, params, ui, state)

/// A modal random choice may yield; stale selections must not enter as another profile.
/datum/latejoin_menu/proc/select_character_job(mob/dead/new_player/owner, list/params)
	if(!owner.client || owner.client.interviewee || !isnewplayer(owner))
		return TRUE
	var/client/requester = owner.client
	var/list/profile_context = requester.prefs.capture_latejoin_profile()
	if(params["edit_slot"] != profile_context["editing_slot"])
		return TRUE
	if(params["job"] == "Random")
		var/job = get_random_job(owner)
		if(!job)
			return TRUE
		params["job"] = job
	if(QDELETED(owner) || !requester || owner.client != requester || requester.mob != owner)
		return TRUE
	if(!requester.prefs.is_latejoin_profile_current(null, profile_context))
		return TRUE
	owner.AttemptLateSpawn(params["job"])
