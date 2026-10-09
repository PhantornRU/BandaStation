/datum/dynamic_ruleset/roundstart
	/// Occupation changes owned by each unexecuted assignment, excluding pre-existing restrictions.
	VAR_PRIVATE/list/prepared_job_changes

/datum/dynamic_ruleset/roundstart/prepare_job_assignment(datum/mind/candidate)
	var/list/previous_blocks = LAZYACCESS(SSjob.prevented_occupations, candidate)
	previous_blocks = previous_blocks ? previous_blocks.Copy() : list()
	var/previous_forced = LAZYACCESS(SSjob.forced_occupations, candidate)
	. = ..()
	var/list/current_blocks = LAZYACCESS(SSjob.prevented_occupations, candidate)
	LAZYSET(prepared_job_changes, candidate, list(
		"blocked" = (current_blocks || list()) - previous_blocks,
		"forced" = LAZYACCESS(SSjob.forced_occupations, candidate),
		"previous_forced" = previous_forced,
	))

/datum/dynamic_ruleset/roundstart/execute()
	. = ..()
	prepared_job_changes = null

/datum/dynamic_ruleset/roundstart/Destroy()
	prepared_job_changes = null
	return ..()

/datum/dynamic_ruleset/roundstart/set_config_value(new_var, new_val)
	if(new_var == NAMEOF(src, prepared_job_changes))
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/proc/cancel_assignment(datum/mind/candidate)
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
