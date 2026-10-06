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

// BANDASTATION EDIT - Initial crime and tattoos are registered on the actual
// manifest record by on_initial_crew_record, after it exists.

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

// BANDASTATION EDIT - Tattoos use the same fixed crime as the initial record.
