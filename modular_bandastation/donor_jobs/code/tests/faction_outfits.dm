/// Independent role requirements: removing a declared outfit slot must not erase its expectation.
/datum/unit_test/donor_faction_outfits/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/loadout], null)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
	var/list/required = list(
		list(/datum/job/donor/tourist_tsf, /obj/item/clothing/under/rank/tsf/donor/marine, /obj/item/clothing/head/soft/donor_tsf, null),
		list(/datum/job/donor/representative_tsf, /obj/item/clothing/under/rank/tsf/donor/representative, /obj/item/clothing/head/beret/donor_tsf, null),
		list(/datum/job/donor/tourist_ussp, /obj/item/clothing/under/costume/soviet/ussp, /obj/item/clothing/head/hats/ussp/classic, /obj/item/clothing/suit/costume/soviet/ussp),
		list(/datum/job/donor/representative_ussp, /obj/item/clothing/under/costume/soviet/ussp/officer, /obj/item/clothing/head/hats/ussp/classic/officer, /obj/item/clothing/suit/costume/soviet/ussp/officer),
	)
	for(var/list/test_case as anything in required)
		var/datum/job/job = allocate(test_case[1])
		var/list/selection = list()
		selection[job.title] = "default"
		TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], selection), "Could not select the faction's default outfit")
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
		body.mind_initialize()
		allocated += body.mind
		body.mind.set_assigned_role(job)
		body.job = job.title
		job.prepare_spawn_character(body, player.prefs)
		body.dress_up_as_job(job, player_client = player, consistent = TRUE)
		TEST_ASSERT_EQUAL(body.w_uniform?.type, test_case[2], "[job.title] lost its original faction uniform")
		TEST_ASSERT_EQUAL(body.head?.type, test_case[3], "[job.title] lost its original faction headwear")
		TEST_ASSERT_EQUAL(body.wear_suit?.type, test_case[4], "[job.title] changed its required faction outerwear")
		TEST_ASSERT_NOTNULL(body.get_idcard(hand_first = FALSE), "The faction outfit bypassed native ID issuance")
		var/obj/item/clothing/under/uniform = body.w_uniform
		TEST_ASSERT((uniform.worn_icon_state || uniform.icon_state) in icon_states(uniform.worn_icon), "[job.title] has no worn uniform appearance")
		TEST_ASSERT(body.head.icon_state in icon_states(body.head.worn_icon), "[job.title] has no worn headwear appearance")
		var/mob/living/carbon/human/preview = allocate(/mob/living/carbon/human/consistent)
		preview.dress_up_as_job(job, visual_only = TRUE, player_client = player, consistent = TRUE)
		TEST_ASSERT_EQUAL(preview.w_uniform?.type, test_case[2], "[job.title] preview shows another uniform")
		TEST_ASSERT_EQUAL(preview.head?.type, test_case[3], "[job.title] preview shows other headwear")
		TEST_ASSERT_EQUAL(preview.wear_suit?.type, test_case[4], "[job.title] preview shows other outerwear")
		TEST_ASSERT_NULL(preview.donor_spawn_context, "The faction preview attached a live spawn context")
		qdel(preview)
		qdel(body)

/datum/unit_test/donor_faction_outfits/Destroy()
	release_job_player_fixtures()
	return ..()
