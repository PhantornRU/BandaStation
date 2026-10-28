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
	TEST_ASSERT_EQUAL(ear_icons[1], right.get_ear_worn_icon(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN), "The mannequin changed the right-ear sprite.")
	var/icon/rendered_left = icon(ear_icons[2])
	var/icon/expected_left = icon(left.get_ear_worn_icon(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN))
	for(var/direction in GLOB.cardinals)
		for(var/x in 1 to expected_left.Width())
			for(var/y in 1 to expected_left.Height())
				TEST_ASSERT_EQUAL(rendered_left.GetPixel(x, y, "headset", direction), expected_left.GetPixel(x, y, "headset", direction), "The mannequin did not mirror the left-ear sprite in [dir2text(direction)] at [x],[y].")
