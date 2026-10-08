/obj/item/cigarette/donor
	chem_volume = 60
	list_reagents = list(/datum/reagent/drug/nicotine = 40)
	smoketime = 5 MINUTES
	dragtime = 2 SECONDS
	lung_harm = 0
	var/first_puff = TRUE

/obj/item/cigarette/donor/handle_reagents(seconds_per_tick)
	if(!reagents.total_volume)
		return
	reagents.expose_temperature(heat, 0.05)
	var/mob/living/carbon/smoker = loc
	if(!istype(smoker) || smoker.get_item_by_slot(ITEM_SLOT_MASK) != src)
		reagents.remove_all(0.2 * seconds_per_tick)
		return
	var/list/puff_reagents = reagents.reagent_list.Copy()
	for(var/datum/reagent/puff as anything in puff_reagents)
		var/amount = first_puff ? 1 : max(0.2 * seconds_per_tick / length(puff_reagents), 0.1)
		reagents.trans_to(smoker, amount, target_id = puff.type, methods = INHALE, ignore_stomach = TRUE)
	first_puff = FALSE

/obj/item/cigarette/donor/process(seconds_per_tick)
	if(!reagents.total_volume)
		put_out(isliving(loc) ? loc : null)
		return
	return ..()

/obj/item/cigarette/donor/menthol
	list_reagents = list(/datum/reagent/drug/nicotine = 40, /datum/reagent/consumable/menthol = 20)

/obj/item/cigarette/donor/syndicate
	list_reagents = list(/datum/reagent/drug/nicotine = 40, /datum/reagent/medicine/omnizine = 20)

/obj/item/cigarette/donor/medical
	list_reagents = list(/datum/reagent/drug/cannabis = 40, /datum/reagent/donor_cbd = 20)

/obj/item/cigarette/donor/gold
	list_reagents = list(/datum/reagent/drug/nicotine = 40, /datum/reagent/gold = 1)

/obj/item/cigarette/donor/shady
	list_reagents = list(
		/datum/reagent/drug/nicotine = 40,
		/datum/reagent/toxin/lipolicide = 7.5,
		/datum/reagent/ammonia = 2,
		/datum/reagent/toxin/donor_atrazine = 1,
		/datum/reagent/toxin = 1.5,
	)

/obj/item/cigarette/donor/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper."
	icon = 'modular_bandastation/donor_jobs/icons/cigarettes.dmi'
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	inhand_icon_on = "spliffon"
	inhand_icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach

/obj/item/cigarette/donor/rollie/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/cigarette/donor/random
	var/static/list/flavors = list(
		/datum/reagent/fuel,
		/datum/reagent/saltpetre,
		/datum/reagent/medicine/synaptizine,
		/datum/reagent/donor_green_vomit,
		/datum/reagent/medicine/potass_iodide,
		/datum/reagent/donor_msg,
		/datum/reagent/toxin/lexorin,
		/datum/reagent/medicine/mannitol,
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/medicine/cryoxadone,
		/datum/reagent/water/holywater,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/donor_egg,
		/datum/reagent/medicine/haloperidol,
		/datum/reagent/toxin/mutagen,
		/datum/reagent/medicine/omnizine,
		/datum/reagent/carpet,
		/datum/reagent/drug/aranesp,
		/datum/reagent/cryostylane,
		/datum/reagent/consumable/donor_chocolate,
		/datum/reagent/consumable/ethanol/bilk,
		/datum/reagent/consumable/donor_cheese,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/blood,
		/datum/reagent/medicine/donor_charcoal,
		/datum/reagent/consumable/coffee,
		/datum/reagent/donor_ectoplasm,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/consumable/milk,
		/datum/reagent/medicine/mutadone,
		/datum/reagent/medicine/antihol,
		/datum/reagent/medicine/donor_teporone,
		/datum/reagent/medicine/insulin,
		/datum/reagent/medicine/salbutamol,
		/datum/reagent/toxin,
	)

/obj/item/cigarette/donor/random/Initialize(mapload)
	list_reagents = list(/datum/reagent/drug/nicotine = 40, pick(flavors) = 20)
	return ..()

/datum/storage/cigarette_box/donor
	max_total_storage = 6

/datum/storage/cigarette_box/donor/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(/obj/item/cigarette, /obj/item/lighter, /obj/item/match), list(/obj/item/cigarette/cigar, /obj/item/cigarette/pipe, /obj/item/lighter/donor_zippo))

/datum/storage/cigarette_box/donor/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = STORAGE_NOT_LOCKED)
	if(to_insert.get_temperature())
		if(messages)
			to_chat(user, span_warning("Погасите [to_insert.declent_ru(ACCUSATIVE)] прежде, чем класть в пачку."))
		return FALSE
	return ..()

/obj/item/storage/fancy/cigarettes/donor
	name = "cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'modular_bandastation/donor_jobs/icons/cigarettes.dmi'
	icon_state = "cigpacket"
	inhand_icon_state = "cigpacket"
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 2
	spawn_type = /obj/item/cigarette/donor
	spawn_count = 6
	spawn_coupon = FALSE
	storage_type = /datum/storage/cigarette_box/donor
	display_cigs = FALSE

/obj/item/storage/fancy/cigarettes/donor/update_icon_state()
	icon_state = "[initial(icon_state)][length(contents)]"

/obj/item/storage/fancy/cigarettes/donor/update_overlays()
	return list()

/obj/item/storage/fancy/cigarettes/donor/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "Dpacket"
	inhand_icon_state = "Dpacket"

/obj/item/storage/fancy/cigarettes/donor/syndicate
	name = "\improper Syndicate Cigarettes"
	desc = "A packet of six evil-looking cigarettes. A label on the packaging reads, \"Donk Co\"."
	icon_state = "robustpacket"
	inhand_icon_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/donor/syndicate/Initialize(mapload)
	. = ..()
	name = "[pick("evil", "suspicious", "ominous", "donk-flavored", "robust", "sneaky")] cigarette packet"

/obj/item/storage/fancy/cigarettes/donor/cigpack_syndicate
	desc = "An obscure brand of cigarettes."
	icon_state = "syndiepacket"
	inhand_icon_state = "syndiepacket"
	spawn_type = /obj/item/cigarette/donor/syndicate

/obj/item/storage/fancy/cigarettes/donor/cigpack_med
	name = "\improper Medical Marijuana Packet"
	desc = "A prescription packet containing six marijuana cigarettes."
	icon_state = "medpacket"
	inhand_icon_state = "medpacket"
	spawn_type = /obj/item/cigarette/donor/medical

/obj/item/storage/fancy/cigarettes/donor/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "Your favorite brand, now menthol flavored."
	icon_state = "upliftpacket"
	inhand_icon_state = "upliftpacket"
	spawn_type = /obj/item/cigarette/donor/menthol

/obj/item/storage/fancy/cigarettes/donor/cigpack_robust
	name = "\improper Robust packet"
	desc = "Smoked by the robust."
	icon_state = "robustpacket"
	inhand_icon_state = "robustpacket"

/obj/item/storage/fancy/cigarettes/donor/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Smoked by the truly robust."
	icon_state = "robustgpacket"
	inhand_icon_state = "robustgpacket"
	spawn_type = /obj/item/cigarette/donor/gold

/obj/item/storage/fancy/cigarettes/donor/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Since 2313."
	icon_state = "carppacket"
	inhand_icon_state = "carppacket"

/obj/item/storage/fancy/cigarettes/donor/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "You can't understand the runes, but the packet smells funny."
	icon_state = "midoripacket"
	inhand_icon_state = "midoripacket"
	spawn_type = /obj/item/cigarette/donor/rollie

/obj/item/storage/fancy/cigarettes/donor/cigpack_shadyjims
	name = "\improper Shady Jim's Super Slims"
	desc = "Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjimpacket"
	inhand_icon_state = "shadyjimpacket"
	spawn_type = /obj/item/cigarette/donor/shady

/obj/item/storage/fancy/cigarettes/cigpack_random
	parent_type = /obj/item/storage/fancy/cigarettes/donor
	name = "\improper Embellished Enigma packet"
	desc = "For the true connoisseur of exotic flavors."
	icon_state = "shadyjimpacket"
	inhand_icon_state = "shadyjimpacket"
	spawn_type = /obj/item/cigarette/donor/random
