/obj/item/poster/donor_syndicate_recruitment
	poster_type = /obj/structure/sign/poster/contraband/syndicate_recruitment

/obj/item/toy/cards/deck/donor_tiny
	name = "tiny cards"
	desc = "A compact deck of space-grade playing cards."

/obj/item/stack/tile/bronze/donor_fifty
	amount = 50

/obj/item/toy/beach_ball/donor
	desc = "An inflatable ball of fun, enjoyed on many beaches."
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 20

/obj/item/toy/beach_ball/donor/holoball
	name = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	icon = 'modular_bandastation/donor_jobs/icons/basketball.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/toy/beach_ball/donor/holoball/attack_self(mob/user)
	if(user.get_inactive_held_item())
		balloon_alert(user, "другая рука занята")
		return
	if(user.temporarilyRemoveItemFromInventory(src))
		user.put_in_inactive_hand(src)

/obj/item/soap/donor
	cleanspeed = 5 SECONDS
	throw_speed = 4
	throw_range = 20

/obj/item/soap/donor/decreaseUses(datum/source, atom/target, mob/living/user, clean_succeeded)
	return

/obj/item/soap/donor/proc/can_wash_mouth(atom/target, mob/living/user)
	var/mob/living/carbon/human/human_target = target
	return istype(human_target) && ishuman(user) && !human_target.stat && !user.stat && user.zone_selected == BODY_ZONE_PRECISE_MOUTH

/obj/item/soap/donor/should_clean(datum/cleaning_source, atom/target, mob/living/user)
	if(can_wash_mouth(target, user))
		return CLEAN_BLOCKED | CLEAN_DONT_BLOCK_INTERACTION
	return ..()

/obj/item/soap/donor/attack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!can_wash_mouth(target, user))
		return ..()
	user.visible_message(span_warning("[user] starts washing [target]'s mouth out with [src]!"))
	if(!do_after(user, cleanspeed, target = target))
		return
	if(QDELETED(target) || QDELETED(src) || !user.is_holding(src) || !user.Adjacent(target) || !can_wash_mouth(target, user))
		return
	target.reagents.add_reagent(/datum/reagent/donor_soap, 6)
	user.visible_message(span_warning("[user] washes [target]'s mouth out with [src]!"))

/obj/item/soap/donor/deluxe
	icon_state = "soapdeluxe"
	inhand_icon_state = "soapdeluxe"
	worn_icon_state = "soapdeluxe"
	cleanspeed = 4 SECONDS

/obj/item/soap/donor/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"
	inhand_icon_state = "soapnt"
	worn_icon_state = "soapnt"

/obj/item/soap/donor/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soapgibs"
	inhand_icon_state = "soapgibs"
	worn_icon_state = "soapgibs"
	cleanspeed = 4.5 SECONDS

/obj/item/soap/donor/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	inhand_icon_state = "soapsyndie"
	worn_icon_state = "soapsyndie"
	cleanspeed = 1 SECONDS

/obj/item/soap/donor/ducttape
	desc = "A homemade bar of soap. It seems to be gibs and tape... Will this clean anything?"
	icon_state = "soapgibs"
	inhand_icon_state = "soapgibs"
	worn_icon_state = "soapgibs"

/obj/item/soap/donor/ducttape/Initialize(mapload)
	. = ..()
	qdel(GetComponent(/datum/component/cleaner))

/obj/item/soap/donor/ducttape/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(can_wash_mouth(target, user))
		return NONE
	if(!isturf(target) && !iscarbon(target))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_warning("[user] begins to smear [src] on [target]."))
	if(!do_after(user, cleanspeed, target = target))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(target) || !user.is_holding(src) || !user.Adjacent(target))
		return ITEM_INTERACT_BLOCKING
	if(isturf(target))
		new /obj/effect/decal/cleanable/blood/gibs/donor_soap(target)
	else
		var/mob/living/carbon/victim = target
		var/list/blood_dna = victim.get_blood_dna_list()
		for(var/obj/item/carried in victim)
			carried.add_blood_DNA(blood_dna)
		victim.add_blood_DNA(blood_dna)
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			human_victim.blood_in_hands = 1
			human_victim.update_worn_gloves()
	return ITEM_INTERACT_SUCCESS

/obj/effect/decal/cleanable/blood/gibs/donor_soap
	mergeable_decal = TRUE
	decal_reagent = null
	reagent_amount = 0

/datum/reagent/donor_soap
	name = "Soap"
	description = "Soap, fit to clean the mouth of a sailor."
	color = "#FFFFFF"
	taste_description = "soap"

/datum/reagent/donor_soap/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	RegisterSignal(affected_mob, COMSIG_MOB_SAY, PROC_REF(clean_speech))

/datum/reagent/donor_soap/on_mob_delete(mob/living/affected_mob)
	UnregisterSignal(affected_mob, COMSIG_MOB_SAY)
	return ..()

/datum/reagent/donor_soap/proc/clean_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/static/regex/dirty_words = regex("\\b(shit|shitter|fuck|fucking|fucker|motherfucker|balls|whore|dumbass|ass|bastard|bitch|cock|cunt|damn|dick|hell|jesus|pussy|twat|wanker)\\b", "gi")
	speech_args[SPEECH_MESSAGE] = dirty_words.Replace(speech_args[SPEECH_MESSAGE], GLOBAL_PROC_REF(donor_clean_word))

/proc/donor_clean_word(matched)
	var/static/list/words = list(
		"shit" = "shoot",
		"shitter" = "toilet",
		"fuck" = "phooey",
		"fucking" = "flipping",
		"fucker" = "individual dedicated to the continuation of their species",
		"motherfucker" = "family time enjoyer",
		"balls" = "baloney",
		"whore" = "overly experienced individual",
		"dumbass" = "sweet, misunderstood person",
		"ass" = "backside",
		"bastard" = "individual born out of wedlock",
		"bitch" = "female dog",
		"cock" = "chicken",
		"cunt" = "countryman",
		"damn" = "beaver-constructed river-blockade",
		"dick" = "detective",
		"hell" = "HFIL",
		"jesus" = "jesús",
		"pussy" = "pusillanimous",
		"twat" = "honorable and esteemed individual",
		"wanker" = "sanguine individual",
	)
	return words[lowertext(matched)]
