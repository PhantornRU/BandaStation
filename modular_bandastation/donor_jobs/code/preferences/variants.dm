/datum/job
	/// Stable variant ID -> list(public title, outfit path).
	var/list/donor_variant_specs
	var/list/donor_variants

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
