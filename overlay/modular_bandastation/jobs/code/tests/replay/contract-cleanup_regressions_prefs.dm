/// Observe the actual native selection boundary, never replace its dispatcher or authorization.
/datum/latejoin_menu/contract_cleanup_fixture
	var/selection_calls = 0

/datum/latejoin_menu/contract_cleanup_fixture/is_latejoin_selection_current(mob/dead/new_player/owner, list/params, datum/latejoin_profile_snapshot/context)
	selection_calls++
	return ..()

/datum/unit_test/contract_cleanup_latejoin_authorization
	var/datum/latejoin_menu/contract_cleanup_fixture/menu
	var/datum/tgui/action_ui
	var/signals_received = 0
	var/block_on_signal = TRUE

/datum/unit_test/contract_cleanup_latejoin_authorization/proc/observe_action(datum/source, mob/user, action, list/params)
	SIGNAL_HANDLER
	signals_received++
	if(block_on_signal)
		action_ui.status = UI_UPDATE

/datum/unit_test/contract_cleanup_latejoin_authorization/Run()
	var/mob/dead/new_player/owner = allocate(/mob/dead/new_player)
	menu = allocate(/datum/latejoin_menu/contract_cleanup_fixture)
	action_ui = allocate(/datum/tgui, owner, menu, "JobSelection")
	RegisterSignal(menu, COMSIG_UI_ACT, PROC_REF(observe_action))
	owner.jobs_menu_mounted = FALSE
	for(var/action in list("ui_mounted_with_no_bluescreen", "select_job", "contract_cleanup_unknown"))
		action_ui.status = UI_INTERACTIVE
		var/signals_before = signals_received
		TEST_ASSERT(menu.ui_act(action, list("job" = "Random"), action_ui, GLOB.new_player_state), "Signal-blocked action lost the native handled result")
		TEST_ASSERT_EQUAL(signals_received, signals_before + 1, "Signal-blocked action did not emit exactly one signal")
		TEST_ASSERT_EQUAL(action_ui.status, UI_UPDATE, "The signal fixture did not alter UI status")
		TEST_ASSERT_EQUAL(menu.selection_calls, 0, "Signal-blocked action entered selected-job admission")
		TEST_ASSERT(!owner.jobs_menu_mounted, "Signal-blocked mounted action changed lobby state")
	block_on_signal = FALSE
	for(var/blocked_status in list(UI_CLOSE, UI_DISABLED, UI_UPDATE))
		action_ui.status = blocked_status
		var/signals_before = signals_received
		TEST_ASSERT(menu.ui_act("ui_mounted_with_no_bluescreen", list(), action_ui, GLOB.new_player_state), "Blocked action lost the native handled result")
		TEST_ASSERT_EQUAL(signals_received, signals_before + 1, "Blocked action did not emit exactly one signal")
		TEST_ASSERT(!owner.jobs_menu_mounted, "Blocked mounted action changed lobby state")
		TEST_ASSERT_EQUAL(menu.selection_calls, 0, "Blocked action entered selected-job admission")

/datum/unit_test/contract_cleanup_latejoin_authorization/Destroy()
	if(menu)
		UnregisterSignal(menu, COMSIG_UI_ACT)
	action_ui = null
	menu = null
	return ..()

/// Localization must never become a second representation of an admission code.
/datum/job/contract_cleanup_availability_fixture
	title = "Contract cleanup fixture"
	total_positions = 3
	current_positions = 1

/datum/job/contract_cleanup_availability_fixture/get_join_lock_reason(client/player)
	return "Fixture-specific lock"

/datum/job/contract_cleanup_availability_fixture/config_check()
	return FALSE

/datum/unit_test/contract_cleanup_availability_code/Run()
	var/datum/job/job = allocate(/datum/job/contract_cleanup_availability_fixture)
	var/datum/latejoin_menu/menu = allocate(/datum/latejoin_menu)
	var/mob/dead/new_player/owner = allocate(/mob/dead/new_player)
	var/list/department = list("open_slots" = 0)
	var/list/row = list("availability" = expected_job_lock_error(), "unavailable_reason" = "A changed translation")
	menu.extend_job_character_data(job, owner, row, department)
	TEST_ASSERT_EQUAL(row["unavailable_reason"], "Fixture-specific lock", "The computed lock code was lost when its message changed")
	TEST_ASSERT_EQUAL(department["open_slots"], 0, "A locked row increased available positions")

	var/profile_message = get_job_unavailable_error_message(expected_job_lock_error(), job.title)
	row = list("availability" = expected_character_profile_error(), "unavailable_reason" = profile_message)
	menu.extend_job_character_data(job, owner, row, department)
	TEST_ASSERT_EQUAL(row["unavailable_reason"], profile_message, "A coincidentally equal message was mistaken for a lock code")
	TEST_ASSERT_EQUAL(department["open_slots"], 0, "A rejected character increased available positions")

	row = list("availability" = JOB_AVAILABLE)
	menu.extend_job_character_data(job, owner, row, department)
	TEST_ASSERT_EQUAL(department["open_slots"], 2, "The available row did not contribute its remaining positions")
	TEST_ASSERT(isnull(get_additional_job_unavailable_message(-424242)), "An unknown module code stole the native generic fallback")
	TEST_ASSERT_EQUAL(get_job_unavailable_error_message(-424242, job.title), GENERIC_JOB_UNAVAILABLE_ERROR, "The native formatter lost its explicit generic fallback")

/datum/unit_test/contract_cleanup_canonical_job_protocol/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	var/datum/preferences/preferences = allocate(/datum/preferences, player)
	player.prefs = preferences
	var/datum/preference_middleware/jobs/middleware = locate(/datum/preference_middleware/jobs) in preferences.middleware
	TEST_ASSERT_NOTNULL(middleware, "Native preferences did not register its jobs middleware")
	TEST_ASSERT(!("set_job_to_profile" in middleware.action_delegations), "The disabled legacy action is still delegated")
	TEST_ASSERT(hascall(middleware, "set_job_to_profile"), "The native handler definition was not preserved")
	TEST_ASSERT("job_assigned_profiles" in preferences.vars, "The native assignment declaration was not preserved")
	TEST_ASSERT_EQUAL(length(preferences.job_assigned_profiles), 0, "The compatibility field owns active assignments")
	preferences.job_preferences = list("Assistant" = JP_HIGH)
	preferences.pref_job_slots = list("Assistant" = 2)
	TEST_ASSERT(preferences.job_assigned_profiles != preferences.pref_job_slots, "Compatibility and canonical assignments alias")
	var/canonical_before = json_encode(preferences.pref_job_slots)
	var/legacy_before = json_encode(preferences.job_assigned_profiles)
	TEST_ASSERT(!middleware.set_job_to_profile(list("job" = "Assistant", "profile" = 3), null), "A direct old handler call was accepted")
	TEST_ASSERT_EQUAL(json_encode(preferences.pref_job_slots), canonical_before, "A direct old handler call changed canonical assignments")
	TEST_ASSERT_EQUAL(json_encode(preferences.job_assigned_profiles), legacy_before, "A direct old handler call changed compatibility state")
	var/list/data = middleware.get_ui_data(null)
	var/list/rows = data["job_preferences"]
	TEST_ASSERT_EQUAL(length(rows), 1, "Canonical priority serialization added a legacy-only row")
	var/list/row = rows[1]
	TEST_ASSERT_EQUAL(row["job"], "Assistant", "Canonical priority serialization changed the job")
	TEST_ASSERT_EQUAL(row["priority"], JP_HIGH, "Canonical priority serialization changed the priority")
	TEST_ASSERT(!("assigned_profile_slot" in row), "The UI protocol still emits a legacy profile field")

	var/mob/dead/new_player/user = allocate(/mob/dead/new_player)
	user.mock_client = player
	player.mob = user
	var/datum/tgui/ui = allocate(/datum/tgui, user, preferences, "PreferencesMenu")
	ui.status = UI_INTERACTIVE
	TEST_ASSERT(!preferences.ui_act("set_job_to_profile", list("job" = "Assistant", "profile" = 3), ui, ui.state), "A forged legacy action was accepted")
	TEST_ASSERT_EQUAL(preferences.pref_job_slots["Assistant"], 2, "A forged legacy action changed canonical assignments")
	TEST_ASSERT_EQUAL(json_encode(preferences.job_assigned_profiles), legacy_before, "A forged legacy action activated compatibility state")

/datum/unit_test/contract_cleanup_canonical_job_protocol/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/unit_test/contract_cleanup_latejoin_offline_selection/Run()
	var/mob/dead/new_player/owner = allocate(/mob/dead/new_player)
	var/datum/latejoin_menu/menu = allocate(/datum/latejoin_menu)
	var/datum/tgui/ui = allocate(/datum/tgui, owner, menu, "JobSelection")
	ui.status = UI_INTERACTIVE
	TEST_ASSERT(menu.ui_act("select_job", list("job" = "Random"), ui, GLOB.new_player_state), "The native selected-profile dispatcher did not reject an offline lobby")
	TEST_ASSERT(!owner.spawning, "Offline selected-profile input entered spawning")
	TEST_ASSERT_NULL(owner.assigned_character, "Offline selected-profile input committed a character")
