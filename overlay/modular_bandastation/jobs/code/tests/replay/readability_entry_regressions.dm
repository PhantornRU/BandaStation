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
