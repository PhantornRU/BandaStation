/// The source inventory includes admiral clothing and both space pairs, beyond the two donor outfits.
/datum/unit_test/ussp_clothing_assets/Run()
	var/list/required = list(
		list(/obj/item/clothing/under/costume/soviet/ussp, ITEM_SLOT_ICLOTHING, "soviet", "soviet"),
		list(/obj/item/clothing/under/costume/soviet/ussp/officer, ITEM_SLOT_ICLOTHING, "sovietofficer", "sovietofficer"),
		list(/obj/item/clothing/under/costume/soviet/ussp/admiral, ITEM_SLOT_ICLOTHING, "sovietadmiral", "sovietadmiral"),
		list(/obj/item/clothing/head/hats/ussp/classic, ITEM_SLOT_HEAD, "ussp_pilotka", "sovietsidecap"),
		list(/obj/item/clothing/head/hats/ussp/classic/officer, ITEM_SLOT_HEAD, "sovietofficerhat", "sovietofficerhat"),
		list(/obj/item/clothing/head/hats/ussp/classic/admiral, ITEM_SLOT_HEAD, "sovietadmiralhat", "sovietadmiralhat"),
		list(/obj/item/clothing/suit/costume/soviet/ussp, ITEM_SLOT_OCLOTHING, "sovietcoat", "sovietcoat"),
		list(/obj/item/clothing/suit/costume/soviet/ussp/officer, ITEM_SLOT_OCLOTHING, "sovietofficercoat", "sovietofficercoat"),
		list(/obj/item/clothing/head/helmet/space/ussp, ITEM_SLOT_HEAD, "hardsuit0-soviet", "hardsuit0-soviet"),
		list(/obj/item/clothing/suit/space/ussp, ITEM_SLOT_OCLOTHING, "hardsuit-soviet", "hardsuit-soviet"),
		list(/obj/item/clothing/head/helmet/space/ussp/commander, ITEM_SLOT_HEAD, "hardsuit0-soviet-commander", "hardsuit0-soviet-commander"),
		list(/obj/item/clothing/suit/space/ussp/commander, ITEM_SLOT_OCLOTHING, "hardsuit-soviet-commander", "hardsuit-soviet-commander"),
	)
	for(var/list/test_case as anything in required)
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/clothing/item = allocate(test_case[1])
		TEST_ASSERT_EQUAL(item.icon_state, test_case[3], "[item.type] lost its required source appearance")
		TEST_ASSERT_EQUAL(item.worn_icon_state || item.icon_state, test_case[4], "[item.type] uses the wrong worn state")
		if(item.type == /obj/item/clothing/head/hats/ussp/classic)
			TEST_ASSERT_EQUAL(item.icon, 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi', "The USSP sidecap duplicated its native inventory icon")
			TEST_ASSERT_EQUAL(item.worn_icon, 'modular_bandastation/donor_jobs/icons/ussp_hats_worn.dmi', "The USSP sidecap lost its distinct source worn appearance")
		TEST_ASSERT(item.icon_state in icon_states(item.icon), "[item.type] has no inventory sprite")
		TEST_ASSERT(test_case[4] in icon_states(item.worn_icon), "[item.type] has no worn sprite")
		TEST_ASSERT(item.inhand_icon_state in icon_states(item.lefthand_file), "[item.type] is invisible in the left hand")
		TEST_ASSERT(item.inhand_icon_state in icon_states(item.righthand_file), "[item.type] is invisible in the right hand")
		for(var/direction in GLOB.cardinals)
			var/icon/worn = icon(item.worn_icon, test_case[4], direction)
			var/visible = FALSE
			for(var/x in 1 to worn.Width())
				for(var/y in 1 to worn.Height())
					visible ||= !isnull(worn.GetPixel(x, y))
			TEST_ASSERT(visible, "[item.type] is transparent when facing [direction]")
		TEST_ASSERT(body.equip_to_slot_if_possible(item, test_case[2]), "[item.type] cannot be equipped in its clothing slot")
		TEST_ASSERT_EQUAL(body.get_item_by_slot(test_case[2]), item, "[item.type] did not reach its native equipment slot")
		qdel(body)

/// Imported appearances must still use the native seal and powered thermal regulator.
/datum/unit_test/ussp_space_clothing/Run()
	var/obj/item/clothing/head/helmet/space/native_helmet = allocate(/obj/item/clothing/head/helmet/space)
	var/obj/item/clothing/suit/space/native_suit = allocate(/obj/item/clothing/suit/space)
	var/list/pairs = list(
		list(/obj/item/clothing/head/helmet/space/ussp, /obj/item/clothing/suit/space/ussp),
		list(/obj/item/clothing/head/helmet/space/ussp/commander, /obj/item/clothing/suit/space/ussp/commander),
	)
	for(var/list/space_pair as anything in pairs)
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/clothing/head/helmet/space/helmet = allocate(space_pair[1])
		var/obj/item/clothing/suit/space/space_suit = allocate(space_pair[2])
		for(var/armor_category in ARMOR_LIST_ALL)
			TEST_ASSERT_EQUAL(helmet.get_armor_rating(armor_category), native_helmet.get_armor_rating(armor_category), "USSP helmet changed native [armor_category] protection")
			TEST_ASSERT_EQUAL(space_suit.get_armor_rating(armor_category), native_suit.get_armor_rating(armor_category), "USSP space suit changed native [armor_category] protection")
		TEST_ASSERT(body.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD), "Could not wear the USSP space helmet")
		TEST_ASSERT(!body.is_atmos_sealed(), "The helmet alone sealed the whole body")
		TEST_ASSERT(body.equip_to_slot_if_possible(space_suit, ITEM_SLOT_OCLOTHING), "Could not wear the USSP space suit")
		TEST_ASSERT(body.is_atmos_sealed(check_hands = TRUE), "The native USSP space pair does not provide its seal")
		STOP_PROCESSING(SSobj, space_suit)
		TEST_ASSERT_NOTNULL(space_suit.cell, "Native space suit initialization did not create the thermal regulator cell")
		if(!space_suit.thermal_on)
			space_suit.toggle_spacesuit(body)
		TEST_ASSERT(space_suit.thermal_on, "The native thermal regulator did not turn on")
		var/charge_before = space_suit.cell.charge
		space_suit.process(1)
		TEST_ASSERT(space_suit.cell.charge < charge_before, "The worn space suit bypassed native thermal power consumption")
		space_suit.cell.use(space_suit.cell.charge)
		space_suit.process(1)
		TEST_ASSERT(!space_suit.thermal_on, "The empty USSP suit bypassed native thermal shutdown")
		qdel(helmet)
		TEST_ASSERT(!body.is_atmos_sealed(), "Removing the helmet left a stale pressure seal")
		qdel(body)
