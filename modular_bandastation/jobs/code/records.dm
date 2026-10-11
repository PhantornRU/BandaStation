/// Called only for the first crew record, never a later identity change.
/datum/job/proc/on_initial_crew_record(mob/living/carbon/human/body, datum/record/crew/record)
	SEND_SIGNAL(body, COMSIG_HUMAN_INITIAL_CREW_RECORD, src, record)

/// Adapt the exact-record callback to the native Prisoner lifecycle.
/datum/job/prisoner/on_initial_crew_record(mob/living/carbon/human/body, datum/record/crew/record)
	..()
	return handle_prisoner_joining(body, record)
