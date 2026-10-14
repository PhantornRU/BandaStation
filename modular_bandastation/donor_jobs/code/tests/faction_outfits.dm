/// Independent role requirements: removing a declared outfit slot must not erase its expectation.
/datum/unit_test/donor_faction_outfits/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/loadout], null)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
	var/list/required = list(
		list(/datum/job/donor/tourist_tsf, /obj/item/clothing/under/rank/tsf/marine, /obj/item/clothing/head/soft/donor_tsf, /obj/item/clothing/suit/hooded/wintercoat/zipup/donor_tsf),
		list(/datum/job/donor/representative_tsf, /obj/item/clothing/under/rank/tsf/commander, /obj/item/clothing/head/beret/donor_tsf, null),
		list(/datum/job/donor/tourist_ussp, /obj/item/clothing/under/costume/soviet/ussp, /obj/item/clothing/head/hats/ussp/classic, /obj/item/clothing/suit/costume/soviet/ussp),
		list(/datum/job/donor/representative_ussp, /obj/item/clothing/under/costume/soviet/ussp/officer, /obj/item/clothing/head/hats/ussp/classic/officer, /obj/item/clothing/suit/costume/soviet/ussp/officer),
	)
	var/list/required_supplies = list(
		/datum/job/donor/tourist_tsf = list(/obj/item/clothing/under/shorts/blue),
		/datum/job/donor/representative_tsf = list(/obj/item/clothing/under/shorts/blue, /obj/item/implanter/death_alarm, /obj/item/lighter, /obj/item/storage/fancy/cigarettes/cigpack_robustgold, /obj/item/storage/box/survival/mining),
		/datum/job/donor/tourist_ussp = list(/obj/item/clothing/under/shorts/red, /obj/item/clothing/head/costume/ushanka),
		/datum/job/donor/representative_ussp = list(/obj/item/clothing/under/shorts/red, /obj/item/clothing/head/costume/ushanka, /obj/item/implanter/death_alarm, /obj/item/lighter, /obj/item/storage/fancy/cigarettes/cigpack_robustgold, /obj/item/storage/box/survival/mining),
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
		if(istype(job, /datum/job/donor/tourist_tsf))
			TEST_ASSERT_EQUAL(body.wear_suit.greyscale_colors, "#02519a", "The TSF tourist lost its source hoodie palette")
			TEST_ASSERT_EQUAL(initial(body.wear_suit.icon), 'modular_bandastation/donor_jobs/icons/tsf_map_icons.dmi', "The TSF hoodie generated a preview outside its module")
			TEST_ASSERT(initial(body.wear_suit.icon_state) in icon_states(initial(body.wear_suit.icon)), "The modular TSF hoodie has no map preview")
		var/is_ussp = istype(job, /datum/job/donor/tourist_ussp) || istype(job, /datum/job/donor/representative_ussp)
		var/is_representative = istype(job, /datum/job/donor/representative_tsf) || istype(job, /datum/job/donor/representative_ussp)
		TEST_ASSERT_EQUAL(body.belt?.type, is_ussp ? /obj/item/storage/belt/fannypack/red : /obj/item/storage/belt/fannypack/black, "[job.title] lost its faction fannypack")
		TEST_ASSERT_EQUAL(body.shoes?.type, istype(job, /datum/job/donor/representative_tsf) ? /obj/item/clothing/shoes/laceup : /obj/item/clothing/shoes/combat, "[job.title] lost its required footwear")
		if(istype(job, /datum/job/donor/tourist_ussp))
			TEST_ASSERT_EQUAL(body.glasses?.type, /obj/item/clothing/glasses/sunglasses/big, "The USSP tourist lost its large sunglasses")
		if(is_representative)
			TEST_ASSERT_EQUAL(body.l_store?.type, /obj/item/melee/baton/telescopic, "The representative lost its baton")
			TEST_ASSERT(locate(/obj/item/implant/death_alarm) in body.implants, "The spare implanter replaced the representative's implanted alarm")
			TEST_ASSERT(locate(/obj/item/implant/mindshield) in body.implants, "The representative lost its mindshield")
		for(var/item_type in required_supplies[job.type])
			TEST_ASSERT_EQUAL(length(body.get_all_contents_type(item_type)), 1, "[job.title] lost or duplicated required supply [item_type]")
		var/obj/item/card/id/advanced/card = body.get_idcard(hand_first = FALSE)
		TEST_ASSERT_NOTNULL(card, "The faction outfit bypassed native ID issuance")
		TEST_ASSERT_EQUAL(length(card.access & CENTCOM_ACCESS), 0, "The civilian faction ID granted military CentCom access")
		var/obj/item/modular_computer/pda/pda = body.r_store
		TEST_ASSERT_EQUAL(pda?.type, /obj/item/modular_computer/pda/crew, "The fannypack displaced the faction PDA")
		TEST_ASSERT_EQUAL(pda.saved_identification, body.real_name, "Native PDA ownership was not initialized")
		TEST_ASSERT_EQUAL(pda.saved_job, job.title, "Native PDA profession was not initialized")
		TEST_ASSERT(body.has_language(is_ussp ? /datum/language/spinwarder : /datum/language/uncommon), "The faction character lost its existing native language")
		job.after_spawn(body, null)
		var/datum/job_variant/variant = job.resolve_donor_variant("default")
		TEST_ASSERT_EQUAL(pda.saved_job, variant.public_title, "The faction PDA lost its displayed role")
		var/obj/item/clothing/under/uniform = body.w_uniform
		TEST_ASSERT(uniform.icon_state in icon_states(uniform.worn_icon), "[job.title] has no worn uniform appearance")
		TEST_ASSERT((body.head.worn_icon_state || body.head.icon_state) in icon_states(body.head.worn_icon), "[job.title] has no worn headwear appearance")
		var/mob/living/carbon/human/preview = allocate(/mob/living/carbon/human/consistent)
		preview.dress_up_as_job(job, visual_only = TRUE, player_client = player, consistent = TRUE)
		TEST_ASSERT_EQUAL(preview.w_uniform?.type, test_case[2], "[job.title] preview shows another uniform")
		TEST_ASSERT_EQUAL(preview.head?.type, test_case[3], "[job.title] preview shows other headwear")
		TEST_ASSERT_EQUAL(preview.wear_suit?.type, test_case[4], "[job.title] preview shows other outerwear")
		TEST_ASSERT_NULL(preview.donor_spawn_context, "The faction preview attached a live spawn context")
		for(var/item_type in required_supplies[job.type])
			TEST_ASSERT_EQUAL(length(preview.get_all_contents_type(item_type)), 0, "The faction preview issued required supply [item_type]")
		qdel(preview)
		qdel(body)

/datum/unit_test/donor_faction_outfits/Destroy()
	release_job_player_fixtures()
	return ..()
