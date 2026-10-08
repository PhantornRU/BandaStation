/mob/living/carbon/human
	var/datum/donor_spawn_context/donor_spawn_context

/datum/donor_spawn_context
	var/job_type
	var/outfit_type
	var/public_title
	var/variant_id
	var/crime_key
	var/kit_issued = FALSE
	var/identity_applied = FALSE
	var/record_registered = FALSE

/datum/donor_spawn_context/New(datum/job/job, datum/job_character_selection/selection)
	job_type = job.type
	var/datum/job_variant/variant = job.resolve_donor_variant(selection.variant_id)
	variant_id = variant?.id
	outfit_type = variant?.outfit_type || job.get_outfit(FALSE)
	public_title = variant?.public_title || job.title
	if(istype(job, /datum/job/prisoner))
		crime_key = selection.prisoner_crime
		if(!GLOB.prisoner_crimes[crime_key])
			crime_key = pick(assoc_to_keys(GLOB.prisoner_crimes))
	return ..()

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

/datum/donor_spawn_context/proc/issue_kit(mob/living/carbon/human/body)
	if(kit_issued)
		return
	// DM creates list initializers on instances, not on typepaths.
	var/datum/outfit/job/outfit = new outfit_type
	var/list/items = outfit.donor_kit
	qdel(outfit)
	for(var/item_type in items)
		var/count = items[item_type]
		if(!ispath(item_type, /obj/item) || !isnum(count) || count < 1 || round(count) != count)
			CRASH("Invalid job kit entry [job_type]: [item_type] x[count]")
	kit_issued = TRUE
	for(var/item_type in items)
		for(var/i in 1 to items[item_type])
			// Construct outside the mob: stacks may merge and delete themselves on movement.
			var/obj/item/item = SSwardrobe.provide_type(item_type, null)
			if(QDELETED(item))
				CRASH("Job kit construction failed: [job_type]/[item_type]")
			if(body.equip_to_storage(item, ITEM_SLOT_BACK, indirect_action = TRUE, del_on_fail = FALSE))
				continue
			if(!body.put_in_hands(item))
				item.forceMove(body.drop_location())
			to_chat(body, span_notice("[item.name] не поместился в сумку и выдан в руки или рядом с вами."))

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
	// Floor stacks can merge into another player's items, so issue kits only after ownership commits.
	if(!body.job_entry_guard || body.job_entry_guard.handover_complete)
		context.issue_kit(body)
	context.apply_identity(body)
	for(var/language_type in donor_languages)
		body.grant_language(language_type, ALL, "donor-job")

/datum/job/proc/on_initial_crew_record(mob/living/carbon/human/body, datum/record/crew/record)
	var/datum/donor_spawn_context/context = body.donor_spawn_context
	if(!context || context.record_registered || !context.belongs_to(src))
		return FALSE
	context.record_registered = TRUE
	record.rank = context.public_title
	return TRUE

/datum/job/prisoner/on_initial_crew_record(mob/living/carbon/human/body, datum/record/crew/record)
	if(!..())
		return FALSE
	var/datum/prisoner_crime/crime = GLOB.prisoner_crimes[body.donor_spawn_context.crime_key]
	if(!crime)
		CRASH("Prisoner context has no valid crime")
	record.crimes += new /datum/crime(crime.name, crime.desc, "Central Command", "Indefinite.")
	body.add_mob_memory(/datum/memory/key/permabrig_crimes, crimes = body.donor_spawn_context.crime_key)
	var/list/limbs = body.get_bodyparts()
	for(var/i in 1 to crime.tattoos)
		if(!length(limbs) || !length(SSpersistence.prison_tattoos_to_use))
			break
		var/obj/item/bodypart/limb = pick_n_take(limbs)
		var/list/tattoo = pick_n_take(SSpersistence.prison_tattoos_to_use)
		limb.AddComponent(/datum/component/tattoo, tattoo["story"])
	record.recreate_manifest_photos(add_height_chart = TRUE)
	to_chat(body, span_warning("Вы отбываете наказание за: [crime.name]."))
	return TRUE
