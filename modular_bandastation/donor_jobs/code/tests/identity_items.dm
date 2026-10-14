/// Source role requirements, independent of the outfit's declared PDA fields.
/datum/unit_test/donor_role_pdas/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/loadout], null)
	var/list/cases = list(
		list(/datum/job/donor/casino, "default", ITEM_SLOT_BELT, /obj/item/modular_computer/pda/crew/bar),
		list(/datum/job/donor/wrestler, "default", ITEM_SLOT_BELT, /obj/item/modular_computer/pda/crew/curator),
		list(/datum/job/donor/uncertain, "default", ITEM_SLOT_BELT, /obj/item/modular_computer/pda/crew/curator),
		list(/datum/job/donor/cleaning_manager, "title_fb98757975", ITEM_SLOT_LPOCKET, /obj/item/modular_computer/pda/crew),
	)
	for(var/list/test_case as anything in cases)
		var/datum/job/job = allocate(test_case[1])
		player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("[job.title]" = test_case[2]))
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
		body.mind_initialize()
		allocated += body.mind
		body.mind.set_assigned_role(job)
		body.job = job.title
		job.prepare_spawn_character(body, player.prefs)
		body.dress_up_as_job(job, player_client = player, consistent = TRUE)
		var/obj/item/modular_computer/pda/pda = body.get_item_by_slot(test_case[3])
		TEST_ASSERT_EQUAL(pda?.type, test_case[4], "[job.title] lost its required native PDA")
		TEST_ASSERT_EQUAL(pda.saved_identification, body.real_name, "[job.title] PDA was not registered to its wearer")
		job.after_spawn(body, null)
		var/datum/job_variant/variant = job.resolve_donor_variant(test_case[2])
		TEST_ASSERT_EQUAL(pda.saved_job, variant.public_title, "The PDA displays another variant")
		TEST_ASSERT_EQUAL(body.mind.assigned_role, job, "The public PDA name replaced the canonical job")
		qdel(body)

/datum/unit_test/donor_role_pdas/Destroy()
	release_job_player_fixtures()
	return ..()

/// Verify the native renderer actually displays every source badge after registration.
/datum/unit_test/donor_id_appearances/Run()
	var/list/required = list(
		/datum/id_trim/job/donor_barber = "trim_barber",
		/datum/id_trim/job/donor_bath = "trim_bath",
		/datum/id_trim/job/donor_casino = "trim_casino",
		/datum/id_trim/job/donor_waiter = "trim_waiter",
		/datum/id_trim/job/donor_acolyte = "trim_acolyte",
		/datum/id_trim/job/cargo_technician/donor_deliverer = "trim_deliverer",
		/datum/id_trim/job/donor_wrestler = "trim_wrestler",
		/datum/id_trim/job/donor_actor/painter = "trim_painter",
		/datum/id_trim/job/donor_musican = "trim_musican",
		/datum/id_trim/job/donor_actor = "trim_actor",
		/datum/id_trim/job/donor_administrator = "trim_administrator",
		/datum/id_trim/job/donor_tourist_tsf = "trim_tourist_tsf",
		/datum/id_trim/job/donor_tourist_ussp = "trim_tourist_ussp",
		/datum/id_trim/job/donor_cleaning_manager = "trim_cleaning_manager",
		/datum/id_trim/job/donor_cleaning_manager/apprentice = "trim_apprentice",
		/datum/id_trim/job/donor_guard = "trim_guard",
		/datum/id_trim/job/donor_migrant = "trim_migrant",
		/datum/id_trim/job/donor_uncertain = "trim_uncertain",
		/datum/id_trim/job/donor_adjutant = "trim_adjutant",
		/datum/id_trim/job/donor_adjutant/butler = "trim_butler",
		/datum/id_trim/job/donor_adjutant/maid = "trim_maid",
		/datum/id_trim/job/donor_representative_tsf = "trim_representative_tsf",
		/datum/id_trim/job/donor_representative_ussp = "trim_representative_ussp",
		/datum/id_trim/job/donor_dealer = "trim_dealer",
		/datum/id_trim/job/donor_vip_guest = "trim_vip_guest",
		/datum/id_trim/job/donor_banker = "trim_banker",
		/datum/id_trim/job/donor_seclown = "trim_seclown",
	)
	for(var/trim_path in required)
		var/obj/item/card/id/advanced/card = allocate(/obj/item/card/id/advanced)
		allocated += card.registered_account
		card.clear_account()
		card.registered_name = "Civilian donor ID test"
		TEST_ASSERT(SSid_access.apply_trim_to_card(card, trim_path, copy_access = FALSE), "Native ID painter rejected [trim_path]")
		var/icon/rendered = getFlatIcon(card)
		var/icon/expected = icon('modular_bandastation/donor_jobs/icons/id_trims.dmi', required[trim_path])
		var/visible = 0
		for(var/x in 8 to 15)
			for(var/y in 13 to 20)
				var/pixel = expected.GetPixel(x, y)
				if(isnull(pixel))
					continue
				visible++
				TEST_ASSERT_EQUAL(rendered.GetPixel(x, y), pixel, "[trim_path] source badge was replaced by a native overlay")
		TEST_ASSERT_EQUAL(visible, 60, "[trim_path] source badge is missing pixels")
		TEST_ASSERT_EQUAL(card.registered_name, "Civilian donor ID test", "The cosmetic trim replaced ID ownership")
		TEST_ASSERT_EQUAL(length(card.access), 0, "A cosmetic ID change granted access")
		TEST_ASSERT_NULL(card.registered_account, "A cosmetic ID change created a bank account")
		TEST_ASSERT_EQUAL(card.icon_state, "card_grey", "The civilian trim selected a privileged ID base")
		qdel(card)
