/// Check the actual native uniform overlay, not the item's unused worn_icon_state.
/datum/unit_test/donor_faction_uniform_overlays/Run()
	var/list/required = list(
		list(/obj/item/clothing/under/rank/tsf/donor/marine, "tsf_marine", 'modular_bandastation/donor_jobs/icons/tsf_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/rank/tsf/donor/specops, "tsf_marsoc", 'modular_bandastation/donor_jobs/icons/tsf_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/rank/tsf/donor/command, "solgovc", 'modular_bandastation/donor_jobs/icons/tsf_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/rank/tsf/donor/command/specops, "solgovcelite", 'modular_bandastation/donor_jobs/icons/tsf_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/rank/tsf/donor/representative, "solgovr", 'modular_bandastation/donor_jobs/icons/tsf_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/rank/tsf/donor/commander, "navy_gold", 'modular_bandastation/donor_jobs/icons/tsf_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/costume/soviet/ussp, "soviet", 'modular_bandastation/donor_jobs/icons/ussp_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/costume/soviet/ussp/officer, "sovietofficer", 'modular_bandastation/donor_jobs/icons/ussp_uniforms_worn.dmi'),
		list(/obj/item/clothing/under/costume/soviet/ussp/admiral, "sovietadmiral", 'modular_bandastation/donor_jobs/icons/ussp_uniforms_worn.dmi'),
	)
	for(var/list/test_case as anything in required)
		for(var/body_gender in list(MALE, FEMALE))
			var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/consistent)
			body.gender = body_gender
			body.physique = body_gender
			var/obj/item/clothing/under/uniform = allocate(test_case[1])
			TEST_ASSERT(body.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING), "Could not wear [uniform.type] on a [body_gender] human")
			for(var/direction in GLOB.cardinals)
				body.setDir(direction)
				body.update_worn_undersuit()
				var/mutable_appearance/uniform_overlay = body.overlays_standing[UNIFORM_LAYER]
				TEST_ASSERT_NOTNULL(uniform_overlay, "[uniform.type] did not create a native worn overlay")
				TEST_ASSERT_EQUAL(uniform_overlay.icon_state, test_case[2], "[uniform.type] rendered another uniform state")
				TEST_ASSERT_EQUAL(uniform_overlay.icon, test_case[3], "[uniform.type] rendered from another uniform file")
				var/icon/rendered = icon(uniform_overlay.icon, uniform_overlay.icon_state, direction)
				var/visible = FALSE
				for(var/x in 1 to rendered.Width())
					for(var/y in 1 to rendered.Height())
						visible ||= !isnull(rendered.GetPixel(x, y))
				TEST_ASSERT(visible, "[uniform.type] has a transparent native overlay on a [body_gender] human facing [direction]")
			qdel(body)
