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

/// Fixed-colour berets must use an existing native hand sprite instead of their inventory state.
/datum/unit_test/donor_tsf_beret_inhands/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/list/beret_types = list(/obj/item/clothing/head/beret/donor_tsf, /obj/item/clothing/head/beret/donor_tsf/specops)
	for(var/beret_type in beret_types)
		var/obj/item/clothing/head/beret/beret = allocate(beret_type)
		for(var/hand_index in list(LEFT_HANDS, RIGHT_HANDS))
			TEST_ASSERT(body.put_in_hand(beret, hand_index), "Could not hold [beret_type] in hand [hand_index]")
			var/list/hand_overlays = body.get_held_overlays()
			TEST_ASSERT_EQUAL(length(hand_overlays), 1, "Native renderer lost the held TSF beret")
			var/mutable_appearance/actual = hand_overlays[1]
			var/expected_file = hand_index == LEFT_HANDS ? 'icons/mob/inhands/clothing/hats_lefthand.dmi' : 'icons/mob/inhands/clothing/hats_righthand.dmi'
			TEST_ASSERT_EQUAL(actual.icon, expected_file, "TSF beret stopped using the native hat hand renderer")
			TEST_ASSERT_EQUAL(actual.icon_state, "greyscale_softcap", "TSF beret hand overlay fell back to an absent inventory state")
			TEST_ASSERT(actual.icon_state in icon_states(actual.icon), "Native TSF beret hand overlay is invisible")
			for(var/direction in GLOB.cardinals)
				var/icon/actual_frame = icon(actual.icon, actual.icon_state, direction)
				var/icon/expected_frame = icon(expected_file, "greyscale_softcap", direction)
				// The far hand is intentionally occluded in E/W; compare the native frame rather than requiring opaque pixels.
				TEST_ASSERT_EQUAL(icon2base64(actual_frame), icon2base64(expected_frame), "TSF beret lost its native hand appearance in direction [direction]")
			TEST_ASSERT(body.dropItemToGround(beret, force = TRUE), "Could not release the TSF beret before checking the other hand")
		qdel(beret)

/// Reusing BS uniforms must preserve a visible native carry appearance in both hands.
/datum/unit_test/donor_tsf_uniform_inhands/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/list/uniform_types = list(
		/obj/item/clothing/under/rank/tsf/marine,
		/obj/item/clothing/under/rank/tsf/marsoc,
		/obj/item/clothing/under/rank/tsf/marine_officer,
		/obj/item/clothing/under/rank/tsf/marsoc_officer,
		/obj/item/clothing/under/rank/tsf/commander,
	)
	for(var/uniform_type in uniform_types)
		var/obj/item/clothing/under/uniform = allocate(uniform_type)
		for(var/hand_index in list(LEFT_HANDS, RIGHT_HANDS))
			TEST_ASSERT(body.put_in_hand(uniform, hand_index), "Could not hold [uniform_type] in hand [hand_index]")
			var/list/hand_overlays = body.get_held_overlays()
			TEST_ASSERT_EQUAL(length(hand_overlays), 1, "Native renderer lost the held TSF uniform")
			var/mutable_appearance/actual = hand_overlays[1]
			var/expected_file = hand_index == LEFT_HANDS ? 'icons/mob/inhands/clothing/suits_lefthand.dmi' : 'icons/mob/inhands/clothing/suits_righthand.dmi'
			TEST_ASSERT_EQUAL(actual.icon, expected_file, "TSF uniform replaced the native carry renderer")
			TEST_ASSERT_EQUAL(actual.icon_state, "ro_suit", "TSF uniform fell back to an absent inventory state")
			TEST_ASSERT(actual.icon_state in icon_states(actual.icon), "The held TSF uniform is invisible")
			for(var/direction in GLOB.cardinals)
				var/icon/actual_frame = icon(actual.icon, actual.icon_state, direction)
				var/icon/expected_frame = icon(expected_file, "ro_suit", direction)
				TEST_ASSERT_EQUAL(icon2base64(actual_frame), icon2base64(expected_frame), "TSF uniform lost its native carry frame in direction [direction]")
			TEST_ASSERT(body.dropItemToGround(uniform, force = TRUE), "Could not release the TSF uniform")
		qdel(uniform)

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
