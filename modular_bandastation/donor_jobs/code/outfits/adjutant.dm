/datum/outfit/job/donor/adjutant
	name = "Adjutant"
	jobtype = /datum/job/donor/adjutant
	id_trim = /datum/id_trim/job/donor_adjutant
	uniform = /obj/item/clothing/under/suit/navy
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/toggle/lawyer/greyscale
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
		/obj/item/clothing/under/suit/navy = 1,
	)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/donor/adjutant/butler
	name = "Adjutant (butler)"
	uniform = /obj/item/clothing/under/suit/black
	glasses = /obj/item/clothing/glasses/monocle
	head = /obj/item/clothing/head/hats/tophat
	donor_kit = list(
		/obj/item/reagent_containers/cup/rag = 1,
		/obj/item/folder/blue = 1,
		/obj/item/camera = 1,
		/obj/item/taperecorder = 1,
		/obj/item/storage/box/tapes = 1,
		/obj/item/clipboard = 1,
		/obj/item/clothing/under/suit/black = 1,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 1,
		/obj/item/clothing/suit/chef/classic = 1,
	)

/datum/outfit/job/donor/adjutant/maid
	name = "Adjutant (maid)"
	uniform = /obj/item/clothing/under/costume/maid
	donor_kit = list(
		/obj/item/reagent_containers/cup/rag = 1,
		/obj/item/folder/blue = 1,
		/obj/item/camera = 1,
		/obj/item/taperecorder = 1,
		/obj/item/storage/box/tapes = 1,
		/obj/item/clipboard = 1,
		/obj/item/clothing/suit/chef/classic = 1,
	)
