// Included after modular_bandastation.dme in the TEMP test overlay: these signal macros are module-owned.
/datum/unit_test/dynamic_roundstart_cancellation/blood_worm_signal_lifecycle/proc/host_is_cancelled(datum/mind/candidate, mob/living/body)
	return SEND_SIGNAL(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, body) & COMPONENT_CANCEL_CHARACTER_SPAWN

// Native assertion-anchor fixtures execute before module-owned admission defines are included.
/datum/unit_test/proc/expected_character_profile_error()
	return JOB_UNAVAILABLE_CHARACTER_PROFILE

/datum/unit_test/proc/expected_job_lock_error()
	return JOB_UNAVAILABLE_JOB_LOCK
