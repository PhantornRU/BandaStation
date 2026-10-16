/// Independent requirements: distinct role variants, imported form and usable HONK gun.
/datum/unit_test/donor_seclown_equipment/Run()
	var/datum/client_interface/player = allocate(/datum/client_interface)
	player.prefs = allocate(/datum/preferences, player)
	player.prefs.write_preference(GLOB.preference_entries[/datum/preference/loadout], null)
	var/datum/job/donor/security_clown/job = allocate(/datum/job/donor/security_clown)
	var/list/required_variants = list(
		"default" = list(/obj/item/clothing/head/helmet, /obj/item/clothing/suit/armor/vest/alt/sec, /obj/item/gun/energy/honk_rifle),
		"detective" = list(/obj/item/clothing/head/fedora/det_hat, /obj/item/clothing/suit/toggle/jacket/det_trench, /obj/item/gun/energy/honk_rifle),
		"warden" = list(/obj/item/clothing/head/hats/warden/red, /obj/item/clothing/suit/armor/vest/warden/alt, /obj/item/gun/energy/honk_rifle/warden),
		"cadet" = list(/obj/item/clothing/head/soft/sec, /obj/item/clothing/suit/armor/vest/alt/sec, /obj/item/gun/energy/honk_rifle),
	)
	for(var/variant_id in required_variants)
		var/list/expected = required_variants[variant_id]
		var/list/selection = list()
		selection[job.title] = variant_id
		TEST_ASSERT(player.prefs.write_preference(GLOB.preference_entries[/datum/preference/job_outfit_variants], selection), "Could not select Security Clown [variant_id]")
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
		body.mind_initialize()
		allocated += body.mind
		body.mind.set_assigned_role(job)
		body.job = job.title
		job.prepare_spawn_character(body, player.prefs)
		body.dress_up_as_job(job, player_client = player, consistent = TRUE)
		TEST_ASSERT(istype(body.w_uniform, /obj/item/clothing/under/rank/civilian/clown/security), "[variant_id] lost the imported Security Clown uniform")
		TEST_ASSERT("security_clown" in icon_states(body.w_uniform.icon), "Security Clown inventory sprite is missing")
		TEST_ASSERT("security_clown" in icon_states(body.w_uniform.worn_icon), "Security Clown worn sprite is missing")
		TEST_ASSERT_EQUAL(body.head.type, expected[1], "[variant_id] lost its native headwear")
		TEST_ASSERT_EQUAL(body.wear_suit.type, expected[2], "[variant_id] lost its native outerwear")
		TEST_ASSERT_EQUAL(body.s_store.type, expected[3], "[variant_id] did not equip its HONK rifle in suit storage")
		TEST_ASSERT(HAS_TRAIT(body, TRAIT_CLUMSY), "Security Clown lost the native clown's clumsiness")
		TEST_ASSERT(HAS_TRAIT(body, TRAIT_CLOWN_ENJOYER), "Security Clown bypassed native clown post_equip")
		TEST_ASSERT(HAS_TRAIT(body, TRAIT_BALLOON_SUTRA), "Security Clown lost the native clown skillchip")
		TEST_ASSERT(body.has_faction(FACTION_CLOWN), "Security Clown lost the native clown faction")
		TEST_ASSERT(locate(/obj/item/implant/mindshield) in body.implants, "Security Clown lost its mindshield")
		var/mob/living/carbon/human/preview = allocate(/mob/living/carbon/human/consistent)
		preview.dress_up_as_job(job, visual_only = TRUE, player_client = player, consistent = TRUE)
		TEST_ASSERT(!HAS_TRAIT(preview, TRAIT_CLUMSY), "Preview applied native clown gameplay effects")
		TEST_ASSERT_EQUAL(length(preview.implants), 0, "Preview implanted the character")
		qdel(preview)
		qdel(body)

/datum/unit_test/donor_seclown_equipment/Destroy()
	release_job_player_fixtures()
	return ..()

/// Fire a real energy gun as a clumsy wearer, then exhaust and recharge its battery.
/datum/unit_test/donor_honk_rifle/Run()
	for(var/gun_type in list(/obj/item/gun/energy/honk_rifle, /obj/item/gun/energy/honk_rifle/warden))
		var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
		ADD_TRAIT(shooter, TRAIT_CLUMSY, REF(src))
		var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
		var/obj/item/gun/energy/honk_rifle/gun = allocate(gun_type)
		STOP_PROCESSING(SSobj, gun) // Advance the existing recharge operation deterministically.
		TEST_ASSERT(shooter.put_in_active_hand(gun), "Could not hold the HONK rifle")
		TEST_ASSERT(gun.inhand_icon_state in icon_states(gun.lefthand_file), "HONK rifle is invisible in the left hand")
		TEST_ASSERT(gun.inhand_icon_state in icon_states(gun.righthand_file), "HONK rifle is invisible in the right hand")
		var/charge_before = gun.cell.charge
		var/health_before = target.health
		var/turf/target_floor = get_turf(target)
		var/list/ashes_before = target_floor.contents.Copy()
		gun.try_fire_gun(target, shooter, null)
		sleep(1 SECONDS)
		TEST_ASSERT_EQUAL(gun.cell.charge, charge_before - 100, "The clumsy wearer failed to fire one native HONK shot")
		TEST_ASSERT_EQUAL(target.health, health_before, "The snap-pop injured its target")
		TEST_ASSERT_EQUAL(target.get_stamina_loss(), 0, "The snap-pop caused stamina damage")
		TEST_ASSERT(!target.IsKnockdown() && !target.IsParalyzed(), "The snap-pop gained the banana honker's incapacitation")
		TEST_ASSERT(locate(/obj/effect/decal/cleanable/ash) in (target_floor.contents - ashes_before), "The actual fired snap-pop did not burst at its target")
		gun.cell.use(gun.cell.charge)
		gun.update_appearance()
		TEST_ASSERT(!gun.can_shoot(), "An empty HONK rifle could fire")
		TEST_ASSERT(gun.inhand_icon_state in icon_states(gun.lefthand_file), "The empty HONK rifle lost its left-hand sprite")
		TEST_ASSERT(gun.inhand_icon_state in icon_states(gun.righthand_file), "The empty HONK rifle lost its right-hand sprite")
		gun.charge_timer = 0
		for(var/tick in 1 to 3)
			gun.process(2)
		TEST_ASSERT_EQUAL(gun.cell.charge, 0, "The HONK rifle recharged before eight seconds")
		gun.process(2)
		TEST_ASSERT_EQUAL(gun.cell.charge, 100, "Native recharge did not restore one shot after eight seconds")
		TEST_ASSERT(gun.can_shoot(), "The recharged HONK rifle could not fire")
		for(var/obj/effect/decal/cleanable/ash/ash in (target_floor.contents - ashes_before))
			qdel(ash)
		qdel(shooter)
		qdel(target)
