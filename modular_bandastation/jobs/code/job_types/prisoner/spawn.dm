/// Resolve one crime for equipment and the initial record.
/mob/living/carbon/human
	var/prisoner_crime
	var/prisoner_record_registered = FALSE
	var/prisoner_tattoos_applied = FALSE

/// Capture one crime before preference application can yield, alongside the shared variant context.
/datum/job/prisoner/prepare_spawn_character(mob/living/body, datum/preferences/preferences)
	. = ..()
	if(!ishuman(body))
		return
	var/mob/living/carbon/human/new_prisoner = body
	if(GLOB.prisoner_crimes[new_prisoner.prisoner_crime])
		return
	var/crime_name = preferences?.read_preference(/datum/preference/choiced/prisoner_crime)
	new_prisoner.prisoner_crime = GLOB.prisoner_crimes[crime_name] ? crime_name : pick(assoc_to_keys(GLOB.prisoner_crimes))

/// Write the already selected crime into the exact initial record once.
/datum/job/prisoner/proc/register_initial_prisoner_record(mob/living/carbon/human/crewmember, datum/record/crew/target_record)
	if(crewmember.prisoner_record_registered)
		return FALSE
	var/crime_name = crewmember.prisoner_crime
	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[crime_name]
	if(!crime)
		CRASH("Initial Prisoner record has no selected crime")
	crewmember.prisoner_record_registered = TRUE
	var/datum/crime/past_crime = new(crime.name, crime.desc, "Central Command", "Indefinite.")
	target_record.crimes += past_crime
	target_record.recreate_manifest_photos(add_height_chart = TRUE)
	to_chat(crewmember, span_warning("Вы отбываете наказание за: [crime.name]."))
	crewmember.add_mob_memory(/datum/memory/key/permabrig_crimes, crimes = crime_name)
	return TRUE
