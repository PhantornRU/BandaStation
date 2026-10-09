/datum/dynamic_ruleset
	/// Occupation changes owned by each unexecuted assignment, excluding pre-existing restrictions.
	VAR_PRIVATE/list/prepared_job_changes

/datum/dynamic_ruleset/proc/record_prepared_job_changes(datum/mind/candidate, list/previous_blocks, previous_forced_job)
	PROTECTED_PROC(TRUE)
	var/list/current_blocks = LAZYACCESS(SSjob.prevented_occupations, candidate)
	LAZYSET(prepared_job_changes, candidate, list(
		"blocked" = (current_blocks || list()) - previous_blocks,
		"forced" = LAZYACCESS(SSjob.forced_occupations, candidate),
		"previous_forced" = previous_forced_job,
	))

/datum/dynamic_ruleset/proc/cancel_assignment(datum/mind/candidate)
	if(!(candidate in selected_minds))
		return FALSE
	var/list/changes = LAZYACCESS(prepared_job_changes, candidate)
	if(changes)
		var/list/blocked_jobs = LAZYACCESS(SSjob.prevented_occupations, candidate)
		blocked_jobs -= changes["blocked"]
		if(!length(blocked_jobs))
			LAZYREMOVE(SSjob.prevented_occupations, candidate)
		if(LAZYACCESS(SSjob.forced_occupations, candidate) == changes["forced"])
			if(changes["previous_forced"])
				LAZYSET(SSjob.forced_occupations, candidate, changes["previous_forced"])
			else
				LAZYREMOVE(SSjob.forced_occupations, candidate)
	LAZYREMOVE(prepared_job_changes, candidate)
	selected_minds -= candidate
	return TRUE

/// Cancel only queued roundstart selections; active antagonists and other minds are untouched.
/datum/controller/subsystem/dynamic/proc/cancel_roundstart_assignment(datum/mind/candidate)
	var/cancelled = FALSE
	for(var/datum/dynamic_ruleset/roundstart/ruleset in queued_rulesets.Copy())
		if((ruleset in executed_rulesets) || !ruleset.cancel_assignment(candidate))
			continue
		cancelled = TRUE
		if(!length(ruleset.selected_minds))
			unqueue_ruleset(ruleset)
			qdel(ruleset)
	return cancelled

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

/datum/dynamic_ruleset/roundstart/blood_worm/proc/check_roundstart_host(datum/mind/source, mob/living/character)
	SIGNAL_HANDLER
	if(!CAN_HAVE_BLOOD(character))
		return COMPONENT_CANCEL_CHARACTER_SPAWN

/datum/dynamic_ruleset/roundstart/blood_worm/cancel_assignment(datum/mind/candidate)
	if(!..())
		return FALSE
	UnregisterSignal(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED)
	return TRUE
