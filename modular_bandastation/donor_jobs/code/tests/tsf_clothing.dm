/// Native cap flipping and dropping must never switch to an absent worn state.
/datum/unit_test/donor_tsf_caps
	var/mob/original_usr

/datum/unit_test/donor_tsf_caps/Run()
	original_usr = usr
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	usr = body // Native soft-cap flip updates usr's worn overlay.
	var/list/caps = list(
		/obj/item/clothing/head/soft/donor_tsf,
		/obj/item/clothing/head/soft/donor_tsf/specops,
		/obj/item/clothing/head/soft/donor_tsf/command,
		/obj/item/clothing/head/soft/donor_tsf/command/specops,
	)
	for(var/cap_type in caps)
		var/obj/item/clothing/head/soft/cap = allocate(cap_type)
		TEST_ASSERT(body.equip_to_slot_if_possible(cap, ITEM_SLOT_HEAD), "Could not wear [cap_type]")
		TEST_ASSERT(cap.flipped, "The TSF marine cap did not start backwards")
		cap.flip(body)
		TEST_ASSERT(!cap.flipped, "Native cap flip did not turn the TSF cap forwards")
		TEST_ASSERT(cap.icon_state in icon_states(cap.icon), "Forwards TSF cap is invisible in inventory")
		TEST_ASSERT(cap.icon_state in icon_states(cap.worn_icon), "Forwards TSF cap is invisible when worn")
		cap.flip(body)
		TEST_ASSERT(cap.flipped, "Native cap flip did not turn the TSF cap backwards")
		TEST_ASSERT(cap.icon_state in icon_states(cap.worn_icon), "Backwards TSF cap is invisible when worn")
		TEST_ASSERT(body.dropItemToGround(cap, force = TRUE), "Could not drop the TSF cap")
		TEST_ASSERT(!cap.flipped, "Native drop did not reset the cap's orientation")
		TEST_ASSERT(cap.icon_state in icon_states(cap.worn_icon), "Dropped TSF cap cannot be worn again")
	usr = original_usr

/datum/unit_test/donor_tsf_caps/Destroy()
	usr = original_usr
	return ..()

/// Imported space appearances preserve TG's pressure protection and armour contract.
/datum/unit_test/donor_tsf_spacesuits/Run()
	var/list/suit_types = list(/obj/item/clothing/suit/space/donor_tsf, /obj/item/clothing/suit/space/donor_tsf/command)
	var/list/helmet_types = list(/obj/item/clothing/head/helmet/space/donor_tsf, /obj/item/clothing/head/helmet/space/donor_tsf/command)
	var/obj/item/clothing/suit/space/native_suit = allocate(/obj/item/clothing/suit/space)
	var/obj/item/clothing/head/helmet/space/native_helmet = allocate(/obj/item/clothing/head/helmet/space)
	for(var/index in 1 to length(suit_types))
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/clothing/suit/space/suit = allocate(suit_types[index])
		var/obj/item/clothing/head/helmet/space/helmet = allocate(helmet_types[index])
		TEST_ASSERT(body.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING), "Could not wear the TSF spacesuit")
		TEST_ASSERT(body.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD), "Could not wear the TSF space helmet")
		TEST_ASSERT_EQUAL(suit.clothing_flags, native_suit.clothing_flags, "TSF appearance changed native spacesuit protection")
		TEST_ASSERT_EQUAL(helmet.clothing_flags, native_helmet.clothing_flags, "TSF appearance changed native helmet protection")
		for(var/armor_rating in ARMOR_LIST_ALL)
			TEST_ASSERT_EQUAL(suit.get_armor_rating(armor_rating), native_suit.get_armor_rating(armor_rating), "TSF spacesuit changed native [armor_rating] armour")
			TEST_ASSERT_EQUAL(helmet.get_armor_rating(armor_rating), native_helmet.get_armor_rating(armor_rating), "TSF helmet changed native [armor_rating] armour")
		TEST_ASSERT_EQUAL(suit.slowdown, native_suit.slowdown, "TSF appearance changed native space movement")
		TEST_ASSERT(suit.icon_state in icon_states(suit.worn_icon), "Equipped TSF spacesuit is invisible")
		TEST_ASSERT(helmet.icon_state in icon_states(helmet.worn_icon), "Equipped TSF space helmet is invisible")
		TEST_ASSERT(suit.inhand_icon_state in icon_states(suit.lefthand_file), "TSF spacesuit lost its native carry appearance")
		TEST_ASSERT(helmet.inhand_icon_state in icon_states(helmet.righthand_file), "TSF helmet lost its native carry appearance")
		qdel(body)
