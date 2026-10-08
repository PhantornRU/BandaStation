/obj/item/gun/ballistic/automatic/toy/donor
	fire_sound = 'modular_bandastation/donor_jobs/sound/toy_smg.ogg'

/obj/item/ammo_box/magazine/toy/pistol/donor
	max_ammo = 8

/obj/item/gun/ballistic/automatic/pistol/toy/donor
	force = 0
	throwforce = 0
	clumsy_check = FALSE
	fire_delay = 0
	accepted_magazine_type = /obj/item/ammo_box/magazine/toy/pistol
	spawn_magazine_type = /obj/item/ammo_box/magazine/toy/pistol/donor
	fire_sound = 'modular_bandastation/donor_jobs/sound/toy_pistol.ogg'

/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot/donor
	desc = "A bullpup two-round burst toy SMG, designated 'C-20r'. Ages 8 and up."
	burst_size = 2

/obj/item/ammo_box/magazine/internal/shot/toy/donor_tommygun
	max_ammo = 10

/obj/item/gun/ballistic/shotgun/toy/donor_tommygun
	name = "tommy gun"
	desc = "Looks almost like the real thing! Great for practicing Drive-bys. Ages 8 and up."
	icon = 'modular_bandastation/donor_jobs/icons/toy_guns.dmi'
	icon_state = "tommygun"
	inhand_icon_state = "shotgun"
	lefthand_file = 'modular_bandastation/donor_jobs/icons/toy_guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/toy_guns_righthand.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/toy/donor_tommygun
	w_class = WEIGHT_CLASS_SMALL
	gun_flags = NOT_A_REAL_GUN

/obj/item/ammo_casing/foam_dart/donor_sniper
	name = "riot foam sniper dart"
	desc = "For the bigger brother of the crowd control toy. Ages 18 and up."
	icon = 'modular_bandastation/donor_jobs/icons/toy_guns.dmi'
	icon_state = "foamdartsniper_riot"
	base_icon_state = "foamdartsniper_riot"
	caliber = "foam_force_sniper"
	projectile_type = /obj/projectile/bullet/foam_dart/donor_sniper
	tip_color = "red"

/obj/item/ammo_casing/foam_dart/donor_sniper/update_icon_state()
	icon_state = "[base_icon_state][modified ? "_empty" : ""]"
	if(loaded_projectile)
		loaded_projectile.icon_state = icon_state

/obj/projectile/bullet/foam_dart/donor_sniper
	name = "riot sniper foam dart"
	icon = 'modular_bandastation/donor_jobs/icons/toy_guns.dmi'
	icon_state = "foamdartsniper_riot"
	base_icon_state = "foamdartsniper_riot"
	shrapnel_type = /obj/item/ammo_casing/foam_dart/donor_sniper
	range = 30
	stamina = 100

/obj/item/ammo_box/magazine/toy/donor_sniper
	name = "donksoft Sniper magazine"
	icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/foam_dart/donor_sniper
	max_ammo = 6
	caliber = "foam_force_sniper"
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/gun/ballistic/automatic/donor_toy_sniper
	name = "donksoft sniper rifle"
	desc = "A recoil-operated, semi-automatic donksoft sniper rifle. Ages 8 and up."
	icon = 'modular_bandastation/donor_jobs/icons/toy_guns.dmi'
	icon_state = "sniper"
	inhand_icon_state = "sniper"
	lefthand_file = 'modular_bandastation/donor_jobs/icons/toy_guns_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/toy_guns_righthand.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/toy/donor_sniper
	fire_sound = 'modular_bandastation/donor_jobs/sound/toy_sniper.ogg'
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 4 SECONDS
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	casing_ejector = FALSE
	can_muzzle_flash = FALSE
	gun_flags = NOT_A_REAL_GUN
