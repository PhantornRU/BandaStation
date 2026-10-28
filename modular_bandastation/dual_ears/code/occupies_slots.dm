/mob/living/carbon/human
	/// Secondary inventory slots reserved by clothing, keyed by stringified slot bit.
	var/list/occupied_clothing_slots

/// Reserve additional clothing slots while keeping one real equipment slot and one set of effects.
/datum/component/occupies_slots
	// Duplicate protection components must not reserve and then release an already worn item.
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/occupied_slots
	var/primary_slot = NONE
	var/mob/living/carbon/human/wearer

/datum/component/occupies_slots/Initialize(occupied_slots)
	if(!isitem(parent) || !isnum(occupied_slots) || occupied_slots <= 0 || round(occupied_slots) != occupied_slots || (occupied_slots & ~(ITEM_SLOT_ON_BODY | ITEM_SLOT_STORAGE)))
		return COMPONENT_INCOMPATIBLE
	src.occupied_slots = occupied_slots

/datum/component/occupies_slots/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_POST_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_icon_updated))
	var/obj/item/item = parent
	var/mob/living/carbon/human/current_wearer = item.loc
	if(istype(current_wearer))
		reserve_slots(current_wearer, current_wearer.get_slot_by_item(item))

/datum/component/occupies_slots/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_POST_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ATOM_UPDATED_ICON))
	release_slots()

/datum/component/occupies_slots/Destroy(force)
	release_slots()
	return ..()

/// ignore_equipped must not allow another item to steal a required slot.
/datum/component/occupies_slots/proc/can_equip(mob/living/carbon/human/target, target_slot)
	if(!(target_slot & occupied_slots))
		return TRUE
	if(QDELETED(target) || QDELETED(parent))
		return FALSE
	for(var/slot in bitfield_to_list(occupied_slots))
		var/obj/item/occupant = target.get_item_by_slot(slot)
		if(occupant && occupant != parent)
			return FALSE
	return TRUE

/datum/component/occupies_slots/proc/on_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	return reserve_slots(user, slot)

/datum/component/occupies_slots/proc/reserve_slots(mob/living/carbon/human/target, target_slot)
	release_slots()
	if(!istype(target) || !(target_slot & occupied_slots))
		return
	var/obj/item/item = parent
	if(QDELETED(item) || item.loc != target || target.get_slot_by_item(item) != target_slot)
		return
	if(!can_equip(target, target_slot))
		// Also protect raw equip calls and components attached to already worn clothing.
		INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, dropItemToGround), item, TRUE, TRUE)
		return COMPONENT_EQUIPPED_FAILED
	wearer = target
	primary_slot = target_slot
	RegisterSignal(wearer, COMSIG_QDELETING, PROC_REF(on_wearer_deleted))
	for(var/slot in bitfield_to_list(occupied_slots & ~primary_slot))
		LAZYSET(wearer.occupied_clothing_slots, "[slot]", item)
	refresh_hud()

/datum/component/occupies_slots/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	release_slots()

/datum/component/occupies_slots/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	release_slots()

/datum/component/occupies_slots/proc/on_icon_updated(datum/source)
	SIGNAL_HANDLER
	refresh_hud()

/datum/component/occupies_slots/proc/refresh_hud()
	if(QDELETED(wearer))
		return
	for(var/slot in bitfield_to_list(occupied_slots))
		wearer.hud_used?.update_inventory_slot(slot)

/datum/component/occupies_slots/proc/release_slots()
	if(!wearer)
		return
	var/mob/living/carbon/human/old_wearer = wearer
	UnregisterSignal(old_wearer, COMSIG_QDELETING)
	for(var/slot in bitfield_to_list(occupied_slots & ~primary_slot))
		if(LAZYACCESS(old_wearer.occupied_clothing_slots, "[slot]") == parent)
			LAZYREMOVE(old_wearer.occupied_clothing_slots, "[slot]")
	refresh_hud()
	wearer = null
	primary_slot = NONE
