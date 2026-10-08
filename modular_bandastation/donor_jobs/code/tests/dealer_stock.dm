/datum/unit_test/donor_dealer_stock/Run()
	var/list/stock = get_donor_dealer_stock()
	for(var/required in list(
		/obj/item/toy/cards/deck/syndicate,
		/obj/item/gun/ballistic/automatic/donor_toy_sniper,
		/obj/item/toy/plush/donor/fluff/fox,
		/obj/item/clothing/head/collectable/swat,
		/obj/item/poster/donor_syndicate_recruitment,
		/obj/item/storage/fancy/cigarettes/cigpack_random,
		/obj/item/lighter/donor_zippo/fluff/warriorstar,
		/obj/item/donor_id_skin/boykisser,
	))
		TEST_ASSERT(required in stock, "Historical Dealer item [required] is missing")
	TEST_ASSERT(!(/obj/item/toy/balloon/syndicate in stock), "The Dealer acquired the later native balloon mechanics")
	var/crayon_entry = stock.Find("crayon")
	TEST_ASSERT(crayon_entry, "The historical random crayon is missing")
	TEST_ASSERT(!stock.Find("crayon", crayon_entry + 1), "The random crayon acquired extra weight in the Dealer pool")
	var/obj/item/toy/crayon/random_crayon = allocate(donor_loot_type(stock[crayon_entry]))
	TEST_ASSERT(random_crayon.type in list(
		/obj/item/toy/crayon/red,
		/obj/item/toy/crayon/orange,
		/obj/item/toy/crayon/yellow,
		/obj/item/toy/crayon/green,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crayon/purple,
	), "The historical random crayon produced an incorrect native crayon: [random_crayon.type]")
	qdel(random_crayon)

	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	var/turf/floor = get_turf(body)
	var/list/before = floor.contents.Copy()
	var/obj/item/storage/box/donor_stock/box = allocate(/obj/item/storage/box/donor_stock)
	before += box
	var/list/loot = (floor.contents - before) + box.contents
	TEST_ASSERT_EQUAL(length(loot), 30, "Creating the Dealer box did not issue all 30 items")
	for(var/obj/item/item as anything in loot)
		TEST_ASSERT(!QDELETED(item), "Dealer issued an already deleted item")
		TEST_ASSERT(isitem(item), "Dealer issued a random spawner instead of its real item")
		if(!(item.type in stock))
			TEST_ASSERT(item.type in donor_toy_choices("mech") + donor_toy_choices("carp") + donor_toy_choices("plush") + donor_toy_choices("figure") + donor_toy_choices("random") + donor_toy_choices("crayon"), "Dealer issued a non-historical item: [item.type]")
	box.attack_self(body)
	var/list/after_repeat = floor.contents - before
	if(!QDELETED(box))
		after_repeat += box.contents
	// Native empty boxes may fold into cardboard when all loot overflowed.
	for(var/obj/item/stack/sheet/cardboard/folded in after_repeat.Copy())
		after_repeat -= folded
	TEST_ASSERT_EQUAL(length(after_repeat), 30, "A repeated Dealer-box activation duplicated loot")
	for(var/obj/item/item as anything in loot)
		qdel(item)
	qdel(box)

	var/list/capsules = list(
		/obj/item/toy/donor_prizeball = list(/obj/item/toy/plush, /obj/item/toy/figure/donor/crew, /obj/item/toy/donor_eight_ball, /obj/item/stack/arcadeticket/donor),
		/obj/item/toy/donor_prizeball/mech = list(/obj/item/toy/figure/donor/mech),
		/obj/item/toy/donor_prizeball/carp_plushie = list(/obj/item/toy/plush/donor/carpplushie, /obj/item/toy/plush/carpplushie/dehy_carp),
		/obj/item/toy/donor_prizeball/plushie = list(/obj/item/toy/plush/donor),
		/obj/item/toy/donor_prizeball/figure = list(/obj/item/toy/figure/donor/crew),
		/obj/item/toy/donor_prizeball/therapy = list(/obj/item/toy/donor_therapy),
	)
	for(var/capsule_type in capsules)
		var/list/floor_before = floor.contents.Copy()
		var/obj/item/toy/donor_prizeball/capsule = allocate(capsule_type)
		TEST_ASSERT_EQUAL(length(floor.contents - floor_before), 1, "[capsule_type] created loot during Initialize")
		capsule.attack_self(body)
		capsule.attack_self(body)
		sleep(1.1 SECONDS)
		var/list/prizes = floor.contents - floor_before
		TEST_ASSERT(QDELETED(capsule), "[capsule_type] was not consumed")
		TEST_ASSERT_EQUAL(length(prizes), 1, "[capsule_type] failed to issue exactly one prize on repeated activation")
		var/obj/item/prize = prizes[1]
		var/correct_type = FALSE
		for(var/expected_type in capsules[capsule_type])
			if(istype(prize, expected_type))
				correct_type = TRUE
		TEST_ASSERT(correct_type, "[capsule_type] issued incorrect prize [prize.type]")
		if(istype(prize, /obj/item/stack/arcadeticket/donor))
			var/obj/item/stack/arcadeticket/donor/tickets = prize
			TEST_ASSERT(tickets.get_amount() in list(5, 10, 15, 25, 50), "Prize ball changed the original ticket quantities")
		qdel(prize)

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	body.zone_selected = BODY_ZONE_PRECISE_MOUTH
	for(var/soap_type in list(/obj/item/soap/donor, /obj/item/soap/donor/ducttape))
		for(var/combat_mode in list(FALSE, TRUE))
			var/obj/item/soap/donor/soap = allocate(soap_type)
			victim.reagents.clear_reagents()
			body.put_in_active_hand(soap, forced = TRUE)
			body.set_combat_mode(combat_mode)
			soap.melee_attack_chain(body, victim)
			TEST_ASSERT_EQUAL(victim.reagents.get_reagent_amount(/datum/reagent/donor_soap), 6, "[soap_type] could not wash a selected mouth through the native click chain (combat: [combat_mode])")
			qdel(soap)
