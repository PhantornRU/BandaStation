/// Failed creation returns to the native lobby before equipment or mind handover.
/mob/dead/new_player/proc/create_roundstart_character(atom/destination)
	var/client/requester = client
	var/datum/preferences/preferences = entry_preferences || requester?.prefs
	var/original_slot = preferences?.default_slot
	var/datum/job/assigned_job = mind?.assigned_role
	var/mob/living/result
	try
		if(destination)
			result = create_character(destination)
	catch(var/exception/problem)
		stack_trace("Roundstart creation [assigned_job?.title]: [problem]")
	if(result || character_handover_complete)
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
	if(preferences && preferences.default_slot != original_slot)
		preferences.load_character(original_slot)
	release_character_entry()
	QDEL_NULL(assigned_character)
	QDEL_NULL(pending_donor_context)
	spawning = FALSE
	ready = PLAYER_NOT_READY
	to_chat(src, span_warning("Персонаж не прошёл условия появления. Проверьте назначенный профиль и точку появления; место освобождено."))
	return null
