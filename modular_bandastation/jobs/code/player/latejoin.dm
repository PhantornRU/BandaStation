/// The transient selection is owned by the lobby mob, including unsuccessful attempts.
/mob/dead/new_player/Destroy()
	QDEL_NULL(assigned_character)
	return ..()

/// Release an unspawned assignment before native logout deletes its mind.
/mob/dead/new_player/Logout()
	if(!spawning && assigned_character && mind?.assigned_role)
		SSjob.free_job_position(mind.assigned_role.title)
	return ..()

/// Admission uses a canonical job and checks its selected profile even for Assistant overflow.
/mob/dead/new_player/IsJobUnavailable(rank, latejoin = FALSE)
	var/client/requester = GET_CLIENT(src)
	if(!requester || !istext(rank))
		return JOB_UNAVAILABLE_GENERIC
	var/datum/job/job = SSjob.get_job(rank)
	if(!job || job.title != rank || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		return JOB_UNAVAILABLE_GENERIC
	if(IsJobSlotUnavailable(job))
		return JOB_UNAVAILABLE_SLOTFULL
	var/eligibility_check = SSjob.check_job_eligibility(src, job, "Mob IsJobUnavailable", latejoin = latejoin)
	if(eligibility_check != JOB_AVAILABLE)
		return eligibility_check
	if(latejoin && !job.special_check_latejoin(requester))
		return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE

/// Own admission and handover; equipment and the remaining native bookkeeping have one owner.
/mob/dead/new_player/AttemptLateSpawn(rank)
	var/client/requester = GET_CLIENT(src)
	var/list/entry_profile = begin_latejoin_attempt(rank, requester)
	if(!entry_profile)
		return FALSE
	if(SSshuttle.arrivals)
		if(SSshuttle.arrivals.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
			return reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
		if(CONFIG_GET(flag/arrivals_shuttle_require_undocked))
			SSshuttle.arrivals.wait_for_latejoin_player(src, requester)
	if(!validate_latejoin(rank, requester, entry_profile))
		return FALSE
	var/datum/job/job = SSjob.get_job(rank)
	if(!SSjob.assign_role(src, job, latejoin = TRUE, do_eligibility_checks = FALSE))
		return reject_late_spawn("Профессия больше недоступна; выберите её повторно.")
	mind.late_joiner = TRUE
	var/atom/destination = job.get_latejoin_spawn_point()
	var/mob/living/character = destination ? create_character(destination) : null
	if(!character)
		cancel_character_spawn()
		return reject_late_spawn("Персонаж не был создан; место профессии освобождено.")
	if(!transfer_character())
		cancel_character_spawn()
		return reject_late_spawn("Передача персонажа не состоялась; место профессии освобождено.")
	SSticker.queued_players -= src
	SSticker.queue_delay = 4
	var/latejoin_period = CEILING(STATION_TIME_PASSED() / (5 MINUTES), 5)
	SSblackbox.record_feedback("tally", "latejoin_time", 1, latejoin_period)
	finish_latejoin_spawn(rank, job, character)
	return TRUE

/// The alternate entrypoint can stop waiting when its original player leaves.
/obj/docking_port/mobile/arrivals/proc/wait_for_latejoin_player(mob/dead/new_player/user, client/requester)
	if(mode == SHUTTLE_CALL || damaged)
		return
	Launch(TRUE)
	to_chat(user, span_notice("Вызываю шаттл. Ожидайте..."))
	while(!QDELETED(user) && requester && user.client == requester && requester.mob == user && mode != SHUTTLE_CALL && !damaged)
		stoplag()

/// Resolve and load the committed profile before entering native construction.
/mob/dead/new_player/create_character(atom/destination, forced_slot)
	spawning = TRUE
	if(!client || !destination || !mind?.assigned_role)
		return null
	var/datum/job/assigned_job = mind.assigned_role
	var/datum/job_character_selection/selection = resolve_assigned_job_character(assigned_job, mind.late_joiner, forced_slot)
	if(selection.character_error(assigned_job, client, mind.late_joiner) || assigned_job.get_join_lock_reason(client) || !load_assigned_job_character())
		return null
	return create_character_body(destination)

/// Specialized jobs may bypass the common spawn proc, so admission stays at the body boundary.
/mob/dead/new_player/proc/validate_created_character(mob/living/body)
	if(QDELETED(body))
		return FALSE
	if(!QDELETED(src))
		var/client/requester = client || body.client
		var/datum/job/assigned_job = mind?.assigned_role || body.mind?.assigned_role
		if(requester && assigned_character && requester.prefs == assigned_character.preferences && assigned_job?.type == assigned_character.job_type && requester.prefs.default_slot == assigned_character.slot && !assigned_job.get_join_lock_reason(requester) && !assigned_character.actual_body_error(assigned_job, body))
			return TRUE
	// AI construction already transfers its mind; restore it before discarding an unfinished body.
	if(isAI(body) && !QDELETED(src))
		body.mind?.transfer_to(src)
	qdel(body)
	return FALSE

/// Preserve the committed profile across native possession and destruction of the lobby mob.
/mob/dead/new_player/transfer_character()
	var/datum/persistent_client/connection = persistent_client || new_character?.persistent_client
	var/character_slot = assigned_character?.slot
	. = ..()
	if(. && connection && !isnull(character_slot))
		LAZYADD(connection.joined_as_slots, "[character_slot]")

/// Start one request and capture its profile before eligibility or native shuttle waits.
/mob/dead/new_player/proc/begin_latejoin_attempt(rank, client/requester)
	if(spawning || !requester || SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		return null
	spawning = TRUE
	notify_localhost_respawn(requester)
	var/list/entry_profile = requester.prefs.capture_latejoin_profile(rank)
	var/error = IsJobUnavailable(rank, latejoin = TRUE)
	if(error != JOB_AVAILABLE)
		reject_late_spawn(get_job_unavailable_error_message(error, rank))
		return null
	return entry_profile

/// Preserve upstream localhost policy without logging every menu/candidate check.
/mob/dead/new_player/proc/notify_localhost_respawn(client/requester)
	if(CONFIG_GET(flag/allow_respawn) != RESPAWN_FLAG_NEW_CHARACTER || !requester.is_localhost())
		return
	to_chat(requester.mob, span_notice("Этот персонаж уже участвовал в данном раунде, однако это ограничение обходится при использовании localhost."))
	log_admin("[key_name_and_tag(requester)] пропускает повторное присоединение к раунду тем же персонажем.")

/// Recheck the request after shuttle waits and yielding eligibility checks.
/mob/dead/new_player/proc/validate_latejoin(rank, client/requester, list/entry_profile)
	if(QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		return reject_late_spawn()
	if(!requester.prefs.is_latejoin_profile_current(rank, entry_profile))
		return reject_late_spawn("Настройки входа изменились; выберите профессию повторно.")
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return reject_late_spawn("Вход временно ограничен из-за нагрузки сервера.")
	if(!requester.holder && length(SSticker.queued_players) && SSticker.queued_players[1] != src)
		return reject_late_spawn("Дождитесь своей очереди на вход.")
	if(!(ckey(key) in GLOB.admin_datums) && SSjob.is_latejoin_population_full())
		return reject_late_spawn("Достигнут лимит живых игроков.")
	var/error = IsJobUnavailable(rank, latejoin = TRUE)
	if(error != JOB_AVAILABLE || QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		return reject_late_spawn(get_job_unavailable_error_message(error, rank))
	if(!requester.prefs.is_latejoin_profile_current(rank, entry_profile))
		return reject_late_spawn("Настройки входа изменились; выберите профессию повторно.")
	if(SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		return reject_late_spawn("Раунд завершён; поздний вход недоступен.")
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return reject_late_spawn("Вход временно ограничен из-за нагрузки сервера.")
	if(!requester.holder && length(SSticker.queued_players) && SSticker.queued_players[1] != src)
		return reject_late_spawn("Дождитесь своей очереди на вход.")
	if(SSshuttle.arrivals?.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
		return reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
	return TRUE

/// Fail before equipment; the only disposable body belongs to this lobby mob.
/mob/dead/new_player/proc/cancel_character_spawn()
	if(new_character && !new_character.key)
		new_character.mind?.transfer_to(src)
		QDEL_NULL(new_character)
	var/datum/job/assigned_job = mind?.assigned_role || SSjob.get_job_type(assigned_character?.job_type)
	if(assigned_character && assigned_job && !is_unassigned_job(assigned_job))
		SSjob.free_job_position(assigned_job.title)
	if(mind)
		mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
	QDEL_NULL(assigned_character)
	ready = PLAYER_NOT_READY
	spawning = FALSE

/mob/dead/new_player/proc/reject_late_spawn(message)
	var/client/requester = GET_CLIENT(src)
	if(message && requester)
		to_chat(src, span_warning(message))
	spawning = FALSE
	if(!requester && !QDELETED(src))
		qdel(src)
	return FALSE
