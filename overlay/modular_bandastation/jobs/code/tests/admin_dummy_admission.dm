// External-only regression for the native Spawn Debug Full Crew consumer.
// Exercise the real assign_role/final admission boundary, without replacing either proc.
/datum/unit_test/native_admin_dummy_admission
	var/datum/job/job
	var/datum/job/unassigned_job
	var/positions_before
	var/list/unassigned_before

/datum/unit_test/native_admin_dummy_admission/Run()
	job = SSjob.get_job_type(/datum/job/cargo_technician)
	unassigned_job = SSjob.get_job_type(/datum/job/unassigned)
	TEST_ASSERT_NOTNULL(job, "The native Cargo Technician job is not registered")
	TEST_ASSERT_NOTNULL(unassigned_job, "The native Unassigned job is not registered")
	positions_before = job.current_positions
	unassigned_before = SSjob.unassigned
	SSjob.unassigned = unassigned_before ? unassigned_before.Copy() : list()

	// An ordinary prechecked caller must still supply a player profile. Merely
	// being clientless cannot implicitly opt in to the admin tool's exception.
	var/mob/dead/new_player/dummy = new_lobby()
	TEST_ASSERT_NULL(GET_CLIENT(dummy), "The admin fixture unexpectedly has a client")
	TEST_ASSERT(!SSjob.assign_role(dummy, job, do_eligibility_checks = FALSE), "An ordinary clientless assignment bypassed final profile admission")
	TEST_ASSERT_EQUAL(dummy.mind.assigned_role, unassigned_job, "A denied ordinary assignment changed the canonical role")
	TEST_ASSERT_EQUAL(job.current_positions, positions_before, "A denied ordinary assignment occupied a vacancy")
	TEST_ASSERT(dummy in SSjob.unassigned, "A denied ordinary assignment removed its lobby from unassigned")

	// The built-in admin command creates a new lobby and initializes its mind,
	// then opts in once. It does not manufacture a preferences/client datum.
	TEST_ASSERT(SSjob.assign_role(dummy, job, do_eligibility_checks = FALSE, is_debug_dummy = TRUE), "The explicit native admin dummy could not receive its job")
	TEST_ASSERT_EQUAL(dummy.mind.assigned_role, job, "The explicit admin assignment did not set the native role")
	TEST_ASSERT_EQUAL(job.current_positions, positions_before + 1, "The explicit admin assignment did not occupy exactly one vacancy")
	TEST_ASSERT(!(dummy in SSjob.unassigned), "The explicit admin assignment retained its lobby in unassigned")
	TEST_ASSERT_NULL(dummy.assigned_character, "A clientless admin dummy acquired a fabricated player profile")

	// A dummy permission is not a way to resume a player's in-flight attempt,
	// take an existing selected profile, or enter through the latejoin path.
	for(var/scenario in list("latejoin", "spawning", "profile_bound", "offline_player"))
		var/mob/dead/new_player/rejected = new_lobby()
		switch(scenario)
			if("spawning")
				rejected.spawning = TRUE
			if("profile_bound")
				rejected.assigned_character = allocate(/datum/job_character_selection)
				rejected.assigned_character.job_type = job.type
				rejected.assigned_character.slot = 2
			if("offline_player")
				// A native offline key is player identity even without a client.
				rejected.key = "external_admin_dummy_admission_offline"
				TEST_ASSERT_NOTNULL(rejected.key, "The offline player fixture lost its native key")
		var/datum/job_character_selection/selection_before = rejected.assigned_character
		var/spawning_before = rejected.spawning
		TEST_ASSERT(!SSjob.assign_role(rejected, job, latejoin = (scenario == "latejoin"), do_eligibility_checks = FALSE, is_debug_dummy = TRUE), "An explicit dummy flag admitted the [scenario] player context")
		TEST_ASSERT_EQUAL(rejected.mind.assigned_role, unassigned_job, "The denied [scenario] context changed its canonical role")
		TEST_ASSERT_EQUAL(job.current_positions, positions_before + 1, "The denied [scenario] context changed occupied vacancies")
		TEST_ASSERT(rejected in SSjob.unassigned, "The denied [scenario] context was removed from unassigned")
		TEST_ASSERT_EQUAL(rejected.assigned_character, selection_before, "The denied [scenario] context discarded or replaced its selected profile")
		TEST_ASSERT_EQUAL(rejected.spawning, spawning_before, "The denied [scenario] context changed an existing spawn attempt")

	// A disconnected lobby can retain a mind identity while its client, key and
	// transient selection are absent. Normal callers still do not get an exception.
	var/mob/dead/new_player/disconnected = new_lobby()
	disconnected.mind.key = "external_admin_dummy_admission_disconnected"
	TEST_ASSERT_NULL(GET_CLIENT(disconnected), "The disconnected fixture unexpectedly has a client")
	TEST_ASSERT_NULL(disconnected.key, "The disconnected fixture retained a connected mob key")
	TEST_ASSERT(!SSjob.assign_role(disconnected, job, do_eligibility_checks = FALSE), "A disconnected player's clientless lobby implicitly received the admin exception")
	TEST_ASSERT_EQUAL(disconnected.mind.assigned_role, unassigned_job, "A denied disconnected player changed the canonical role")
	TEST_ASSERT_EQUAL(job.current_positions, positions_before + 1, "A denied disconnected player occupied another vacancy")
	TEST_ASSERT(disconnected in SSjob.unassigned, "A denied disconnected player was removed from unassigned")

/datum/unit_test/native_admin_dummy_admission/proc/new_lobby()
	var/mob/dead/new_player/lobby = allocate(/mob/dead/new_player)
	// Use the same native mind lifecycle as spawn_debug_full_crew.
	lobby.mind_initialize()
	allocated += lobby.mind
	SSjob.unassigned |= lobby
	return lobby

/datum/unit_test/native_admin_dummy_admission/Destroy()
	// Detach minds/keys before allocated mobs are deleted. Native mind/mob
	// Destroy removes their SSticker.minds and GLOB.new_player_list entries.
	release_job_player_fixtures()
	if(!isnull(positions_before))
		job.current_positions = positions_before
		SSjob.unassigned = unassigned_before
	return ..()
