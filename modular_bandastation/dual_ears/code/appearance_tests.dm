/// Ordinary and bowman headsets have opposite native sides.
/datum/unit_test/dual_ear_sprites/Run()
	var/obj/item/radio/headset/headset = allocate(/obj/item/radio/headset)
	TEST_ASSERT_EQUAL(headset.get_worn_icon_for_slot(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN), headset.worn_icon, "The ordinary headset lost its native right-ear sprite.")
	var/left_icon = headset.get_worn_icon_for_slot(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN)
	TEST_ASSERT_NOTNULL(left_icon, "The ordinary headset has no left-ear sprite.")
	TEST_ASSERT_NOTEQUAL(left_icon, headset.worn_icon, "The ordinary headset did not select a left-ear sprite.")

	var/obj/item/radio/headset/headset_sec/alt/bowman = allocate(/obj/item/radio/headset/headset_sec/alt)
	TEST_ASSERT_EQUAL(bowman.get_worn_icon_for_slot(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN), bowman.worn_icon, "The bowman headset lost its native left-ear sprite.")
	var/right_icon = bowman.get_worn_icon_for_slot(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN)
	TEST_ASSERT_NOTNULL(right_icon, "The bowman headset has no right-ear sprite.")
	TEST_ASSERT_NOTEQUAL(right_icon, bowman.worn_icon, "The bowman headset did not select a right-ear sprite.")

/// Each ear renders independently, while covering headgear hides both.
/datum/unit_test/dual_ear_appearance/Run()
	var/mob/living/carbon/human/consistent/wearer = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/radio/headset/right = allocate(/obj/item/radio/headset)
	var/obj/item/radio/headset/left = allocate(/obj/item/radio/headset)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(right, ITEM_SLOT_EAR_RIGHT), "Could not equip the right headset.")
	TEST_ASSERT(wearer.equip_to_slot_if_possible(left, ITEM_SLOT_EAR_LEFT), "Could not equip the left headset.")
	var/list/rendered = wearer.overlays_standing[EARS_LAYER]
	TEST_ASSERT_EQUAL(length(rendered), 2, "Equipping both ears did not produce both clothing overlays.")
	var/mutable_appearance/right_overlay = rendered[1]
	var/mutable_appearance/left_overlay = rendered[2]
	TEST_ASSERT_EQUAL(right_overlay.icon, right.get_worn_icon_for_slot(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN), "The right ear selected the wrong sprite.")
	// Appearances store resources, while the mirrored selector returns an /icon datum.
	TEST_ASSERT_EQUAL(left_overlay.icon, fcopy_rsc(left.get_worn_icon_for_slot(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN)), "The left ear selected the wrong sprite.")

	ADD_TRAIT(right, TRAIT_NO_WORN_ICON, TRAIT_SOURCE_UNIT_TESTS)
	wearer.update_worn_ears()
	rendered = wearer.overlays_standing[EARS_LAYER]
	TEST_ASSERT_EQUAL(length(rendered), 1, "Hiding one ear's worn icon also hid the other ear.")
	left_overlay = rendered[1]
	TEST_ASSERT_EQUAL(left_overlay.icon, fcopy_rsc(left.get_worn_icon_for_slot(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN)), "Hiding the right ear changed the left ear's sprite.")
	REMOVE_TRAIT(right, TRAIT_NO_WORN_ICON, TRAIT_SOURCE_UNIT_TESTS)

	var/obj/item/clothing/head/helmet/toggleable/riot/helmet = allocate(/obj/item/clothing/head/helmet/toggleable/riot)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD), "Could not equip the ear-covering helmet.")
	TEST_ASSERT_NULL(wearer.overlays_standing[EARS_LAYER], "The helmet left an earpiece visible.")
	TEST_ASSERT(wearer.dropItemToGround(helmet), "Could not remove the ear-covering helmet.")
	TEST_ASSERT_EQUAL(length(wearer.overlays_standing[EARS_LAYER]), 2, "Removing the helmet did not reveal both earpieces.")

/// Real fitted earwear uses its species resource through the worn renderer.
/datum/unit_test/dual_ear_species_appearance/Run()
	var/mob/living/carbon/human/consistent/wearer = allocate(/mob/living/carbon/human/consistent)
	wearer.set_species(/datum/species/vox)
	var/obj/item/clothing/ears/earmuffs/muffs = allocate(/obj/item/clothing/ears/earmuffs)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(muffs, ITEM_SLOT_EAR_LEFT), "Could not equip fitted earmuffs.")
	var/list/rendered = wearer.overlays_standing[EARS_LAYER]
	TEST_ASSERT_EQUAL(length(rendered), 1, "The fitted earmuffs did not produce one worn overlay.")
	var/mutable_appearance/overlay = rendered[1]
	TEST_ASSERT_EQUAL(overlay.icon, 'icons/bandastation/mob/species/vox/clothing/ears.dmi', "The earmuffs ignored their fitted vox sprite.")
