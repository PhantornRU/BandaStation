// Original donor appearances on the target's existing ID-access, obstruction and atmosphere door mechanism.
/obj/machinery/door/san_francisco
	name = "\improper door"
	desc = "It opens and closes."
	icon = 'modular_bandastation/san_francisco/icons/doors/city_doors.dmi'
	icon_state = "door-1"
	base_icon_state = "door"
	pixel_w = -16
	flags_1 = PREVENT_CLICK_UNDER_1|IGNORE_TURF_PIXEL_OFFSET_1
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	has_access_panel = FALSE
	can_be_glass = FALSE
	can_crush = FALSE
	autoclose = FALSE

/obj/machinery/door/san_francisco/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[density ? "1" : "0"]"

/obj/machinery/door/san_francisco/animation_effects(animation, force_type = DEFAULT_DOOR_CHECKS)
	. = ..()
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			playsound(src, 'sound/machines/door/door_open.ogg', 40, TRUE)
		if(DOOR_CLOSING_ANIMATION)
			playsound(src, 'sound/machines/door/door_close.ogg', 40, TRUE)
		if(DOOR_DENY_ANIMATION)
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 25, FALSE)

/obj/machinery/door/san_francisco/glass
	name = "glass door"
	icon_state = "glass_blue-1"
	base_icon_state = "glass_blue"
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/san_francisco/old
	name = "old door"
	icon_state = "old-1"
	base_icon_state = "old"

/obj/machinery/door/san_francisco/oldwood
	name = "old wooden door"
	icon_state = "oldwood-1"
	base_icon_state = "oldwood"
	resistance_flags = FLAMMABLE

/obj/machinery/door/san_francisco/prison
	name = "security door"
	icon_state = "prison-1"
	base_icon_state = "prison"

/obj/machinery/door/san_francisco/reinf
	name = "reinforced door"
	icon_state = "reinf-1"
	base_icon_state = "reinf"

/obj/machinery/door/san_francisco/simple
	name = "simple door"
	icon_state = "cam-1"
	base_icon_state = "cam"

/obj/machinery/door/san_francisco/wood
	name = "wooden door"
	icon_state = "wood-1"
	base_icon_state = "wood"
	resistance_flags = FLAMMABLE

/obj/machinery/door/san_francisco/woodglass
	name = "wooden glass door"
	icon_state = "glass-1"
	base_icon_state = "glass"
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/san_francisco/gate
	name = "graveyard gate"
	icon = 'modular_bandastation/san_francisco/icons/doors/gate.dmi'
	icon_state = "gate"
	pixel_x = -32
	base_pixel_x = -32
	pixel_w = 0
	max_integrity = 500
	opacity = FALSE
	visible = FALSE
	layer = OBJ_LAYER
	closingLayer = OBJ_LAYER
	can_atmos_pass = ATMOS_PASS_YES

/obj/machinery/door/san_francisco/gate/Initialize(mapload)
	. = ..()
	// The donor gate opens only its centre; the two side pillars remain impassable.
	var/turf/right_turf = get_step(src, EAST)
	var/turf/left_turf = get_step(src, WEST)
	if(right_turf)
		right_turf.set_density(TRUE)
	if(left_turf)
		left_turf.set_density(TRUE)

/obj/machinery/door/san_francisco/gate/update_icon_state()
	. = ..()
	icon_state = density ? "gate" : "gate-open"

/obj/machinery/door/san_francisco/vault
	name = "bank vault door"
	desc = "A massive reinforced vault door protecting the bank's reserves."
	icon = 'modular_bandastation/san_francisco/icons/doors/vault.dmi'
	icon_state = "vault-1"
	base_icon_state = "vault"
	layer = ABOVE_ALL_MOB_LAYER
	closingLayer = ABOVE_ALL_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

// The donor uses the same native multi-tile/filler and transport-link mechanisms.
/obj/machinery/door/airlock/san_francisco_elevator
	name = "elevator door"
	icon = 'modular_bandastation/san_francisco/icons/doors/elevator_double.dmi'
	icon_state = "closed"
	overlays_file = null
	multi_tile = TRUE
	doorDeni = null

/obj/machinery/door/airlock/san_francisco_elevator/Initialize(mapload)
	if(!isnull(transport_linked_id))
		elevator_mode = TRUE
	return ..()

/obj/machinery/door/airlock/san_francisco_elevator/setDir(newdir)
	. = ..()
	set_bounds()

/obj/machinery/door/airlock/san_francisco_elevator/update_icon_state()
	. = ..()
	// This sheet contains complete frames, without a separate access-denied frame.
	if(animation == DOOR_DENY_ANIMATION)
		icon_state = "closed"

// AI EDIT START - Keep parent rendering updates while using complete donor frames
/obj/machinery/door/airlock/san_francisco_elevator/update_overlays()
	. = ..()
	// The donor's complete frames must not receive standard station-airlock filler panels.
	return list()
// AI EDIT END

/obj/machinery/door/poddoor/shutters/san_francisco
	icon = 'modular_bandastation/san_francisco/icons/doors/shutters.dmi'
	layer = ABOVE_ALL_MOB_LAYER
	closingLayer = ABOVE_ALL_MOB_LAYER

/obj/machinery/door/poddoor/shutters/san_francisco/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/san_francisco/armory
	name = "armory shutters"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	id = 10
