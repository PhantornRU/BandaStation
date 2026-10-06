/// Failed creation returns to the native lobby before equipment or mind handover.
/mob/dead/new_player/proc/create_roundstart_character(atom/destination)
	var/client/requester = client
	var/original_slot = requester?.prefs.default_slot
	var/datum/job/assigned_job = mind?.assigned_role
	var/mob/living/result
	try
		if(destination)
			result = create_character(destination)
	catch(var/exception/problem)
		stack_trace("Roundstart creation [assigned_job?.title]: [problem]")
	if(result || new_character?.client)
		return result || new_character
	if(!QDELETED(new_character))
		if(new_character.mind)
			new_character.mind.transfer_to(src)
		qdel(new_character)
	new_character = null
	if(assigned_job)
		SSjob.free_job_position(assigned_job.title)
	if(mind)
		for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in SSdynamic.queued_rulesets)
			ruleset.selected_minds -= mind
		GLOB.pre_setup_antags -= mind
		mind.active = TRUE
		mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
	if(requester?.prefs)
		if(requester.prefs.default_slot != original_slot)
			requester.prefs.load_character(original_slot)
		requester.prefs.donor_entry_locked = FALSE
	QDEL_NULL(assigned_character)
	QDEL_NULL(pending_donor_context)
	spawning = FALSE
	ready = PLAYER_NOT_READY
	to_chat(src, span_warning("Персонаж не прошёл условия появления. Проверьте назначенный профиль и точку появления; место освобождено."))
	return null
