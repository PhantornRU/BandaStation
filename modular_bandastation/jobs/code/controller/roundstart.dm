/// Validate the native construction; failed admission cancels only this prepared assignment.
/datum/controller/subsystem/ticker/proc/validate_initial_job_character(mob/dead/new_player/player, mob/living/character)
	if(character && !(SEND_SIGNAL(character.mind, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, character) & COMPONENT_CANCEL_CHARACTER_SPAWN))
		return TRUE
	var/datum/mind/candidate = player.mind || player.new_character?.mind
	SSdynamic.cancel_roundstart_assignment(candidate)
	player.cancel_character_spawn()
	return FALSE
