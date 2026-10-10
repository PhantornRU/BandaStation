/datum/outfit/job/donor
	ears = /obj/item/radio/headset/headset_srv

/// Keep starting supplies with their recipient before falling back to the floor.
/datum/outfit/job/proc/equip_backpack_item_preserving_overflow(mob/living/carbon/human/user, item_path)
	var/obj/item/supply = SSwardrobe.provide_type(item_path, user)
	if(QDELETED(supply))
		return TRUE
	if(user.equip_to_storage(supply, ITEM_SLOT_BACK, indirect_action = TRUE) || QDELETED(supply))
		return TRUE
	to_chat(user, span_notice("[supply] не помещается в сумку и оставлен рядом с вами."))
	supply.forceMove(user.drop_location())
	return FALSE

/datum/outfit/job/donor/equip_backpack_item(mob/living/carbon/human/user, item_path)
	return equip_backpack_item_preserving_overflow(user, item_path)

/datum/outfit/job/cargo_tech/donor_deliverer/equip_backpack_item(mob/living/carbon/human/user, item_path)
	return equip_backpack_item_preserving_overflow(user, item_path)
