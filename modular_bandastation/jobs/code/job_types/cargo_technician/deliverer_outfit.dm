/datum/outfit/job/cargo_tech/deliverer
	name = "Cargo Technician (Deliverer)"
	id_trim = /datum/id_trim/job/cargo_technician/deliverer
	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/workboots
	suit = null
	head = /obj/item/clothing/head/soft
	r_hand = /obj/item/storage/bag/mail
	backpack_contents = list(
		/obj/item/boxcutter = 1,
		/obj/item/clipboard = 1,
	)

/datum/outfit/job/cargo_tech/deliverer/equip_backpack_item(mob/living/carbon/human/user, item_path)
	return equip_backpack_item_preserving_overflow(user, item_path)
