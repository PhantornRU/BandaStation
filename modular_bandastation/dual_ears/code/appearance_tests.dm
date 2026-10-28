/// One-sided earpieces must move between ears and disappear behind the correct profile.
/datum/unit_test/dual_ear_sprites/Run()
	var/obj/item/radio/headset/headset = allocate(/obj/item/radio/headset)
	var/source_file = headset.worn_icon
	var/right_file = headset.get_ear_worn_icon(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN)
	var/left_file = headset.get_ear_worn_icon(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN)
	TEST_ASSERT_EQUAL(right_file, source_file, "The ordinary headset lost its native right-ear sprite.")
	TEST_ASSERT_EQUAL(left_file, headset.get_ear_worn_icon(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN), "Mirrored earpieces did not reuse their cached icon.")
	check_mirrored(source_file, left_file, "headset")
	var/icon/left_sprite = icon(left_file)
	TEST_ASSERT_EQUAL(visible_pixels(left_sprite, EAST), 0, "The left earpiece shows through the head while facing east.")
	TEST_ASSERT(visible_pixels(left_sprite, WEST), "The left earpiece disappeared while facing west.")

	headset.worn_icon_state = "sec_headset_alt"
	TEST_ASSERT_EQUAL(headset.get_ear_worn_icon(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN), source_file, "The bowman headset lost its native left-ear sprite.")
	check_mirrored(source_file, headset.get_ear_worn_icon(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN), "sec_headset_alt")
	headset.worn_icon_state = "ussp_headset"
	TEST_ASSERT_EQUAL(headset.get_ear_worn_icon(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN), source_file, "The USSP headset was assigned the wrong native side.")

	// Whole-head headphones must remain bilateral, including their animated state.
	headset.worn_icon_state = "headphones_on"
	TEST_ASSERT_EQUAL(headset.get_ear_worn_icon(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN), source_file, "Bilateral headphones were altered for the right slot.")
	TEST_ASSERT_EQUAL(headset.get_ear_worn_icon(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN), source_file, "Bilateral headphones were altered for the left slot.")
	check_mirrored(source_file, left_file, "headphones_on", 7)
	var/obj/item/clothing/ears/earmuffs/muffs = allocate(/obj/item/clothing/ears/earmuffs)
	TEST_ASSERT_EQUAL(muffs.get_ear_worn_icon(ITEM_SLOT_EAR_RIGHT, SPECIES_HUMAN), muffs.get_ear_worn_icon(ITEM_SLOT_EAR_LEFT, SPECIES_HUMAN), "Bilateral earmuffs changed their sprite between ear slots.")

/// Pixel comparisons also cover the transparent profile and every animation frame requested.
/datum/unit_test/dual_ear_sprites/proc/check_mirrored(source_file, mirrored_file, state, frames = 1)
	var/icon/original = icon(source_file)
	var/icon/mirrored = icon(mirrored_file)
	TEST_ASSERT_EQUAL(original.Width(), mirrored.Width(), "Mirroring changed the ear sprite width.")
	TEST_ASSERT_EQUAL(original.Height(), mirrored.Height(), "Mirroring changed the ear sprite height.")
	for(var/direction in GLOB.cardinals)
		var/source_direction = direction == EAST ? WEST : (direction == WEST ? EAST : direction)
		for(var/frame in 1 to frames)
			for(var/x in 1 to original.Width())
				for(var/y in 1 to original.Height())
					TEST_ASSERT_EQUAL(mirrored.GetPixel(x, y, state, direction, frame), original.GetPixel(original.Width() - x + 1, y, state, source_direction, frame), "[state] was not reflected correctly in [dir2text(direction)], frame [frame], pixel [x],[y].")

/datum/unit_test/dual_ear_sprites/proc/visible_pixels(icon/sprite, direction)
	var/pixels = 0
	for(var/x in 1 to sprite.Width())
		for(var/y in 1 to sprite.Height())
			if(sprite.GetPixel(x, y, "headset", direction))
				pixels++
	return pixels

/// Both real equipment overlays retain fitted art, dimensions and per-head/height offsets.
/datum/unit_test/dual_ear_appearance/Run()
	var/mob/living/carbon/human/consistent/wearer = allocate(/mob/living/carbon/human/consistent)
	wearer.mob_height = HUMAN_HEIGHT_TALL
	var/obj/item/bodypart/head/head = wearer.get_bodypart(BODY_ZONE_HEAD)
	head.limb_id = SPECIES_VOX
	QDEL_NULL(head.worn_ears_offset)
	head.worn_ears_offset = new(head, OFFSET_EARS, list("south" = 3), list("south" = 2))
	var/obj/item/radio/headset/right = allocate(/obj/item/radio/headset)
	var/obj/item/radio/headset/left = allocate(/obj/item/radio/headset)
	for(var/obj/item/radio/headset/headset as anything in list(right, left))
		// A fitted fixture tests selection using the attached head instead of bypassing it.
		headset.worn_icon_species = list(SPECIES_VOX = 'icons/bandastation/mob/species/vox/clothing/ears.dmi')
		headset.worn_x_dimension = 64
		headset.worn_y_dimension = 64
		headset.worn_y_offset = 4
	TEST_ASSERT(wearer.equip_to_slot_if_possible(right, ITEM_SLOT_EAR_RIGHT, disable_warning = TRUE), "Could not equip the right-ear appearance fixture.")
	TEST_ASSERT(wearer.equip_to_slot_if_possible(left, ITEM_SLOT_EAR_LEFT, disable_warning = TRUE), "Could not equip the left-ear appearance fixture.")
	wearer.update_worn_ears()
	var/list/rendered = wearer.overlays_standing[EARS_LAYER]
	TEST_ASSERT_EQUAL(length(rendered), 2, "Equipping both ears did not produce both clothing overlays.")
	var/mutable_appearance/right_overlay = rendered[1]
	var/mutable_appearance/left_overlay = rendered[2]
	TEST_ASSERT_EQUAL(right_overlay.icon, 'icons/bandastation/mob/species/vox/clothing/ears.dmi', "The right ear ignored its species-fitted file.")
	var/height_offset = GLOB.human_heights_to_offsets[HUMAN_HEIGHT_TALL][UPPER_BODY]
	for(var/mutable_appearance/overlay as anything in rendered)
		TEST_ASSERT_EQUAL(overlay.pixel_w, -16 + 3, "An ear lost the large-sprite anchor or attached-head horizontal offset.")
		TEST_ASSERT_EQUAL(overlay.pixel_z, -16 + 4 + height_offset + 2, "An ear lost the large-sprite anchor, item offset, height or attached-head vertical offset.")
	var/icon/left_sprite = icon(left_overlay.icon)
	var/icon/fitted = icon('icons/bandastation/mob/species/vox/clothing/ears.dmi')
	for(var/x in 1 to fitted.Width())
		for(var/y in 1 to fitted.Height())
			TEST_ASSERT_EQUAL(left_sprite.GetPixel(x, y, "headset", SOUTH), fitted.GetPixel(fitted.Width() - x + 1, y, "headset", SOUTH), "The left ear mirrored the human file instead of its fitted sprite.")

	ADD_TRAIT(right, TRAIT_NO_WORN_ICON, REF(src))
	wearer.update_worn_ears()
	rendered = wearer.overlays_standing[EARS_LAYER]
	TEST_ASSERT_EQUAL(length(rendered), 1, "Hiding one ear's worn icon also hid the other ear.")
	REMOVE_TRAIT(right, TRAIT_NO_WORN_ICON, REF(src))
	wearer.obscured_slots |= HIDEEARS
	wearer.update_worn_ears()
	TEST_ASSERT_NULL(wearer.overlays_standing[EARS_LAYER], "Headgear hiding ears left an earpiece visible.")
