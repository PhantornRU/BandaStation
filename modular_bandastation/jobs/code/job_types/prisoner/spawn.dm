/// Resolve one crime for equipment and the initial record.
/mob/living/carbon/human
	var/prisoner_crime
	var/prisoner_record_registered = FALSE
	var/prisoner_tattoos_applied = FALSE

/datum/job/prisoner/get_spawn_mob(client/player_client, atom/spawn_point)
	var/crime_name = player_client.prefs.read_preference(/datum/preference/choiced/prisoner_crime)
	. = ..()
	if(!ishuman(.))
		return
	var/mob/living/carbon/human/new_prisoner = .
	new_prisoner.prisoner_crime = GLOB.prisoner_crimes[crime_name] ? crime_name : pick(assoc_to_keys(GLOB.prisoner_crimes))
