/datum/preference_middleware/donor_jobs
	action_delegations = list("set_donor_job_variant" = PROC_REF(set_donor_job_variant))

/datum/preference_middleware/donor_jobs/pre_set_preference(mob/user, preference, value)
	// Variants are edited through the slot-checked action, not an arbitrary preference payload.
	return preference == "job_outfit_variants"

/datum/preference_middleware/donor_jobs/proc/set_donor_job_variant(list/params, mob/user)
	if(!user.client || user.client.prefs != preferences)
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
	var/list/saved_selection = preferences.read_preference(/datum/preference/job_outfit_variants)
	var/list/selection = saved_selection?.Copy() || list()
	selection[job.title] = variant_id
	return preferences.update_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], selection)

/datum/preference_middleware/donor_jobs/get_ui_data(mob/user)
	var/list/donor_jobs = list()
	var/list/selection = preferences.read_preference(/datum/preference/job_outfit_variants)
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/required_tier = job.get_required_donor_tier()
		if(!length(job.donor_variant_specs) && !required_tier)
			continue
		var/list/variants = job.get_donor_variants()
		var/list/options = list()
		for(var/variant_id in variants)
			var/datum/job_variant/variant = variants[variant_id]
			options += list(list("id" = variant_id, "name" = variant.public_title))
		var/datum/job_variant/selected_variant = job.resolve_donor_variant(selection[job.title])
		var/datum/job_variant/default_variant = job.resolve_donor_variant("default")
		var/profile_title
		if(length(variants))
			var/datum/job_character_selection/character = preferences.select_job_character(job)
			var/list/profile_variants = character.read_preference(/datum/preference/job_outfit_variants)
			var/datum/job_variant/profile_variant = job.resolve_donor_variant(profile_variants?[job.title])
			profile_title = profile_variant?.public_title
			qdel(character)
		donor_jobs[job.title] = list(
			"title" = default_variant?.public_title,
			"profile_title" = profile_title,
			"selected" = selected_variant?.id,
			"variants" = options,
			"required_tier" = required_tier,
			"lock_reason" = job.donor_lock_reason(user.client),
		)
	return list(
		"donor_jobs" = donor_jobs,
	)
