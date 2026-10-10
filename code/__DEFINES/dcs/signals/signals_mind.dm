///from mind/transfer_to. Sent after the mind has been transferred: (mob/previous_body)
#define COMSIG_MIND_TRANSFERRED "mind_transferred"

/// From ticker/create_characters, before equipment and handover: (mob/living/character).
#define COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED "mind_roundstart_character_created" // BANDASTATION ADDITION
	#define COMPONENT_CANCEL_CHARACTER_SPAWN (1<<0)

/// Called on the mind when an antagonist is being gained, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_GAINED "antagonist_gained"

/// Called on the mind when an antagonist is being removed, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_REMOVED "antagonist_removed"

/// Called on the mob when losing an antagonist datum (datum/antagonist/antagonist)
#define COMSIG_MOB_ANTAGONIST_REMOVED "mob_antagonist_removed"
