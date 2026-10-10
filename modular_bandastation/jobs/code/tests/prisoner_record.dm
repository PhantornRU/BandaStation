/datum/unit_test/native_prisoner_initial_record
	var/prisoner_gate_before
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
		allocated += body.mind
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
	release_job_player_fixtures()
	if(!isnull(prisoner_gate_before))
		CONFIG_SET(flag/donor_prisoner_gate, prisoner_gate_before)
	for(var/datum/record/crew/record in allocated)
		if(QDELETED(record))
			continue
		for(var/photo_key in record.record_photos?.Copy())
			record.delete_photos(photo_key)
	return ..()
