/obj/item/toy/donor_russian_revolver
	name = "russian revolver"
	desc = "For fun and games!"
	icon = 'modular_bandastation/donor_jobs/icons/roulette.dmi'
	icon_state = "russian_revolver"
	inhand_icon_state = "gun"
	lefthand_file = 'modular_bandastation/donor_jobs/icons/toy_guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/toy_guns_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	throw_range = 5
	var/bullets_left = 0
	var/max_shots = 6

/obj/item/toy/donor_russian_revolver/Initialize(mapload)
	. = ..()
	spin_cylinder()

/obj/item/toy/donor_russian_revolver/attack_self(mob/user)
	user.visible_message(span_warning("[user] [bullets_left ? "spins" : "loads a bullet into"] [src]'s cylinder."))
	spin_cylinder()

/obj/item/toy/donor_russian_revolver/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isliving(target) || target in user.contents)
		return ITEM_INTERACT_BLOCKING
	shoot_gun(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/toy/donor_russian_revolver/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	shoot_gun(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/toy/donor_russian_revolver/proc/spin_cylinder()
	bullets_left = rand(1, max_shots)

/obj/item/toy/donor_russian_revolver/proc/post_shot(mob/user)
	return

// Despite its historical toy type, the original roulette revolver is lethal to its user.
/obj/item/toy/donor_russian_revolver/proc/shoot_gun(mob/living/user)
	if(!ishuman(user))
		return FALSE
	if(bullets_left > 1)
		bullets_left--
		visible_message(span_warning("*click*"))
		playsound(src, 'sound/items/weapons/gun/general/dry_fire.ogg', 100, TRUE)
		return FALSE
	if(!bullets_left)
		to_chat(user, span_warning("[src] needs to be reloaded."))
		return FALSE
	bullets_left = 0
	var/mob/living/carbon/human/shooter = user
	var/zone = shooter.get_bodypart(BODY_ZONE_HEAD) ? BODY_ZONE_HEAD : BODY_ZONE_CHEST
	playsound(src, 'modular_bandastation/donor_jobs/sound/roulette_gunshot.ogg', 50, TRUE)
	visible_message(span_danger("[src] goes off!"))
	post_shot(shooter)
	log_combat(shooter, shooter, "shot themselves with", src)
	shooter.apply_damage(300, BRUTE, zone, sharpness = SHARP_POINTY)
	shooter.bleed(BLOOD_VOLUME_NORMAL)
	shooter.death()
	return TRUE

/obj/item/toy/donor_russian_revolver/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] loads six bullets into [src] and pulls the trigger against [user.p_their()] head!"))
	playsound(src, 'modular_bandastation/donor_jobs/sound/roulette_gunshot.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/toy/donor_russian_revolver/trick_revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	max_shots = 1
	var/fake_bullets = 0

/obj/item/toy/donor_russian_revolver/trick_revolver/Initialize(mapload)
	. = ..()
	fake_bullets = rand(2, 7)

/obj/item/toy/donor_russian_revolver/trick_revolver/examine(mob/user)
	. = ..()
	. += span_notice("Use a pen on it to rename it. It has [fake_bullets] live rounds remaining. Use in hand to empty it, or Alt-click to spin its barrel.")

/obj/item/toy/donor_russian_revolver/trick_revolver/post_shot(mob/user)
	to_chat(user, span_danger("[src] did look pretty dodgy!"))
	SEND_SOUND(user, sound('sound/misc/sadtrombone.ogg'))

/obj/item/toy/donor_russian_revolver/trick_revolver/click_alt(mob/user)
	shoot_gun(user)
	return CLICK_ACTION_SUCCESS

/obj/item/toy/donor_russian_revolver/trick_revolver/attack_self(mob/user)
	if(!bullets_left)
		return ..()
	shoot_gun(user)

/obj/item/toy/donor_russian_revolver/trick_revolver/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/pen) || istype(tool, /obj/item/ammo_casing/c357) || istype(tool, /obj/item/ammo_box/c357) || istype(tool, /obj/item/ammo_box/speedloader/c357))
		shoot_gun(user)
		return ITEM_INTERACT_SUCCESS
	return NONE
