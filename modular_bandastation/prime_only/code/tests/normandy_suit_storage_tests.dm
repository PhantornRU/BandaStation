/datum/unit_test/normandy_suit_storage
	abstract_type = /datum/unit_test/normandy_suit_storage

/datum/unit_test/normandy_suit_storage/return_kit/Run()
	var/obj/machinery/normandy_suit_storage/storage = allocate(/obj/machinery/normandy_suit_storage)
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human/consistent)
	wearer.set_base_pixel_y(3)
	var/original_pixel_y = wearer.base_pixel_y

	storage.close_machine(wearer)
	storage.cancel_dressing_start_timer()
	storage.begin_dressing()
	if(!storage.is_kit_worn_by(wearer))
		TEST_FAIL("The dressing cycle did not equip its kit")
		return
	if(wearer.base_pixel_y == original_pixel_y)
		TEST_FAIL("Dressing did not apply the character offset")
		return

	if(!storage.store_kit_from(wearer))
		TEST_FAIL("The kit could not be returned to its storage unit")
		return
	if(wearer.base_pixel_y != original_pixel_y)
		TEST_FAIL("Returning the kit did not restore the character offset ([wearer.base_pixel_y], expected [original_pixel_y])")
		return
	qdel(storage)
	if(wearer.base_pixel_y != original_pixel_y)
		TEST_FAIL("Deleting the empty unit applied the character offset a second time")

/datum/unit_test/normandy_suit_storage/delete_storage/Run()
	var/obj/machinery/normandy_suit_storage/storage = allocate(/obj/machinery/normandy_suit_storage)
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human/consistent)
	wearer.set_base_pixel_y(3)
	var/original_pixel_y = wearer.base_pixel_y

	storage.close_machine(wearer)
	storage.cancel_dressing_start_timer()
	storage.begin_dressing()
	if(!storage.is_kit_worn_by(wearer))
		TEST_FAIL("The dressing cycle did not equip its kit")
		return
	if(wearer.base_pixel_y == original_pixel_y)
		TEST_FAIL("Dressing did not apply the character offset")
		return

	qdel(storage)
	for(var/slot in list(ITEM_SLOT_HEAD, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_NECK))
		var/obj/item/worn_item = wearer.get_item_by_slot(slot)
		if(worn_item && !wearer.dropItemToGround(worn_item))
			TEST_FAIL("The kit could not be removed after deleting its storage unit")
			return
	if(wearer.base_pixel_y != original_pixel_y)
		TEST_FAIL("Deleting the unit and removing its kit left a permanent character offset ([wearer.base_pixel_y], expected [original_pixel_y])")

/datum/unit_test/normandy_suit_storage/delete_wearer/Run()
	var/obj/machinery/normandy_suit_storage/storage = allocate(/obj/machinery/normandy_suit_storage)
	var/list/deleted_refs = dress_and_delete_wearer(storage)
	if(isnull(deleted_refs))
		TEST_FAIL("The dressing cycle did not equip its kit")
		return

	// The filter queue holds a reference briefly; the hard-delete queue is still minutes away.
	sleep(10 SECONDS)
	for(var/deleted_part in deleted_refs)
		if(locate(deleted_refs[deleted_part]))
			TEST_FAIL("The surviving storage unit kept its deleted [deleted_part] alive")

/datum/unit_test/normandy_suit_storage/delete_wearer/proc/dress_and_delete_wearer(obj/machinery/normandy_suit_storage/storage)
	// allocate() would itself retain the wearer until the test ends.
	var/mob/living/carbon/human/wearer = new /mob/living/carbon/human/consistent(run_loc_floor_bottom_left)
	storage.close_machine(wearer)
	storage.cancel_dressing_start_timer()
	storage.begin_dressing()
	var/was_dressed = storage.is_kit_worn_by(wearer)
	var/list/deleted_refs = list(
		"wearer" = text_ref(wearer),
		"armor" = text_ref(storage.stored_armor),
		"gloves" = text_ref(storage.stored_gloves),
		"boots" = text_ref(storage.stored_boots),
		"helmet" = text_ref(storage.stored_helmet),
		"cloak" = text_ref(storage.stored_cloak),
	)
	qdel(wearer)
	wearer = null
	return was_dressed ? deleted_refs : null

/datum/unit_test/normandy_suit_storage/delete_kit_piece/Run()
	var/obj/machinery/normandy_suit_storage/storage = allocate(/obj/machinery/normandy_suit_storage)
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human/consistent)
	if(!storage.is_kit_stored())
		TEST_FAIL("The unit did not start with its complete kit stored")
		return

	var/boots_ref = text_ref(storage.stored_boots)
	qdel(storage.stored_boots)
	if(!isnull(storage.stored_boots))
		TEST_FAIL("The unit kept a reference to its deleted boots")
	if(locate(boots_ref) in storage.kit_items)
		TEST_FAIL("The unit kept its deleted boots in the kit list")
	if(storage.is_kit_stored())
		TEST_FAIL("The unit considered its four remaining pieces a complete stored kit")

	storage.close_machine(wearer)
	if(!storage.state_open || wearer.loc == storage)
		TEST_FAIL("The unit started closing with an incomplete kit")
