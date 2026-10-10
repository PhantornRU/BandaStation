/datum/unit_test/donor_id_templates/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/machinery/modular_computer/preset/id/station_console = allocate(/obj/machinery/modular_computer/preset/id)
	var/obj/machinery/modular_computer/preset/id/centcom/centcom_console = allocate(/obj/machinery/modular_computer/preset/id/centcom)
	var/datum/computer_file/program/card_mod/station_program = station_console.cpu.find_file_by_name("plexagonidwriter")
	var/datum/computer_file/program/card_mod/centcom_program = centcom_console.cpu.find_file_by_name("plexagonidwriter")
	var/obj/item/card/id/advanced/auth_card = allocate(/obj/item/card/id/advanced)
	auth_card.access = list(ACCESS_CHANGE_IDS)
	TEST_ASSERT(station_program.authenticate(user, auth_card), "The ordinary station ID program could not authenticate")
	TEST_ASSERT(centcom_program.authenticate(user, auth_card), "The ordinary CentCom ID program could not authenticate")
	var/donor_jobs_enabled = CONFIG_GET(flag/donor_jobs_enabled)
	for(var/trim_path in subtypesof(/datum/id_trim/job))
		var/datum/id_trim/job/trim = SSid_access.trim_singletons_by_path[trim_path]
		if(!trim.centcom_template)
			continue
		if(donor_jobs_enabled)
			TEST_ASSERT_NOTNULL(trim.job, "The enabled donor job for [trim.assignment] was not registered")
			TEST_ASSERT(trim_path in centcom_program.job_templates, "CentCom cannot issue [trim.assignment] through native authentication")
		else
			TEST_ASSERT(!(trim_path in centcom_program.job_templates), "A disabled donor role leaked into CentCom templates")
		TEST_ASSERT(!(trim_path in station_program.job_templates), "A CentCom-only role leaked into station templates")

	var/obj/item/card/id/advanced/blank_card = allocate(/obj/item/card/id/advanced)
	allocated += blank_card.registered_account
	blank_card.clear_account()
	centcom_console.cpu.stored_id = auth_card
	centcom_console.cpu.alt_stored_id = blank_card
	var/datum/id_trim/job/barber = SSid_access.trim_singletons_by_path[/datum/id_trim/job/donor_barber]
	if(donor_jobs_enabled)
		TEST_ASSERT(length(barber.access), "The registered Barber trim has no real accesses")
		TEST_ASSERT(SSid_access.apply_trim_to_card(blank_card, /datum/id_trim/job/donor_barber, copy_access = FALSE), "The native ID painter could not apply the Barber trim")
		TEST_ASSERT_EQUAL(length(blank_card.access), 0, "Applying the blank trim already issued access")
		world.push_usr(user, CALLBACK(centcom_program, TYPE_PROC_REF(/datum/computer_file/program/card_mod, ui_act), "PRG_template", list("name" = barber.assignment)))
		TEST_ASSERT_EQUAL(length(barber.access - blank_card.access), 0, "The native CentCom template lost its station accesses")
	TEST_ASSERT_NULL(blank_card.registered_account, "Issuing access created an unrelated bank account")
	TEST_ASSERT_EQUAL(length(blank_card.access & CENTCOM_ACCESS), 0, "A station donor template granted CentCom authority")
	blank_card.clear_access()
	station_console.cpu.stored_id = auth_card
	station_console.cpu.alt_stored_id = blank_card
	world.push_usr(user, CALLBACK(station_program, TYPE_PROC_REF(/datum/computer_file/program/card_mod, ui_act), "PRG_access", list("access_target" = ACCESS_BAR)))
	TEST_ASSERT(ACCESS_BAR in blank_card.access, "Native manual station access requires an unrelated donor entitlement")
