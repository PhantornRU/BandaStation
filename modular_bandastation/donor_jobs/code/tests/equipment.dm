/datum/unit_test/donor_job_outfits
	var/prisoner_gate_before

/datum/unit_test/donor_job_outfits/Run()
	prisoner_gate_before = CONFIG_GET(flag/donor_prisoner_gate)
	CONFIG_SET(flag/donor_prisoner_gate, TRUE)
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/loadout], null)
	var/list/outfit_paths = subtypesof(/datum/outfit/job/donor) + list(/datum/outfit/job/prisoner, /datum/outfit/job/cargo_tech/donor_deliverer)
	TEST_ASSERT_EQUAL(length(outfit_paths), 35, "The agreed outfit profiles must all exercise real equipment")
	for(var/outfit_path in outfit_paths)
		check_outfit(outfit_path, player)

/datum/unit_test/donor_job_outfits/Destroy()
	if(!isnull(prisoner_gate_before))
		CONFIG_SET(flag/donor_prisoner_gate, prisoner_gate_before)
	return ..()

/datum/unit_test/donor_job_outfits/proc/check_outfit(datum/outfit/job/outfit_path, datum/client_interface/player)
	var/datum/outfit/job/outfit = allocate(outfit_path)
	var/datum/job/job = allocate(initial(outfit_path.jobtype))
	var/list/variants = job.get_donor_variants()
	var/datum/job_variant/variant
	for(var/variant_id in variants)
		var/datum/job_variant/candidate = variants[variant_id]
		if(candidate.outfit_type == outfit_path)
			variant = candidate
			break
	TEST_ASSERT_NOTNULL(variant, "[outfit_path] is unreachable through its canonical job")
	var/list/selected_variants = list()
	selected_variants[job.title] = variant.id
	TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], selected_variants), "Could not select [outfit_path]")

	var/mob/living/carbon/human/preview = allocate(/mob/living/carbon/human/consistent)
	var/list/turf_contents = run_loc_floor_bottom_left.contents.Copy()
	preview.dress_up_as_job(job, visual_only = TRUE, player_client = player, consistent = TRUE)
	TEST_ASSERT_NOTNULL(preview.w_uniform, "[outfit_path] has no usable preview uniform")
	TEST_ASSERT_EQUAL(length(preview.get_all_contents_type(/obj/item/stack/spacecash)), 0, "[outfit_path] preview issued starting money")
	TEST_ASSERT_EQUAL(length(preview.implants), 0, "[outfit_path] preview implanted the character")
	for(var/obj/item/storage/storage as anything in preview.get_all_contents_type(/obj/item/storage))
		TEST_ASSERT_EQUAL(length(storage.contents), 0, "[outfit_path] preview issued contents inside [storage.type]")
	TEST_ASSERT_NULL(preview.donor_spawn_context, "[outfit_path] preview attached a live spawn context")
	TEST_ASSERT_EQUAL(length(run_loc_floor_bottom_left.contents - turf_contents), 0, "[outfit_path] preview dropped loot into the world")
	qdel(preview)

	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	body.backpack = DSATCHEL
	if(ispath(outfit_path, /datum/outfit/job/donor/actor))
		body.gender = FEMALE
	body.mind_initialize()
	body.mind.set_assigned_role(job)
	body.job = job.title
	job.prepare_donor_character(body, player.prefs)
	body.dress_up_as_job(job, player_client = player, consistent = TRUE)
	check_equipped_slots(body, outfit_path)
	var/obj/item/card/id/card = body.get_idcard(hand_first = FALSE)
	TEST_ASSERT_NOTNULL(card, "[outfit_path] did not equip a usable ID")
	var/list/kit = outfit.donor_kit
	var/list/counts_before = list()
	for(var/item_type in kit)
		counts_before[item_type] = count_supplies(item_type)
	job.after_spawn(body, null)
	TEST_ASSERT_EQUAL(card.assignment, variant.public_title, "[outfit_path] did not apply the selected public title")
	TEST_ASSERT_EQUAL(body.mind.assigned_role, job, "[outfit_path] replaced the canonical profession")
	var/list/counts_after = list()
	for(var/item_type in kit)
		var/quantity = kit[item_type]
		if(ispath(item_type, /obj/item/stack))
			var/obj/item/stack/stack_path = item_type
			quantity *= initial(stack_path.amount)
		counts_after[item_type] = count_supplies(item_type)
		TEST_ASSERT_EQUAL(counts_after[item_type] - counts_before[item_type], quantity, "[outfit_path] lost or duplicated [item_type]")
	for(var/implant_type in outfit.implants)
		TEST_ASSERT(locate(implant_type) in body.implants, "[outfit_path] failed to implant [implant_type]")
	job.after_spawn(body, null)
	for(var/item_type in kit)
		TEST_ASSERT_EQUAL(count_supplies(item_type), counts_after[item_type], "[outfit_path] repeated starting rewards")
	qdel(body)

/datum/unit_test/donor_job_outfits/proc/check_equipped_slots(mob/living/carbon/human/body, outfit_path)
	var/datum/outfit/job/outfit = allocate(outfit_path)
	outfit.prepare_for_character(body)
	var/list/equipped_slots = list(
		"uniform" = ITEM_SLOT_ICLOTHING,
		"suit" = ITEM_SLOT_OCLOTHING,
		"belt" = ITEM_SLOT_BELT,
		"gloves" = ITEM_SLOT_GLOVES,
		"shoes" = ITEM_SLOT_FEET,
		"head" = ITEM_SLOT_HEAD,
		"mask" = ITEM_SLOT_MASK,
		"neck" = ITEM_SLOT_NECK,
		"ears" = ITEM_SLOT_EARS,
		"glasses" = ITEM_SLOT_EYES,
		"l_pocket" = ITEM_SLOT_LPOCKET,
		"r_pocket" = ITEM_SLOT_RPOCKET,
		"suit_store" = ITEM_SLOT_SUITSTORE,
	)
	for(var/outfit_slot in equipped_slots)
		var/item_type = outfit.vars[outfit_slot]
		if(item_type)
			TEST_ASSERT(istype(body.get_item_by_slot(equipped_slots[outfit_slot]), item_type), "[outfit_path] lost [item_type] from [outfit_slot]")
	if(outfit.l_hand)
		TEST_ASSERT(istype(body.get_held_items_for_side(LEFT_HANDS), outfit.l_hand), "[outfit_path] lost its declared left-hand item")
	if(outfit.r_hand)
		TEST_ASSERT(istype(body.get_held_items_for_side(RIGHT_HANDS), outfit.r_hand), "[outfit_path] lost its declared right-hand item")
	TEST_ASSERT(istype(body.back, outfit.satchel), "[outfit_path] did not equip the preferred department satchel")

/// Include dropped overflow and count stack units after native stack merging.
/datum/unit_test/donor_job_outfits/proc/count_supplies(item_type)
	var/count = 0
	for(var/obj/item/item as anything in run_loc_floor_bottom_left.get_all_contents_type(/obj/item))
		if(QDELETED(item) || item.type != item_type)
			continue
		if(isstack(item))
			var/obj/item/stack/stack = item
			count += stack.get_amount()
		else
			count++
	return count

/datum/unit_test/donor_job_kit_overflow/Run()
	var/datum/job/job = allocate(/datum/job/donor/barber)
	var/datum/outfit/job/outfit = allocate(job.outfit)
	TEST_ASSERT_EQUAL(outfit.donor_kit?[/obj/item/storage/box/donor_barber], 1, "Barber did not declare its starting kit")
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	body.mind_initialize()
	body.mind.set_assigned_role(job)
	body.job = job.title
	body.donor_spawn_context = allocate(/datum/donor_spawn_context, job, "default")
	body.dress_up_as_job(job, consistent = TRUE)
	var/obj/item/storage/backpack/backpack = body.back
	TEST_ASSERT_NOTNULL(backpack, "Barber did not receive a normal backpack")
	var/storage_slots = backpack.atom_storage.max_slots
	var/storage_weight = backpack.atom_storage.max_total_storage
	var/obj/item/pen/filler = allocate(/obj/item/pen)
	for(var/i in 1 to storage_slots)
		if(!backpack.atom_storage.can_insert(filler, body, messages = FALSE))
			break
		TEST_ASSERT(body.equip_to_storage(filler, ITEM_SLOT_BACK), "Could not fill the actual backpack")
		filler = allocate(/obj/item/pen)
	TEST_ASSERT(!backpack.atom_storage.can_insert(filler, body, messages = FALSE), "The filled backpack still accepts another item")
	TEST_ASSERT(length(backpack.contents) == storage_slots || backpack.atom_storage.get_total_weight() == storage_weight, "The backpack did not reach either native capacity limit")
	qdel(filler)
	TEST_ASSERT(body.put_in_hands(allocate(/obj/item/pen)), "Could not occupy the first hand")
	TEST_ASSERT(body.put_in_hands(allocate(/obj/item/pen)), "Could not occupy the second hand")
	TEST_ASSERT_EQUAL(body.get_num_held_items(), 2, "The overflow scenario did not occupy both hands")
	TEST_ASSERT(!body.donor_spawn_context.kit_issued, "The overflow fixture issued its kit before filling the backpack")
	var/atom/drop_location = body.drop_location()
	TEST_ASSERT_NOTNULL(drop_location, "The equipped character has no native drop location")
	job.after_spawn(body, null)
	var/obj/item/storage/box/donor_barber/kit = locate(/obj/item/storage/box/donor_barber) in drop_location
	TEST_ASSERT_NOTNULL(kit, "A full bag and occupied hands lost the starting kit")
	TEST_ASSERT_NOTNULL(locate(/obj/item/razor/donor_scissors) in kit, "The dropped kit lost its scissors")
	TEST_ASSERT_EQUAL(backpack.atom_storage.max_slots, storage_slots, "Overflow changed backpack capacity")
	TEST_ASSERT_EQUAL(backpack.atom_storage.max_total_storage, storage_weight, "Overflow changed backpack weight capacity")
	var/list/items_after = drop_location.get_all_contents_type(/obj/item)
	job.after_spawn(body, null)
	TEST_ASSERT_EQUAL(length(drop_location.get_all_contents_type(/obj/item) - items_after), 0, "A repeated callback issued another overflow kit")

/datum/unit_test/donor_variant_before_loadout/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	var/datum/job/job = allocate(/datum/job/donor/actor)
	var/datum/job_variant/artist = job.resolve_donor_variant("title_e639ea25de")
	TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/loadout], list(/obj/item/clothing/head/beanie = list(), /obj/item/toy/plush/beeplushie = list())), "Could not save the native personal loadout")
	var/mob/living/carbon/human/female = allocate(/mob/living/carbon/human/consistent)
	female.gender = FEMALE
	female.job = job.title
	female.donor_spawn_context = allocate(/datum/donor_spawn_context, job, artist.id)
	female.dress_up_as_job(job, player_client = player, consistent = TRUE)
	TEST_ASSERT(istype(female.w_uniform, /obj/item/clothing/under/donor/victorian_dress/red), "Artist did not choose the female uniform before loadout")
	TEST_ASSERT(istype(female.head, /obj/item/clothing/head/beanie), "Personal headwear was overwritten by the artist outfit")
	TEST_ASSERT_NOTNULL(locate(/obj/item/toy/plush/beeplushie) in female.back, "The personal backpack item was lost")

	TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], list("Actor" = "default")), "Could not change the edited character's variant")
	var/mob/living/carbon/human/male = allocate(/mob/living/carbon/human/consistent)
	male.gender = MALE
	male.job = job.title
	male.donor_spawn_context = allocate(/datum/donor_spawn_context, job, artist.id)
	male.dress_up_as_job(job, player_client = player, consistent = TRUE)
	TEST_ASSERT(istype(male.w_uniform, /obj/item/clothing/under/donor/victorian/red), "The live artist variant was replaced by editor state or the previous female outfit")
	TEST_ASSERT(istype(male.head, /obj/item/clothing/head/beanie), "Personal headwear was lost on the second character")

	var/mob/living/carbon/human/plasmaman = allocate(/mob/living/carbon/human/consistent)
	plasmaman.job = job.title
	plasmaman.set_species(/datum/species/plasmaman)
	plasmaman.donor_spawn_context = allocate(/datum/donor_spawn_context, job, artist.id)
	plasmaman.dress_up_as_job(job, player_client = player, consistent = TRUE)
	TEST_ASSERT(istype(plasmaman.w_uniform, /obj/item/clothing/under/plasmaman), "Donor equipment replaced the species pressure suit")
	TEST_ASSERT(istype(plasmaman.head, /obj/item/clothing/head/helmet/space/plasmaman), "Personal headwear replaced the species pressure helmet")
	TEST_ASSERT_NOTNULL(locate(/obj/item/clothing/head/beanie) in plasmaman.back, "Species equipment deleted personal headwear instead of preserving it")

/datum/unit_test/donor_character_handover/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.all_quirks = list(/datum/quirk/item_quirk/food_allergic::name)
	TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/food_allergy], "Молочные продукты"), "Could not save the customized allergy")
	var/datum/job/job = allocate(/datum/job/donor/barber)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
	body.mind_initialize()
	body.mind.set_assigned_role(job)
	job.prepare_donor_character(body, player.prefs)
	SSjob.equip_rank(body, job, null)
	SSquirks.AssignQuirks(body, player)
	var/datum/quirk/item_quirk/food_allergic/allergy = locate() in body.quirks
	TEST_ASSERT_NOTNULL(allergy, "Native post-equipment quirks did not add the selected allergy")
	TEST_ASSERT_EQUAL(allergy.target_foodtypes, DAIRY, "Native quirks lost the customized allergy")
	TEST_ASSERT_NOTNULL(locate(/obj/item/clothing/accessory/dogtag/allergy) in body.get_all_contents(), "Native quirks lost their actual equipment")
	TEST_ASSERT(body.donor_spawn_context.kit_issued, "Initial native equipment did not issue the donor kit")
	var/list/items_before = run_loc_floor_bottom_left.get_all_contents_type(/obj/item)
	var/obj/item/card/id/card = body.get_idcard(hand_first = FALSE)
	card.assignment = "Reassigned employee"
	job.after_spawn(body, null)
	TEST_ASSERT_EQUAL(length(run_loc_floor_bottom_left.get_all_contents_type(/obj/item) - items_before), 0, "A repeated spawn callback issued additional equipment")
	TEST_ASSERT_EQUAL(card.assignment, "Reassigned employee", "A repeated callback restored the old public title")
	TEST_ASSERT_NULL(body.client, "Reward issuance required a Login or reconnect")

/datum/unit_test/donor_emergency_glowstick/Run()
	var/obj/item/flashlight/donor_emergency_glowstick/glowstick = allocate(/obj/item/flashlight/donor_emergency_glowstick)
	TEST_ASSERT(!glowstick.light_on, "The emergency glowstick started burning before activation")
	TEST_ASSERT_NULL(glowstick.reagents, "The emergency glowstick acquired extractable chemical fuel")
	TEST_ASSERT(glowstick.seconds_remaining >= 60 && glowstick.seconds_remaining <= 180, "The emergency glowstick lost its historical one-to-three-minute lifetime")
	TEST_ASSERT(glowstick.toggle_light(), "The emergency glowstick could not be activated")
	TEST_ASSERT(!glowstick.toggle_light(), "The burning emergency glowstick could be switched off or restarted")
	glowstick.process(glowstick.seconds_remaining - 1)
	TEST_ASSERT(glowstick.light_on, "The emergency glowstick stopped before its fuel ran out")
	TEST_ASSERT_EQUAL(glowstick.light_range, 4, "The emergency glowstick's light faded before expiry")
	TEST_ASSERT_EQUAL(glowstick.light_power, 1, "The emergency glowstick changed its historical light strength")
	TEST_ASSERT_EQUAL(glowstick.light_color, LIGHT_COLOR_BLUE, "The emergency glowstick changed its historical blue light")
	TEST_ASSERT_EQUAL(glowstick.process(1), PROCESS_KILL, "The spent emergency glowstick kept processing")
	TEST_ASSERT(!glowstick.light_on, "The spent emergency glowstick retained its light")
	TEST_ASSERT_EQUAL(glowstick.icon_state, "glowstick-empty", "The spent emergency glowstick did not preserve its empty item")
	TEST_ASSERT(!glowstick.toggle_light(), "The spent emergency glowstick could be reignited")
