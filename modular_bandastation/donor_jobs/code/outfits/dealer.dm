/datum/outfit/job/donor/dealer
	name = "Dealer"
	jobtype = /datum/job/donor/dealer
	id_trim = /datum/id_trim/job/donor_dealer
	back = /obj/item/storage/backpack/duffelbag
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/cowboy/black/laced
	suit = /obj/item/clothing/suit/pirate_black
	belt = /obj/item/melee/baton
	head = /obj/item/clothing/head/fedora
	l_hand = /obj/item/cane
	glasses = /obj/item/clothing/glasses/sunglasses/big
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_srv
	l_pocket = /obj/item/modular_computer/pda/crew
	pda_slot = ITEM_SLOT_LPOCKET
	donor_kit = list(
		/obj/item/donor_payment_terminal = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/hand_labeler_refill = 1,
		/obj/item/storage/box/donor_stock = 1,
	)

/datum/outfit/job/donor/dealer/brown
	name = "Dealer (brown)"
	uniform = /obj/item/clothing/under/color/brown
	shoes = /obj/item/clothing/shoes/cowboy/laced
	suit = /obj/item/clothing/suit/costume/pirate
	head = /obj/item/clothing/head/cowboy/grey
	gloves = /obj/item/clothing/gloves/color/brown
