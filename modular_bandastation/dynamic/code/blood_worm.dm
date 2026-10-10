/datum/dynamic_ruleset/roundstart/blood_worm/proc/get_bloodless_jobs(client/player)
	var/list/bloodless_jobs = list()
	if(!player)
		return bloodless_jobs
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		var/datum/job_character_selection/selection = player.prefs.select_job_character(job)
		var/datum/species/species = GLOB.species_prototypes[selection.species]
		qdel(selection)
		if(!species || (TRAIT_NOBLOOD in species.inherent_traits))
			bloodless_jobs += job.title
	return bloodless_jobs

/datum/dynamic_ruleset/roundstart/blood_worm/prepare_for_role(datum/mind/candidate)
	..()
	LAZYADDASSOC(SSjob.prevented_occupations, candidate, get_bloodless_jobs(GET_CLIENT(candidate.current)))
	RegisterSignal(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, PROC_REF(check_roundstart_host))

/datum/dynamic_ruleset/roundstart/blood_worm/proc/check_roundstart_host(datum/mind/source, mob/living/character)
	SIGNAL_HANDLER
	if(!CAN_HAVE_BLOOD(character))
		return COMPONENT_CANCEL_CHARACTER_SPAWN

/datum/dynamic_ruleset/roundstart/blood_worm/cancel_assignment(datum/mind/candidate)
	if(!..())
		return FALSE
	UnregisterSignal(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED)
	return TRUE
