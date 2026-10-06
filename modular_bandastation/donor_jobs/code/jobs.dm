/datum/config_entry/flag/donor_jobs_enabled
	default = FALSE

/datum/config_entry/flag/donor_prisoner_gate
	default = FALSE

/proc/donor_job_tier_allows(actual, required)
	if(!isnum(required) || required < 0 || required > MAX_DONATOR_LEVEL || round(required) != required)
		return FALSE
	return !required || (isnum(actual) && actual >= required && actual <= MAX_DONATOR_LEVEL && round(actual) == actual)

/datum/job
	var/donor_tier = 0
	/// Stable variant ID -> list(public title, outfit path).
	var/list/donor_variant_specs
	var/list/donor_variants
	var/list/donor_languages

/datum/job/proc/get_required_donor_tier()
	return donor_tier

/datum/job/proc/donor_lock_reason(client/player)
	var/required = get_required_donor_tier()
	if(!donor_job_tier_allows(MAX_DONATOR_LEVEL, required))
		return "Некорректный уровень подписки в объявлении профессии."
	if(!required)
		return null
	if(!player || !donor_job_tier_allows(player.get_donator_level(), required))
		return "Требуется подписка уровня [required]."
	return null

/datum/job/donor
	abstract_type = /datum/job/donor
	faction = FACTION_STATION
	exp_granted_type = EXP_TYPE_CREW
	allow_bureaucratic_error = FALSE
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS
	tgui_icon = FA_ICON_USER

/datum/job/donor/config_check()
	return ..() && type != /datum/job/donor && CONFIG_GET(flag/donor_jobs_enabled)

/datum/job/donor/donor_lock_reason(client/player)
	if(!CONFIG_GET(flag/donor_jobs_enabled))
		return "Донатные профессии отключены."
	return ..()

/datum/job/prisoner/get_required_donor_tier()
	return CONFIG_GET(flag/donor_prisoner_gate) ? DONATOR_TIER_1 : 0

/datum/job/proc/requires_explicit_preference()
	return istype(src, /datum/job/donor) || (istype(src, /datum/job/prisoner) && CONFIG_GET(flag/donor_prisoner_gate))

/datum/job/proc/uses_donor_spawn_context()
	return istype(src, /datum/job/prisoner) || length(donor_variant_specs)

/datum/job_variant
	var/id
	var/public_title
	var/outfit_type
	var/job_type

/datum/job_variant/New(new_id, new_title, new_outfit, new_job)
	id = new_id
	public_title = new_title
	outfit_type = new_outfit
	job_type = new_job
	return ..()

/datum/job/proc/get_donor_variants()
	if(!isnull(donor_variants))
		return donor_variants
	donor_variants = list()
	for(var/id in donor_variant_specs)
		var/list/spec = donor_variant_specs[id]
		if(!istext(id) || !length(id) || !islist(spec) || length(spec) != 2 || !istext(spec[1]) || !length(spec[1]) || !ispath(spec[2], /datum/outfit/job))
			CRASH("Invalid job variant declaration: [type]/[id]")
		var/datum/outfit/job/outfit_path = spec[2]
		var/datum/id_trim/job/trim_path = initial(outfit_path.id_trim)
		if(initial(outfit_path.jobtype) != type || !ispath(trim_path, /datum/id_trim/job) || initial(trim_path.job) != type)
			CRASH("Variant outfit/trim belongs to another job: [type]/[id]")
		donor_variants[id] = new /datum/job_variant(id, spec[1], spec[2], type)
	if(length(donor_variants) && !donor_variants["default"])
		CRASH("Job variants require a default: [type]")
	return donor_variants

/datum/job/proc/resolve_donor_variant(variant_id)
	var/list/variants = get_donor_variants()
	return variants[variant_id] || variants["default"]

/datum/outfit
	var/preserve_backpack_overflow = FALSE

/datum/outfit/job
	/// Starting supplies issued once after live job equipment, never in preview.
	var/list/donor_kit

/datum/outfit/job/donor
	preserve_backpack_overflow = TRUE

/datum/id_trim/job
	/// Available only to the ordinary, authenticated CentCom ID program.
	var/centcom_template = FALSE
