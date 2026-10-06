#define JOB_CHOICE_YES "Yes"
#define JOB_CHOICE_REROLL "Reroll"
#define JOB_CHOICE_CANCEL "Cancel"

GLOBAL_DATUM_INIT(latejoin_menu, /datum/latejoin_menu, new)

/// Makes a list of jobs and pushes them to a DM list selector. Just in case someone did a special kind of fucky-wucky with TGUI.
/datum/latejoin_menu/proc/fallback_ui(mob/dead/new_player/user)
	// BANDASTATION EDIT START: both menus show the same restrictions and use the same admission path.
	var/client/requester = user.client
	if(!requester || requester.interviewee || requester.prefs.donor_entry_locked)
		return
	var/editing_slot = requester.prefs.default_slot
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/availability = user.IsJobUnavailable(job.title, latejoin = TRUE)
		if(QDELETED(user) || user.client != requester || requester.mob != user)
			return
		if(availability != JOB_AVAILABLE && (job.job_flags & JOB_HIDE_WHEN_EMPTY))
			continue
		var/list/character_data = get_job_character_data(job, user)
		var/label = "[character_data["public_title"]] ([character_data["character_profile"]])"
		var/reason = get_job_unavailable_reason(job, user, availability)
		if(reason)
			label += " — [reason]"
		if(jobs[label])
			label += " ([job.title])"
		jobs[label] = job.title

	var/input_contents = input(user, "Выберите профессию:", "Поздний вход") as null|anything in jobs

	if(!input_contents || QDELETED(user) || user.client != requester || requester.mob != user)
		return
	if(requester.prefs.default_slot != editing_slot || requester.prefs.donor_entry_locked)
		return

	user.AttemptLateSpawn(jobs[input_contents])
	// BANDASTATION EDIT END

// BANDASTATION ADDITION START
/datum/latejoin_menu/proc/get_job_character_data(datum/job/job, mob/dead/new_player/user)
	if(!user.client)
		return list("public_title" = job_title_ru(job.title))
	var/datum/preferences/preferences = user.client.prefs
	var/datum/job_character_selection/character = preferences.select_job_character(job, TRUE)
	var/datum/job_variant/variant = job.resolve_donor_variant(character.variant_id)
	var/profile_name = character.slot == preferences.default_slot \
		? preferences.read_preference(/datum/preference/name/real_name) \
		: preferences.savefile.get_entry("character[character.slot]")?["real_name"]
	var/profile_description = character.error ? "Недоступный профиль" : "Профиль [character.slot]: [profile_name]"
	if(character.randomized)
		profile_description += ", случайные имя и внешность"
	var/list/data = list(
		"public_title" = variant?.public_title || job_title_ru(job.title),
		"character_profile" = profile_description,
	)
	qdel(character)
	return data

/datum/latejoin_menu/proc/get_job_unavailable_reason(datum/job/job, mob/dead/new_player/user, availability)
	if(availability == JOB_AVAILABLE)
		return null
	if(availability == JOB_UNAVAILABLE_DONOR)
		return job.donor_lock_reason(user.client)
	if(availability == JOB_UNAVAILABLE_CHARACTER_PROFILE)
		if(user.client)
			var/datum/job_character_selection/character = user.client.prefs.select_job_character(job, TRUE)
			var/error = character.character_error(job, user.client, TRUE)
			qdel(character)
			if(error)
				return error
	return get_job_unavailable_error_message(availability, job.title)
// BANDASTATION ADDITION END

/datum/latejoin_menu/ui_close(mob/dead/new_player/user)
	. = ..()
	if(istype(user))
		user.jobs_menu_mounted = TRUE // Don't flood a user's chat if they open and close the UI.

/datum/latejoin_menu/ui_interact(mob/dead/new_player/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// In case they reopen the GUI
		// FIXME: this can cause a runtime since user can be a living mob
		if(istype(user))
			user.jobs_menu_mounted = FALSE
			addtimer(CALLBACK(src, PROC_REF(scream_at_player), user), 5 SECONDS)

		ui = new(user, src, "JobSelection", "Latejoin Menu")
		ui.open()

/datum/latejoin_menu/proc/scream_at_player(mob/dead/new_player/player)
	if(!player.jobs_menu_mounted)
		to_chat(player, span_notice("If the late join menu isn't showing, hold CTRL while clicking the join button!"))

/datum/latejoin_menu/ui_data(mob/user)
	var/mob/dead/new_player/owner = user
	var/client/requester = owner.client // BANDASTATION ADDITION
	if(!requester)
		return list()
	var/list/departments = list()
	var/list/data = list(
		"disable_jobs_for_non_observers" = SSlag_switch.measures[DISABLE_NON_OBSJOBS],
		"round_duration" = DisplayTimeText(world.time - SSticker.round_start_time, round_seconds_to = 1),
		"departments" = departments,
		"edit_slot" = owner.client.prefs.default_slot, // BANDASTATION ADDITION
		"entry_locked" = owner.client.prefs.donor_entry_locked, // BANDASTATION ADDITION
	)
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				data["shuttle_status"] = "The station has been evacuated."
			if(SHUTTLE_CALL, SHUTTLE_DOCKED, SHUTTLE_IGNITING, SHUTTLE_ESCAPE)
				data["shuttle_status"] = "The station is currently undergoing evacuation procedures."

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"open_slots" = 0,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			//Jobs under multiple departments should only be displayed if this is their first department or the command department
			if(LAZYLEN(job_datum.departments_list) > 1 && job_datum.departments_list[1] != department.type && !(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue

			var/job_availability = owner.IsJobUnavailable(job_datum.title, latejoin = TRUE)
			// BANDASTATION ADDITION START: eligibility can wait for native ban checks.
			if(QDELETED(owner) || owner.client != requester)
				return list()
			// BANDASTATION ADDITION END

			var/list/job_data = list(
				"prioritized" = (job_datum in SSjob.prioritized_jobs),
				"used_slots" = job_datum.current_positions,
				"open_slots" = job_datum.total_positions < 0 ? "∞" : job_datum.total_positions,
				"jobIcon" = job_datum.tgui_icon,
			)
			job_data += get_job_character_data(job_datum, owner) // BANDASTATION ADDITION

			if(job_availability != JOB_AVAILABLE)
				if (job_datum.job_flags & JOB_HIDE_WHEN_EMPTY)
					continue
				job_data["unavailable_reason"] = get_job_unavailable_reason(job_datum, owner, job_availability) // BANDASTATION EDIT

			// BANDASTATION EDIT START: count vacancies available to this player.
			if(job_availability == JOB_AVAILABLE)
				if(job_datum.total_positions < 0)
					department_data["open_slots"] = "∞"
				if(department_data["open_slots"] != "∞")
					if(job_datum.total_positions - job_datum.current_positions > 0)
						department_data["open_slots"] += job_datum.total_positions - job_datum.current_positions
			// BANDASTATION EDIT END

			department_jobs[job_datum.title] = job_data

	return data

/datum/latejoin_menu/ui_static_data(mob/user)
	var/list/departments = list()

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/department_jobs = list()
		var/list/department_data = list(
			"jobs" = department_jobs,
			"color" = department.ui_color,
		)
		departments[department.department_name] = department_data

		for(var/datum/job/job_datum as anything in department.department_jobs)
			//Jobs under multiple departments should only be displayed if this is their first department or the command department
			if(LAZYLEN(job_datum.departments_list) > 1 && job_datum.departments_list[1] != department.type && !(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue
			// BANDASTATION EDIT: visibility and availability live in ui_data, including reopened vacancies.

			var/list/job_data = list(
				"command" = !!(job_datum.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND),
				"description" = job_datum.description,
			)

			department_jobs[job_datum.title] = job_data

	return list("departments_static" = departments)

/datum/latejoin_menu/ui_state(mob/user)
	return GLOB.new_player_state

/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.) // BANDASTATION EDIT: honor native UI status.
		return

	if(!ui.user.client || ui.user.client.interviewee || !isnewplayer(ui.user))
		return TRUE

	var/mob/dead/new_player/owner = ui.user

	switch(action)
		if("ui_mounted_with_no_bluescreen")
			owner.jobs_menu_mounted = TRUE
		if("select_job")
			// BANDASTATION EDIT START: stale selections must not change a different character.
			var/client/requester = owner.client
			var/editing_slot = requester.prefs.default_slot
			if(requester.prefs.donor_entry_locked || params["edit_slot"] != editing_slot)
				return TRUE
			// BANDASTATION EDIT END
			if(params["job"] == "Random")
				var/job = get_random_job(owner)
				if(!job)
					return TRUE

				params["job"] = job

			// BANDASTATION EDIT START: random-job confirmation yields; final checks belong to AttemptLateSpawn.
			if(QDELETED(owner) || owner.client != requester || requester.mob != owner)
				return TRUE
			if(requester.prefs.donor_entry_locked || requester.prefs.default_slot != editing_slot)
				return TRUE
			// BANDASTATION EDIT END
			owner.AttemptLateSpawn(params["job"])
		if("viewpoll")
			var/datum/poll_question/poll = locate(params["viewpoll"]) in GLOB.polls
			if(!poll)
				return TRUE

			owner.poll_player(poll)
			return TRUE

		if("votepollref")
			var/datum/poll_question/poll = locate(params["votepollref"]) in GLOB.polls
			if(!poll)
				return TRUE

			owner.vote_on_poll_handler(poll, params)
			return TRUE

/// Gives the user a random job that they can join as, and prompts them if they'd actually like to keep it, rerolling if not. Cancellable by the user.
/// WARNING: BLOCKS THREAD!
/datum/latejoin_menu/proc/get_random_job(mob/dead/new_player/owner)
	var/client/requester = owner.client // BANDASTATION ADDITION
	if(!requester)
		return
	var/editing_slot = requester.prefs.default_slot // BANDASTATION ADDITION
	var/list/dept_data = list()

	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		for(var/datum/job/job_datum as anything in department.department_jobs)
			// BANDASTATION ADDITION START: RP donor roles need an explicit preference.
			if((istype(job_datum, /datum/job/donor) || (istype(job_datum, /datum/job/prisoner) && job_datum.get_required_donor_tier())) && !requester.prefs.job_preferences[job_datum.title])
				continue
			// BANDASTATION ADDITION END
			var/availability = owner.IsJobUnavailable(job_datum.title, latejoin = TRUE)
			if(QDELETED(owner) || owner.client != requester)
				return
			if(availability != JOB_AVAILABLE)
				continue
			dept_data += job_datum.title

	if(dept_data.len <= 0) //Congratufuckinglations
		tgui_alert(owner, "В данный момент для вас нет случайной профессии. Обратитесь в ahelp за помощью.", "О нет!")
		return

	var/random_job

	while(random_job != JOB_CHOICE_YES)
		if(dept_data.len <= 0)
			tgui_alert(owner, "В данный момент нет доступных для вас случайных профессий!", "О нет!")
			return

		var/random = pick_n_take(dept_data)
		var/list/random_job_options = list(JOB_CHOICE_YES, JOB_CHOICE_REROLL, JOB_CHOICE_CANCEL)

		var/list/character_data = get_job_character_data(SSjob.get_job(random), owner) // BANDASTATION ADDITION
		random_job = tgui_alert(owner, "[character_data["public_title"]]?", "Случайная должность", random_job_options) // BANDASTATION EDIT
		// BANDASTATION ADDITION START: do not use a reply from a departed or changed player.
		if(QDELETED(owner) || owner.client != requester || requester.mob != owner)
			return
		if(requester.prefs.default_slot != editing_slot || requester.prefs.donor_entry_locked)
			return
		// BANDASTATION ADDITION END

		if(random_job == JOB_CHOICE_CANCEL)
			return
		if(random_job == JOB_CHOICE_YES)
			return random

#undef JOB_CHOICE_YES
#undef JOB_CHOICE_REROLL
#undef JOB_CHOICE_CANCEL
