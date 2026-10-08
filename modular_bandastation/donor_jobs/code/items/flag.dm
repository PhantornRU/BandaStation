/obj/item/donor_flag
	name = "flag"
	desc = "It's a flag."
	icon = 'modular_bandastation/donor_jobs/icons/flag.dmi'
	icon_state = "ntflag"
	lefthand_file = 'modular_bandastation/donor_jobs/icons/flags_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/flags_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_integrity = 40
	resistance_flags = FLAMMABLE
	var/rolled = FALSE

/obj/item/donor_flag/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/donor_flag/attack_self(mob/user)
	rolled = !rolled
	user.visible_message(span_notice("[user] [rolled ? "rolls up" : "unfurls"] [src]."))
	update_appearance()

/obj/item/donor_flag/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.get_temperature() && !(resistance_flags & ON_FIRE))
		user.visible_message(span_notice("[user] lights [src] with [tool]."))
		fire_act(tool.get_temperature())
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/donor_flag/update_icon_state()
	icon_state = "[initial(icon_state)][rolled ? "_rolled" : ""]"
	inhand_icon_state = "[initial(icon_state)][resistance_flags & ON_FIRE ? "_fire" : ""]"
	return ..()

/obj/item/donor_flag/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	update_appearance()

/obj/item/donor_flag/extinguish()
	. = ..()
	update_appearance()

/obj/item/donor_flag/grey
	name = "\improper Greytide flag"
	desc = "A banner made from an old grey jumpsuit."
	icon_state = "greyflag"
