GLOBAL_LIST_EMPTY(donor_prisoner_starts)

// Native roundstart landmarks are deleted once the round starts; keep their turfs for latejoin.
/obj/effect/landmark/start/prisoner/Initialize(mapload)
	. = ..()
	GLOB.donor_prisoner_starts |= get_turf(src)

/datum/job/prisoner/proc/get_safe_prisoner_turfs()
	var/list/candidates = GLOB.donor_prisoner_starts.Copy()
	for(var/atom/override_spawn as anything in GLOB.jobspawn_overrides[title])
		candidates |= get_turf(override_spawn)
	var/list/result = list()
	for(var/turf/location as anything in candidates)
		if(QDELETED(location) || !is_station_level(location.z) || location.is_blocked_turf(TRUE))
			continue
		if(!istype(get_area(location), /area/station/security/prison))
			continue
		result += location
	return result

/datum/job/prisoner/special_check_latejoin(client/player)
	return ..() && (!CONFIG_GET(flag/donor_prisoner_gate) || length(get_safe_prisoner_turfs()))

/datum/job/prisoner/get_latejoin_spawn_point()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return ..()
	var/list/locations = get_safe_prisoner_turfs()
	return length(locations) ? pick(locations) : null

/datum/job/prisoner/get_roundstart_spawn_point()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return ..()
	return get_latejoin_spawn_point()

/datum/job/prisoner/donor_lock_reason(client/player)
	. = ..()
	if(. || !CONFIG_GET(flag/donor_prisoner_gate))
		return
	if(!length(get_safe_prisoner_turfs()))
		return "На карте нет безопасной точки появления в пермабриге."
