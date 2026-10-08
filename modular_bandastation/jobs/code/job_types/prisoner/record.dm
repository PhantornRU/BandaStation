/mob/living/carbon/human
	var/prisoner_crime
	var/prisoner_record_registered = FALSE

/datum/job/prisoner/get_spawn_mob(client/player_client, atom/spawn_point)
	var/crime_key = player_client.prefs.read_preference(/datum/preference/choiced/prisoner_crime)
	. = ..()
	if(!ishuman(.))
		return
	var/mob/living/carbon/human/body = .
	body.prisoner_crime = GLOB.prisoner_crimes[crime_key] ? crime_key : pick(assoc_to_keys(GLOB.prisoner_crimes))

/datum/job/prisoner/on_initial_crew_record(mob/living/carbon/human/body, datum/record/crew/record)
	..()
	if(body.prisoner_record_registered)
		return FALSE
	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[body.prisoner_crime]
	if(!crime)
		CRASH("Initial Prisoner record has no selected crime")
	body.prisoner_record_registered = TRUE
	record.crimes += new /datum/crime(crime.name, crime.desc, "Central Command", "Indefinite.")
	body.add_mob_memory(/datum/memory/key/permabrig_crimes, crimes = body.prisoner_crime)
	var/list/limbs = body.get_bodyparts()
	for(var/i in 1 to crime.tattoos)
		if(!length(limbs) || !length(SSpersistence.prison_tattoos_to_use))
			break
		var/obj/item/bodypart/limb = pick_n_take(limbs)
		var/list/tattoo = pick_n_take(SSpersistence.prison_tattoos_to_use)
		limb.AddComponent(/datum/component/tattoo, tattoo["story"])
	record.recreate_manifest_photos(add_height_chart = TRUE)
	to_chat(body, span_warning("Вы отбываете наказание за: [crime.name]."))
	return TRUE
