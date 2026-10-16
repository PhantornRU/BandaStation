/datum/unit_test/dynamic_roundstart_cancellation/blood_worm_signal_lifecycle/Run()
	queue_before = SSdynamic.queued_rulesets
	prevented_before = SSjob.prevented_occupations
	forced_before = SSjob.forced_occupations
	lobby_before = GLOB.new_player_list
	spawns_before = GLOB.jobspawn_overrides
	SSdynamic.queued_rulesets = list()
	SSjob.prevented_occupations = list()
	SSjob.forced_occupations = list()
	GLOB.new_player_list = list()
	var/datum/job/job = SSjob.get_job_type(/datum/job/assistant)
	var/mob/living/carbon/human/valid_body = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/invalid_body = allocate(/mob/living/carbon/human/consistent)
	invalid_body.set_species(/datum/species/plasmaman)
	TEST_ASSERT(CAN_HAVE_BLOOD(valid_body), "The human host fixture cannot have blood")
	TEST_ASSERT(!CAN_HAVE_BLOOD(invalid_body), "The plasmaman host fixture has blood")
	for(var/success in list(TRUE, FALSE))
		var/datum/dynamic_ruleset/roundstart/blood_worm/ruleset = allocate(/datum/dynamic_ruleset/roundstart/blood_worm)
		ruleset.max_antag_cap = 1
		ruleset.blacklisted_roles = list(JOB_CARGO_TECHNICIAN)
		var/mob/dead/new_player/player = make_player(ruleset.pref_flag, job)
		var/datum/mind/candidate = player.mind
		SSjob.prevented_occupations[candidate] = list(JOB_PRISONER)
		TEST_ASSERT(ruleset.prepare_execution(1, list(player)), "Blood Worm could not prepare a native assignment")
		var/mob/living/body = success ? valid_body : invalid_body
		var/cancelled = host_is_cancelled(candidate, body)
		if(success)
			TEST_ASSERT(!cancelled, "The valid host was rejected")
			TEST_ASSERT(!host_is_cancelled(candidate, invalid_body), "Successful validation retained its one-shot listener")
		else
			TEST_ASSERT(cancelled, "The bloodless host was accepted")
		TEST_ASSERT(ruleset.cancel_assignment(candidate), "The pending assignment could not be cancelled")
		TEST_ASSERT(!host_is_cancelled(candidate, invalid_body), "Cancellation retained its host listener")
		TEST_ASSERT(JOB_PRISONER in LAZYACCESS(SSjob.prevented_occupations, candidate), "Cleanup removed a pre-existing restriction")
		TEST_ASSERT(!(JOB_CARGO_TECHNICIAN in LAZYACCESS(SSjob.prevented_occupations, candidate)), "Cleanup retained its own restriction")

/datum/unit_test/donor_centcom_template_idempotence/Run()
	var/list/templates = SSid_access.centcom_job_templates.Copy()
	SSid_access.setup_tgui_lists()
	SSid_access.setup_tgui_lists()
	TEST_ASSERT_EQUAL(length(SSid_access.centcom_job_templates), length(templates), "Repeated setup changed template count")
	for(var/trim_path in templates)
		TEST_ASSERT_EQUAL(SSid_access.centcom_job_templates[trim_path], templates[trim_path], "Repeated setup changed [trim_path]")
	for(var/trim_path in subtypesof(/datum/id_trim/job))
		var/datum/id_trim/job/trim = SSid_access.trim_singletons_by_path[trim_path]
		if(trim.centcom_template && trim.job)
			TEST_ASSERT_EQUAL(SSid_access.centcom_job_templates[trim_path], trim.assignment, "A registered job template was not extended after native setup")

/datum/preferences/committed_slot_test
	var/selection_reads = 0
	var/slot_loads = 0
	var/slot_saves = 0

/datum/preferences/committed_slot_test/select_job_character(datum/job/job, latejoin = FALSE, forced_slot)
	selection_reads++
	return ..()

/datum/preferences/committed_slot_test/load_character(slot)
	slot_loads++
	return ..()

/datum/preferences/committed_slot_test/save_character()
	slot_saves++
	return ..()

/datum/unit_test/committed_job_slot_reuse/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/committed_slot_test/preferences = allocate(/datum/preferences/committed_slot_test, player)
	player.prefs = preferences
	preferences.default_slot = 1
	preferences.max_save_slots = 2
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.savefile.set_entry("character2", list("real_name" = "Committed Character", "age" = 35, "species" = SPECIES_HUMAN))
	var/datum/job/job = SSjob.get_job_type(/datum/job/assistant)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	lobby.mock_client = player
	player.mob = lobby
	for(var/randomized in list(FALSE, TRUE))
		preferences.pref_job_slots[job.title] = randomized ? -1 : 2
		lobby.assigned_character = preferences.select_job_character(job)
		TEST_ASSERT_NULL(lobby.assigned_character.error, "Could not prepare the committed profile")
		var/reads_before = preferences.selection_reads
		var/loads_before = preferences.slot_loads
		var/saves_before = preferences.slot_saves
		preferences.pref_job_slots[job.title] = 999
		TEST_ASSERT_EQUAL(preferences.set_assigned_slot(job.title), randomized, "Committed appearance mode was replaced by a new selection")
		TEST_ASSERT_EQUAL(preferences.selection_reads, reads_before, "Applying a committed job resolved another profile")
		TEST_ASSERT_EQUAL(preferences.slot_loads, loads_before, "Applying a committed job loaded another character")
		TEST_ASSERT_EQUAL(preferences.slot_saves, saves_before, "Applying a committed job saved a character")
		QDEL_NULL(lobby.assigned_character)

/datum/unit_test/committed_job_slot_reuse/Destroy()
	release_job_player_fixtures()
	return ..()

/// The canonical protocol has no legacy callable/delegation/variable or DTO field.
/datum/unit_test/native_job_profile_legacy_action/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	var/datum/preference_middleware/jobs/jobs = locate(/datum/preference_middleware/jobs) in preferences.middleware
	TEST_ASSERT_NOTNULL(jobs, "Native preferences did not discover jobs middleware")
	TEST_ASSERT_NULL(jobs.action_delegations["set_job_to_profile"], "A removed legacy action remains delegated")
	TEST_ASSERT(!hascall(jobs, "set_job_to_profile"), "The removed legacy handler survives as a callable stub")
	TEST_ASSERT(!("job_assigned_profiles" in preferences.vars), "The removed legacy runtime variable survives")
	var/datum/job/job = SSjob.get_job_type(/datum/job/assistant)
	preferences.job_preferences = list(job.title = JP_MEDIUM)
	preferences.pref_job_slots = list(job.title = 2, "Canonical profile only" = 999)
	var/canonical_before = json_encode(preferences.pref_job_slots)
	// Exercise the real dispatcher after native UI authorization, not datum/ui_act with no UI.
	var/mob/dead/new_player/owner = allocate(/mob/dead/new_player)
	owner.mock_client = player
	player.mob = owner
	var/datum/tgui/action_ui = allocate(/datum/tgui, owner, preferences, "PreferencesMenu")
	action_ui.status = UI_INTERACTIVE
	TEST_ASSERT(!preferences.ui_act("set_job_to_profile", list("job" = job.title, "profile" = 1), action_ui, GLOB.always_state), "Forged legacy input was handled")
	TEST_ASSERT_EQUAL(json_encode(preferences.pref_job_slots), canonical_before, "Forged legacy input changed canonical assignments")
	var/list/data = jobs.get_ui_data(null)
	var/list/priorities = data["job_preferences"]
	TEST_ASSERT_EQUAL(length(priorities), 1, "An assignment-only row entered priorities")
	var/list/row = priorities[1]
	TEST_ASSERT_EQUAL(length(row), 2, "A legacy field entered the priority DTO")
	TEST_ASSERT_EQUAL(row["job"], job.title, "The canonical title changed")
	TEST_ASSERT_EQUAL(row["priority"], JP_MEDIUM, "Native priority changed")
	TEST_ASSERT(!("assigned_profile_slot" in row), "A legacy assignment field reached UI")
	TEST_ASSERT_EQUAL(json_encode(preferences.pref_job_slots), canonical_before, "UI serialization changed canonical assignments")

/datum/unit_test/native_job_profile_legacy_action/Destroy()
	release_job_player_fixtures()
	return ..()

/// Both native phase hooks must use only the canonical format, including keybinding-triggered saves.
/datum/unit_test/native_job_profile_storage_boundary/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.max_save_slots = 3
	preferences.default_slot = 1
	TEST_ASSERT(preferences.save_preferences(), "Could not initialize native preference metadata")
	var/list/character = list("real_name" = "Preserved Character", "age" = 44)
	preferences.savefile.set_entry("character2", character)
	preferences.savefile.set_entry("unrelated_setting", "keep")
	var/list/canonical = list("Assistant" = -1, "Temporarily unavailable job" = 999)
	preferences.savefile.set_entry("pref_job_slots", canonical)
	preferences.savefile.set_entry("job_assigned_profiles", list("Assistant" = 3, "Legacy only" = 2))
	TEST_ASSERT(preferences.load_preferences(), "The native preference loader failed")
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 2, "The native loader merged legacy assignments")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots["Assistant"], -1, "Legacy storage overrode canonical randomization")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots["Temporarily unavailable job"], 999, "Native legacy sanitation erased an unavailable canonical assignment")
	TEST_ASSERT(!("job_assigned_profiles" in preferences.vars), "The legacy runtime variable was reintroduced")
	TEST_ASSERT(!("job_assigned_profiles" in preferences.savefile.get_entry()), "A keybinding-triggered save retained the legacy root key")
	TEST_ASSERT_EQUAL(preferences.savefile.get_entry("pref_job_slots")["Temporarily unavailable job"], 999, "Native sanitation mutated the saved canonical map")
	TEST_ASSERT(preferences.save_preferences(), "The native preference saver failed")
	TEST_ASSERT(!("job_assigned_profiles" in preferences.savefile.get_entry()), "The native saver wrote the legacy format")
	TEST_ASSERT_EQUAL(preferences.savefile.get_entry("pref_job_slots")["Assistant"], -1, "Saving used dormant native assignments")
	preferences.savefile.remove_entry("pref_job_slots")
	preferences.savefile.set_entry("job_assigned_profiles", list("Legacy only" = 2))
	preferences.pref_job_slots = list("Previously loaded" = 2)
	TEST_ASSERT(preferences.load_preferences(), "The native loader rejected an absent canonical map")
	TEST_ASSERT_EQUAL(length(preferences.pref_job_slots), 0, "An absent canonical map used legacy or in-memory fallback")
	TEST_ASSERT(!("job_assigned_profiles" in preferences.savefile.get_entry()), "Saving an absent canonical map retained the legacy format")
	TEST_ASSERT_EQUAL(json_encode(preferences.savefile.get_entry("character2")), json_encode(character), "Preference IO changed a saved character")
	TEST_ASSERT_EQUAL(preferences.savefile.get_entry("unrelated_setting"), "keep", "Preference IO changed an unrelated setting")

/datum/unit_test/native_job_profile_storage_boundary/Destroy()
	release_job_player_fixtures()
	return ..()

/// The donor-only name override must preserve the original middleware for ordinary jobs.
/datum/unit_test/native_job_profile_display_name
	var/datum/job/seclown_fixture
	var/datum/job/previous_type_job
	var/datum/job/previous_name_job
	var/had_type_entry = FALSE
	var/had_name_entry = FALSE

/datum/unit_test/native_job_profile_display_name/Run()
	var/datum/job/registered_seclown = SSjob.type_occupations[/datum/job/donor/security_clown]
	if(!registered_seclown || !SSjob.name_occupations[registered_seclown.title])
		seclown_fixture = allocate(/datum/job/donor/security_clown)
		had_type_entry = seclown_fixture.type in SSjob.type_occupations
		had_name_entry = seclown_fixture.title in SSjob.name_occupations
		previous_type_job = SSjob.type_occupations[seclown_fixture.type]
		previous_name_job = SSjob.name_occupations[seclown_fixture.title]
		SSjob.type_occupations[seclown_fixture.type] = seclown_fixture
		SSjob.name_occupations[seclown_fixture.title] = seclown_fixture
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	var/datum/preference_middleware/names/names = locate(/datum/preference_middleware/names) in preferences.middleware
	TEST_ASSERT_NOTNULL(names, "The real preferences constructor did not register names middleware")
	var/list/cases = list(
		/datum/job/donor/security_clown = "clown_name",
		/datum/job/clown = "clown_name",
		/datum/job/mime = "mime_name",
		/datum/job/assistant = "real_name",
	)
	for(var/job_type, expected in cases)
		var/datum/job/job = SSjob.get_job_type(job_type)
		TEST_ASSERT_NOTNULL(job, "The display-name fixture job is not registered: [job_type]")
		preferences.job_preferences = list("[job.title]" = JP_HIGH)
		var/list/data = names.get_ui_data(null)
		TEST_ASSERT_EQUAL(data["name_to_use"], expected, "The display name changed for [job_type]")
	preferences.job_preferences = list()
	var/list/data = names.get_ui_data(null)
	TEST_ASSERT_EQUAL(data["name_to_use"], "real_name", "The empty job selection lost its native name fallback")

/datum/unit_test/native_job_profile_display_name/Destroy()
	if(seclown_fixture)
		if(had_type_entry)
			SSjob.type_occupations[seclown_fixture.type] = previous_type_job
		else
			SSjob.type_occupations -= seclown_fixture.type
		if(had_name_entry)
			SSjob.name_occupations[seclown_fixture.title] = previous_name_job
		else
			SSjob.name_occupations -= seclown_fixture.title
	release_job_player_fixtures()
	return ..()

// External overlay only. Include at the native unit-test assertion anchor, after the pinned fixtures.

/datum/unit_test/native_job_latejoin_offline_signal_once
	var/datum/job/test_job
	var/signal_calls = 0

/datum/unit_test/native_job_latejoin_offline_signal_once/Run()
	test_job = allocate(/datum/job/assistant)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	var/datum/client_interface/player = allocate(/datum/client_interface)
	body.mock_client = player
	player.mob = body
	// The headless interface does not provide a real BYOND client; this covers the offline branch only.
	TEST_ASSERT_NULL(body.client, "The headless fixture unexpectedly has a real client")
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, PROC_REF(clear_mock_after_signal))
	test_job.after_latejoin_spawn(body)
	TEST_ASSERT_EQUAL(signal_calls, 1, "Latejoin emitted its native global signal more than once")
	TEST_ASSERT_NULL(body.mock_client, "The native global signal did not execute its fixture listener")
	test_job.after_latejoin_spawn(body)
	TEST_ASSERT_EQUAL(signal_calls, 2, "An offline character lost its native global spawn signal")

/datum/unit_test/native_job_latejoin_offline_signal_once/proc/clear_mock_after_signal(datum/source, datum/job/job, mob/living/spawning)
	SIGNAL_HANDLER
	if(job != test_job)
		return
	signal_calls++
	if(spawning.mock_client)
		spawning.mock_client.mob = null
		spawning.mock_client = null

/datum/unit_test/native_job_latejoin_offline_signal_once/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN)
	release_job_player_fixtures()
	return ..()

/mob/living/carbon/human/consistent/prisoner_ancestor_test
	var/id_update_calls = 0

/mob/living/carbon/human/consistent/prisoner_ancestor_test/update_ID_card()
	id_update_calls++
	return ..()

/datum/unit_test/prisoner_native_ancestor_and_dormant_join/Run()
	var/datum/job/prisoner/job = allocate(/datum/job/prisoner)
	var/mob/living/carbon/human/consistent/prisoner_ancestor_test/body = allocate(/mob/living/carbon/human/consistent/prisoner_ancestor_test)
	body.mind_initialize()
	allocated += body.mind
	body.mind.set_assigned_role(job)
	body.job = job.title
	body.prisoner_crime = /datum/prisoner_crime/negligence::name
	var/datum/record/crew/older_record = allocate(/datum/record/crew)
	older_record.name = body.real_name
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREWMEMBER_JOINED, body, job.title)
	TEST_ASSERT_EQUAL(length(older_record.crimes), 0, "The dormant native global handler wrote to a name-matched record")
	TEST_ASSERT(!body.prisoner_record_registered, "The global join signal consumed the exact-record callback")
	// Native human ID slots require a uniform; the consistent fixture starts without one.
	var/obj/item/clothing/under/rank/prisoner/uniform = allocate(/obj/item/clothing/under/rank/prisoner)
	TEST_ASSERT(body.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING), "The ancestor fixture could not equip its prerequisite uniform")
	var/obj/item/card/id/advanced/prisoner/card = allocate(/obj/item/card/id/advanced/prisoner)
	TEST_ASSERT(body.equip_to_slot_if_possible(card, ITEM_SLOT_ID), "The ancestor fixture could not equip its ID")
	card.registered_name = "Unset native ID"
	body.id_update_calls = 0
	var/datum/outfit/job/prisoner/outfit = allocate(/datum/outfit/job/prisoner)
	outfit.post_equip(body, visuals_only = FALSE)
	TEST_ASSERT_EQUAL(card.registered_name, body.real_name, "Direct ancestor dispatch skipped native ID registration")
	TEST_ASSERT(HAS_TRAIT(card, TRAIT_JOB_FIRST_ID_CARD), "Direct ancestor dispatch skipped the native first-ID trait")
	TEST_ASSERT_EQUAL(body.id_update_calls, 1, "Prisoner post_equip repeated or skipped common native job ID setup")
	TEST_ASSERT(body.prisoner_tattoos_applied, "Live equipment did not commit its once-only Prisoner effects")

/datum/unit_test/prisoner_native_ancestor_and_dormant_join/Destroy()
	release_job_player_fixtures()
	return ..()

/mob/living/silicon/ai/name_lookup_disconnect_test/apply_pref_name(preference_type, client/requesting_client)
	// This is the exact boundary where an appearance-ban SQL lookup may yield and lose its client.
	del(requesting_client)
	return FALSE

/datum/unit_test/native_ai_name_lookup_disconnect/Run()
	var/datum/job/job = allocate(/datum/job/ai)
	job.spawn_type = /mob/living/silicon/ai/name_lookup_disconnect_test
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	player.mob = lobby
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	lobby.mind.active = FALSE
	lobby.mind.set_assigned_role(job)
	var/datum/mind/mind = lobby.mind
	lobby.assigned_character = player.prefs.select_job_character(job)
	TEST_ASSERT_NULL(job.get_spawn_mob(player, run_loc_floor_bottom_left), "The AI preference disconnect returned an unfinished body")
	TEST_ASSERT_NULL(player, "The name lookup fixture did not actually disconnect its client")
	TEST_ASSERT_EQUAL(lobby.mind, mind, "A name-lookup disconnect lost the AI lobby mind")
	TEST_ASSERT_EQUAL(mind.current, lobby, "A name-lookup disconnect retained its mind in the deleted AI")

/datum/unit_test/native_ai_name_lookup_disconnect/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/unit_test/job_character_greeting_entrypoint/Run()
	var/datum/job/ordinary = allocate(/datum/job/assistant)
	TEST_ASSERT_EQUAL(ordinary.get_spawn_message(null), ordinary.get_spawn_message(), "The alternate greeting changed an ordinary native job")
	// Actor variant resolution and spawn context do not depend on startup donor admission flags.
	var/datum/job/donor/actor/job = allocate(/datum/job/donor/actor)
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("Actor" = "painter")), "Could not select the painter variant")
	job.prepare_spawn_character(body, player.prefs)
	TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("Actor" = "default")), "Could not change the subsequently active variant")
	var/message = job.get_spawn_message(body)
	TEST_ASSERT(findtext(message, job.variant_information[/datum/outfit/job/donor/actor/painter]), "The greeting did not receive the body's committed painter context")
	TEST_ASSERT(!findtext(message, job.important_information), "The greeting used the subsequently active variant instead of the created body")

/datum/unit_test/job_character_greeting_entrypoint/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/controller/subsystem/job/random_preference_boundary_test
	name = "External random preference fixture"
	ss_flags = SS_NO_INIT | SS_NO_FIRE
	dependencies = list()
	dependents = list()
	var/eligibility_calls = 0
	var/last_debug_prefix
	var/last_add_to_log
	var/remove_preference_during_check = FALSE
	var/eligibility_result = JOB_AVAILABLE
	var/assignment_calls = 0

/datum/controller/subsystem/job/random_preference_boundary_test/New()
	// MC enumerates this subtype too. Never enter SUBSYSTEM_DEF(job)/New or replace the live SSjob.
	return

/datum/controller/subsystem/job/random_preference_boundary_test/check_job_eligibility(mob/dead/new_player/player, datum/job/possible_job, debug_prefix = "", add_job_to_log = FALSE, latejoin = FALSE)
	eligibility_calls++
	last_debug_prefix = debug_prefix
	last_add_to_log = add_job_to_log
	if(remove_preference_during_check)
		var/client/requester = GET_CLIENT(player)
		requester.prefs.job_preferences -= possible_job.title
	return eligibility_result

/datum/controller/subsystem/job/random_preference_boundary_test/assign_role(mob/dead/new_player/player, datum/job/job, latejoin = FALSE, do_eligibility_checks = TRUE, is_debug_dummy = FALSE)
	assignment_calls++
	return TRUE

/datum/unit_test/random_job_current_preference_boundary/Run()
	var/datum/controller/subsystem/job/live_jobs = SSjob
	var/datum/controller/subsystem/job/random_preference_boundary_test/controller = allocate(/datum/controller/subsystem/job/random_preference_boundary_test)
	TEST_ASSERT_EQUAL(SSjob, live_jobs, "Allocating the isolated fixture replaced the live Jobs subsystem")
	var/datum/job/job = allocate(/datum/job/donor/actor)
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	lobby.mock_client = player
	player.mob = lobby
	player.prefs.job_preferences[job.title] = JP_LOW
	TEST_ASSERT_EQUAL(controller.check_random_job_eligibility(lobby, job, "GRJ live", add_job_to_log = TRUE), JOB_AVAILABLE, "An explicitly enabled random candidate was rejected")
	TEST_ASSERT_EQUAL(controller.eligibility_calls, 1, "An enabled random candidate ran eligibility more than once")
	TEST_ASSERT_EQUAL(controller.last_debug_prefix, "GRJ live", "The fallback helper lost the native debug prefix")
	TEST_ASSERT(controller.last_add_to_log, "The fallback helper lost native job logging")
	player.prefs.job_preferences -= job.title
	TEST_ASSERT_EQUAL(controller.check_random_job_eligibility(lobby, job), JOB_UNAVAILABLE_GENERIC, "Random fallback retained a preference snapshot from a previous candidate")
	TEST_ASSERT_EQUAL(controller.eligibility_calls, 1, "A disabled explicit preference entered yielding eligibility")
	var/datum/job/ordinary = allocate(/datum/job/assistant)
	TEST_ASSERT_EQUAL(controller.check_random_job_eligibility(lobby, ordinary), JOB_AVAILABLE, "An ordinary job incorrectly required an explicit preference")
	TEST_ASSERT_EQUAL(controller.eligibility_calls, 2, "An ordinary random candidate did not run native eligibility once")
	controller.remove_preference_during_check = TRUE
	player.prefs.job_preferences[job.title] = JP_LOW
	TEST_ASSERT_EQUAL(controller.check_random_job_eligibility(lobby, job), JOB_UNAVAILABLE_GENERIC, "Fallback accepted an explicit preference disabled during its eligibility lookup")
	TEST_ASSERT_EQUAL(controller.eligibility_calls, 3, "Rechecking the current preference repeated the yielding eligibility lookup")
	controller.eligibility_result = JOB_UNAVAILABLE_BANNED
	player.prefs.job_preferences[job.title] = JP_LOW
	TEST_ASSERT_EQUAL(controller.check_random_job_eligibility(lobby, job), JOB_UNAVAILABLE_BANNED, "The post-lookup preference check replaced a native eligibility rejection")
	TEST_ASSERT_EQUAL(controller.eligibility_calls, 4, "A native rejection ran yielding eligibility more than once")
	controller.eligibility_result = JOB_AVAILABLE
	controller.all_occupations = list(job, ordinary)
	controller.joinable_occupations = list(job)
	controller.type_occupations[/datum/job/assistant] = ordinary
	job.current_positions = 0
	job.spawn_positions = 1
	for(var/prioritized in list(FALSE, TRUE))
		player.prefs.job_preferences[job.title] = JP_LOW
		var/calls_before = controller.eligibility_calls
		var/assigned = prioritized ? controller.give_priority_job(lobby) : controller.give_random_job(lobby)
		TEST_ASSERT(!assigned, "The [prioritized ? "priority" : "native random"] consumer accepted a preference disabled during eligibility")
		TEST_ASSERT_EQUAL(controller.eligibility_calls, calls_before + 1, "The [prioritized ? "priority" : "native random"] consumer repeated or skipped eligibility")
		TEST_ASSERT_EQUAL(controller.assignment_calls, 0, "The [prioritized ? "priority" : "native random"] consumer entered assignment after the preference was disabled")
	TEST_ASSERT_EQUAL(SSjob, live_jobs, "The isolated random consumers replaced the live Jobs subsystem")

/datum/unit_test/random_job_current_preference_boundary/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/unit_test/entry_history_handover_once/Run()
	for(var/connection_at_body in list(FALSE, TRUE))
		var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
		var/datum/client_interface/player = allocate(/datum/client_interface)
		player.prefs = allocate(/datum/preferences, player)
		player.prefs.default_slot = 1
		var/datum/persistent_client/connection = player.persistent_client
		lobby.spawning = TRUE
		lobby.PossessByPlayer(player.key)
		connection.set_mob(connection_at_body ? body : lobby)
		lobby.mind = allocate(/datum/mind)
		lobby.mind.key = player.key
		lobby.mind.set_current(lobby)
		lobby.mind.active = FALSE
		lobby.mind.set_assigned_role(SSjob.get_job_type(/datum/job/cargo_technician))
		lobby.mind.transfer_to(body)
		lobby.new_character = body
		lobby.assigned_character = allocate(/datum/job_character_selection)
		lobby.assigned_character.slot = 2
		connection.set_client(null)
		TEST_ASSERT_NULL(connection.client, "The handover fixture did not disconnect its player")
		TEST_ASSERT_NULL(connection.joined_as_slots, "Construction wrote history before handover")
		TEST_ASSERT_EQUAL(lobby.transfer_character(), body, "The real native handover did not return its prepared body")
		TEST_ASSERT(QDELETED(lobby), "History was not committed after native lobby destruction")
		TEST_ASSERT_NULL(lobby.transfer_character(), "A repeated handover returned an already transferred character")
		TEST_ASSERT_EQUAL(length(connection.joined_as_slots), 1, "A repeated handover committed history twice")
		TEST_ASSERT_EQUAL(connection.joined_as_slots[1], "2", "History did not use the committed character slot")
		body.key = null
		var/mob/dead/new_player/cancelled_lobby = allocate(/mob/dead/new_player)
		connection.set_mob(cancelled_lobby)
		cancelled_lobby.assigned_character = allocate(/datum/job_character_selection)
		cancelled_lobby.assigned_character.slot = 3
		cancelled_lobby.new_character = allocate(/mob/living/carbon/human/consistent)
		cancelled_lobby.cancel_character_spawn()
		TEST_ASSERT_NULL(cancelled_lobby.new_character, "Rollback retained a character pending handover")
		TEST_ASSERT_NULL(cancelled_lobby.transfer_character(), "Rollback still allowed a character handover")
		TEST_ASSERT_EQUAL(length(connection.joined_as_slots), 1, "Rollback wrote another history entry")

/datum/unit_test/entry_history_handover_once/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/preferences/core_minimum_color_fixture
	var/color_calls = 0
	var/color_result = TRUE
	var/list/color_params
	var/datum/tgui/color_ui

/datum/preferences/core_minimum_color_fixture/set_character_color(list/params, datum/tgui/ui)
	color_calls++
	color_params = params
	color_ui = ui
	return color_result

/datum/preferences/core_minimum_color_fixture/Destroy()
	color_params = null
	color_ui = null
	return ..()

/// Native preferences construction discovers this middleware exactly like product middleware.
/datum/preference_middleware/core_minimum_color_probe
	action_delegations = list("core_minimum_parent_probe" = PROC_REF(probe))
	var/calls = 0
	var/list/received_params

/datum/preference_middleware/core_minimum_color_probe/proc/probe(list/params, mob/user)
	calls++
	received_params = params
	return TRUE

/datum/preference_middleware/core_minimum_color_probe/Destroy()
	received_params = null
	return ..()

/datum/unit_test/core_minimum_color_entrypoint
	var/datum/preferences/core_minimum_color_fixture/preferences
	var/signals_received = 0
	var/last_action

/datum/unit_test/core_minimum_color_entrypoint/proc/observe_action(datum/source, mob/user, action, list/params)
	SIGNAL_HANDLER
	signals_received++
	last_action = action

/datum/unit_test/core_minimum_color_entrypoint/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	preferences = allocate(/datum/preferences/core_minimum_color_fixture, player)
	player.prefs = preferences
	var/mob/dead/new_player/user = allocate(/mob/dead/new_player)
	user.mock_client = player
	player.mob = user
	var/datum/tgui/ui = allocate(/datum/tgui, user, preferences, "PreferencesMenu")
	var/datum/preference_middleware/core_minimum_color_probe/probe = locate(/datum/preference_middleware/core_minimum_color_probe) in preferences.middleware
	TEST_ASSERT_NOTNULL(probe, "The real preferences constructor did not register the action probe")
	RegisterSignal(preferences, COMSIG_UI_ACT, PROC_REF(observe_action))
	var/list/params = list("preference" = "not_a_registered_preference")

	ui.status = UI_INTERACTIVE
	TEST_ASSERT(preferences.ui_act("set_color_preference", params, ui, ui.state), "Interactive color input did not reach the modular helper")
	TEST_ASSERT_EQUAL(signals_received, 1, "Interactive color input did not emit exactly one native signal")
	TEST_ASSERT_EQUAL(last_action, "set_color_preference", "The native signal received a renamed color action")
	TEST_ASSERT_EQUAL(preferences.color_calls, 1, "Interactive color input did not call the helper exactly once")
	TEST_ASSERT_EQUAL(preferences.color_params, params, "Color dispatch changed the payload")
	TEST_ASSERT_EQUAL(preferences.color_ui, ui, "Color dispatch lost the originating UI")
	TEST_ASSERT_EQUAL(probe.calls, 0, "Color input leaked into middleware delegation")

	preferences.color_result = FALSE
	TEST_ASSERT(!preferences.ui_act("set_color_preference", params, ui, ui.state), "Color dispatch lost the helper's FALSE result")
	TEST_ASSERT_EQUAL(signals_received, 2, "Rejected color input did not emit exactly one additional signal")
	TEST_ASSERT_EQUAL(preferences.color_calls, 2, "Rejected color input did not call the helper exactly once")

	for(var/blocked_status in list(UI_CLOSE, UI_DISABLED, UI_UPDATE))
		ui.status = blocked_status
		var/signals_before = signals_received
		TEST_ASSERT(preferences.ui_act("set_color_preference", params, ui, ui.state), "A blocked UI did not preserve the native handled result")
		TEST_ASSERT_EQUAL(signals_received, signals_before + 1, "A blocked UI did not preserve one native signal")
		TEST_ASSERT_EQUAL(preferences.color_calls, 2, "A blocked UI entered the modal helper")
	var/signals_before = signals_received
	TEST_ASSERT(preferences.ui_act("set_color_preference", params, null, null), "A missing UI bypassed native authorization")
	TEST_ASSERT_EQUAL(signals_received, signals_before + 1, "A missing UI did not preserve one native signal")
	TEST_ASSERT_EQUAL(preferences.color_calls, 2, "A missing UI entered the modal helper")

	ui.status = UI_INTERACTIVE
	signals_before = signals_received
	TEST_ASSERT(preferences.ui_act("core_minimum_parent_probe", params, ui, ui.state), "An unrelated action did not reach native preferences delegation")
	TEST_ASSERT_EQUAL(signals_received, signals_before + 1, "An unrelated action called its native parent more than once")
	TEST_ASSERT_EQUAL(last_action, "core_minimum_parent_probe", "An unrelated action was changed before the native signal")
	TEST_ASSERT_EQUAL(probe.calls, 1, "An unrelated action was not delegated exactly once")
	TEST_ASSERT_EQUAL(probe.received_params, params, "Native delegation changed an unrelated payload")
	TEST_ASSERT_EQUAL(preferences.color_calls, 2, "An unrelated action entered the modal helper")

	signals_before = signals_received
	TEST_ASSERT(!preferences.ui_act("core_minimum_unknown_action", params, ui, ui.state), "An unknown action lost the native FALSE result")
	TEST_ASSERT_EQUAL(signals_received, signals_before + 1, "An unknown action did not call its native parent exactly once")
	TEST_ASSERT_EQUAL(probe.calls, 1, "An unknown action reached unrelated middleware delegation")
	TEST_ASSERT_EQUAL(preferences.color_calls, 2, "An unknown action entered the modal helper")

	ui.status = UI_UPDATE
	signals_before = signals_received
	TEST_ASSERT(preferences.ui_act("core_minimum_parent_probe", params, ui, ui.state), "A blocked unrelated action lost native authorization")
	TEST_ASSERT_EQUAL(signals_received, signals_before + 1, "A blocked unrelated action did not preserve one native signal")
	TEST_ASSERT_EQUAL(probe.calls, 1, "A blocked unrelated action reached middleware delegation")

/datum/unit_test/core_minimum_color_entrypoint/Destroy()
	if(preferences)
		UnregisterSignal(preferences, COMSIG_UI_ACT)
	release_job_player_fixtures()
	preferences = null
	return ..()

/datum/unit_test/entry_error_messages/Run()
	var/job_title = SSjob.get_job_type(/datum/job/cargo_technician).title
	TEST_ASSERT_EQUAL(get_job_unavailable_error_message(JOB_AVAILABLE, job_title), "[job_title_ru(job_title)] доступна для выбора.", "A native availability message changed")
	TEST_ASSERT_EQUAL(get_job_unavailable_error_message(JOB_UNAVAILABLE_AGE, job_title), "Ваш персонаж недостаточно стар для игры за [job_title_ru(job_title)].", "A known native rejection fell through to module messages")
	// The existing TEMP late helper resolves module-owned codes after their definitions are included.
	var/profile_error = expected_character_profile_error()
	var/profile_message = get_additional_job_unavailable_message(profile_error)
	TEST_ASSERT_NOTEQUAL(profile_message, GENERIC_JOB_UNAVAILABLE_ERROR, "The fixture did not select a module rejection")
	TEST_ASSERT_EQUAL(get_job_unavailable_error_message(profile_error, job_title), profile_message, "A module rejection did not reach the native formatter fallback")
	TEST_ASSERT_EQUAL(get_job_unavailable_error_message(-12345, job_title), GENERIC_JOB_UNAVAILABLE_ERROR, "An unknown rejection lost the generic fallback")

// External overlay only, after the pinned job-player and roundstart-cancellation fixtures.

/datum/unit_test/dynamic_roundstart_cancellation/blood_worm_selected_profile_entrypoint/Run()
	allow_job_fixture_species(list(/datum/species/plasmaman))
	queue_before = SSdynamic.queued_rulesets
	prevented_before = SSjob.prevented_occupations
	forced_before = SSjob.forced_occupations
	lobby_before = GLOB.new_player_list
	spawns_before = GLOB.jobspawn_overrides
	SSdynamic.queued_rulesets = list()
	SSjob.prevented_occupations = list()
	SSjob.forced_occupations = list()
	GLOB.new_player_list = list()
	var/datum/job/job = SSjob.get_job_type(/datum/job/assistant)
	TEST_ASSERT_NOTNULL(job, "The host fixture has no canonical Assistant job")
	var/datum/dynamic_ruleset/roundstart/blood_worm/ruleset = allocate(/datum/dynamic_ruleset/roundstart/blood_worm)
	var/mob/dead/new_player/player = make_player(ruleset.pref_flag, job)
	var/datum/client_interface/requester = player.mock_client
	var/datum/preferences/preferences = requester.prefs
	preferences.max_save_slots = 2
	preferences.pref_job_slots = list(job.title = 2)
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], FALSE), "Could not select the assigned host profile")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_PLASMAMAN), "Could not set the active bloodless profile")
	preferences.savefile.set_entry("character2", list("real_name" = "Selected Human Host", "age" = 35, "species" = SPECIES_HUMAN))
	TEST_ASSERT(ruleset.is_valid_candidate(player, requester), "The dormant native active-profile veto rejected an assigned human host")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Candidate admission switched the active character")
	TEST_ASSERT_EQUAL(preferences.read_preference(/datum/preference/choiced/species), /datum/species/plasmaman, "Candidate admission changed the active species")
	var/datum/dynamic_ruleset/roundstart/traitor/other_ruleset = allocate(/datum/dynamic_ruleset/roundstart/traitor)
	other_ruleset.selected_minds = list(player.mind)
	SSdynamic.queued_rulesets = list(other_ruleset)
	TEST_ASSERT(!ruleset.is_valid_candidate(player, requester), "Concrete ancestor dispatch skipped the native queued-candidate veto")
	SSdynamic.queued_rulesets = list()
	var/datum/mind/saved_mind = player.mind
	player.mind = null
	var/mindless_accepted = ruleset.is_valid_candidate(player, requester)
	player.mind = saved_mind
	TEST_ASSERT(!mindless_accepted, "Concrete ancestor dispatch skipped the native missing-mind veto")
	preferences.job_preferences = list()
	TEST_ASSERT(!ruleset.is_valid_candidate(player, requester), "Concrete ancestor dispatch skipped the modular roundstart crew-preference veto")
	preferences.job_preferences = list(job.title = JP_HIGH)
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN), "Could not restore the active human profile")
	preferences.savefile.set_entry("character2", list("real_name" = "Selected Bloodless Host", "age" = 35, "species" = SPECIES_PLASMAMAN))
	TEST_ASSERT(!ruleset.is_valid_candidate(player, requester), "The active human profile bypassed the assigned bloodless-host veto")

// This job stays outside the live registries and uses the real SSjob eligibility parent.
/datum/job/eligibility_entrypoint_test
	title = "External eligibility boundary fixture"
	job_flags = NONE
	required_character_age = 30
	var/account_allowed = TRUE
	var/playtime_remaining = 0
	var/account_checks = 0
	var/playtime_checks = 0
	var/profile_checks = 0

/datum/job/eligibility_entrypoint_test/config_check()
	return FALSE

/datum/job/eligibility_entrypoint_test/player_old_enough(client/player)
	account_checks++
	return account_allowed

/datum/job/eligibility_entrypoint_test/required_playtime_remaining(client/player)
	playtime_checks++
	return playtime_remaining

/datum/job/eligibility_entrypoint_test/get_join_lock_reason(client/player)
	profile_checks++
	return ..()

/datum/unit_test/job_eligibility_native_parent_boundary
	var/mob/dead/new_player/lobby
	var/datum/client_interface/requester
	var/datum/client_interface/replacement
	var/ban_lookup_completed = FALSE

/datum/unit_test/job_eligibility_native_parent_boundary/Run()
	var/datum/job/eligibility_entrypoint_test/job = allocate(/datum/job/eligibility_entrypoint_test)
	requester = allocate(/datum/client_interface)
	requester.ban_cache = list()
	requester.prefs = allocate(/datum/preferences, requester)
	var/datum/preferences/preferences = requester.prefs
	preferences.default_slot = 1
	preferences.max_save_slots = 2
	preferences.load_and_save = FALSE
	preferences.path = null
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.pref_job_slots = list(job.title = 2)
	preferences.savefile.set_entry("character2", list("real_name" = "Selected Adult", "age" = 40, "species" = SPECIES_HUMAN))
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 18), "Could not set the younger active profile")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], FALSE), "Could not enable assigned roundstart profiles")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], FALSE), "Could not enable assigned latejoin profiles")
	lobby = allocate(/mob/dead/new_player)
	lobby.mock_client = requester
	requester.mob = lobby
	lobby.key = requester.key
	lobby.mind = allocate(/datum/mind)
	lobby.mind.set_current(lobby)
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(null, job), JOB_UNAVAILABLE_GENERIC, "The wrapper passed a null lobby to the native parent")
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, null), JOB_UNAVAILABLE_GENERIC, "The wrapper passed a null job to the native parent")
	job.account_allowed = FALSE
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job), JOB_UNAVAILABLE_ACCOUNTAGE, "Selected-profile admission replaced an early native account refusal")
	TEST_ASSERT_EQUAL(job.account_checks, 1, "Eligibility repeated the native account check")
	TEST_ASSERT_EQUAL(job.playtime_checks, 0, "Eligibility continued after the native account refusal")
	TEST_ASSERT_EQUAL(job.profile_checks, 0, "Profile admission ran after the native account refusal")
	job.account_allowed = TRUE
	job.playtime_remaining = 1
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job), JOB_UNAVAILABLE_PLAYTIME, "Selected-profile admission replaced a native playtime refusal")
	TEST_ASSERT_EQUAL(job.account_checks, 2, "Eligibility repeated the native account check before playtime refusal")
	TEST_ASSERT_EQUAL(job.playtime_checks, 1, "Eligibility repeated the native playtime check")
	TEST_ASSERT_EQUAL(job.profile_checks, 0, "Profile admission ran after the native playtime refusal")
	job.playtime_remaining = 0
	requester.ban_cache = list(job.title)
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job), JOB_UNAVAILABLE_BANNED, "Selected-profile admission replaced a native role-ban refusal")
	TEST_ASSERT_EQUAL(job.profile_checks, 0, "Profile admission ran after the native role-ban refusal")
	requester.ban_cache = list()
	var/account_before = job.account_checks
	var/playtime_before = job.playtime_checks
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job), JOB_AVAILABLE, "The dormant native age check rejected the selected adult using the younger active profile")
	TEST_ASSERT_EQUAL(job.account_checks, account_before + 1, "Successful admission repeated the native account check")
	TEST_ASSERT_EQUAL(job.playtime_checks, playtime_before + 1, "Successful admission repeated the native playtime check")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Eligibility switched the active character")
	preferences.savefile.set_entry("character2", list("real_name" = "Selected Young Character", "age" = 18, "species" = SPECIES_HUMAN))
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 40), "Could not set the older active profile")
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job), JOB_UNAVAILABLE_AGE, "The active adult profile bypassed the selected younger character's age requirement")
	preferences.savefile.set_entry("character2", list("real_name" = "Selected Adult", "age" = 40, "species" = SPECIES_HUMAN))
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 18), "Could not restore the younger active profile")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], TRUE), "Could not separate the roundstart and latejoin policies")
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job, latejoin = FALSE), JOB_UNAVAILABLE_AGE, "The wrapper ignored the roundstart current-profile policy")
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job, latejoin = TRUE), JOB_AVAILABLE, "The wrapper lost its named latejoin argument while calling the native four-argument parent")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], FALSE), "Could not restore the assigned profile")
	replacement = allocate(/datum/client_interface)
	replacement.prefs = allocate(/datum/preferences, replacement)
	replacement.ban_cache = list()
	// Exercise the real native ban-cache wait, simulating an in-flight DB request without a DB server.
	requester.ban_cache = null
	requester.ban_cache_start = REALTIMEOFDAY + 1 MINUTES
	var/profiles_before = job.profile_checks
	addtimer(CALLBACK(src, PROC_REF(complete_ban_lookup_with_new_requester)), 1)
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(lobby, job), JOB_UNAVAILABLE_GENERIC, "A requester swapped during the native ban lookup reached selected-profile admission")
	TEST_ASSERT(ban_lookup_completed, "The fixture did not reach the native ban-cache wait")
	TEST_ASSERT_EQUAL(job.profile_checks, profiles_before, "The wrapper evaluated a replacement requester's profile after the yielding lookup")

/datum/unit_test/job_eligibility_native_parent_boundary/proc/complete_ban_lookup_with_new_requester()
	requester.mob = null
	lobby.mock_client = replacement
	replacement.mob = lobby
	requester.ban_cache = list()
	ban_lookup_completed = TRUE

/datum/unit_test/job_eligibility_native_parent_boundary/Destroy()
	release_job_player_fixtures()
	return ..()
