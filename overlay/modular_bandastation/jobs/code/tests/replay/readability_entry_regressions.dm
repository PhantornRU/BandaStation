// TEMP overlay only. Exercise the production context helpers without pretending a mock is a live client.
/datum/unit_test/readability_latejoin_context/proc/make_preferences()
	var/datum/client_interface/player = allocate(/datum/client_interface/entry_admission_test)
	player.prefs = allocate(/datum/preferences, player)
	var/datum/preferences/preferences = player.prefs
	preferences.load_and_save = FALSE
	preferences.path = null
	preferences.default_slot = 1
	preferences.pref_job_slots = list()
	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], FALSE)
	return preferences

/datum/unit_test/readability_latejoin_context/Run()
	var/datum/preferences/preferences = make_preferences()
	var/job_title = SSjob.get_job_type(/datum/job/cargo_technician).title
	var/other_title = SSjob.get_job_type(/datum/job/assistant).title
	preferences.pref_job_slots[job_title] = 2
	preferences.pref_job_slots[other_title] = 3
	var/datum/latejoin_profile_snapshot/job_context = preferences.capture_latejoin_profile(job_title)
	var/datum/latejoin_profile_snapshot/menu_context = preferences.capture_latejoin_profile()
	TEST_ASSERT(preferences.is_latejoin_profile_current(job_title, job_context), "An unchanged job context became stale")
	TEST_ASSERT(preferences.is_latejoin_profile_current(null, menu_context), "An unchanged menu context became stale")

	// Mutating a different row invalidates the menu, but must not alter single-job Attempt semantics.
	preferences.pref_job_slots[other_title] = 4
	TEST_ASSERT(preferences.is_latejoin_profile_current(job_title, job_context), "An unrelated assignment invalidated a chosen job")
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, menu_context), "A menu context aliased the mutable assignment map")
	preferences.pref_job_slots[other_title] = 3
	preferences.pref_job_slots[job_title] = 4
	TEST_ASSERT(!preferences.is_latejoin_profile_current(job_title, job_context), "A chosen job ignored its changed profile")
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, menu_context), "A modal menu ignored its changed profile")
	preferences.pref_job_slots[job_title] = 2

	preferences.pref_job_slots["Added role"] = 2
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, menu_context), "A menu accepted an added assignment")
	preferences.pref_job_slots -= "Added role"
	preferences.pref_job_slots -= other_title
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, menu_context), "A menu accepted a removed assignment")
	preferences.pref_job_slots["Replaced role"] = 3
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, menu_context), "Equal map lengths hid a replaced assignment key")
	preferences.pref_job_slots -= "Replaced role"
	preferences.pref_job_slots[other_title] = 3
	preferences.pref_job_slots = preferences.pref_job_slots.Copy()
	TEST_ASSERT(preferences.is_latejoin_profile_current(null, menu_context), "An equal replacement map was compared by reference")

	preferences.default_slot = 2
	TEST_ASSERT(!preferences.is_latejoin_profile_current(job_title, job_context), "A job context ignored the edited slot")
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, menu_context), "A menu context ignored the edited slot")
	preferences.default_slot = 1
	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], TRUE)
	TEST_ASSERT(!preferences.is_latejoin_profile_current(job_title, job_context), "A job context ignored the current-slot toggle")
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, menu_context), "A modal menu ignored the current-slot toggle")
	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], FALSE)

	var/datum/preferences/replacement = make_preferences()
	replacement.pref_job_slots = preferences.pref_job_slots.Copy()
	TEST_ASSERT(!replacement.is_latejoin_profile_current(job_title, job_context), "A job context accepted replacement preferences")
	TEST_ASSERT(!replacement.is_latejoin_profile_current(null, menu_context), "A menu context accepted replacement preferences")

	preferences.pref_job_slots = null
	var/datum/latejoin_profile_snapshot/empty_context = preferences.capture_latejoin_profile()
	var/datum/latejoin_profile_snapshot/current_job_context = preferences.capture_latejoin_profile(job_title)
	preferences.pref_job_slots = list()
	TEST_ASSERT(preferences.is_latejoin_profile_current(null, empty_context), "Nil and empty menu maps were treated differently")
	TEST_ASSERT(preferences.is_latejoin_profile_current(job_title, current_job_context), "An unassigned job lost current-slot semantics")
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, null), "A missing context was accepted")
	TEST_ASSERT(!preferences.is_latejoin_profile_current(null, list()), "An incomplete context was accepted")

/datum/unit_test/readability_latejoin_context/Destroy()
	release_job_player_fixtures()
	return ..()

// External TEMP-only regression for retained native menu continuations.
// Run with the normal early unit-test assertion include; no module-owned macros are used.
// Calls the retained native fallback/random/ui_data/ui_static_data procedures.
// An eligibility seam hard-deletes the lobby at the point where SQL could resume.
// This is not a live client, real SQL wait, or an interactive modal replay.

/datum/client_interface/latejoin_harddelete_fixture
	var/interviewee = FALSE

/datum/job/latejoin_harddelete_fixture
	title = "External harddelete UI fixture"
	job_flags = JOB_HIDE_WHEN_EMPTY

/datum/job/latejoin_harddelete_fixture/config_check()
	return FALSE

/mob/dead/new_player/latejoin_harddelete_fixture
	var/datum/unit_test/native_latejoin_harddelete_ui/fixture_test

// Match GC hard deletion: native Destroy must remove every registry reference
// before del() clears caller locals. Direct del(src) would leave null list entries.
/mob/dead/new_player/latejoin_harddelete_fixture/Destroy(force)
	. = ..()
	fixture_test.destroy_calls++
	return QDEL_HINT_HARDDEL_NOW

/mob/dead/new_player/latejoin_harddelete_fixture/capture_latejoin_request(job_title = null)
	. = ..()
	if(.)
		fixture_test.context = .
		fixture_test.allocated += .

// Deliberately replace eligibility only: the native menu retains its own loops,
// availability branch, return behavior, and post-eligibility continuation.
/mob/dead/new_player/latejoin_harddelete_fixture/IsJobUnavailable(rank, latejoin = FALSE)
	return fixture_test.delete_at_eligibility(src)

/datum/latejoin_menu/latejoin_harddelete_fixture

// A headless lobby has no /client, so the real random predicate rejects it before
// eligibility. Allow only this fixture to reach the native SQL boundary. After
// hard deletion call the production predicate, testing its null-owner guard.
/datum/latejoin_menu/latejoin_harddelete_fixture/is_latejoin_random_job_allowed(mob/dead/new_player/owner, datum/job/job)
	if(istype(owner, /mob/dead/new_player/latejoin_harddelete_fixture))
		return TRUE
	return ..()

/datum/unit_test/native_latejoin_harddelete_ui
	var/datum/latejoin_profile_snapshot/context
	var/eligibility_calls = 0
	var/destroy_calls = 0
	var/eligibility_result = JOB_UNAVAILABLE_GENERIC
	var/list/departments_before
	var/list/occupations_before
	var/list/prioritized_before
	var/datum/job/first_job
	var/datum/job/second_job

/datum/unit_test/native_latejoin_harddelete_ui/proc/delete_at_eligibility(mob/dead/new_player/owner)
	eligibility_calls++
	qdel(owner)
	return eligibility_result

/datum/unit_test/native_latejoin_harddelete_ui/Run()
	departments_before = SSjob.joinable_departments
	occupations_before = SSjob.joinable_occupations
	prioritized_before = SSjob.prioritized_jobs
	first_job = allocate(/datum/job/latejoin_harddelete_fixture)
	second_job = allocate(/datum/job/latejoin_harddelete_fixture)
	first_job.title = "External harddelete UI first"
	second_job.title = "External harddelete UI second"
	SSjob.name_occupations[first_job.title] = first_job
	SSjob.name_occupations[second_job.title] = second_job
	var/datum/job_department/department = allocate(/datum/job_department/undefined)
	department.department_name = "External harddelete UI department"
	department.department_jobs = list(first_job, second_job)
	SSjob.joinable_departments = list(department)
	SSjob.joinable_occupations = list(first_job, second_job)
	SSjob.prioritized_jobs = list()
	var/datum/latejoin_menu/latejoin_harddelete_fixture/menu = allocate(/datum/latejoin_menu/latejoin_harddelete_fixture)

	for(var/route in list("fallback", "random_available", "random_rejected", "dynamic", "static"))
		var/datum/client_interface/latejoin_harddelete_fixture/player = allocate(/datum/client_interface/latejoin_harddelete_fixture)
		player.prefs = allocate(/datum/preferences, player)
		player.prefs.load_and_save = FALSE
		player.prefs.path = null
		var/mob/dead/new_player/latejoin_harddelete_fixture/owner = allocate(/mob/dead/new_player/latejoin_harddelete_fixture)
		owner.fixture_test = src
		owner.mock_client = player
		player.mob = owner
		player.persistent_client.set_mob(owner)
		owner.mind = allocate(/datum/mind)
		owner.mind.set_current(owner)
		context = null
		eligibility_calls = 0
		destroy_calls = 0
		eligibility_result = route == "random_available" ? JOB_AVAILABLE : JOB_UNAVAILABLE_GENERIC
		var/result
		switch(route)
			if("fallback")
				result = menu.fallback_ui(owner)
			if("random_available", "random_rejected")
				result = menu.get_random_job(owner)
			if("dynamic")
				result = menu.ui_data(owner)
			if("static")
				result = menu.ui_static_data(owner)
		TEST_ASSERT_NULL(owner, "The [route] fixture did not actually hard-delete the caller's local lobby")
		TEST_ASSERT_EQUAL(eligibility_calls, 1, "The [route] route queried another job after its lobby was deleted")
		TEST_ASSERT_EQUAL(destroy_calls, 1, "The [route] hard deletion skipped or repeated native Destroy cleanup")
		TEST_ASSERT(!GLOB.mob_list.Find(null), "The [route] hard deletion left a null entry in the mob registry")
		TEST_ASSERT(!GLOB.dead_mob_list.Find(null), "The [route] hard deletion left a null entry in the dead-mob registry")
		TEST_ASSERT(!GLOB.new_player_list.Find(null), "The [route] hard deletion left a null entry in the lobby registry")
		if(route == "dynamic")
			TEST_ASSERT(islist(result) && !length(result), "Dynamic UI retained rows after lobby deletion")
		else if(route == "static")
			TEST_ASSERT(islist(result) && islist(result["departments_static"]), "Static UI lost its native result shape while aborting")
		else
			TEST_ASSERT_NULL(result, "The [route] route accepted a hard-deleted lobby")
		if(context)
			// Replay the post-modal adapters directly: headless input cannot supply a reply.
			TEST_ASSERT_NULL(menu.resolve_latejoin_job_choice(owner, "reply", list("reply" = first_job.title), context), "A stale modal reply resolved after lobby deletion")
			TEST_ASSERT(!menu.is_latejoin_selection_current(owner, list("edit_slot" = context.editing_slot), context), "A selected-job reply retained a deleted owner")
			TEST_ASSERT_NULL(menu.prepare_latejoin_job_choices(owner, list(first_job.title), context), "Choice preparation accepted a deleted owner")
		TEST_ASSERT(!menu.is_latejoin_random_job_allowed(owner, first_job), "The production random predicate accepted a null owner")

/datum/unit_test/native_latejoin_harddelete_ui/Destroy()
	if(departments_before)
		SSjob.joinable_departments = departments_before
		SSjob.joinable_occupations = occupations_before
		SSjob.prioritized_jobs = prioritized_before
	if(first_job)
		SSjob.name_occupations -= first_job.title
	if(second_job)
		SSjob.name_occupations -= second_job.title
	context = null
	release_job_player_fixtures()
	return ..()

// TEMP-only: exercise the real IsJobUnavailable parent chain with different
// roundstart/current and latejoin/assigned profiles. Cached mock bans avoid SQL;
// special_check_latejoin only records native dispatch, not a connected client.
/datum/job/eligibility_entrypoint_test/latejoin_request_state
	title = "External latejoin request state fixture"
	job_flags = JOB_NEW_PLAYER_JOINABLE
	total_positions = -1
	var/special_checks = 0
	var/special_allowed = TRUE

/datum/job/eligibility_entrypoint_test/latejoin_request_state/special_check_latejoin(client/player)
	special_checks++
	return ..() && special_allowed

/datum/unit_test/latejoin_request_state_entrypoint
	var/datum/job/eligibility_entrypoint_test/latejoin_request_state/job
	var/datum/job/previous_named_job
	var/mob/dead/new_player/owner
	var/list/queue_before
	var/queue_saved = FALSE

/datum/unit_test/latejoin_request_state_entrypoint/Run()
	queue_before = SSticker.queued_players
	queue_saved = TRUE
	job = allocate(/datum/job/eligibility_entrypoint_test/latejoin_request_state)
	previous_named_job = SSjob.name_occupations[job.title]
	SSjob.name_occupations[job.title] = job
	var/datum/client_interface/requester = allocate(/datum/client_interface/entry_admission_test)
	requester.ban_cache = list()
	requester.prefs = allocate(/datum/preferences, requester)
	var/datum/preferences/preferences = requester.prefs
	preferences.load_and_save = FALSE
	preferences.path = null
	preferences.default_slot = 1
	preferences.max_save_slots = 2
	QDEL_NULL(preferences.savefile)
	preferences.savefile = allocate(/datum/json_savefile)
	preferences.pref_job_slots = list(job.title = 2)
	preferences.savefile.set_entry("character2", list("real_name" = "Assigned Adult", "age" = 40, "species" = SPECIES_HUMAN))
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 18), "Could not prepare the younger current profile")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN), "Could not prepare the current species")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/round_start_always_join_current_slot], TRUE), "Could not select current-profile roundstart policy")
	TEST_ASSERT(preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], FALSE), "Could not select assigned-profile latejoin policy")
	owner = allocate(/mob/dead/new_player)
	owner.mock_client = requester
	requester.mob = owner
	owner.key = requester.key
	owner.mind = allocate(/datum/mind)
	owner.mind.set_current(owner)

	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title), JOB_UNAVAILABLE_AGE, "A requestless omitted argument stopped using roundstart profile policy")
	TEST_ASSERT_EQUAL(job.special_checks, 0, "A requestless roundstart check dispatched latejoin policy")
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title, latejoin = TRUE), JOB_AVAILABLE, "An explicit latejoin flag without a request lost its assigned profile")
	TEST_ASSERT_EQUAL(job.special_checks, 1, "An explicit latejoin flag skipped the native special check")

	owner.latejoin_request = owner.capture_latejoin_request(job.title)
	TEST_ASSERT(owner.is_latejoin_request_current(owner.latejoin_request), "Could not prepare the active matching request")
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title), JOB_AVAILABLE, "The native omitted argument ignored its active matching latejoin request")
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title, latejoin = FALSE), JOB_AVAILABLE, "The active matching request did not supply the native latejoin context")
	TEST_ASSERT_EQUAL(job.special_checks, 3, "Matching request admission skipped or repeated native special checks")

	QDEL_NULL(owner.latejoin_request)
	owner.latejoin_request = owner.capture_latejoin_request("External unrelated request")
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title), JOB_UNAVAILABLE_AGE, "Another job's request changed omitted-argument profile policy")
	TEST_ASSERT_EQUAL(job.special_checks, 3, "Another job's request dispatched latejoin policy")
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title, latejoin = TRUE), JOB_AVAILABLE, "Another job's request suppressed an explicit latejoin flag")
	TEST_ASSERT_EQUAL(job.special_checks, 4, "Explicit latejoin with another request skipped its special check")

	QDEL_NULL(owner.latejoin_request)
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title), JOB_UNAVAILABLE_AGE, "A cleared request retained latejoin profile state")
	TEST_ASSERT_EQUAL(job.special_checks, 4, "A cleared request retained latejoin special-check state")
	owner.latejoin_request = owner.capture_latejoin_request(job.title)
	job.special_allowed = FALSE
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title), JOB_UNAVAILABLE_GENERIC, "Matching request admission bypassed the native special latejoin refusal")
	TEST_ASSERT_EQUAL(job.special_checks, 5, "Native special latejoin refusal was skipped or repeated")
	job.account_allowed = FALSE
	TEST_ASSERT_EQUAL(owner.IsJobUnavailable(job.title), JOB_UNAVAILABLE_ACCOUNTAGE, "Matching request admission replaced an early native account refusal")
	TEST_ASSERT_EQUAL(job.special_checks, 5, "An early account refusal continued into the native special check")
	TEST_ASSERT_EQUAL(job.account_checks, 9, "Request context normalization repeated or skipped native account admission")
	TEST_ASSERT_EQUAL(job.playtime_checks, 8, "Request context normalization repeated eligibility or continued after account refusal")
	TEST_ASSERT_EQUAL(preferences.default_slot, 1, "Availability loaded the assigned character instead of inspecting it")
	TEST_ASSERT_NULL(owner.assigned_character, "Availability occupied an assignment")
	TEST_ASSERT_NULL(owner.new_character, "Availability created a body")

	// Directly replay the existing post-wait guard. This is a stale-routing
	// boundary check, not a claim that this headless fixture ran arrivals/modal.
	var/list/waiting_queue = list(owner)
	SSticker.queued_players = waiting_queue
	preferences.pref_job_slots[job.title] = 1
	TEST_ASSERT(!owner.is_latejoin_request_current(owner.latejoin_request), "A changed assigned slot did not invalidate the active request")
	TEST_ASSERT(!owner.validate_latejoin_request(job.title), "The post-wait guard accepted a stale matching request")
	TEST_ASSERT_EQUAL(SSticker.queued_players, waiting_queue, "Stale request validation replaced the native queue")
	TEST_ASSERT_EQUAL(length(waiting_queue), 1, "Stale request validation dequeued the waiting player")
	TEST_ASSERT_EQUAL(waiting_queue[1], owner, "Stale request validation changed queue ownership")
	TEST_ASSERT_NULL(owner.assigned_character, "Stale request validation committed an assignment")
	TEST_ASSERT_NULL(owner.new_character, "Stale request validation created a body")
	TEST_ASSERT_EQUAL(job.current_positions, 0, "Availability or stale request validation occupied a vacancy")

/datum/unit_test/latejoin_request_state_entrypoint/Destroy()
	if(queue_saved)
		SSticker.queued_players = queue_before
	if(job)
		if(previous_named_job)
			SSjob.name_occupations[job.title] = previous_named_job
		else
			SSjob.name_occupations -= job.title
	release_job_player_fixtures()
	return ..()
