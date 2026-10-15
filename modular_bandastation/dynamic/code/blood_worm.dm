/// Keep the full roundstart parent chain while replacing the old active-profile species check.
/datum/dynamic_ruleset/roundstart/blood_worm/is_valid_candidate(mob/living/candidate, client/candidate_client)
	// The concrete ancestor call preserves its chain; the replaced active-profile veto must remain dormant.
	SHOULD_CALL_PARENT(FALSE)
	if(!call(src, /datum/dynamic_ruleset/roundstart::is_valid_candidate())(candidate, candidate_client))
		return FALSE
	return is_valid_host_profile(candidate, candidate_client)

/// Native candidacy has already checked the mind and queued rulesets before this phase.
/datum/dynamic_ruleset/roundstart/blood_worm/proc/is_valid_host_profile(mob/candidate, client/candidate_client)
	if(isnewplayer(candidate))
		var/mob/dead/new_player/player = candidate
		return player.has_eligible_crew_preference(get_blacklisted_roles() | get_bloodless_jobs(candidate_client))
	var/species_type = candidate_client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = GLOB.species_prototypes[species_type]
	return !(TRAIT_NOBLOOD in species.inherent_traits)

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
	// This prepared assignment only validates its initial body; rejected bodies are cleaned up by cancellation.
	UnregisterSignal(source, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED)

/datum/dynamic_ruleset/roundstart/blood_worm/cancel_assignment(datum/mind/candidate)
	if(!..())
		return FALSE
	UnregisterSignal(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED)
	return TRUE
