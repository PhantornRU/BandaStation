/mob/dead/new_player
	var/datum/latejoin_profile_snapshot/latejoin_request
	var/character_creation_in_progress = FALSE
	var/is_admin_job_dummy = FALSE

/datum/latejoin_profile_snapshot
	var/client/requester
	var/datum/mind/character_mind
	var/job_title
	var/datum/job_character_selection/assignment

/datum/job_character_selection
	/// The body and history entry belong to this construction, until native handover succeeds.
	var/mob/living/created_body
	var/datum/mind/created_mind
	var/spawn_rejection
	var/spawn_handed_over = FALSE
	var/datum/persistent_client/history_connection
	var/history_index

/mob/dead/new_player/Destroy()
	QDEL_NULL(assigned_character)
	QDEL_NULL(latejoin_request)
	return ..()

/mob/dead/new_player/Logout()
	if(!spawning && assigned_character && mind?.assigned_role)
		SSjob.free_job_position(mind.assigned_role.title)
	return ..()

/// Menu snapshots remain local to the request; the singleton menu never stores a player's state.
/mob/dead/new_player/proc/capture_latejoin_request(job_title = null)
	var/client/requester = GET_CLIENT(src)
	if(!requester || requester.mob != src || !mind)
		return null
	var/datum/latejoin_profile_snapshot/context = requester.prefs.capture_latejoin_profile(job_title)
	context.requester = requester
	context.character_mind = mind
	context.job_title = job_title
	return context

/mob/dead/new_player/proc/is_latejoin_request_current(datum/latejoin_profile_snapshot/context)
	if(QDELETED(src) || !istype(context) || QDELETED(context))
		return FALSE
	var/client/requester = context.requester
	return requester && GET_CLIENT(src) == requester && requester.mob == src && mind == context.character_mind && requester.prefs.is_latejoin_profile_current(context.job_title, context)

/// Keep native capacity, including its early newbie Assistant return, without bypassing admission.
/mob/dead/new_player/IsJobUnavailable(rank, latejoin = FALSE)
	var/datum/job/job = istext(rank) ? SSjob.get_job(rank) : null
	var/datum/latejoin_profile_snapshot/context = capture_latejoin_request(rank)
	if(!job || job.title != rank || !context)
		return JOB_UNAVAILABLE_GENERIC
	var/client/requester = context.requester
	var/newbie_capacity_exception = job.current_positions >= job.total_positions && job.total_positions != -1 && is_assistant_job(job) && isnum(requester.player_age) && requester.player_age <= 14
	// The native latejoin caller omits the flag; its active request supplies the context.
	if(latejoin_request && latejoin_request.job_title == rank)
		latejoin = TRUE
	. = ..(rank, latejoin)
	if(. != JOB_AVAILABLE)
		return
	if(!is_latejoin_request_current(context))
		return JOB_UNAVAILABLE_GENERIC
	// This native path returned before eligibility; every other path has already checked it.
	if(newbie_capacity_exception)
		. = SSjob.check_job_eligibility(src, job, "Newbie assistant admission", latejoin = latejoin)
		if(. != JOB_AVAILABLE)
			return
		if(!is_latejoin_request_current(context) || (latejoin && !job.special_check_latejoin(requester)))
			return JOB_UNAVAILABLE_GENERIC
		if(!is_latejoin_request_current(context))
			return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE

/mob/dead/new_player/AttemptLateSpawn(rank)
	if(spawning || assigned_character || new_character || SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		return FALSE
	var/datum/latejoin_profile_snapshot/context = capture_latejoin_request(rank)
	if(!context)
		return FALSE
	latejoin_request = context
	spawning = TRUE
	. = ..()
	var/handed_over = context.assignment?.spawn_handed_over
	if(!handed_over && !QDELETED(context.assignment))
		cancel_character_spawn(context.assignment, context.character_mind, context.assignment.created_body)
	if(latejoin_request == context)
		latejoin_request = null
		if(!assigned_character && !new_character)
			spawning = FALSE
	qdel(context)
	if(handed_over)
		return TRUE

/// Used by native respawn history and its forced-slot argument, before any profile is loaded.
/mob/dead/new_player/proc/get_latejoin_character_slot(rank)
	var/datum/job/job = SSjob.get_job(rank)
	if(job && assigned_character?.job_type == job.type)
		return assigned_character.slot
	var/client/requester = GET_CLIENT(src)
	if(!job || !requester)
		return null
	var/datum/job_character_selection/selection = requester.prefs.select_job_character(job, TRUE)
	var/character_slot = selection.slot
	qdel(selection)
	return character_slot

/// Run after waits and once more in final assignment, before any vacancy is occupied. No SQL.
/mob/dead/new_player/proc/validate_latejoin_request(rank, check_queue = TRUE)
	if(!latejoin_request || latejoin_request.job_title != rank || !is_latejoin_request_current(latejoin_request))
		return reject_late_spawn("Настройки персонажа изменились; выберите профессию повторно.")
	if(SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		return reject_late_spawn()
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return reject_late_spawn("Вход в раунд временно отключён администрацией.")
	if(!(ckey(key) in GLOB.admin_datums))
		if((check_queue && length(SSticker.queued_players) && SSticker.queued_players[1] != src) || SSjob.is_latejoin_population_full())
			return reject_late_spawn("Сервер заполнен; дождитесь своей очереди.")
	if(SSshuttle.arrivals?.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
		return reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
	return TRUE

/// Commit the selected profile, then let the original constructor and mind transfer run once.
/mob/dead/new_player/create_character(atom/destination, forced_slot)
	if(character_creation_in_progress || new_character)
		return null
	var/datum/job_character_selection/selection = prepare_character_profile(destination, forced_slot)
	if(!selection)
		return null
	var/datum/persistent_client/connection = client.persistent_client
	var/previous_history_length = length(connection?.joined_as_slots)
	selection.created_mind = mind
	character_creation_in_progress = TRUE
	. = ..(destination, selection.slot)
	character_creation_in_progress = FALSE
	if(.)
		selection.created_body = .
		// Native LAZYADD is immediately followed by non-yielding init_verbs and return.
		if(connection && length(connection.joined_as_slots) > previous_history_length && connection.joined_as_slots[length(connection.joined_as_slots)] == "[selection.slot]")
			selection.history_connection = connection
			selection.history_index = length(connection.joined_as_slots)

/mob/dead/new_player/proc/prepare_character_profile(atom/destination, forced_slot)
	if(!mind?.assigned_role || !destination)
		return null
	if(!client)
		if(assigned_character)
			assigned_character.spawn_rejection = "Клиент отключился во время входа."
		return null
	var/datum/job/job = mind.assigned_role
	var/datum/job_character_selection/selection = resolve_assigned_job_character(job, mind.late_joiner, forced_slot)
	if(latejoin_request)
		latejoin_request.assignment = selection
	selection.spawn_rejection = selection.character_error(job, client, mind.late_joiner) || job.get_join_lock_reason(client)
	if(selection.spawn_rejection)
		return null
	if(!load_assigned_job_character())
		selection.spawn_rejection = "Не удалось загрузить назначенный профиль."
		return null
	return selection

/// Before native mind/history changes, reject a stale request and dispose only of its own body.
/mob/dead/new_player/proc/validate_created_character(mob/living/body, datum/mind/spawning_mind, datum/job/spawning_job, datum/job_character_selection/character_context)
	if(!QDELETED(src) && !QDELETED(spawning_mind) && !QDELETED(character_context) && spawning_job)
		var/client/requester = client || body?.client
		var/datum/mind/current_mind = mind || body?.mind
		var/owns_assignment = current_mind == spawning_mind && (!body?.mind || body.mind == spawning_mind) && spawning_mind.assigned_role == spawning_job && assigned_character == character_context && spawning_job.type == character_context.job_type && !new_character
		var/owns_profile = requester && requester.prefs == character_context.preferences && requester.prefs.default_slot == character_context.slot
		if(!QDELETED(body) && owns_assignment && owns_profile)
			character_context.spawn_rejection = spawning_job.get_join_lock_reason(requester) || character_context.actual_body_error(spawning_job, body)
			if(!character_context.spawn_rejection)
				return TRUE
		else if(!owns_assignment || !owns_profile)
			character_context.spawn_rejection = "Контекст создания персонажа изменился."
	if(QDELETED(body))
		return FALSE
	// Another mind may have taken the body during a yield; never destroy that mind's body.
	if(body.mind && body.mind != spawning_mind)
		return FALSE
	spawning_job?.rollback_spawn_character(body, src, spawning_mind)
	qdel(body)
	return FALSE

/mob/dead/new_player/transfer_character()
	var/datum/job_character_selection/selection = assigned_character
	var/mob/living/body = new_character
	if(selection && (body != selection.created_body || body?.mind != selection.created_mind || body?.mind?.current != body || body?.mind?.assigned_role?.type != selection.job_type))
		return null
	. = ..()
	if(. && selection)
		selection.spawn_handed_over = TRUE

/// Remove one native append, never pre-existing history or another attempt's entry.
/datum/job_character_selection/proc/rollback_spawn_history()
	if(spawn_handed_over || !history_index)
		return
	var/list/history = history_connection?.joined_as_slots
	if(islist(history) && history_index <= length(history) && history[history_index] == "[slot]")
		history.Cut(history_index, history_index + 1)
	history_index = null

/// Native failures keep their original alert/CRASH; only a recorded admission rejection returns FALSE.
/mob/dead/new_player/proc/handle_latejoin_creation_failure()
	var/datum/latejoin_profile_snapshot/context = latejoin_request
	var/datum/job_character_selection/selection = context?.assignment
	var/rejection = selection?.spawn_rejection
	if(!selection || !cancel_character_spawn(selection, context.character_mind, selection.created_body))
		return FALSE
	if(rejection && context.requester)
		to_chat(src, span_warning(rejection))
	return !!rejection

/// Release only the captured assignment/body; a newer or foreign assignment is never rollback state.
/mob/dead/new_player/proc/cancel_character_spawn(datum/job_character_selection/expected_character = assigned_character, datum/mind/expected_mind = mind || new_character?.mind, mob/living/expected_body = new_character)
	if(QDELETED(expected_character) || assigned_character != expected_character || QDELETED(expected_mind))
		return FALSE
	if(expected_character.created_mind && expected_character.created_mind != expected_mind)
		return FALSE
	if(new_character != expected_body || (mind && mind != expected_mind))
		return FALSE
	if(expected_body)
		if(QDELETED(expected_body) || expected_body.key || expected_body != expected_character.created_body || expected_body.mind != expected_mind || expected_mind.current != expected_body)
			return FALSE
	else if(mind != expected_mind || expected_mind.current != src)
		return FALSE
	if(expected_mind.assigned_role?.type != expected_character.job_type)
		return FALSE
	if(expected_body)
		expected_mind.transfer_to(src)
		QDEL_NULL(new_character)
	var/datum/job/assigned_job = expected_mind.assigned_role
	if(assigned_job && !is_unassigned_job(assigned_job))
		SSjob.free_job_position(assigned_job.title)
	expected_character.rollback_spawn_history()
	expected_mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
	QDEL_NULL(assigned_character)
	ready = PLAYER_NOT_READY
	spawning = FALSE
	return TRUE

/// Pre-assignment rejection has no right to clear a body or a committed selection.
/mob/dead/new_player/proc/reject_late_spawn(message)
	if(assigned_character || new_character)
		return FALSE
	var/client/requester = GET_CLIENT(src)
	if(message && requester)
		to_chat(src, span_warning(message))
	spawning = FALSE
	if(!requester && !QDELETED(src))
		qdel(src)
	return FALSE
