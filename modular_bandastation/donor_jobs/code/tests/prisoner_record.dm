/datum/unit_test/donor_prisoner_initial_record
	var/prisoner_gate_before

/datum/unit_test/donor_prisoner_initial_record/Run()
	prisoner_gate_before = CONFIG_GET(flag/donor_prisoner_gate)
	CONFIG_SET(flag/donor_prisoner_gate, TRUE)
	var/datum/job/prisoner/job = allocate(/datum/job/prisoner)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	body.fully_replace_character_name(body.real_name, "Donor Record Test")
	body.mind_initialize()
	body.mind.set_assigned_role(job)
	body.job = job.title
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list(JOB_PRISONER = "title_b4b118ef86"))
	body.prisoner_crime = /datum/prisoner_crime/negligence::name
	job.prepare_donor_character(body, player.prefs)
	body.dress_up_as_job(job, consistent = TRUE)
	job.after_spawn(body, null)
	var/obj/item/card/id/card = body.get_idcard(hand_first = FALSE)
	TEST_ASSERT_NOTNULL(card, "Prisoner did not receive a usable ID")
	var/datum/id_trim/job/prisoner/prisoner_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/prisoner]
	TEST_ASSERT_EQUAL(card.trim, prisoner_trim, "The selected title replaced the native prisoner trim")
	TEST_ASSERT_EQUAL(card.assignment, "Уголовник", "Prisoner did not apply the selected public title")
	TEST_ASSERT_EQUAL(card.get_trim_assignment(), prisoner_trim.assignment, "The selected title replaced the canonical ID trim")
	var/list/crew_before = GLOB.manifest.general.Copy()
	var/list/locked_before = GLOB.manifest.locked.Copy()
	GLOB.manifest.inject(body, initial_spawn = TRUE)
	var/list/created_records = GLOB.manifest.general - crew_before
	allocated += created_records
	allocated += GLOB.manifest.locked - locked_before
	TEST_ASSERT_EQUAL(length(created_records), 1, "Initial prisoner injection did not create exactly one crew record")
	var/datum/record/crew/record = created_records[1]
	allocated += record.crimes
	TEST_ASSERT_EQUAL(record.rank, "Уголовник", "The initial record did not receive the selected public title")
	TEST_ASSERT_EQUAL(record.trim, prisoner_trim.assignment, "The initial record lost the canonical prisoner trim")
	TEST_ASSERT_EQUAL(length(record.crimes), 1, "The selected crime was missing or duplicated in the actual record")
	var/datum/crime/crime = record.crimes[1]
	TEST_ASSERT_EQUAL(crime.name, /datum/prisoner_crime/negligence::name, "The record used another character's crime")
	TEST_ASSERT_EQUAL(crime.author, "Central Command", "The initial sentence lost its authority")
	TEST_ASSERT(!job.on_initial_crew_record(body, record), "The same initial record was registered twice")
	TEST_ASSERT_EQUAL(length(record.crimes), 1, "A repeated record callback duplicated the sentence")
	TEST_ASSERT_EQUAL(record.crimes[1], crime, "A repeated record callback replaced the sentence")

	body.fully_replace_character_name(body.real_name, "Rehabilitated Record Test")
	body.mind.set_assigned_role(SSjob.get_job_type(/datum/job/cargo_technician))
	body.job = JOB_CARGO_TECHNICIAN
	TEST_ASSERT(body.dropItemToGround(card), "Could not replace the original ID through native inventory")
	var/obj/item/card/id/advanced/replacement = allocate(/obj/item/card/id/advanced)
	TEST_ASSERT(SSid_access.apply_trim_to_card(replacement, /datum/id_trim/job/cargo_technician), "Could not apply an ordinary cargo trim")
	replacement.assignment = "Technical Trainee"
	replacement.registered_name = body.real_name
	TEST_ASSERT(body.equip_to_slot_if_possible(replacement, ITEM_SLOT_ID), "Could not equip the replacement ID")
	GLOB.manifest.modify(body.real_name, "Technical Trainee", JOB_CARGO_TECHNICIAN)
	job.after_spawn(body, null)
	TEST_ASSERT_EQUAL(replacement.assignment, "Technical Trainee", "A repeated spawn callback restored the old donor ID title")
	TEST_ASSERT_EQUAL(record.rank, "Technical Trainee", "Normal rank editing restored the old donor record title")
	TEST_ASSERT_EQUAL(record.name, body.real_name, "Normal identity editing did not update the record")
	TEST_ASSERT_EQUAL(body.mind.assigned_role.type, /datum/job/cargo_technician, "Normal reassignment restored the old canonical job")

	crew_before = GLOB.manifest.general.Copy()
	locked_before = GLOB.manifest.locked.Copy()
	GLOB.manifest.inject(body)
	created_records = GLOB.manifest.general - crew_before
	allocated += created_records
	allocated += GLOB.manifest.locked - locked_before
	TEST_ASSERT_EQUAL(length(created_records), 1, "Normal record regeneration did not create one record")
	var/datum/record/crew/regenerated = created_records[1]
	TEST_ASSERT_EQUAL(regenerated.rank, replacement.get_trim_assignment(), "Normal record regeneration restored the old donor title")
	TEST_ASSERT_EQUAL(length(regenerated.crimes), 0, "Normal record regeneration recreated the old starting sentence")

/datum/unit_test/donor_prisoner_initial_record/Destroy()
	if(!isnull(prisoner_gate_before))
		CONFIG_SET(flag/donor_prisoner_gate, prisoner_gate_before)
	for(var/datum/record/crew/record in allocated)
		if(QDELETED(record))
			continue
		for(var/photo_key in record.record_photos?.Copy())
			record.delete_photos(photo_key)
	return ..()

/datum/unit_test/native_prisoner_initial_record
	parent_type = /datum/unit_test/donor_prisoner_initial_record
	var/jobs_enabled_before
	var/list/tattoos_before

/datum/unit_test/native_prisoner_initial_record/Run()
	prisoner_gate_before = CONFIG_GET(flag/donor_prisoner_gate)
	jobs_enabled_before = CONFIG_GET(flag/donor_jobs_enabled)
	tattoos_before = SSpersistence.prison_tattoos_to_use
	CONFIG_SET(flag/donor_jobs_enabled, FALSE)
	CONFIG_SET(flag/donor_prisoner_gate, FALSE)
	var/datum/job/prisoner/job = allocate(/datum/job/prisoner)
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	player.mob = lobby
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	lobby.mind.set_assigned_role(job)
	for(var/crime_key in list(/datum/prisoner_crime/attempted_murder::name, "Random"))
		player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/prisoner_crime], crime_key)
		SSpersistence.prison_tattoos_to_use = list()
		for(var/i in 1 to 6)
			SSpersistence.prison_tattoos_to_use += list(list("story" = "Native prisoner test tattoo [i]"))
		var/mob/living/carbon/human/body = job.get_spawn_mob(player, run_loc_floor_bottom_left)
		allocated += body
		TEST_ASSERT_NULL(body.donor_spawn_context, "Disabled donor flags left native Prisoner dependent on a donor context")
		body.mind_initialize()
		body.mind.set_assigned_role(job)
		body.dress_up_as_job(job, consistent = TRUE)
		var/datum/prisoner_crime/selected_crime = GLOB.prisoner_crimes[body.prisoner_crime]
		TEST_ASSERT_NOTNULL(selected_crime, "The native spawn did not resolve a selected or random crime")
		if(crime_key != "Random")
			TEST_ASSERT_EQUAL(body.prisoner_crime, crime_key, "The native spawn used another profile's crime")
		var/list/crew_before = GLOB.manifest.general.Copy()
		var/list/locked_before = GLOB.manifest.locked.Copy()
		GLOB.manifest.inject(body, initial_spawn = TRUE)
		var/list/created_records = GLOB.manifest.general - crew_before
		allocated += created_records
		allocated += GLOB.manifest.locked - locked_before
		TEST_ASSERT_EQUAL(length(created_records), 1, "Native Prisoner did not receive one actual crew record")
		var/datum/record/crew/record = created_records[1]
		allocated += record.crimes
		TEST_ASSERT_EQUAL(length(record.crimes), 1, "Native Prisoner lost its initial crime with both flags disabled")
		var/datum/crime/crime = record.crimes[1]
		TEST_ASSERT_EQUAL(crime.name, selected_crime.name, "Native record changed the resolved crime")
		var/datum/memory/key/permabrig_crimes/memory = body.mind.memories[/datum/memory/key/permabrig_crimes]
		TEST_ASSERT_NOTNULL(memory, "Native Prisoner lost its crime memory")
		TEST_ASSERT_EQUAL(memory.crimes, selected_crime.name, "Crime memory differed from the actual record")
		TEST_ASSERT_EQUAL(length(record.record_photos), 2, "Native Prisoner lost front or side manifest photos")
		var/tattoo_count = 0
		for(var/obj/item/bodypart/limb as anything in body.get_bodyparts())
			if(limb.GetComponent(/datum/component/tattoo))
				tattoo_count++
		TEST_ASSERT_EQUAL(tattoo_count, selected_crime.tattoos, "Native Prisoner lost crime-specific tattoos")
		TEST_ASSERT(!job.on_initial_crew_record(body, record), "A repeated native callback registered the crime again")
		TEST_ASSERT_EQUAL(length(record.crimes), 1, "A repeated native callback duplicated the crime")
		TEST_ASSERT_EQUAL(body.mind.memories[/datum/memory/key/permabrig_crimes], memory, "A repeated callback rerolled the crime memory")

/datum/unit_test/native_prisoner_initial_record/Destroy()
	if(!isnull(jobs_enabled_before))
		CONFIG_SET(flag/donor_jobs_enabled, jobs_enabled_before)
	SSpersistence.prison_tattoos_to_use = tattoos_before
	return ..()
