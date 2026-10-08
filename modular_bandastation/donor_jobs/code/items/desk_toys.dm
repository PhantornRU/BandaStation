/obj/item/toy/donor_desk
	name = "desk toy"
	desc = "A microfusion-powered office desk toy."
	icon = 'modular_bandastation/donor_jobs/icons/officetoys.dmi'
	icon_state = "desktoy"
	layer = ABOVE_MOB_LAYER
	var/on = FALSE
	var/datum/looping_sound/soundloop
	var/soundloop_type

/obj/item/toy/donor_desk/Initialize(mapload)
	. = ..()
	if(soundloop_type)
		soundloop = new soundloop_type(src)

/obj/item/toy/donor_desk/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/item/toy/donor_desk/update_icon_state()
	icon_state = "[initial(icon_state)][on ? "-on" : ""]"

/obj/item/toy/donor_desk/attack_self(mob/user)
	on = !on
	update_appearance(UPDATE_ICON)
	if(soundloop)
		if(on)
			soundloop.start()
		else
			soundloop.stop()
	else
		playsound(src, 'modular_bandastation/donor_jobs/sound/office_button.ogg', 75, TRUE)

/obj/item/toy/donor_desk/click_alt(mob/user)
	dir = turn(dir, 270)
	return CLICK_ACTION_SUCCESS

/obj/item/toy/donor_desk/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to rotate.")

/obj/item/toy/donor_desk/officetoy
	name = "office toy"
	desc = "A generic microfusion powered office desk toy. Only generates magnetism and ennui."

/obj/item/toy/donor_desk/dippingbird
	name = "dipping bird toy"
	desc = "An ancient human bird idol, worshipped by clerks and desk jockeys."
	icon_state = "dippybird"

/obj/item/toy/donor_desk/newtoncradle
	name = "\improper Newton's cradle"
	desc = "An ancient 21st century super-weapon model demonstrating that Sir Isaac Newton is the deadliest sonuvabitch in space."
	icon_state = "newtoncradle"
	soundloop_type = /datum/looping_sound/donor_newtonballs

/obj/item/toy/donor_desk/fan
	name = "office fan"
	desc = "Your greatest fan."
	icon_state = "fan"
	soundloop_type = /datum/looping_sound/donor_fanblow

/datum/looping_sound/donor_newtonballs
	mid_sounds = 'modular_bandastation/donor_jobs/sound/office_newton.ogg'
	mid_length = 0.9 SECONDS
	volume = 50

/datum/looping_sound/donor_fanblow
	start_sound = 'modular_bandastation/donor_jobs/sound/fan_start.ogg'
	start_length = 4 SECONDS
	mid_sounds = 'modular_bandastation/donor_jobs/sound/fan_loop.ogg'
	mid_length = 2.3 SECONDS
	end_sound = 'modular_bandastation/donor_jobs/sound/fan_end.ogg'
	volume = 30
