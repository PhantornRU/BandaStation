/// Complete a color modal only for the character and client that opened it.
/datum/preferences/proc/set_character_color(list/params, datum/tgui/ui)
	var/datum/preference/requested_preference = GLOB.preference_entries_by_key[params["preference"]]
	if(!istype(requested_preference, /datum/preference/color))
		return FALSE
	var/default_value = read_preference(requested_preference.type)
	var/editing_slot = default_slot
	var/new_color = tgui_color_picker(
		usr,
		"Select new color",
		null,
		default_value || COLOR_WHITE,
	)
	if(!new_color)
		return FALSE
	if(editing_slot != default_slot || QDELETED(ui) || !ui.user?.client || ui.user.client != parent)
		return FALSE
	return update_preference(requested_preference, new_color)
