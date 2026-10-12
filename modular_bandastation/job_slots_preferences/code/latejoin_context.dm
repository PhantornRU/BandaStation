/// Read-only request context, not another saved assignment map.
/datum/preferences/proc/capture_latejoin_profile(job_title)
	return list(
		"preferences" = src,
		"editing_slot" = default_slot,
		"assigned_slot" = istext(job_title) ? pref_job_slots[job_title] : null,
		"use_current_slot" = read_preference(/datum/preference/toggle/late_join_always_current_slot),
	)

/// Reject a stale request before native assignment commits a character selection.
/datum/preferences/proc/is_latejoin_profile_current(job_title, list/context)
	if(!islist(context) || context["preferences"] != src || context["editing_slot"] != default_slot)
		return FALSE
	if(!istext(job_title) || context["assigned_slot"] != pref_job_slots[job_title])
		return FALSE
	return context["use_current_slot"] == read_preference(/datum/preference/toggle/late_join_always_current_slot)
