/// Preserve upstream localhost policy without logging every menu/candidate check.
/mob/dead/new_player/proc/notify_localhost_respawn(client/requester)
	if(CONFIG_GET(flag/allow_respawn) != RESPAWN_FLAG_NEW_CHARACTER || !requester.is_localhost())
		return
	to_chat(requester.mob, span_notice("Этот персонаж уже участвовал в данном раунде, однако это ограничение обходится при использовании localhost."))
	log_admin("[key_name_and_tag(requester)] пропускает повторное присоединение к раунду тем же персонажем.")

/// Only the additional admission checks; the native caller owns preflight and shuttle waits.
/mob/dead/new_player/proc/validate_latejoin(rank, client/requester)
	if(QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		return reject_late_spawn()
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return reject_late_spawn("Вход временно ограничен из-за нагрузки сервера.")
	if(!requester.holder && length(SSticker.queued_players) && SSticker.queued_players[1] != src)
		return reject_late_spawn("Дождитесь своей очереди на вход.")
	if(!(ckey(key) in GLOB.admin_datums) && SSjob.is_latejoin_population_full())
		return reject_late_spawn("Достигнут лимит живых игроков.")
	var/error = IsJobUnavailable(rank, latejoin = TRUE)
	if(error != JOB_AVAILABLE || QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		return reject_late_spawn(get_job_unavailable_error_message(error, rank))
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
