/datum/unit_test/donor_job_hud_icons/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/list/cases = list(
		list(/datum/job/donor/security_clown, "default", "hudsecurityclown"),
		list(/datum/job/donor/barber, "default", "hudbarber"),
		list(/datum/job/donor/actor, "painter", "hudpainter"),
		list(/datum/job/donor/cleaning_manager, "apprentice", "hudapprentice"),
		list(/datum/job/donor/adjutant, "butler", "hudbutler"),
		list(/datum/job/donor/adjutant, "maid", "hudmaid"),
		list(/datum/job/prisoner, "default", "hudprisoner"),
		list(/datum/job/cargo_technician, "deliverer", "huddeliverer"),
	)
	for(var/list/test_case as anything in cases)
		var/datum/job/job = allocate(test_case[1])
		var/variant_id = test_case[2]
		var/expected_state = test_case[3]
		TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("[job.title]" = variant_id)), "Could not select the icon test variant")
		var/datum/job_character_selection/character = player.prefs.select_job_character(job)
		var/icon/actual = job.get_character_job_icon(character)
		var/icon/expected = icon('modular_bandastation/donor_jobs/icons/job_hud.dmi', expected_state)
		expected.Crop(1, 17, 8, 24)
		TEST_ASSERT_EQUAL(actual.Width(), 8, "[job.title] returned a full HUD frame instead of the isolated glyph")
		TEST_ASSERT_EQUAL(actual.Height(), 8, "[job.title] returned the wrong HUD crop")
		var/visible = FALSE
		for(var/x in 1 to 8)
			for(var/y in 1 to 8)
				var/pixel = actual.GetPixel(x, y)
				TEST_ASSERT_EQUAL(pixel, expected.GetPixel(x, y), "[job.title]/[variant_id] displayed the wrong role icon")
				visible ||= !isnull(pixel)
		TEST_ASSERT(visible, "[job.title] glyph is transparent; the source HUD coordinates were not adapted")
		TEST_ASSERT(istext(icon2base64(actual)), "[job.title] glyph cannot be sent to TGUI")
		qdel(character)

/datum/unit_test/donor_job_hud_icons/Destroy()
	release_job_player_fixtures()
	return ..()

/datum/unit_test/donor_job_landmarks
	var/list/starts_before
	var/list/overrides_before
	var/list/created_points = list()

/datum/unit_test/donor_job_landmarks/Run()
	starts_before = GLOB.start_landmarks_list
	overrides_before = GLOB.jobspawn_overrides
	GLOB.start_landmarks_list = list()
	GLOB.jobspawn_overrides = list()
	var/list/covered_jobs = list()
	for(var/landmark_type in subtypesof(/obj/effect/landmark/start/donor))
		var/obj/effect/landmark/start/definition = landmark_type
		if(initial(definition.jobspawn_override))
			continue
		// Native landmark cleanup nulls the empty list; reset the next isolated fixture.
		GLOB.jobspawn_overrides ||= list()
		var/obj/effect/landmark/start/point = allocate(landmark_type, run_loc_floor_bottom_left)
		created_points += point
		TEST_ASSERT(point.icon_state in icon_states(point.icon), "[landmark_type] is invisible in the map editor")
		var/datum/job/job
		for(var/datum/job/job_type as anything in subtypesof(/datum/job/donor))
			if(initial(job_type.title) == point.name)
				job = allocate(job_type)
				break
		TEST_ASSERT_NOTNULL(job, "[landmark_type] does not name a canonical donor job")
		job.random_spawns_possible = FALSE
		TEST_ASSERT_EQUAL(job.get_roundstart_spawn_point(), point, "Native roundstart did not consume [landmark_type]")
		TEST_ASSERT(point.used, "Native roundstart did not reserve the start landmark")
		var/override_type = text2path("[landmark_type]/override")
		TEST_ASSERT(ispath(override_type, /obj/effect/landmark/start), "[landmark_type] has no persistent override")
		var/obj/effect/landmark/start/override_point = allocate(override_type, run_loc_floor_bottom_left)
		created_points += override_point
		TEST_ASSERT(!override_point.delete_after_roundstart, "[override_type] would disappear before latejoin")
		TEST_ASSERT_EQUAL(job.get_roundstart_spawn_point(), override_point, "Native roundstart did not honor the mapped override")
		TEST_ASSERT_EQUAL(job.get_latejoin_spawn_point(), override_point, "Native latejoin did not consume the mapped override")
		qdel(point)
		qdel(override_point)
		TEST_ASSERT(!length(GLOB.jobspawn_overrides?[job.title]), "Deleted override left a stale native spawn entry")
		covered_jobs |= job.title
	TEST_ASSERT_EQUAL(length(covered_jobs), 22, "A donor job is missing its map-editor spawn type")

/datum/unit_test/donor_job_landmarks/Destroy()
	QDEL_LIST(created_points)
	if(!isnull(starts_before))
		GLOB.start_landmarks_list = starts_before
	if(!isnull(overrides_before))
		GLOB.jobspawn_overrides = overrides_before
	return ..()
