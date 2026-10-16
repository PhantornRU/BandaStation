/// The transient selection is owned by the lobby mob, including unsuccessful attempts.
/mob/dead/new_player/Destroy()
	QDEL_NULL(assigned_character)
	return ..()

/// Release an unspawned assignment before native logout deletes its mind.
/mob/dead/new_player/Logout()
	if(!spawning && assigned_character && mind?.assigned_role)
		SSjob.free_job_position(mind.assigned_role.title)
	return ..()

/// Stop the native latejoin wait when its original player leaves.
/obj/docking_port/mobile/arrivals/proc/wait_for_latejoin_player(mob/dead/new_player/user, client/requester)
	if(mode == SHUTTLE_CALL || damaged)
		return
	Launch(TRUE)
	to_chat(user, span_notice("Вызываю шаттл. Ожидайте..."))
	while(!QDELETED(user) && requester && user.client == requester && requester.mob == user && mode != SHUTTLE_CALL && !damaged)
		stoplag()

/// Resolve and load the committed profile before native construction starts.
/mob/dead/new_player/proc/prepare_character_profile(atom/destination, forced_slot)
	if(!client || !destination || !mind?.assigned_role)
		return null
	var/datum/job/assigned_job = mind.assigned_role
	var/datum/job_character_selection/selection = resolve_assigned_job_character(assigned_job, mind.late_joiner, forced_slot)
	if(selection.character_error(assigned_job, client, mind.late_joiner) || assigned_job.get_join_lock_reason(client) || !load_assigned_job_character())
		return null
	return selection

/// Specialized constructors share this final boundary; only the captured assignment may be accepted.
/mob/dead/new_player/proc/validate_created_character(mob/living/body, datum/mind/spawning_mind, datum/job/spawning_job, datum/job_character_selection/character_context)
	if(QDELETED(body))
		return FALSE
	if(!QDELETED(src) && !QDELETED(spawning_mind) && !QDELETED(character_context) && spawning_job)
		var/client/requester = client || body.client
		var/datum/mind/current_mind = mind || body.mind
		var/owns_assignment = current_mind == spawning_mind && spawning_mind.assigned_role == spawning_job && assigned_character == character_context && spawning_job.type == character_context.job_type
		var/owns_profile = requester && requester.prefs == character_context.preferences && requester.prefs.default_slot == character_context.slot
		if(owns_assignment && owns_profile && !spawning_job.get_join_lock_reason(requester) && !character_context.actual_body_error(spawning_job, body))
			return TRUE
	// The constructor and this final boundary use the same ownership-checked AI rollback.
	spawning_job?.rollback_spawn_character(body, src, spawning_mind)
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
	var/datum/latejoin_profile_snapshot/entry_profile = requester.prefs.capture_latejoin_profile(rank)
	return entry_profile

/// Preserve upstream localhost policy without logging every menu/candidate check.
/mob/dead/new_player/proc/notify_localhost_respawn(client/requester)
	if(CONFIG_GET(flag/allow_respawn) != RESPAWN_FLAG_NEW_CHARACTER || !requester.is_localhost())
		return
	to_chat(requester.mob, span_notice("Этот персонаж уже участвовал в данном раунде, однако это ограничение обходится при использовании localhost."))
	log_admin("[key_name_and_tag(requester)] пропускает повторное присоединение к раунду тем же персонажем.")

/// Recheck the request after shuttle waits and yielding eligibility checks.
/mob/dead/new_player/proc/validate_latejoin(rank, client/requester, datum/latejoin_profile_snapshot/entry_profile)
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
/mob/dead/new_player/proc/cancel_character_spawn(datum/job_character_selection/expected_character = assigned_character, datum/mind/expected_mind = mind || new_character?.mind)
	// A yielding constructor or signal must not let an old attempt cancel a newer assignment.
	if(QDELETED(expected_character) || assigned_character != expected_character)
		return FALSE
	if((mind || new_character?.mind) != expected_mind)
		return FALSE
	if(expected_mind && expected_mind.assigned_role?.type != expected_character.job_type)
		return FALSE
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
	return TRUE

/mob/dead/new_player/proc/reject_late_spawn(message)
	// Admission failures before assignment do not own a character installed by another caller.
	if(assigned_character || new_character)
		return FALSE
	var/client/requester = GET_CLIENT(src)
	if(message && requester)
		to_chat(src, span_warning(message))
	spawning = FALSE
	if(!requester && !QDELETED(src))
		qdel(src)
	return FALSE
