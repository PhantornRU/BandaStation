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
	lobby.assigned_character.job_type = mind.assigned_role.type
	lobby.assigned_character.created_body = body
	lobby.assigned_character.created_mind = mind
	// Headless fixture supplies the owned result of native create_character, including its early append.
	LAZYADD(player.persistent_client.joined_as_slots, "2")
	lobby.assigned_character.history_connection = player.persistent_client
	lobby.assigned_character.history_index = length(player.persistent_client.joined_as_slots)
	TEST_ASSERT_EQUAL(lobby.transfer_character(), body, "The native offline handover did not return its created character")
	TEST_ASSERT_EQUAL(body.ckey, player.ckey, "Disconnect before handover left the character without the offline player's key")
	TEST_ASSERT_EQUAL(body.mind, mind, "The native offline handover lost the assigned mind")
	TEST_ASSERT_EQUAL(mind.current, body, "The native offline handover moved the mind away from its character")
	TEST_ASSERT("2" in player.persistent_client.joined_as_slots, "Offline handover did not record the effective profile")
	TEST_ASSERT_EQUAL(length(player.persistent_client.joined_as_slots), 1, "Handover duplicated native construction history")
	TEST_ASSERT_NULL(body.job_variant_context, "An ordinary native handover created a donor context")
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
		var/datum/job_character_creation/creation = allocate(/datum/job_character_creation, lobby)
		var/mob/living/body = job.get_spawn_mob(player, run_loc_floor_bottom_left)
		if(scenario["job"] == /datum/job/ai)
			TEST_ASSERT_NULL(body, "A disconnected AI constructor returned a partial character")
			qdel(creation)
		else
			TEST_ASSERT_NOTNULL(body, "The constructor did not return its human for final admission")
			TEST_ASSERT_EQUAL(player.prefs.default_slot, 2, "The constructor did not exercise the profile mutation")
			TEST_ASSERT_EQUAL(lobby.assigned_character.slot, 1, "The captured assignment followed the mutated profile")
			// The public create_character route calls this boundary after every constructor.
			// Headless also lacks a real client: this isolates rejection/cleanup, not connected profile mismatch.
			TEST_ASSERT(!creation.validate_character(body, lobby), "Final admission accepted the interrupted human")
			TEST_ASSERT(QDELETED(creation), "Final admission retained its consumed construction context")
			TEST_ASSERT(QDELETED(body), "Rejected final admission retained its partial human")
			TEST_ASSERT_NULL(lobby.new_character, "Rejected final admission committed its partial human")
		TEST_ASSERT_EQUAL(lobby.mind, mind, "An interrupted native spawn lost the lobby mind")
		TEST_ASSERT_EQUAL(mind.current, lobby, "An interrupted native spawn retained its mind in a discarded body")
		TEST_ASSERT_EQUAL(mind.assigned_role, job, "An interrupted native spawn lost its canonical role before cancellation")

/datum/unit_test/native_spawn_admission_interruptions/Destroy()
	release_job_player_fixtures()
	return ..()

/// A stale constructor or cancellation must not steal or delete another mind's body.
/datum/unit_test/native_spawn_foreign_body_ownership
	var/mob/dead/new_player/roundstart_player
	var/datum/job_character_selection/replacement_selection
	var/mob/living/replacement_body
	var/signal_mode
	var/signal_calls = 0
	var/signal_cancel_result
	var/list/joined_before
	var/datum/job/roundstart_job
	var/positions_before_roundstart

/datum/unit_test/native_spawn_foreign_body_ownership/proc/change_signal_ownership(datum/mind/source, mob/living/character)
	SIGNAL_HANDLER
	signal_calls++
	if(signal_mode == "replace")
		roundstart_player.assigned_character = replacement_selection
		roundstart_player.new_character = replacement_body
	else
		signal_cancel_result = roundstart_player.cancel_character_spawn()
	// Deliberately omit the cancellation bit: the validator must re-read actual ownership.
	return NONE

/datum/unit_test/native_spawn_foreign_body_ownership/Run()
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	var/datum/job/job = SSjob.get_job_type(/datum/job/cargo_technician)
	var/positions_before = job.current_positions
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	lobby.mind.set_assigned_role(job)
	var/datum/mind/captured_mind = lobby.mind
	var/datum/job_character_selection/selection = allocate(/datum/job_character_selection)
	selection.job_type = job.type
	selection.created_mind = captured_mind
	lobby.assigned_character = selection
	var/datum/job_character_creation/creation = allocate(/datum/job_character_creation, lobby)
	var/mob/living/basic/foreign_body = allocate(/mob/living/basic)
	var/datum/mind/foreign_mind = allocate(/datum/mind)
	foreign_mind.set_assigned_role(job)
	foreign_mind.transfer_to(foreign_body)
	TEST_ASSERT(!creation.validate_character(foreign_body, lobby), "Final admission accepted a foreign mind's body")
	TEST_ASSERT(QDELETED(creation), "Foreign-body rejection retained its consumed construction context")
	TEST_ASSERT(!QDELETED(foreign_body), "Final admission deleted another mind's body")
	TEST_ASSERT_EQUAL(foreign_body.mind, foreign_mind, "Final admission replaced another mind")
	TEST_ASSERT_EQUAL(lobby.mind, captured_mind, "Final admission moved the captured lobby mind")
	selection.created_body = allocate(/mob/living/basic)
	lobby.new_character = foreign_body
	TEST_ASSERT_NULL(lobby.transfer_character(), "Handover accepted a foreign new_character")
	TEST_ASSERT(!lobby.cancel_character_spawn(selection, captured_mind, selection.created_body), "Rollback accepted a replaced new_character")
	TEST_ASSERT_EQUAL(lobby.new_character, foreign_body, "Rollback cleared another caller's pending body")
	TEST_ASSERT_EQUAL(job.current_positions, positions_before, "A foreign body released another caller's vacancy")
	joined_before = GLOB.joined_player_list
	GLOB.joined_player_list = joined_before.Copy()
	roundstart_job = job
	positions_before_roundstart = positions_before
	for(var/mode in list("replace", "cancel"))
		signal_mode = mode
		signal_cancel_result = null
		roundstart_player = allocate(/mob/dead/new_player)
		roundstart_player.spawning = TRUE
		var/datum/client_interface/player = allocate(/datum/client_interface)
		roundstart_player.PossessByPlayer(player.key)
		player.persistent_client.set_mob(roundstart_player)
		roundstart_player.mind = allocate(/datum/mind)
		roundstart_player.mind.key = player.key
		roundstart_player.mind.set_current(roundstart_player)
		roundstart_player.mind.active = FALSE
		roundstart_player.mind.set_assigned_role(job)
		var/datum/mind/roundstart_mind = roundstart_player.mind
		var/datum/job_character_selection/roundstart_selection = allocate(/datum/job_character_selection)
		roundstart_selection.job_type = job.type
		roundstart_selection.created_mind = roundstart_mind
		roundstart_player.assigned_character = roundstart_selection
		var/datum/roundstart_character_attempt/attempt = SSticker.capture_roundstart_character(roundstart_player)
		var/prior_joined = json_encode(GLOB.joined_player_list)
		GLOB.joined_player_list += roundstart_player.ckey
		TEST_ASSERT_EQUAL(length(GLOB.joined_player_list), length(joined_before) + 1, "The roundstart fixture did not append its captured ckey")
		var/mob/living/basic/roundstart_body = allocate(/mob/living/basic)
		roundstart_mind.transfer_to(roundstart_body)
		roundstart_selection.created_body = roundstart_body
		roundstart_player.new_character = roundstart_body
		job.current_positions = positions_before + 1
		replacement_selection = allocate(/datum/job_character_selection)
		replacement_selection.job_type = job.type
		replacement_body = allocate(/mob/living/basic)
		var/datum/mind/replacement_mind = allocate(/datum/mind)
		replacement_mind.active = FALSE
		replacement_mind.set_assigned_role(job)
		replacement_mind.transfer_to(replacement_body)
		replacement_selection.created_body = replacement_body
		replacement_selection.created_mind = replacement_mind
		RegisterSignal(roundstart_mind, expected_roundstart_character_signal(), PROC_REF(change_signal_ownership))
		var/signals_before = signal_calls
		TEST_ASSERT(!SSticker.validate_roundstart_character(roundstart_player, roundstart_body, attempt), "Roundstart accepted changed ownership after a [mode] listener")
		UnregisterSignal(roundstart_mind, expected_roundstart_character_signal())
		TEST_ASSERT_EQUAL(signal_calls, signals_before + 1, "Roundstart did not execute the real ownership-changing signal once")
		TEST_ASSERT(QDELETED(attempt), "Roundstart retained the consumed receipt")
		TEST_ASSERT_EQUAL(json_encode(GLOB.joined_player_list), prior_joined, "Rejected roundstart changed another player's joined history")
		if(mode == "replace")
			TEST_ASSERT_EQUAL(roundstart_player.assigned_character, replacement_selection, "Old roundstart cancelled the replacement selection")
			TEST_ASSERT_EQUAL(roundstart_player.new_character, replacement_body, "Old roundstart cleared the replacement body")
			TEST_ASSERT(!QDELETED(replacement_body), "Old roundstart deleted the replacement body")
			TEST_ASSERT_EQUAL(replacement_body.mind, replacement_mind, "Old roundstart stole the replacement mind")
			TEST_ASSERT_EQUAL(job.current_positions, positions_before + 1, "Old roundstart released a replacement vacancy")
		else
			TEST_ASSERT(signal_cancel_result, "The signal did not exercise owned cancellation")
			TEST_ASSERT_NULL(roundstart_player.assigned_character, "Signal cancellation retained its selection")
			TEST_ASSERT_NULL(roundstart_player.new_character, "Signal cancellation retained its body")
			TEST_ASSERT_EQUAL(roundstart_player.mind, roundstart_mind, "Signal cancellation lost its captured mind")
			TEST_ASSERT_EQUAL(job.current_positions, positions_before, "Post-signal validation double-freed a cancelled vacancy")
		job.current_positions = positions_before

/datum/unit_test/native_spawn_foreign_body_ownership/Destroy()
	if(joined_before)
		GLOB.joined_player_list = joined_before
	if(roundstart_job)
		roundstart_job.current_positions = positions_before_roundstart
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
	job.prepare_spawn_character(body, player.prefs)
	SSjob.equip_rank(body, job, null)
	allocated += SSeconomy.bank_accounts_by_id["[body.account_id]"]
	SSquirks.AssignQuirks(body, player)
	var/datum/quirk/item_quirk/food_allergic/allergy = locate() in body.quirks
	TEST_ASSERT_NOTNULL(allergy, "Native post-equipment quirks did not add the selected allergy")
	TEST_ASSERT_EQUAL(allergy.target_foodtypes, DAIRY, "Native quirks lost the customized allergy")
	TEST_ASSERT_NOTNULL(locate(/obj/item/clothing/accessory/dogtag/allergy) in body.get_all_contents(), "Native quirks lost their actual equipment")
	SSquirks.AssignQuirks(body, null)
	TEST_ASSERT_EQUAL(allergy.target_foodtypes, DAIRY, "Disconnect after handover changed the applied customized quirk")
	TEST_ASSERT(body.job_variant_context.identity_applied, "Initial native equipment did not apply its public title")
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
