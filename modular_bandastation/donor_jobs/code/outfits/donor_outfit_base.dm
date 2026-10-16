/datum/outfit/job/donor
	ears = /obj/item/radio/headset/headset_srv

/datum/outfit/job/donor/equip_backpack_item(mob/living/carbon/human/user, item_path)
	return equip_backpack_item_preserving_overflow(user, item_path)
