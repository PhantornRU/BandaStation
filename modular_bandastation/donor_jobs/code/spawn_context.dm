/mob/living/carbon/human
	var/datum/donor_spawn_context/donor_spawn_context

/datum/donor_spawn_context
	var/job_type
	var/outfit_type
	var/public_title
	var/variant_id
	var/identity_applied = FALSE
	var/record_registered = FALSE

/datum/donor_spawn_context/New(datum/job/job, variant_choice)
	job_type = job.type
	var/datum/job_variant/variant = job.resolve_donor_variant(variant_choice)
	variant_id = variant?.id
	outfit_type = variant?.outfit_type || job.get_outfit(FALSE)
	public_title = variant?.public_title || job.title
	return ..()

/// Capture only the chosen variant before appearance callbacks or the job greeting.
/datum/job/proc/prepare_donor_character(mob/living/spawned, datum/preferences/preferences)
	if(!length(donor_variant_specs) || !ishuman(spawned) || !length(get_donor_variants()))
		return
	var/mob/living/carbon/human/body = spawned
	var/list/variants = preferences.read_preference(/datum/preference/job_outfit_variants)
	body.donor_spawn_context = new(src, variants?[title])
	body.donor_spawn_context.RegisterSignal(body, COMSIG_HUMAN_INITIAL_CREW_RECORD, TYPE_PROC_REF(/datum/donor_spawn_context, register_crew_record))

/datum/donor_spawn_context/proc/belongs_to(datum/job/job)
	return job && job.type == job_type

/datum/job/proc/donor_outfit_for(mob/living/carbon/human/body, datum/preferences/preferences, visual_only, consistent)
	if(!visual_only)
		return body.donor_spawn_context?.belongs_to(src) ? body.donor_spawn_context.outfit_type : get_outfit(consistent)
	if(!preferences)
		return get_outfit(consistent)
	var/list/selections = preferences.read_preference(/datum/preference/job_outfit_variants)
	var/datum/job_variant/variant = resolve_donor_variant(selections?[title])
	return variant?.outfit_type || get_outfit(consistent)

/datum/donor_spawn_context/proc/apply_identity(mob/living/carbon/human/body)
	if(identity_applied)
		return
	identity_applied = TRUE
	var/obj/item/card/id/card = body.get_idcard(hand_first = FALSE)
	if(card)
		card.assignment = public_title
		card.update_label()
		body.update_ID_card()
	var/datum/outfit/job/outfit_path = outfit_type
	var/pda_slot = initial(outfit_path.pda_slot)
	if(!pda_slot)
		return
	var/obj/item/slot_item = body.get_item_by_slot(pda_slot)
	var/obj/item/modular_computer/pda/pda
	if(istype(slot_item, /obj/item/modular_computer/pda))
		pda = slot_item
	else if(slot_item)
		pda = locate(/obj/item/modular_computer/pda) in slot_item
	if(pda)
		pda.imprint_id(body.real_name, public_title)
		pda.UpdateDisplay()

/datum/job/proc/apply_donor_spawn_context(mob/living/spawned)
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/body = spawned
	var/datum/donor_spawn_context/context = body.donor_spawn_context
	if(!context?.belongs_to(src))
		return
	context.apply_identity(body)

/datum/donor_spawn_context/proc/register_crew_record(mob/living/carbon/human/body, datum/job/job, datum/record/crew/record)
	SIGNAL_HANDLER
	if(record_registered || !belongs_to(job))
		return FALSE
	record_registered = TRUE
	record.rank = public_title
	return TRUE
