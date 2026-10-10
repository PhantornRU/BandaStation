/// Preflight owns the attempt guard and rechecks admission after every potentially yielding phase.
/mob/dead/new_player/proc/prepare_latejoin(rank)
	var/client/requester = GET_CLIENT(src)
	// A repeated request must leave the first attempt's spawning guard intact.
	if(spawning || !requester || SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		return null
	spawning = TRUE
	var/error = IsJobUnavailable(rank, latejoin = TRUE)
	if(error != JOB_AVAILABLE)
		reject_late_spawn(get_job_unavailable_error_message(error, rank))
		return null
	if(SSshuttle.arrivals)
		if(SSshuttle.arrivals.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
			reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
			return null
		if(CONFIG_GET(flag/arrivals_shuttle_require_undocked))
			SSshuttle.arrivals.RequireUndocked(src)
	if(QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		reject_late_spawn()
		return null
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		reject_late_spawn("Вход временно ограничен из-за нагрузки сервера.")
		return null
	if(!requester.holder && length(SSticker.queued_players) && SSticker.queued_players[1] != src)
		reject_late_spawn("Дождитесь своей очереди на вход.")
		return null
	if(!(ckey(key) in GLOB.admin_datums) && SSjob.is_latejoin_population_full())
		reject_late_spawn("Достигнут лимит живых игроков.")
		return null
	error = IsJobUnavailable(rank, latejoin = TRUE)
	if(error != JOB_AVAILABLE || QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		reject_late_spawn(get_job_unavailable_error_message(error, rank))
		return null
	if(SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		reject_late_spawn("Раунд завершён; поздний вход недоступен.")
		return null
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		reject_late_spawn("Вход временно ограничен из-за нагрузки сервера.")
		return null
	if(!requester.holder && length(SSticker.queued_players) && SSticker.queued_players[1] != src)
		reject_late_spawn("Дождитесь своей очереди на вход.")
		return null
	if(SSshuttle.arrivals?.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
		reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
		return null
	return SSjob.get_job(rank)

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
