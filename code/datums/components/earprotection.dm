///Whenever get_ear_protection() is called, this proc adds 'protection_value' to the wearer's natural ear protection.
/datum/component/wearertargeting/earprotection
	signals = list(COMSIG_LIVING_GET_EAR_PROTECTION)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(reducebang)
	//positive amount indicating how much protection this gives
	var/protection_amount = 1
	valid_slots = ITEM_SLOT_EARS | ITEM_SLOT_HEAD

/datum/component/wearertargeting/earprotection/Initialize(protection_amount = EAR_PROTECTION_NORMAL)
	. = ..()
	// BANDASTATION ADDITION START - Protected earpieces occupy both ears
	if(. == COMPONENT_INCOMPATIBLE)
		return
	// BANDASTATION ADDITION END
	src.protection_amount = protection_amount
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_tags))
	// BANDASTATION ADDITION START - Protected earpieces occupy both ears
	var/obj/item/protected_item = parent
	if(protected_item.slot_flags & ITEM_SLOT_EARS)
		protected_item.AddComponent(/datum/component/occupies_slots, ITEM_SLOT_EARS)
	// BANDASTATION ADDITION END

/datum/component/wearertargeting/earprotection/proc/reducebang(datum/source, list/reflist)
	SIGNAL_HANDLER
	reflist[EAR_PROTECTION_ARG] += protection_amount

/datum/component/wearertargeting/earprotection/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(protection_amount == EAR_PROTECTION_NORMAL)
		examine_list["звуконепроницаемый"] = "Защищает уши от светошумовых гранат и других громких звуков."
	else if(protection_amount >= EAR_PROTECTION_HEAVY)
		examine_list["звуконепроницаемый"] = "Обеспечивает [protection_amount == EAR_PROTECTION_FULL ? "полную" : "серьёзную"] защиту от светошумовых гранат и других громких звуков."
