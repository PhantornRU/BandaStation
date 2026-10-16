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
	job_flags = (STATION_JOB_FLAGS | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_PROTECTED) & ~JOB_REOPEN_ON_ROUNDSTART_LOSS
	tgui_icon = FA_ICON_LOCK

// BANDASTATION EDIT: the exact initial-record callback owns Prisoner crime and memory registration.

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

	// BANDASTATION EDIT START - Use the committed crime once, independently of donor flags.
	if(visuals_only || new_prisoner.prisoner_tattoos_applied)
		return
	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[new_prisoner.prisoner_crime]
	if (isnull(crime))
		return
	new_prisoner.prisoner_tattoos_applied = TRUE
	// BANDASTATION EDIT END
	var/list/limbs_to_tat = new_prisoner.get_bodyparts()
	for(var/i in 1 to crime.tattoos)
		if(!length(SSpersistence.prison_tattoos_to_use) || !length(limbs_to_tat)) // BANDASTATION EDIT: each limb can receive only one tattoo from this outfit.
			return
		var/obj/item/bodypart/tatted_limb = pick_n_take(limbs_to_tat)
		var/list/tattoo = pick_n_take(SSpersistence.prison_tattoos_to_use)
		tatted_limb.AddComponent(/datum/component/tattoo, tattoo["story"])
