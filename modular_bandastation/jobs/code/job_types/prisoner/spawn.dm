/// Resolve one crime for equipment and the initial record.
/mob/living/carbon/human
	var/prisoner_crime
	var/prisoner_record_registered = FALSE
	var/prisoner_tattoos_applied = FALSE

/// The native global join callback runs before the actual initial record exists.
/datum/job/prisoner/New()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)

/datum/job/prisoner/get_spawn_mob(client/player_client, atom/spawn_point)
	var/crime_name = player_client.prefs.read_preference(/datum/preference/choiced/prisoner_crime)
	. = ..()
	if(!ishuman(.))
		return
	var/mob/living/carbon/human/new_prisoner = .
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

/datum/outfit/job/prisoner/post_equip(mob/living/carbon/human/new_prisoner, visuals_only)
	// Run common ID/PDA setup once, bypassing the original preference-based Prisoner tattoos.
	. = call(src, /datum/outfit/job::post_equip())(new_prisoner, visuals_only)
	if(visuals_only || new_prisoner.prisoner_tattoos_applied)
		return
	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[new_prisoner.prisoner_crime]
	if(isnull(crime))
		return
	new_prisoner.prisoner_tattoos_applied = TRUE
	var/list/limbs_to_tat = new_prisoner.get_bodyparts()
	for(var/i in 1 to crime.tattoos)
		if(!length(SSpersistence.prison_tattoos_to_use) || !length(limbs_to_tat))
			return
		var/obj/item/bodypart/tatted_limb = pick_n_take(limbs_to_tat)
		var/list/tattoo = pick_n_take(SSpersistence.prison_tattoos_to_use)
		tatted_limb.AddComponent(/datum/component/tattoo, tattoo["story"])
