/// Validate the constructed body before roundstart equipment, minds and ownership change hands.
/datum/controller/subsystem/ticker/proc/validate_roundstart_character(mob/dead/new_player/player, mob/living/character)
	var/datum/mind/candidate = player.mind || player.new_character?.mind
	var/datum/job_character_selection/selection = player.assigned_character
	if(character && !(SEND_SIGNAL(character.mind, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, character) & COMPONENT_CANCEL_CHARACTER_SPAWN))
		return TRUE
	SSdynamic.cancel_roundstart_assignment(candidate)
	player.cancel_character_spawn(selection, candidate)
	return FALSE
