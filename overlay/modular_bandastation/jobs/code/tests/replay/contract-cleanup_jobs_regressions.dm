// External overlay only. These fixtures exercise public native phases and the shared rollback hook.

/datum/unit_test/job_spawn_rollback_ownership/Run()
	var/datum/job/ai_job = allocate(/datum/job/ai)
	var/datum/job/other_job = allocate(/datum/job/assistant)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	var/datum/mind/original_mind = allocate(/datum/mind)
	lobby.mind = original_mind
	original_mind.set_current(lobby)
	original_mind.active = FALSE
	original_mind.set_assigned_role(ai_job)
	var/mob/living/silicon/ai/body = allocate(/mob/living/silicon/ai, null, lobby, null, null, TRUE)
	TEST_ASSERT_EQUAL(body.mind, original_mind, "The real AI constructor did not move the captured lobby mind")
	TEST_ASSERT_NULL(lobby.mind, "AI construction left a second lobby owner")
	var/datum/mind/foreign_mind = allocate(/datum/mind)
	ai_job.rollback_spawn_character(body, lobby, foreign_mind)
	TEST_ASSERT_EQUAL(body.mind, original_mind, "Rollback accepted a foreign captured mind")
	TEST_ASSERT_NULL(lobby.mind, "A foreign captured mind restored an unrelated lobby")
	original_mind.set_assigned_role(other_job)
	ai_job.rollback_spawn_character(body, lobby, original_mind)
	TEST_ASSERT_EQUAL(body.mind, original_mind, "Rollback stole a reassigned mind")
	TEST_ASSERT_NULL(lobby.mind, "Rollback cancelled a different role assignment")
	original_mind.set_assigned_role(ai_job)
	foreign_mind.transfer_to(lobby)
	ai_job.rollback_spawn_character(body, lobby, original_mind)
	TEST_ASSERT_EQUAL(lobby.mind, foreign_mind, "Rollback overwrote a new lobby owner")
	TEST_ASSERT_EQUAL(body.mind, original_mind, "An occupied lobby detached the AI mind")
	var/mob/living/carbon/human/foreign_body = allocate(/mob/living/carbon/human)
	foreign_mind.transfer_to(foreign_body)
	ai_job.rollback_spawn_character(body, lobby, original_mind)
	TEST_ASSERT_EQUAL(lobby.mind, original_mind, "An owned AI failure did not restore the original lobby mind")
	TEST_ASSERT_EQUAL(original_mind.current, lobby, "Owned rollback left the mind in the failed AI")
	TEST_ASSERT_NULL(body.mind, "Owned rollback left a second AI owner")
	ai_job.rollback_spawn_character(body, lobby, original_mind)
	TEST_ASSERT_EQUAL(lobby.mind, original_mind, "Repeated cleanup moved the restored mind again")
	qdel(body)
	ai_job.rollback_spawn_character(body, lobby, original_mind)
	TEST_ASSERT_EQUAL(lobby.mind, original_mind, "Cleanup of a deleted body changed lobby ownership")

/mob/living/carbon/human/job_contract_equipment
	var/list/job_equipment_phases = list()
	var/equipment_calls = 0
	var/completed_outfits = 0

/mob/living/carbon/human/job_contract_equipment/equip_outfit_and_loadout(datum/outfit/outfit = /datum/outfit, datum/preferences/preference_source, visuals_only = FALSE)
	equipment_calls++
	job_equipment_phases += "equipment"
	return ..()

/datum/species/human/job_contract_equipment
	id = "external-job-equipment"
	changesource_flags = NONE

/datum/species/human/job_contract_equipment/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	var/mob/living/carbon/human/job_contract_equipment/body = equipping
	body.job_equipment_phases += "species"
	return ..()

/datum/outfit/job_contract_equipment
	uniform = /obj/item/clothing/under/color/grey

/datum/outfit/job_contract_equipment/post_equip(mob/living/carbon/human/equipping, visuals_only)
	. = ..()
	var/mob/living/carbon/human/job_contract_equipment/body = equipping
	body.completed_outfits++
	body.job_equipment_phases += "finished"

/datum/job/job_contract_equipment
	title = "External equipment boundary fixture"
	outfit = /datum/outfit

/datum/job/job_contract_equipment/config_check()
	return FALSE

/datum/job/job_contract_equipment/get_spawn_outfit(mob/living/carbon/human/equipping, datum/preferences/preferences, visual_only, consistent)
	var/mob/living/carbon/human/job_contract_equipment/body = equipping
	body.job_equipment_phases += "outfit"
	return /datum/outfit/job_contract_equipment

/datum/unit_test/job_native_equipment_sequence_once/Run()
	var/datum/job/job = allocate(/datum/job/job_contract_equipment)
	for(var/visual_only in list(FALSE, TRUE))
		var/mob/living/carbon/human/job_contract_equipment/body = allocate(/mob/living/carbon/human/job_contract_equipment)
		body.set_species(/datum/species/human/job_contract_equipment)
		body.dress_up_as_job(job, visual_only)
		TEST_ASSERT_EQUAL(jointext(body.job_equipment_phases, ","), "species,outfit,equipment,finished", "The native [visual_only ? "preview" : "live"] sequence changed phase or repeated an effect")
		TEST_ASSERT_EQUAL(body.equipment_calls, 1, "The native equipment/loadout sequence ran more than once")
		TEST_ASSERT_EQUAL(body.completed_outfits, 1, "The chosen outfit completed more than once")
		TEST_ASSERT(istype(body.w_uniform, /obj/item/clothing/under/color/grey), "The native equipment path ignored its character outfit hook")

/datum/unit_test/prisoner_committed_crime_lifecycle
	var/list/tattoo_pool_before

/datum/unit_test/prisoner_committed_crime_lifecycle/Run()
	tattoo_pool_before = SSpersistence.prison_tattoos_to_use
	SSpersistence.prison_tattoos_to_use = list(
		list("story" = "External committed crime tattoo one"),
		list("story" = "External committed crime tattoo two"),
		list("story" = "External unused tattoo"),
	)
	var/datum/job/prisoner/job = allocate(/datum/job/prisoner)
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/datum/preference/crime_preference = GLOB.preference_entries[/datum/preference/choiced/prisoner_crime]
	TEST_ASSERT(player.prefs.write_preference(crime_preference, /datum/prisoner_crime/attempted_murder::name), "The crime fixture could not select its initial preference")
	var/mob/living/carbon/human/consistent/body = allocate(/mob/living/carbon/human/consistent)
	body.mind_initialize()
	allocated += body.mind
	body.mind.set_assigned_role(job)
	body.job = job.title
	job.prepare_spawn_character(body, player.prefs)
	TEST_ASSERT_EQUAL(body.prisoner_crime, /datum/prisoner_crime/attempted_murder::name, "The before-preferences phase did not commit the chosen crime")
	TEST_ASSERT(player.prefs.write_preference(crime_preference, /datum/prisoner_crime/negligence::name), "The crime fixture could not change the later active preference")
	job.prepare_spawn_character(body, player.prefs)
	TEST_ASSERT_EQUAL(body.prisoner_crime, /datum/prisoner_crime/attempted_murder::name, "Repeated preparation replaced an already committed crime")
	var/datum/record/crew/older_record = allocate(/datum/record/crew)
	older_record.name = body.real_name
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREWMEMBER_JOINED, body, job.title)
	TEST_ASSERT_EQUAL(length(older_record.crimes), 0, "The removed global listener still wrote to a name-matched record")
	var/datum/record/crew/actual_record = allocate(/datum/record/crew)
	actual_record.name = body.real_name
	actual_record.character_appearance = new /mutable_appearance(body.appearance)
	TEST_ASSERT(job.on_initial_crew_record(body, actual_record), "The exact initial-record hook did not register its crime")
	TEST_ASSERT_EQUAL(length(actual_record.crimes), 1, "The initial record received a missing or duplicate crime")
	var/datum/crime/record_crime = actual_record.crimes[1]
	TEST_ASSERT_EQUAL(record_crime.name, body.prisoner_crime, "The initial record used the subsequently active crime preference")
	var/datum/memory/key/permabrig_crimes/memory = body.mind.memories[/datum/memory/key/permabrig_crimes]
	TEST_ASSERT_NOTNULL(memory, "The committed crime did not create its memory")
	TEST_ASSERT_EQUAL(memory.crimes, body.prisoner_crime, "The Prisoner memory disagreed with its initial record")
	TEST_ASSERT(!job.on_initial_crew_record(body, actual_record), "Repeated initial-record callback repeated its effects")
	TEST_ASSERT_EQUAL(length(actual_record.crimes), 1, "Repeated initial-record callback added another crime")
	TEST_ASSERT_EQUAL(body.mind.memories[/datum/memory/key/permabrig_crimes], memory, "Repeated initial-record callback replaced the original memory")
	TEST_ASSERT_EQUAL(length(older_record.crimes), 0, "The exact callback touched a different record with the same name")
	var/datum/outfit/job/prisoner/outfit = allocate(/datum/outfit/job/prisoner)
	outfit.post_equip(body, visuals_only = TRUE)
	TEST_ASSERT(!body.prisoner_tattoos_applied, "A preview consumed the Prisoner's once-only live effects")
	TEST_ASSERT_EQUAL(length(SSpersistence.prison_tattoos_to_use), 3, "A preview consumed persistent tattoos")
	outfit.post_equip(body, visuals_only = FALSE)
	TEST_ASSERT_EQUAL(length(SSpersistence.prison_tattoos_to_use), 1, "Native Prisoner equipment used the later preference instead of the committed two-tattoo crime")
	outfit.post_equip(body, visuals_only = FALSE)
	TEST_ASSERT_EQUAL(length(SSpersistence.prison_tattoos_to_use), 1, "Repeated native Prisoner equipment consumed more tattoos")

/datum/unit_test/prisoner_committed_crime_lifecycle/Destroy()
	SSpersistence.prison_tattoos_to_use = tattoo_pool_before
	for(var/datum/record/crew/record in allocated)
		if(QDELETED(record))
			continue
		for(var/photo_key in record.record_photos?.Copy())
			record.delete_photos(photo_key)
	release_job_player_fixtures()
	return ..()
