/datum/outfit/job/donor/cleaning_manager
	name = "Cleaning Manager"
	jobtype = /datum/job/donor/cleaning_manager
	id_trim = /datum/id_trim/job/donor_cleaning_manager
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	shoes = /obj/item/clothing/shoes/galoshes/dry
	suit = /obj/item/clothing/suit/apron/overalls
	gloves = /obj/item/clothing/gloves/color/purple
	mask = /obj/item/clothing/mask/bandana/purple
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor/full
	r_pocket = /obj/item/door_remote/donor_janitor
	ears = /obj/item/radio/headset/headset_srv
	l_pocket = /obj/item/modular_computer/pda/crew/janitor/donor
	pda_slot = ITEM_SLOT_LPOCKET
	donor_kit = list(
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 1,
		/obj/item/clipboard = 1,
	)

/datum/outfit/job/donor/cleaning_manager/pre_equip(mob/living/carbon/human/human, visuals_only = FALSE)
	. = ..()
	if(visuals_only && belt == /obj/item/storage/belt/janitor/full)
		belt = /obj/item/storage/belt/janitor

/datum/outfit/job/donor/cleaning_manager/apprentice
	name = "Cleaning Manager (apprentice)"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/grey
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/soft/grey
	belt = /obj/item/storage/belt/fannypack/white
	l_hand = /obj/item/storage/toolbox/mechanical
	r_hand = /obj/item/donor_flag/grey
	donor_kit = list(
		/obj/item/clothing/head/utility/welding = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/under/shorts/grey = 1,
		/obj/item/clothing/under/misc/assistantformal = 1,
	)

/datum/outfit/job/donor/cleaning_manager/apprentice/pre_equip(mob/living/carbon/human/human, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		l_hand = /obj/item/storage/toolbox/mechanical/donor_preview
