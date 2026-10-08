/obj/item/food/doshik
	name = "дошик"
	desc = "Вкусная сухая лапша быстрого приготовления с курицей. Её можно приготовить, залив водой."
	icon = 'modular_bandastation/donor_jobs/icons/food.dmi'
	icon_state = "doshik"
	bite_consumption = 3
	trash_type = /obj/item/trash/donor_doshik
	food_reagents = list(/datum/reagent/consumable/dry_ramen = 30)
	tastes = list("курица" = 1, "лапша" = 1)
	foodtypes = GRAIN | JUNKFOOD

/obj/item/food/doshik_spicy
	parent_type = /obj/item/food/doshik
	name = "острый дошик"
	desc = "Вкусная сухая лапша быстрого приготовления с говядиной. Её можно приготовить, залив водой."
	icon_state = "doshikspicy"
	food_reagents = list(/datum/reagent/consumable/dry_ramen = 30, /datum/reagent/consumable/capsaicin = 5)
	tastes = list("говядина" = 1, "лапша" = 1)

/obj/item/trash/donor_doshik
	name = "упаковка из-под дошика"
	desc = "Вы уже съели дошик."
	icon = 'modular_bandastation/donor_jobs/icons/food.dmi'
	icon_state = "doshik-empty"

/obj/item/reagent_containers/cup/donor_banana_jug
	name = "Jolly Jug"
	desc = "A jug filled with banana juice."
	icon = 'modular_bandastation/donor_jobs/icons/drinks.dmi'
	icon_state = "bottleofjolly"
	inhand_icon_state = "bottleofjolly"
	volume = 100
	list_reagents = list(/datum/reagent/consumable/banana = 100)

/obj/item/stack/cable_coil/random

/obj/item/stack/cable_coil/random/Initialize(mapload, new_amount, merge = TRUE, list/mat_override = null, mat_amt = 1)
	. = ..()
	set_cable_color(pick(GLOB.cable_colors))

/obj/item/food/donor_toast
	name = "toast"
	desc = "Yeah! Toast!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "toast"
	bite_consumption = 3
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("toast" = 1)
	foodtypes = GRAIN

/obj/item/flashlight/donor_emergency_glowstick
	name = "emergency glowstick"
	desc = "A cheap looking, mass produced glowstick. You can practically feel it was made on a tight budget."
	icon_state = "glowstick"
	inhand_icon_state = "flare"
	worn_icon_state = "lightstick"
	color = LIGHT_COLOR_BLUE
	light_color = LIGHT_COLOR_BLUE
	light_system = OVERLAY_LIGHT
	light_range = 4
	light_power = 1
	sound_on = 'sound/effects/wounds/crack2.ogg'
	toggle_context = FALSE
	ignore_base_color = TRUE
	has_closed_handle = FALSE
	custom_materials = null
	/// Remaining seconds; Paradise consumed 30–90 fuel ticks at two seconds per tick.
	var/seconds_remaining = 0

/obj/item/flashlight/donor_emergency_glowstick/Initialize(mapload)
	seconds_remaining = rand(30, 90) * 2
	return ..()

/obj/item/flashlight/donor_emergency_glowstick/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flashlight/donor_emergency_glowstick/toggle_light(mob/user)
	if(light_on || seconds_remaining <= 0)
		return FALSE
	. = ..()
	if(.)
		START_PROCESSING(SSobj, src)

/obj/item/flashlight/donor_emergency_glowstick/process(seconds_per_tick)
	seconds_remaining = max(seconds_remaining - seconds_per_tick, 0)
	if(seconds_remaining > 0)
		return
	set_light_on(FALSE)
	update_brightness()
	update_item_action_buttons()
	return PROCESS_KILL

/obj/item/flashlight/donor_emergency_glowstick/update_icon_state()
	. = ..()
	icon_state = seconds_remaining > 0 ? "glowstick" : "glowstick-empty"
	// The native flare-on hand sprite contains a flame.
	inhand_icon_state = initial(inhand_icon_state)

/obj/item/flashlight/donor_emergency_glowstick/update_overlays()
	. = ..()
	if(light_on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		. += glowstick_overlay
