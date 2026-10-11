/datum/job/prisoner
	title = JOB_PRISONER
	description = "Окажитесь заточенным в пермабриге."
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 4
	supervisors = "Службой Безопасности"
	exp_granted_type = EXP_TYPE_CREW
	paycheck = PAYCHECK_LOWER
	config_tag = "PRISONER"

	outfit = /datum/outfit/job/prisoner
	plasmaman_outfit = /datum/outfit/plasmaman/prisoner

	display_order = JOB_DISPLAY_ORDER_PRISONER
	department_for_prefs = /datum/job_department/security

	exclusive_mail_goodies = TRUE
	mail_goodies = list (
		/obj/effect/spawner/random/contraband/prison = 1
	)

	family_heirlooms = list(/obj/item/pen/blue)
	rpg_title = "Defeated Miniboss"
	job_flags = STATION_JOB_FLAGS | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_PROTECTED & ~JOB_REOPEN_ON_ROUNDSTART_LOSS
	tgui_icon = FA_ICON_LOCK

// BANDASTATION EDIT - The initial-record callback supplies the created record;
// CREWMEMBER_JOINED is too early, so there is no global join subscription.
/datum/job/prisoner/proc/handle_prisoner_joining(mob/living/carbon/human/crewmember, datum/record/crew/target_record)
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

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	id = /obj/item/card/id/advanced/prisoner
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner
	belt = null
	ears = null
	shoes = /obj/item/clothing/shoes/sneakers/orange
	box = /obj/item/storage/box/survival/prisoner
	pda_slot = null

/datum/outfit/job/prisoner/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(1)) // D BOYYYYSSSSS
		head = /obj/item/clothing/head/beanie/black/dboy

/datum/outfit/job/prisoner/post_equip(mob/living/carbon/human/new_prisoner, visuals_only)
	. = ..()
	// BANDASTATION EDIT START - Preview and repeated equipment must not consume tattoos.
	if(visuals_only || new_prisoner.prisoner_tattoos_applied)
		return
	var/crime_name = new_prisoner.prisoner_crime
	// BANDASTATION EDIT END
	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[crime_name]
	if (isnull(crime))
		return
	new_prisoner.prisoner_tattoos_applied = TRUE // BANDASTATION EDIT - Effects belong to this character once.
	var/list/limbs_to_tat = new_prisoner.get_bodyparts()
	for(var/i in 1 to crime.tattoos)
		if(!length(SSpersistence.prison_tattoos_to_use) || !length(limbs_to_tat)) // BANDASTATION EDIT - A body may have fewer limbs than tattoos.
			return
		var/obj/item/bodypart/tatted_limb = pick_n_take(limbs_to_tat)
		var/list/tattoo = pick_n_take(SSpersistence.prison_tattoos_to_use)
		tatted_limb.AddComponent(/datum/component/tattoo, tattoo["story"])
