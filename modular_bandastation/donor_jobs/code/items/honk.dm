/obj/item/gun/energy/donor_honk
	name = "security HONK rifle"
	desc = "Личное ХОНК-ружьё клоуна Службы Безопасности. Стреляет хлопушками."
	icon = 'modular_bandastation/donor_jobs/icons/custom_guns.dmi'
	icon_state = "honkrifle_security"
	inhand_icon_state = "honkrifle_security"
	lefthand_file = 'modular_bandastation/donor_jobs/icons/custom_guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/custom_guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/donor_honk)
	clumsy_check = FALSE
	selfcharge = TRUE
	self_charge_amount = 50 // Native process multiplies this by its two-second tick.
	charge_delay = 8
	cell_type = /obj/item/stock_parts/power_store/cell/donor_honk
	ammo_x_offset = 3
	w_class = WEIGHT_CLASS_NORMAL
	automatic_charge_overlays = FALSE
	single_shot_type_overlay = FALSE
	display_empty = FALSE

/obj/item/gun/energy/donor_honk/warden
	name = "warden's HONK rifle"
	desc = "Личное ХОНК-ружьё клоуна-смотрителя, выданное за заслуги перед Нанотрейзен."

/obj/item/stock_parts/power_store/cell/donor_honk
	maxcharge = 1000

/obj/item/ammo_casing/energy/donor_honk
	projectile_type = /obj/projectile/donor_honk
	e_cost = 100
	fire_sound = 'modular_bandastation/donor_jobs/sound/gunshot_smg.ogg'
	firing_effect_type = null
	select_name = "clown"

// The source rifle fires snap-pops, not the unrelated banana projectile /bullet/honker.
/obj/projectile/donor_honk
	name = "snap-pop"
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "snappop"
	damage = 0

/obj/projectile/donor_honk/impact(atom/target)
	if(deletion_queued)
		return
	deletion_queued = TRUE
	do_sparks(3, TRUE, src)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	visible_message(span_warning("[src] explodes!"), blind_message = span_warning("You hear a snap!"))
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)
