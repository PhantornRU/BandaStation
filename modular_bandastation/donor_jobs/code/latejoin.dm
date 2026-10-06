/client
	var/datum/job_entry_guard/job_entry_guard

/datum/controller/subsystem/job
	/// Pending public entries count towards global capacity before client handover.
	var/list/datum/job_entry_guard/latejoin_reservations = list()

/datum/controller/subsystem/job/proc/pending_latejoin_count()
	. = 0
	for(var/datum/job_entry_guard/entry as anything in latejoin_reservations)
		if(!(entry.created_body in GLOB.player_list) || !(entry.created_body in GLOB.alive_mob_list))
			.++

/datum/job_entry_guard
	var/client/owner
	var/mob/dead/new_player/player
	var/original_slot
	var/datum/job/reserved_job
	var/mob/living/created_body
	var/history_added = FALSE
	var/history_slot
	var/entered = FALSE
	var/error

/datum/job_entry_guard/New(mob/dead/new_player/new_player)
	player = new_player
	owner = player.client
	original_slot = owner.prefs.default_slot
	return ..()

/datum/job_entry_guard/proc/enter()
	if(owner.job_entry_guard)
		return FALSE
	owner.job_entry_guard = src
	owner.prefs.donor_entry_locked = TRUE
	entered = TRUE
	return TRUE

/datum/job_entry_guard/proc/lobby_error()
	if(QDELETED(player) || !owner || player.client != owner || owner.interviewee)
		return "Попытка входа больше не действительна."
	if(!SSticker.IsRoundInProgress())
		return "Раунд ещё не начался или уже завершён."
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return "Вход в раунд временно закрыт администрацией."
	if(!(owner.ckey in GLOB.admin_datums))
		var/hard_cap = CONFIG_GET(number/hard_popcap)
		var/extreme_cap = CONFIG_GET(number/extreme_popcap)
		var/cap = hard_cap && extreme_cap ? min(hard_cap, extreme_cap) : max(hard_cap, extreme_cap)
		if(cap && living_player_count() + SSjob.pending_latejoin_count() >= cap)
			return "Сервер заполнен."
		if(length(SSticker.queued_players) && SSticker.queued_players[1] != player)
			return "Дождитесь своей очереди."
	return null

/// The caller increments the native job counter immediately after this returns.
/datum/job_entry_guard/proc/commit_error(datum/job/job)
	if(reserved_job)
		return "В этой попытке роль уже назначена."
	if(!job || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE) || job.faction != FACTION_STATION)
		return "Профессия недоступна для обычного входа."
	var/entry_error = lobby_error()
	if(entry_error)
		return entry_error
	if(!job.special_check_latejoin(owner))
		return "Не выполнены особые условия позднего входа."
	// special_check_latejoin may sleep. Revalidate before reserving either capacity.
	entry_error = lobby_error() || job.donor_lock_reason(owner)
	if(entry_error)
		return entry_error
	entry_error = player.assigned_character.character_error(job, owner, TRUE)
	if(entry_error)
		return entry_error
	return player.IsJobSlotUnavailable(job) ? "Последнее место уже занято." : null

/datum/job_entry_guard/proc/note_assignment(datum/job/job)
	reserved_job = job
	SSjob.latejoin_reservations += src

/datum/job_entry_guard/proc/note_slot_history(slot)
	history_slot = "[slot]"
	history_added = !(history_slot in owner.persistent_client.joined_as_slots)

/datum/job_entry_guard/proc/finish(success)
	if(!entered)
		return FALSE
	var/transferred = created_body?.client || (owner && created_body && owner.mob == created_body)
	if(!success && !transferred)
		if(!QDELETED(created_body))
			if(!QDELETED(player) && created_body.mind)
				created_body.mind.transfer_to(player)
				player.mind.active = TRUE
			qdel(created_body)
		if(history_added && owner?.persistent_client)
			LAZYREMOVE(owner.persistent_client.joined_as_slots, history_slot)
		if(reserved_job)
			SSjob.free_job_position(reserved_job.title)
			if(!QDELETED(player) && player.mind)
				player.mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
		if(owner?.prefs && owner.prefs.default_slot != original_slot)
			owner.prefs.load_character(original_slot)
	SSjob.latejoin_reservations -= src
	if(owner?.prefs)
		owner.prefs.donor_entry_locked = FALSE
	if(owner?.job_entry_guard == src)
		owner.job_entry_guard = null
	if(!QDELETED(player))
		player.spawning = FALSE
		player.new_character = null
		QDEL_NULL(player.assigned_character)
		QDEL_NULL(player.pending_donor_context)
	reserved_job = null
	entered = FALSE
	return success || transferred

/mob/dead/new_player/proc/AttemptLateSpawn(rank)
	if(!client || !istext(rank))
		return FALSE
	var/datum/job/job = SSjob.get_job(rank)
	if(!job || job.title != rank)
		return FALSE
	var/datum/job_entry_guard/guard = new(src)
	if(!guard.enter())
		qdel(guard)
		return FALSE
	var/success = FALSE
	try
		guard.error = guard.lobby_error()
		if(!guard.error)
			success = perform_late_spawn(rank, guard)
	catch(var/exception/problem)
		guard.error = "Ошибка входа; администрация уведомлена."
		stack_trace("Latejoin [job.title]: [problem]")
		message_admins("Ошибка входа на [job.title]; проверьте runtime log.")
	. = guard.finish(success)
	if(!. && !QDELETED(src) && client && guard.error)
		to_chat(src, span_warning(guard.error))
	qdel(guard)
	return .
