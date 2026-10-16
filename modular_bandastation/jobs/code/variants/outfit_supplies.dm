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

/datum/outfit/job
	/// Preserve a role's starting supplies when its selected backpack cannot hold them.
	var/preserve_backpack_supplies = FALSE

/datum/outfit/job/equip_backpack_item(mob/living/carbon/human/user, item_path)
	. = ..()
	if(. || !preserve_backpack_supplies)
		return
	equip_backpack_item_preserving_overflow(user, item_path)
	return TRUE
