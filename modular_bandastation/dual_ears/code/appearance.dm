/// Keep the normal species fitting and item overrides for anything worn on an ear.
/obj/item/proc/get_ear_worn_icon(ear_slot, species_id)
	return get_species_worn_icon(species_id) || worn_icon || 'icons/mob/clothing/ears.dmi'

/// The small earpieces and the bowman headsets have opposite native sides.
/obj/item/radio/headset/get_ear_worn_icon(ear_slot, species_id)
	var/icon_file = ..()
	var/state = worn_icon_state || icon_state
	var/static/list/bilateral_states = list("earmuffs", "earset", "headphones", "headphones_on", "spacepods", "spacepods_on")
	if(state in bilateral_states)
		return icon_file
	var/static/list/native_left_states = list(
		"sec_headset_alt",
		"syndie_headset",
		"com_headset_alt",
		"cent_headset_alt",
		"med_headset_alt",
		"abductor_headset",
		"ussp_headset",
	)
	if((ear_slot == ITEM_SLOT_EAR_LEFT) != (state in native_left_states))
		return get_mirrored_ear_icon(icon_file)
	return icon_file

/// Mirror each sprite and exchange profiles so the far earpiece stays behind the head.
/// Copy the whole file to preserve states, animation frames and their delays.
/proc/get_mirrored_ear_icon(icon_file)
	var/static/list/mirrored_icons = list()
	var/cache_key = "[icon_file]"
	if(mirrored_icons[cache_key])
		return mirrored_icons[cache_key]
	var/icon/mirrored = icon(icon_file)
	mirrored.Flip(WEST)
	for(var/state in icon_states(icon_file))
		var/icon/east_profile = icon(mirrored, state, EAST)
		var/icon/west_profile = icon(mirrored, state, WEST)
		mirrored.Insert(east_profile, state, WEST)
		mirrored.Insert(west_profile, state, EAST)
	mirrored_icons[cache_key] = mirrored
	return mirrored
