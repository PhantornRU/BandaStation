/datum/outfit/job/donor/acolyte
	name = "Acolyte"
	jobtype = /datum/job/donor/acolyte
	id_trim = /datum/id_trim/job/donor_acolyte
	belt = /obj/item/modular_computer/pda/crew/chaplain/donor
	uniform = /obj/item/clothing/under/donor/victorian
	shoes = /obj/item/clothing/shoes/sandal/velcro
	suit = /obj/item/clothing/suit/hooded/monk
	r_hand = /obj/item/storage/bag/garment/chaplain
	ears = /obj/item/radio/headset/headset_srv
	donor_kit = list()

/datum/outfit/job/donor/acolyte/pre_equip(mob/living/carbon/human/human, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		r_hand = /obj/item/storage/bag/garment
