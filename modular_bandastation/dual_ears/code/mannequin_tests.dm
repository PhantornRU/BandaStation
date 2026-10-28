/// Mannequins must render the same side-specific resources as living wearers.
/datum/unit_test/dual_ears_mannequin/Run()
	var/obj/structure/mannequin/mannequin = allocate(/obj/structure/mannequin)
	var/obj/item/radio/headset/right = allocate(/obj/item/radio/headset, mannequin)
	var/obj/item/radio/headset/left = allocate(/obj/item/radio/headset, mannequin)
	mannequin.worn_items["[ITEM_SLOT_EAR_RIGHT]"] = right
	mannequin.worn_items["[ITEM_SLOT_EAR_LEFT]"] = left
	var/list/ear_icons = list()
	for(var/mutable_appearance/overlay as anything in mannequin.update_overlays())
		if(overlay.layer == -EARS_LAYER)
			ear_icons += overlay.icon
	TEST_ASSERT_EQUAL(length(ear_icons), 2, "The mannequin did not render both ear slots.")
	TEST_ASSERT_EQUAL(ear_icons[1], right.get_worn_icon_for_slot(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN), "The mannequin changed the right-ear sprite.")
	TEST_ASSERT_EQUAL(ear_icons[2], fcopy_rsc(left.get_worn_icon_for_slot(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN)), "The mannequin changed the left-ear sprite.")
