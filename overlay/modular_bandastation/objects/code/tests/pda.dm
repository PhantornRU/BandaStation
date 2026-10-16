/datum/unit_test/pda_recycled_item_ownership
	test_flags = parent_type::test_flags & ~UNIT_TEST_DEBUG_MAP_ONLY

/datum/unit_test/pda_recycled_item_ownership/Run()
	for(var/item_type in list(/obj/item/pen, /obj/item/pen/fourcolor))
		var/obj/item/modular_computer/pda/tablet = allocate(/obj/item/modular_computer/pda)
		if(tablet.inserted_item.type != item_type)
			qdel(tablet.inserted_item)
			tablet.inserted_item = new item_type(tablet)
		var/obj/item/inserted = tablet.inserted_item
		TEST_ASSERT(SSwardrobe.canon_minimum[item_type], "The native wardrobe does not cache this PDA item")
		// Make room in the native stock without constructing a replacement subsystem.
		var/list/stock = SSwardrobe.preloaded_stock[item_type]
		if(stock && length(stock[WARDROBE_STOCK_CONTENTS]))
			var/obj/item/stock_item = SSwardrobe.provide_type(item_type, run_loc_floor_bottom_left)
			allocated += stock_item
			TEST_ASSERT(!QDELETED(stock_item), "The native wardrobe already held a deleted PDA item")
		TEST_ASSERT(SSwardrobe.stash_object(inserted), "The wardrobe did not accept the PDA item")
		TEST_ASSERT_NULL(tablet.inserted_item, "The PDA retained ownership after its item entered the wardrobe")
		qdel(tablet)
		TEST_ASSERT(!QDELETED(inserted), "Deleting the PDA deleted the wardrobe's item")
		var/obj/item/returned = SSwardrobe.provide_type(item_type, run_loc_floor_bottom_left)
		allocated += returned
		TEST_ASSERT_EQUAL(returned, inserted, "The wardrobe replaced its recycled PDA item")
		TEST_ASSERT(!QDELETED(returned), "The wardrobe returned a deleted PDA item")
