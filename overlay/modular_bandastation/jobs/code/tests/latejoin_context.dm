/mob/dead/new_player/latejoin_profile_context_test
	var/availability_calls = 0
	var/change_on_call
	var/change_kind

/mob/dead/new_player/latejoin_profile_context_test/IsJobUnavailable(rank, latejoin = FALSE)
	. = ..()
	if(++availability_calls != change_on_call)
		return
	var/client/player = GET_CLIENT(src)
	switch(change_kind)
		if("active_slot")
			player.prefs.load_character(2)
		if("assignment")
			player.prefs.set_job_character_slot(rank, 2)
		if("current_toggle")
			player.prefs.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], TRUE)

/datum/unit_test/latejoin_profile_context
	var/datum/job/job
	var/positions_before
	var/total_before
	var/state_before
	var/list/queue_before
	var/lag_before
	var/undocked_before
	var/safe_before
	var/hard_cap_before
	var/extreme_cap_before

/datum/unit_test/latejoin_profile_context/Run()
	state_before = SSticker.current_state
	queue_before = SSticker.queued_players
	lag_before = SSlag_switch.measures[DISABLE_NON_OBSJOBS]
	undocked_before = CONFIG_GET(flag/arrivals_shuttle_require_undocked)
	safe_before = CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin)
	hard_cap_before = CONFIG_GET(number/hard_popcap)
	extreme_cap_before = CONFIG_GET(number/extreme_popcap)
	SSticker.current_state = GAME_STATE_PLAYING
	SSticker.queued_players = list()
	SSlag_switch.measures[DISABLE_NON_OBSJOBS] = FALSE
	CONFIG_SET(flag/arrivals_shuttle_require_undocked, FALSE)
	CONFIG_SET(flag/arrivals_shuttle_require_safe_latejoin, FALSE)
	CONFIG_SET(number/hard_popcap, 0)
	CONFIG_SET(number/extreme_popcap, 0)
	job = SSjob.get_job_type(/datum/job/cargo_technician)
	positions_before = job.current_positions
	total_before = job.total_positions
	job.total_positions = -1

	for(var/boundary in list(1, 2))
		for(var/change_kind in list("active_slot", "assignment", "current_toggle"))
			var/datum/client_interface/player = allocate(/datum/client_interface/entry_admission_test)
			player.ban_cache = list()
			player.prefs = allocate(/datum/preferences, player)
			var/datum/preferences/preferences = player.prefs
			preferences.load_and_save = FALSE
			preferences.path = null
			QDEL_NULL(preferences.savefile)
			preferences.savefile = allocate(/datum/json_savefile)
			preferences.default_slot = 1
			preferences.max_save_slots = 2
			preferences.pref_job_slots = list()
			preferences.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], 40)
			preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
			preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/late_join_always_current_slot], FALSE)
			// Obtain the character schema version from the native writer, not a second constant.
			preferences.path = "unit-test"
			TEST_ASSERT(preferences.save_character(), "Could not prepare the source character")
			preferences.path = null
			var/list/second_profile = preferences.savefile.get_entry("character1")
			second_profile = second_profile.Copy()
			second_profile["real_name"] = "Second Entry Character"
			preferences.savefile.set_entry("character2", second_profile)
			var/mob/dead/new_player/latejoin_profile_context_test/lobby = allocate(/mob/dead/new_player/latejoin_profile_context_test)
			lobby.mock_client = player
			player.mob = lobby
			lobby.key = player.key
			lobby.mind = allocate(/datum/mind)
			lobby.mind.set_current(lobby)
			lobby.change_on_call = boundary
			lobby.change_kind = change_kind
			var/datum/latejoin_profile_snapshot/unchanged_context = preferences.capture_latejoin_profile(job.title)
			TEST_ASSERT(preferences.is_latejoin_profile_current(job.title, unchanged_context), "An unchanged request became stale")
			TEST_ASSERT(!lobby.AttemptLateSpawn(job.title), "A stale request spawned a different profile: [change_kind]/[boundary]")
			TEST_ASSERT_EQUAL(lobby.availability_calls, boundary, "The test did not reach its intended eligibility boundary")
			TEST_ASSERT(!preferences.is_latejoin_profile_current(job.title, unchanged_context), "The changed context was not detected")
			TEST_ASSERT_NULL(lobby.assigned_character, "A rejected request committed a profile")
			TEST_ASSERT_NULL(lobby.new_character, "A rejected request created a body")
			TEST_ASSERT_EQUAL(lobby.mind.assigned_role.type, /datum/job/unassigned, "A rejected request assigned a role")
			TEST_ASSERT_EQUAL(job.current_positions, positions_before, "A rejected request changed vacancies")
			TEST_ASSERT(!lobby.spawning, "A rejected request retained its attempt guard")

/datum/unit_test/latejoin_profile_context/Destroy()
	if(job)
		job.current_positions = positions_before
		job.total_positions = total_before
	if(!isnull(state_before))
		SSticker.current_state = state_before
		SSticker.queued_players = queue_before
		SSlag_switch.measures[DISABLE_NON_OBSJOBS] = lag_before
		CONFIG_SET(flag/arrivals_shuttle_require_undocked, undocked_before)
		CONFIG_SET(flag/arrivals_shuttle_require_safe_latejoin, safe_before)
		CONFIG_SET(number/hard_popcap, hard_cap_before)
		CONFIG_SET(number/extreme_popcap, extreme_cap_before)
	release_job_player_fixtures()
	return ..()
