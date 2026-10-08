/obj/item/toy/donor_blink
	name = "electronic blink toy game"
	desc = "Blink. Blink. Blink. Ages 8 and up."
	icon = 'modular_bandastation/donor_jobs/icons/radio.dmi'
	icon_state = "beacon"
	inhand_icon_state = "signaler"

/obj/item/toy/donor_syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	icon = 'modular_bandastation/donor_jobs/icons/toys.dmi'
	icon_state = "syndballoon"
	inhand_icon_state = "syndballoon"
	throw_speed = 4
	throw_range = 20
	w_class = WEIGHT_CLASS_BULKY
	var/next_play = 0

/obj/item/toy/donor_syndicateballoon/attack_self(mob/user)
	if(world.time < next_play)
		return
	next_play = world.time + CLICK_CD_MELEE
	user.visible_message(span_notice("[user] plays with [src]."), span_notice("You [pick("bat [src]", "tug on [src]'s string", "play with [src]")]."))

/obj/item/toy/donor_syndicateballoon/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] ties [src] around [user.p_their()] neck and starts to float away!"))
	playsound(user, 'modular_bandastation/donor_jobs/sound/fleshtostone.ogg', 80, TRUE)
	user.Immobilize(10 SECONDS)
	for(var/obj/item/equipped as anything in user.get_equipped_items())
		user.dropItemToGround(equipped, force = TRUE)
	var/obj/effect/extraction_holder/holder = new(get_turf(user))
	holder.appearance = user.appearance
	user.forceMove(holder)
	animate(holder, pixel_z = 1000, time = 5 SECONDS)
	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	QDEL_IN(user, 2 SECONDS)
	QDEL_IN(src, 2 SECONDS)
	QDEL_IN(holder, 5 SECONDS)
	return MANUAL_SUICIDE

/obj/item/toy/donor_syndicateballoon/contractor
	name = "contractor balloon"
	desc = "A black and gold balloon carried only by legendary Syndicate agents."
	// The historical contractor sprite is absent from its declared icon file.
	color = "#D4AF37"

/obj/item/toy/nuke/donor
	icon = 'modular_bandastation/donor_jobs/icons/toys.dmi'

/obj/item/toy/nuke/donor/attack_self(mob/user)
	if(world.time < cooldown)
		to_chat(user, span_alert("Nothing happens, and '[round((cooldown - world.time) / 10)]' appears on the small display."))
		return
	cooldown = world.time + 3 MINUTES
	user.visible_message(span_warning("[user] presses a button on [src]."), span_notice("You activate [src], it plays a loud noise!"), span_hear("You hear the click of a button."))
	addtimer(CALLBACK(src, PROC_REF(alarm_state), "nuketoy"), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(alarm_state), "nuketoycool"), 14 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(alarm_state), "nuketoyidle"), 3 MINUTES)

/obj/item/toy/nuke/donor/proc/alarm_state(new_state)
	icon_state = new_state
	if(new_state == "nuketoy")
		playsound(src, 'modular_bandastation/donor_jobs/sound/toy_alarm.ogg', 100, FALSE)

/obj/item/toy/nuke/donor/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/item/toy/minimeteor/donor/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/item/toy/sword/donor_chaosprank
	name = "energy sword"
	var/pranked = FALSE

/obj/item/toy/sword/donor_chaosprank/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!pranked)
		pranked = TRUE
		name = "toy sword"
		to_chat(user, span_warning("Oh... it's a fake."))

/obj/item/toy/snappop/donor_virus
	name = "unstable goo"
	desc = "Your palm is oozing this stuff!"
	icon = 'modular_bandastation/donor_jobs/icons/slimes.dmi'
	icon_state = "red slime extract"
	throwforce = 5
	throw_speed = 10
	throw_range = 30
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/donor_therapy
	name = "therapy doll"
	desc = "A toy for therapeutic and recreational purposes."
	icon = 'modular_bandastation/donor_jobs/icons/toys.dmi'
	icon_state = "therapyred"
	inhand_icon_state = "egg4"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/next_squeeze = 0

/obj/item/toy/donor_therapy/attack_self(mob/user)
	if(world.time < next_squeeze)
		return
	next_squeeze = world.time + 0.8 SECONDS
	to_chat(user, span_notice("You relieve some stress with [src]."))
	playsound(user, 'modular_bandastation/donor_jobs/sound/squeaktoy.ogg', 20, TRUE)

/obj/item/toy/donor_therapy/red
	name = "red therapy doll"

/obj/item/toy/donor_therapy/purple
	name = "purple therapy doll"
	icon_state = "therapypurple"
	inhand_icon_state = "egg1"

/obj/item/toy/donor_therapy/blue
	name = "blue therapy doll"
	icon_state = "therapyblue"
	inhand_icon_state = "egg2"

/obj/item/toy/donor_therapy/yellow
	name = "yellow therapy doll"
	icon_state = "therapyyellow"
	inhand_icon_state = "egg5"

/obj/item/toy/donor_therapy/orange
	name = "orange therapy doll"
	icon_state = "therapyorange"
	inhand_icon_state = "egg3"

/obj/item/toy/donor_therapy/green
	name = "green therapy doll"
	icon_state = "therapygreen"
	inhand_icon_state = "egg6"

/obj/item/toy/donor_flash
	name = "toy flash"
	desc = "FOR THE REVOLU- Oh wait, that's just a toy."
	icon = 'icons/obj/devices/flash.dmi'
	icon_state = "flash"
	inhand_icon_state = "flashtool"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/donor_flash/attack(mob/living/target, mob/living/user)
	playsound(src, 'sound/items/weapons/flash.ogg', 100, TRUE)
	flick("flash2", src)
	user.visible_message(span_notice("[user] blinds [target] with the flash!"))

/obj/item/toy/donor_pet_rock
	name = "pet rock"
	desc = "The perfect pet!"
	icon = 'modular_bandastation/donor_jobs/icons/toys.dmi'
	icon_state = "pet_rock"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/donor_pet_rock/fred
	name = "fred"
	desc = "Fred, the bestest boy pet in the whole wide universe!"
	icon_state = "fred"

/obj/item/toy/donor_pet_rock/roxie
	name = "roxie"
	desc = "Roxie, the bestest girl pet in the whole wide universe!"
	icon_state = "roxie"

/obj/item/toy/donor_minigibber
	name = "miniature gibber"
	desc = "A miniature recreation of Nanotrasen's famous meat grinder."
	icon = 'modular_bandastation/donor_jobs/icons/toys.dmi'
	icon_state = "minigibber"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/toy/donor_character/stored_miniature
	var/next_button = 0

/obj/item/toy/donor_minigibber/Destroy()
	QDEL_NULL(stored_miniature)
	return ..()

/obj/item/toy/donor_minigibber/attack_self(mob/user)
	if(!stored_miniature && world.time < next_button)
		return
	if(stored_miniature)
		to_chat(user, span_warning("[src] tears apart the miniature figure inside!"))
		QDEL_NULL(stored_miniature)
	else
		to_chat(user, span_notice("You hit the gib button on [src]."))
	next_button = world.time + 0.8 SECONDS
	playsound(src, 'modular_bandastation/donor_jobs/sound/fake_gib.ogg', 20, TRUE)

/obj/item/toy/donor_minigibber/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/toy/donor_character))
		return NONE
	if(stored_miniature || !user.is_holding(tool))
		return ITEM_INTERACT_BLOCKING
	if(!do_after(user, 1 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src) || QDELETED(tool) || stored_miniature || !user.is_holding(tool))
		return ITEM_INTERACT_BLOCKING
	if(user.transferItemToLoc(tool, src))
		stored_miniature = tool
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/toy/donor_chainsaw
	name = "toy chainsaw"
	desc = "A toy chainsaw with a rubber edge. Ages 8 and up."
	icon = 'modular_bandastation/donor_jobs/icons/barber.dmi'
	icon_state = "chainsaw0"
	base_icon_state = "chainsaw"
	inhand_icon_state = "chainsaw0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	throw_speed = 4
	throw_range = 20

/obj/item/toy/donor_chainsaw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, wieldsound = 'sound/items/weapons/chainsaw_start.ogg', icon_wielded = "chainsaw1", force_wielded = 0, force_unwielded = 0)

/obj/item/toy/donor_chainsaw/update_icon_state()
	icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED) ? 1 : 0]"

/obj/item/toy/donor_eight_ball
	name = "\improper Magic 8-Ball"
	desc = "Mystical! Magical! Ages 8+!"
	icon = 'modular_bandastation/donor_jobs/icons/toys.dmi'
	icon_state = "eight-ball"
	var/use_action = "shakes the ball"
	var/list/possible_answers = list("Definitely", "All signs point to yes.", "Most likely.", "Yes.", "Ask again later.", "Better not tell you now.", "Future Unclear.", "Maybe.", "Doubtful.", "No.", "Don't count on it.", "Never.")

/obj/item/toy/donor_eight_ball/attack_self(mob/user)
	user.visible_message(span_notice("[user] focuses on [user.p_their()] question and [use_action]..."))
	visible_message(span_notice("[src] says: [pick(possible_answers)]"))

/obj/item/toy/donor_eight_ball/conch
	name = "\improper Magic Conch Shell"
	desc = "All hail the Magic Conch!"
	icon_state = "conch"
	use_action = "pulls the string"
	possible_answers = list("Yes.", "No.", "Try asking again.", "Nothing.", "I don't think so.", "Neither.", "Maybe someday.")
