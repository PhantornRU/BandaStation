/datum/unit_test/donor_dealer_stock/Run()
	var/datum/job/job = allocate(/datum/job/donor/dealer)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	body.mind_initialize()
	allocated += body.mind
	body.mind.set_assigned_role(job)
	body.job = job.title
	body.dress_up_as_job(job, consistent = TRUE)
	var/list/stock = body.back.contents.Copy()
	stock -= locate(/obj/item/storage/box/survival) in stock
	TEST_ASSERT_EQUAL(length(stock), 6, "The Dealer did not receive its compact civilian stock")
	var/pens = 0
	for(var/obj/item/item as anything in stock)
		TEST_ASSERT(item.type in list(/obj/item/pen/fourcolor, /obj/item/flashlight, /obj/item/storage/crayons, /obj/item/clothing/glasses/sunglasses, /obj/item/lighter), "The Dealer received an unexpected trade item: [item.type]")
		if(istype(item, /obj/item/pen/fourcolor))
			pens++
	TEST_ASSERT_EQUAL(pens, 2, "The Dealer lost its second four-color pen")
	TEST_ASSERT_EQUAL(length(body.get_all_contents_type(/obj/item/stack/spacecash)), 0, "The Dealer acquired additional starting cash")
	var/list/items_before = run_loc_floor_bottom_left.get_all_contents_type(/obj/item)
	job.after_spawn(body, null)
	job.after_spawn(body, null)
	TEST_ASSERT_EQUAL(length(run_loc_floor_bottom_left.get_all_contents_type(/obj/item) - items_before), 0, "Repeating a spawn callback issued more trade goods")

/datum/unit_test/donor_dealer_stock/Destroy()
	release_donor_player_fixtures()
	return ..()
