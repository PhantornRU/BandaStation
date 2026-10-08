/datum/outfit/job/donor/adjutant
	name = "Adjutant"
	jobtype = /datum/job/donor/adjutant
	id_trim = /datum/id_trim/job/donor_adjutant
	belt = /obj/item/modular_computer/pda/crew/lawyer/donor
	uniform = /obj/item/clothing/under/donor/iaa/blue
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/white
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge
	l_hand = /obj/item/storage/briefcase
	ears = /obj/item/radio/headset/donor_service_command
	donor_kit = list(
		/obj/item/folder/blue = 1,
		/obj/item/camera = 1,
		/obj/item/taperecorder = 1,
		/obj/item/storage/box/tapes = 1,
		/obj/item/clipboard = 1,
		/obj/item/clothing/under/rank/civilian/lawyer/blue = 1,
	)
	implants = list(/obj/item/implant/mindshield)
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

/datum/outfit/job/donor/adjutant/pre_equip(mob/living/carbon/human/human, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		l_hand = /obj/item/storage/briefcase/empty

/datum/outfit/job/donor/adjutant/butler
	name = "Adjutant (butler)"
	belt = /obj/item/modular_computer/pda/crew/bar/donor
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/black
	glasses = /obj/item/clothing/glasses/monocle
	head = /obj/item/clothing/head/hats/tophat
	donor_kit = list(
		/obj/item/rag = 1,
		/obj/item/folder/blue = 1,
		/obj/item/camera = 1,
		/obj/item/taperecorder = 1,
		/obj/item/storage/box/tapes = 1,
		/obj/item/clipboard = 1,
		/obj/item/clothing/under/donor/iaa = 1,
		/obj/item/clothing/suit/toggle/lawyer/black = 1,
		/obj/item/clothing/suit/chef/classic = 1,
	)

/datum/outfit/job/donor/adjutant/maid
	name = "Adjutant (maid)"
	belt = /obj/item/modular_computer/pda/crew/bar/donor
	uniform = /obj/item/clothing/under/donor/maid
	donor_kit = list(
		/obj/item/rag = 1,
		/obj/item/folder/blue = 1,
		/obj/item/camera = 1,
		/obj/item/taperecorder = 1,
		/obj/item/storage/box/tapes = 1,
		/obj/item/clipboard = 1,
		/obj/item/clothing/suit/chef/classic = 1,
	)
