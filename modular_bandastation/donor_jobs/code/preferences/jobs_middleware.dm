/datum/preference_middleware/donor_jobs
	action_delegations = list("set_donor_job_variant" = PROC_REF(set_donor_job_variant))

/datum/preference_middleware/donor_jobs/pre_set_preference(mob/user, preference, value)
	// Variants are edited through the slot-checked action, not an arbitrary preference payload.
	return preference == "job_outfit_variants"

/datum/preference_middleware/donor_jobs/proc/set_donor_job_variant(list/params, mob/user)
	if(!user.client || user.client.prefs != preferences || preferences.donor_entry_locked)
		return FALSE
	if(params["slot"] != preferences.default_slot)
		return FALSE
	var/job_title = params["job"]
	var/variant_id = params["variant"]
	if(!istext(job_title) || !istext(variant_id))
		return FALSE
	var/datum/job/job = SSjob.get_job(job_title)
	if(!job || job.title != job_title || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		return FALSE
	var/list/variants = job.get_donor_variants()
	if(!variants[variant_id])
		return FALSE
	var/list/selection = preferences.read_preference(/datum/preference/job_outfit_variants).Copy()
	selection[job.title] = variant_id
	return preferences.update_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], selection)

/datum/preference_middleware/donor_jobs/get_ui_data(mob/user)
	var/list/donor_jobs = list()
	var/list/job_lock_reasons = list()
	var/list/job_character_profiles = list()
	var/list/selection = preferences.read_preference(/datum/preference/job_outfit_variants)
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/datum/job_character_selection/character = preferences.select_job_character(job)
		var/lock_reason = get_job_lock_reason(job, user, character)
		if(lock_reason)
			job_lock_reasons[job.title] = lock_reason
		var/datum/job_variant/spawn_variant = job.resolve_donor_variant(character.variant_id)
		job_character_profiles[job.title] = list(
			"slot" = isnum(character.slot) ? character.slot : null,
			"randomized" = character.randomized,
			"title" = spawn_variant?.public_title,
		)
		qdel(character)
		var/list/variants = job.get_donor_variants()
		if(!length(variants) && !job.get_required_donor_tier())
			continue
		var/list/options = list()
		for(var/variant_id in variants)
			var/datum/job_variant/variant = variants[variant_id]
			options += list(list("id" = variant_id, "name" = variant.public_title))
		var/datum/job_variant/selected_variant = job.resolve_donor_variant(selection[job.title])
		var/datum/job_variant/default_variant = job.resolve_donor_variant("default")
		donor_jobs[job.title] = list(
			"title" = default_variant?.public_title,
			"selected" = selected_variant?.id,
			"variants" = options,
		)
	return list(
		"donor_jobs" = donor_jobs,
		"job_lock_reasons" = job_lock_reasons,
		"job_character_profiles" = job_character_profiles,
		"donor_edit_slot" = preferences.default_slot,
		"donor_entry_locked" = !isnull(preferences.donor_entry_locked),
	)

/datum/preference_middleware/donor_jobs/proc/get_job_lock_reason(datum/job/job, mob/user, datum/job_character_selection/character)
	var/client/requester = user.client
	if(!requester)
		return "Нет соединения с сервером."
	var/reason = job.donor_lock_reason(requester)
	if(reason)
		return reason
	if(is_banned_from(requester.ckey, job.title))
		return "Вы заблокированы на этой профессии."
	if(QDELETED(user) || user.client != requester)
		return "Нет соединения с сервером."
	if(!job.player_old_enough(requester))
		return "Для этой профессии нужно ещё [job.available_in_days(requester)] дней игры."
	var/remaining_playtime = job.required_playtime_remaining(requester)
	if(remaining_playtime)
		return "Нужно ещё [CEILING(remaining_playtime / 60, 1)] ч. игры за [job.get_exp_req_type()]."
	return character.character_error(job, requester, FALSE)
