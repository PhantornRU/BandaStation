/// Only jobs declaring variants participate in the outfit extension.
/datum/job/donor/prepare_spawn_character(mob/living/body, datum/preferences/preferences)
	..()
	prepare_donor_character(body, preferences)

/datum/job/donor/get_spawn_outfit(mob/living/carbon/human/body, datum/preferences/preferences, visual_only, consistent)
	return donor_outfit_for(body, preferences, visual_only, consistent)

/datum/job/donor/get_character_job_title(datum/job_character_selection/character)
	return get_donor_character_title(character)

/datum/job/prisoner/prepare_spawn_character(mob/living/body, datum/preferences/preferences)
	..()
	prepare_donor_character(body, preferences)

/datum/job/prisoner/get_spawn_outfit(mob/living/carbon/human/body, datum/preferences/preferences, visual_only, consistent)
	return donor_outfit_for(body, preferences, visual_only, consistent)

/datum/job/prisoner/get_character_job_title(datum/job_character_selection/character)
	return get_donor_character_title(character)

/datum/job/cargo_technician/prepare_spawn_character(mob/living/body, datum/preferences/preferences)
	..()
	prepare_donor_character(body, preferences)

/datum/job/cargo_technician/get_spawn_outfit(mob/living/carbon/human/body, datum/preferences/preferences, visual_only, consistent)
	return donor_outfit_for(body, preferences, visual_only, consistent)

/datum/job/cargo_technician/get_character_job_title(datum/job_character_selection/character)
	return get_donor_character_title(character)

/datum/job/donor/get_join_lock_reason(client/player)
	return ..() || donor_lock_reason(player)

/datum/job/prisoner/get_join_lock_reason(client/player)
	return ..() || donor_lock_reason(player)

/datum/job/proc/get_donor_character_title(datum/job_character_selection/character)
	var/list/variants = character.read_preference(/datum/preference/job_outfit_variants)
	var/datum/job_variant/variant = resolve_donor_variant(variants?[title])
	return variant?.public_title || job_title_ru(title)
