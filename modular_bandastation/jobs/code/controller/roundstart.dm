/// Create and validate one assigned character before the native ticker advances to equipment.
/datum/controller/subsystem/ticker/proc/create_initial_job_character(mob/dead/new_player/player)
	var/atom/destination = player.mind.assigned_role.get_roundstart_spawn_point()
	var/mob/living/character = destination ? player.create_character(destination) : null
	if(character && (SEND_SIGNAL(character.mind, COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED, character) & COMPONENT_CANCEL_CHARACTER_SPAWN))
		character = null
	if(character)
		GLOB.joined_player_list += player.ckey
		return character
	var/datum/mind/candidate = player.mind || player.new_character?.mind
	SSdynamic.cancel_roundstart_assignment(candidate)
	player.cancel_character_spawn()
	return null
