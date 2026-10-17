// Included after modular_bandastation.dme in the TEMP test overlay: these signal macros are module-owned.
/datum/unit_test/dynamic_roundstart_cancellation/blood_worm_signal_lifecycle/proc/host_is_cancelled(datum/mind/candidate, mob/living/body)
	return SEND_SIGNAL(candidate, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, body) & COMPONENT_CANCEL_CHARACTER_SPAWN

// Native assertion-anchor fixtures execute before module-owned admission defines are included.
/datum/unit_test/proc/expected_character_profile_error()
	return JOB_UNAVAILABLE_CHARACTER_PROFILE

/datum/unit_test/proc/expected_job_lock_error()
	return JOB_UNAVAILABLE_JOB_LOCK

/datum/unit_test/proc/expected_roundstart_character_signal()
	return COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED

// Observe the actual snapshot validator after its product implementation is included.
// The snapshot and job remain callable even when construction hard-deletes the player.
/datum/job_character_creation/validate_character(mob/living/body, mob/dead/new_player/player)
	if(istype(player, /mob/dead/new_player/contract_create_fixture))
		var/mob/dead/new_player/contract_create_fixture/fixture_player = player
		fixture_player.validation_calls++
		fixture_player.last_creation = src
	if(istype(job, /datum/job/contract_creation_interrupt_fixture))
		var/datum/job/contract_creation_interrupt_fixture/fixture_job = job
		fixture_job.validation_calls++
		fixture_job.last_creation = src
		fixture_job.captured_mind = character_mind
		fixture_job.captured_assignment = assignment
	. = ..()
