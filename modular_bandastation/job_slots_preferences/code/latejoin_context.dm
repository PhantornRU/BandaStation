/// Capture one job, or the whole menu when no job is known yet, without retaining the mutable map.
/datum/preferences/proc/capture_latejoin_profile(job_title = null)
	var/list/assigned_slots = list()
	if(istext(job_title))
		assigned_slots[job_title] = pref_job_slots?[job_title]
	else if(islist(pref_job_slots))
		assigned_slots = pref_job_slots.Copy()
	return list(
		"preferences" = src,
		"editing_slot" = default_slot,
		"assigned_slots" = assigned_slots,
		"use_current_slot" = read_preference(/datum/preference/toggle/late_join_always_current_slot),
	)

/// A chosen job only depends on its own assignment; menu rows and modal choices depend on every row.
/datum/preferences/proc/is_latejoin_profile_current(job_title, list/context)
	if(!islist(context) || context["preferences"] != src || context["editing_slot"] != default_slot)
		return FALSE
	if(context["use_current_slot"] != read_preference(/datum/preference/toggle/late_join_always_current_slot))
		return FALSE
	var/list/assigned_slots = context["assigned_slots"]
	if(!islist(assigned_slots))
		return FALSE
	var/list/current_slots = islist(pref_job_slots) ? pref_job_slots : list()
	if(istext(job_title))
		return assigned_slots[job_title] == current_slots[job_title]
	if(length(assigned_slots) != length(current_slots))
		return FALSE
	for(var/title in assigned_slots)
		if(!(title in current_slots) || assigned_slots[title] != current_slots[title])
			return FALSE
	return TRUE
