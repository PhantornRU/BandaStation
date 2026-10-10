/datum/unit_test/native_offline_character_handover/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	lobby.spawning = TRUE
	lobby.PossessByPlayer(player.key)
	player.persistent_client.set_mob(lobby)
	lobby.mind = allocate(/datum/mind)
	lobby.mind.key = player.key
	lobby.mind.set_current(lobby)
	lobby.mind.active = FALSE
	lobby.mind.set_assigned_role(SSjob.get_job_type(/datum/job/cargo_technician))
	var/datum/mind/mind = lobby.mind
	mind.transfer_to(body)
	lobby.new_character = body
	lobby.assigned_character = allocate(/datum/job_character_selection)
	lobby.assigned_character.slot = 2
	TEST_ASSERT_EQUAL(lobby.transfer_character(), body, "The native offline handover did not return its created character")
	TEST_ASSERT_EQUAL(body.ckey, player.ckey, "Disconnect before handover left the character without the offline player's key")
	TEST_ASSERT_EQUAL(body.mind, mind, "The native offline handover lost the assigned mind")
	TEST_ASSERT_EQUAL(mind.current, body, "The native offline handover moved the mind away from its character")
	TEST_ASSERT("2" in player.persistent_client.joined_as_slots, "Offline handover did not record the effective profile")
	TEST_ASSERT_NULL(body.donor_spawn_context, "An ordinary native handover created a donor context")
	body.key = null

/datum/unit_test/native_offline_character_handover/Destroy()
	release_job_player_fixtures()
	return ..()

/mob/living/silicon/ai/entry_disconnect_test/apply_prefs_job(client/player_client, datum/job/job)
	// Disconnect at the same boundary as the yielding appearance-ban lookup.
	del(player_client)

/mob/living/carbon/human/entry_profile_change_test/apply_prefs_job(client/player_client, datum/job/job)
	. = ..()
	player_client.prefs.default_slot = 2

/datum/unit_test/native_spawn_admission_interruptions/Run()
	for(var/list/scenario as anything in list(
		list("job" = /datum/job/ai, "body" = /mob/living/silicon/ai/entry_disconnect_test),
		list("job" = /datum/job/cargo_technician, "body" = /mob/living/carbon/human/entry_profile_change_test),
	))
		var/datum/job/job = allocate(scenario["job"])
		job.spawn_type = scenario["body"]
		var/datum/client_interface/player = allocate(/datum/client_interface)
		player.prefs = allocate(/datum/preferences, player)
		player.prefs.default_slot = 1
		var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
		player.mob = lobby
		lobby.mock_client = player
		lobby.mind = allocate(/datum/mind)
		lobby.mind.set_current(lobby)
		lobby.mind.active = FALSE
		lobby.mind.set_assigned_role(job)
		var/datum/mind/mind = lobby.mind
		lobby.assigned_character = player.prefs.select_job_character(job)
		TEST_ASSERT_NULL(job.get_spawn_mob(player, run_loc_floor_bottom_left), "A disconnected or changed-profile attempt returned a partial character")
		TEST_ASSERT_EQUAL(lobby.mind, mind, "An interrupted native spawn lost the lobby mind")
		TEST_ASSERT_EQUAL(mind.current, lobby, "An interrupted native spawn retained its mind in a discarded body")
		TEST_ASSERT_EQUAL(mind.assigned_role, job, "An interrupted native spawn lost its canonical role before cancellation")

/datum/unit_test/native_spawn_admission_interruptions/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/unit_test/donor_character_handover/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.all_quirks = list(/datum/quirk/item_quirk/food_allergic::name)
	TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/food_allergy], "Молочные продукты"), "Could not save the customized allergy")
	var/datum/job/job = allocate(/datum/job/donor/barber)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	body.mind_initialize()
	allocated += body.mind
	body.mind.set_assigned_role(job)
	job.prepare_donor_character(body, player.prefs)
	SSjob.equip_rank(body, job, null)
	allocated += SSeconomy.bank_accounts_by_id["[body.account_id]"]
	SSquirks.AssignQuirks(body, player)
	var/datum/quirk/item_quirk/food_allergic/allergy = locate() in body.quirks
	TEST_ASSERT_NOTNULL(allergy, "Native post-equipment quirks did not add the selected allergy")
	TEST_ASSERT_EQUAL(allergy.target_foodtypes, DAIRY, "Native quirks lost the customized allergy")
	TEST_ASSERT_NOTNULL(locate(/obj/item/clothing/accessory/dogtag/allergy) in body.get_all_contents(), "Native quirks lost their actual equipment")
	SSquirks.AssignQuirks(body, null)
	TEST_ASSERT_EQUAL(allergy.target_foodtypes, DAIRY, "Disconnect after handover changed the applied customized quirk")
	TEST_ASSERT(body.donor_spawn_context.identity_applied, "Initial native equipment did not apply its public title")
	var/list/items_before = run_loc_floor_bottom_left.get_all_contents_type(/obj/item)
	var/obj/item/card/id/card = body.get_idcard(hand_first = FALSE)
	card.assignment = "Reassigned employee"
	job.after_spawn(body, null)
	TEST_ASSERT_EQUAL(length(run_loc_floor_bottom_left.get_all_contents_type(/obj/item) - items_before), 0, "A repeated spawn callback issued additional equipment")
	TEST_ASSERT_EQUAL(card.assignment, "Reassigned employee", "A repeated callback restored the old public title")
	TEST_ASSERT_NULL(body.client, "Reward issuance required a Login or reconnect")

/datum/unit_test/donor_character_handover/Destroy()
	release_job_player_fixtures()
	return ..()
