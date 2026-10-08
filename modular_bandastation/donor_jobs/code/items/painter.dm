/obj/item/painter
	parent_type = /obj/item/airlock_painter
	name = "modular painter"
	desc = "An autopainter for station floors, pipes, windows and airlocks."
	desc_controls = "Ctrl-click in your hand to change its mode. Use it in hand to choose a pattern or colour."
	icon = 'modular_bandastation/donor_jobs/icons/painter.dmi'
	icon_state = "floor_painter"
	inhand_icon_state = null
	var/painter_mode = "Floor"
	var/floor_pattern = "floor"
	var/floor_direction = SOUTH
	var/paint_colour = "grey"
	var/static/list/floor_patterns = list(
		"arrival", "arrivalcorner", "bar", "barber", "bcircuit", "black", "blackcorner", "blue", "bluecorner",
		"bluefull", "bluered", "blueyellow", "blueyellowfull", "bot", "brown", "browncorner", "browncornerold", "cafeteria", "caution",
		"cautioncorner", "cautionfull", "chapel", "cmo", "dark", "delivery", "escape", "escapecorner", "floor", "floorgrime", "freezerfloor", "gcircuit",
		"green", "greenblue", "greenbluefull", "greencorner", "greenfull", "greenyellow", "greenyellowfull", "grimy", "hydrofloor", "loadingarea", "neutral",
		"neutralcorner", "neutralfull", "orange", "orangecorner", "orangefull", "purple", "purplecorner", "purplefull", "rcircuit", "rampbottom", "ramptop", "red",
		"redblue", "redbluefull", "darkredblue", "darkredbluefull", "redcorner", "redfull", "redgreen", "redgreenfull", "darkredgreen", "darkredgreenfull",
		"redyellow", "redyellowfull", "darkredyellow", "darkredyellowfull", "warning", "warningcorner", "warnwhite", "warnwhitecorner", "white",
		"whiteblue", "whitebluecorner", "whitebluefull", "whitebot", "whitecorner", "whitedelivery", "whitegreen", "whitegreencorner", "whitegreenfull", "whitehall",
		"whitepurple", "whitepurplecorner", "whitepurplefull", "whitered", "whiteredcorner", "whiteredfull", "whiteyellow", "whiteyellowcorner", "whiteyellowfull",
		"yellow", "yellowcorner", "yellowcornersiding", "yellowsiding", "darkpurple", "darkpurplecorners", "darkpurplefull",
		"darkred", "darkredcorners", "darkredfull", "darkblue", "darkbluecorners", "darkbluefull", "darkgreen", "darkgreencorners",
		"darkgreenfull", "darkyellow", "darkyellowcorners", "darkyellowfull", "darkbrown", "darkbrowncorners", "darkbrownfull",
	)

/obj/item/painter/click_ctrl(mob/user)
	if(!user.is_holding(src))
		return NONE
	var/new_mode = tgui_input_list(user, "Что покрасить?", name, list("Floor", "Pipe", "Window", "Airlock"), painter_mode)
	if(!new_mode || QDELETED(src) || !user.is_holding(src))
		return CLICK_ACTION_BLOCKING
	painter_mode = new_mode
	icon_state = "[lowertext(new_mode)]_painter"
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/painter/attack_self(mob/user)
	if(painter_mode == "Airlock")
		to_chat(user, span_notice("Use the painter on an airlock to choose its paintjob."))
		return
	if(painter_mode != "Floor")
		var/new_colour = tgui_input_list(user, "Выберите цвет", name, GLOB.pipe_paint_colors, paint_colour)
		if(new_colour && !QDELETED(src) && user.is_holding(src))
			paint_colour = new_colour
		return
	var/new_pattern = tgui_input_list(user, "Выберите рисунок", name, floor_patterns, floor_pattern)
	if(!new_pattern || QDELETED(src) || !user.is_holding(src))
		return
	var/list/directions = list("North" = NORTH, "South" = SOUTH, "East" = EAST, "West" = WEST,
		"Northeast" = NORTHEAST, "Northwest" = NORTHWEST, "Southeast" = SOUTHEAST, "Southwest" = SOUTHWEST)
	var/new_direction = tgui_input_list(user, "Выберите направление", name, directions)
	if(!new_direction || QDELETED(src) || !user.is_holding(src))
		return
	floor_pattern = new_pattern
	floor_direction = directions[new_direction]

/obj/item/painter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	switch(painter_mode)
		if("Floor")
			if(!istype(interacting_with, /turf/open/floor/iron))
				return ITEM_INTERACT_BLOCKING
			var/turf/open/floor/iron/floor = interacting_with
			if(floor.broken || floor.burnt)
				return ITEM_INTERACT_BLOCKING
			floor.icon = 'modular_bandastation/donor_jobs/icons/paintable_floors.dmi'
			floor.base_icon_state = floor_pattern
			floor.setDir(floor_direction)
			floor.update_appearance()
		if("Pipe")
			if(!istype(interacting_with, /obj/machinery/atmospherics/pipe))
				return ITEM_INTERACT_BLOCKING
			var/obj/machinery/atmospherics/pipe/pipe = interacting_with
			var/turf/pipe_floor = get_turf(pipe)
			if(HAS_TRAIT(pipe, TRAIT_UNDERFLOOR) && pipe_floor.underfloor_accessibility == UNDERFLOOR_HIDDEN)
				return ITEM_INTERACT_BLOCKING
			if(!pipe.paint(GLOB.pipe_paint_colors[paint_colour]))
				return ITEM_INTERACT_BLOCKING
		if("Window")
			if(!istype(interacting_with, /obj/structure/window) && !istype(interacting_with, /obj/machinery/door/window))
				return ITEM_INTERACT_BLOCKING
			interacting_with.add_atom_colour(GLOB.pipe_paint_colors[paint_colour], FIXED_COLOUR_PRIORITY)
		if("Airlock")
			if(!istype(interacting_with, /obj/machinery/door/airlock))
				return ITEM_INTERACT_BLOCKING
			var/obj/machinery/door/airlock/door = interacting_with
			door.change_paintjob(src, user)
			return ITEM_INTERACT_SUCCESS
	playsound(src, usesound, 30, TRUE)
	return ITEM_INTERACT_SUCCESS

// The source modular painter has no consumable ink; door painting still uses its native API.
/obj/item/painter/use_paint(mob/user)
	playsound(src, usesound, 30, TRUE)
	return TRUE

/obj/item/painter/can_use(mob/user)
	return user.is_holding(src) && painter_mode == "Airlock"

/obj/item/painter/click_alt(mob/user)
	return CLICK_ACTION_BLOCKING
