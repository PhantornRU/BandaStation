/datum/dynamic_ruleset/proc/accepts_job_character(datum/job_character_selection/selection)
	return TRUE

/datum/dynamic_ruleset/proc/accepts_job_body(mob/living/carbon/human/body)
	return TRUE

/datum/dynamic_ruleset/roundstart/blood_worm/accepts_job_character(datum/job_character_selection/selection)
	var/datum/species/species = GLOB.species_prototypes[selection.species]
	return species && !(TRAIT_NOBLOOD in species.inherent_traits)

/datum/dynamic_ruleset/roundstart/blood_worm/accepts_job_body(mob/living/carbon/human/body)
	return CAN_HAVE_BLOOD(body)

/datum/job_character_selection/proc/queued_antagonist_error(datum/mind/player_mind)
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in SSdynamic.queued_rulesets)
		if((player_mind in ruleset.selected_minds) && !ruleset.accepts_job_character(src))
			return "Профиль несовместим с выбранной ролью антагониста."
	return null

/mob/dead/new_player/proc/has_eligible_crew_preference(datum/dynamic_ruleset/roundstart/ruleset)
	if(!client)
		return FALSE
	if(ruleset && (ruleset.ruleset_flags & RULESET_INVADER))
		return TRUE
	var/list/blacklist = ruleset ? ruleset.get_blacklisted_roles() : list()
	var/list/jobs = client.prefs.job_preferences
	var/random_fallback = client.prefs.read_preference(/datum/preference/choiced/jobless_role) != RETURNTOLOBBY
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if((job.title in blacklist) || job.spawn_positions == 0 || (job.job_flags & JOB_LATEJOIN_ONLY))
			continue
		if(!jobs[job.title] && (!random_fallback || job.requires_explicit_preference()))
			continue
		if(SSjob.check_job_eligibility(src, job, "Candidate admission") != JOB_AVAILABLE)
			continue
		if(QDELETED(src) || !client)
			return FALSE
		var/datum/job_character_selection/selection = client.prefs.select_job_character(job, FALSE)
		var/accepted = !ruleset || ruleset.accepts_job_character(selection)
		qdel(selection)
		if(accepted)
			return TRUE
	return FALSE
