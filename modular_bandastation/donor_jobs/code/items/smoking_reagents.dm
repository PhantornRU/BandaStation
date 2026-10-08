/datum/reagent/donor_cbd
	name = "Cannabidiol"
	description = "A non-psychoactive phytocannabinoid extracted from the cannabis plant."
	color = "#00e100"
	taste_description = "relaxation"

/datum/reagent/donor_cbd/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(SPT_PROB(5, seconds_per_tick / 2))
		affected_mob.emote(pick("sigh", "yawn"))
	if(SPT_PROB(5, seconds_per_tick / 2))
		to_chat(affected_mob, span_notice("[pick("You feel peaceful.", "You breathe softly.", "You feel chill.", "You vibe.")]"))
	if(SPT_PROB(10, seconds_per_tick / 2))
		affected_mob.adjust_confusion(-10 SECONDS)
		affected_mob.SetKnockdown(0)
	if(volume >= 70 && affected_mob.reagents.get_reagent_amount(/datum/reagent/drug/cannabis) <= 20 && SPT_PROB(25, seconds_per_tick / 2))
		affected_mob.adjust_drowsiness(20 SECONDS)
	if(SPT_PROB(25, seconds_per_tick / 2))
		affected_mob.adjust_brute_loss(-2)
		affected_mob.adjust_fire_loss(-2)

/datum/reagent/donor_green_vomit
	name = "Green vomit"
	description = "Whoa, that can't be natural. That's horrible."
	color = "#78FF74"
	taste_description = "puke"

/datum/reagent/donor_green_vomit/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume >= 5 && !isspaceturf(exposed_turf))
		exposed_turf.add_vomit_floor(vomit_type = /obj/effect/decal/cleanable/vomit/toxic)

/datum/reagent/donor_msg
	name = "Monosodium glutamate"
	description = "A sodium salt used as a controversial flavor enhancer."
	color = "#F5F5F5"
	taste_description = "excellent cuisine"
	taste_mult = 4

/datum/reagent/donor_msg/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(!SPT_PROB(5, seconds_per_tick / 2))
		return
	if(prob(10))
		affected_mob.adjust_tox_loss(rand(2, 4))
	if(prob(7))
		to_chat(affected_mob, span_warning("A horrible migraine overpowers you."))
		affected_mob.Stun(rand(4 SECONDS, 10 SECONDS))

/datum/reagent/medicine/donor_charcoal
	name = "Charcoal"
	description = "Activated charcoal helps to absorb toxins."
	color = "#000000"
	taste_description = "dust"

/datum/reagent/medicine/donor_charcoal/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.adjust_tox_loss(-0.75 * seconds_per_tick * metabolization_ratio)
	if(SPT_PROB(50, seconds_per_tick / 2))
		for(var/datum/reagent/absorbed as anything in affected_mob.reagents.reagent_list.Copy())
			if(absorbed != src)
				affected_mob.reagents.remove_reagent(absorbed.type, 1)

/datum/reagent/medicine/donor_teporone
	name = "Teporone"
	description = "An experimental plasma compound which regulates body temperature."
	color = "#D782E6"
	overdose_threshold = 50
	taste_description = "warmth and stability"

/datum/reagent/medicine/donor_teporone/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	// Paradise regulated the outer body to 310 kelvin, not the species' core temperature.
	if(affected_mob.bodytemperature > 310)
		affected_mob.adjust_bodytemperature(-30 * seconds_per_tick * metabolization_ratio, 310)
	else if(affected_mob.bodytemperature < 310)
		affected_mob.adjust_bodytemperature(30 * seconds_per_tick * metabolization_ratio, 0, 310)

/datum/reagent/toxin/donor_atrazine
	name = "Atrazine"
	description = "A herbicidal compound used for destroying unwanted plants."
	color = "#773E73"
	toxpwr = 1
	taste_description = "bitterness"

/datum/reagent/toxin/donor_atrazine/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	mytray.adjust_weedlevel(-volume)

/datum/reagent/toxin/donor_atrazine/expose_obj(obj/exposed_obj, reac_volume, methods = TOUCH, show_message = TRUE)
	. = ..()
	if(istype(exposed_obj, /obj/structure/alien/weeds))
		var/obj/structure/alien/weeds/weeds = exposed_obj
		weeds.take_damage(rand(15, 35))

/datum/reagent/donor_cholesterol
	name = "Cholesterol"
	description = "Pure cholesterol. Probably not very good for you."
	color = "#FFFAC8"
	taste_description = "heart attack"

/datum/reagent/donor_cholesterol/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(volume >= 25 && SPT_PROB(volume * 0.15, seconds_per_tick / 2))
		to_chat(affected_mob, span_warning("Your chest feels uncomfortable!"))
		affected_mob.adjust_tox_loss(rand(1, 2))
	else if(volume >= 45 && SPT_PROB(volume * 0.08, seconds_per_tick / 2))
		to_chat(affected_mob, span_warning("Your chest hurts!"))
		affected_mob.adjust_tox_loss(rand(2, 4))
		affected_mob.Stun(2 SECONDS)
	else if(volume >= 150 && SPT_PROB(volume * 0.01, seconds_per_tick / 2))
		to_chat(affected_mob, span_warning("Your chest is burning with pain!"))
		affected_mob.Knockdown(2 SECONDS)
		affected_mob.set_heartattack(TRUE)

/datum/reagent/consumable/donor_egg
	name = "Egg"
	description = "A runny and viscous mixture of clear and yellow fluids."
	color = "#F0C814"
	taste_description = "eggs"

/datum/reagent/consumable/donor_egg/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(SPT_PROB(3, seconds_per_tick / 2))
		affected_mob.reagents.add_reagent(/datum/reagent/donor_cholesterol, rand(1, 2))

/datum/reagent/consumable/donor_cheese
	name = "Cheese"
	description = "Some cheese. Pour it out to make it solid."
	color = "#FFFF00"
	taste_description = "cheese"

/datum/reagent/consumable/donor_cheese/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(SPT_PROB(3, seconds_per_tick / 2))
		affected_mob.reagents.add_reagent(/datum/reagent/donor_cholesterol, rand(1, 2))

/datum/reagent/consumable/donor_cheese/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume >= 5 && !isspaceturf(exposed_turf))
		new /obj/item/food/cheese/wedge(exposed_turf)

/datum/reagent/consumable/donor_chocolate
	name = "Chocolate"
	description = "A delightful product derived from the seeds of the theobroma cacao tree."
	color = "#2E2418"
	nutriment_factor = 5
	taste_description = "chocolate"

/datum/reagent/consumable/donor_chocolate/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.reagents.add_reagent(/datum/reagent/consumable/sugar, 0.4 * seconds_per_tick)

/datum/reagent/consumable/donor_chocolate/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume >= 5 && !isspaceturf(exposed_turf))
		new /obj/item/food/donor_chocolate_pile(exposed_turf)

/datum/reagent/donor_ectoplasm
	name = "Ectoplasm"
	description = "A bizarre gelatinous substance supposedly derived from ghosts."
	color = "#8EAE7B"
	taste_description = "spooks"

/datum/reagent/donor_ectoplasm/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(SPT_PROB(8, seconds_per_tick / 2))
		to_chat(affected_mob, span_warning("[pick("You notice something moving out of the corner of your eye, but nothing is there...", "You feel uneasy.", "You shudder as if cold...", "You feel something gliding across your back...")]"))

/datum/reagent/donor_ectoplasm/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume)
	. = ..()
	if(methods & INGEST)
		to_chat(exposed_mob, span_warning("Your mouth feels haunted. Haunted with bad flavors."))

/datum/reagent/donor_ectoplasm/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume >= 10 && !isspaceturf(exposed_turf))
		new /obj/item/food/donor_ectoplasm(exposed_turf)

/obj/item/food/donor_chocolate_pile
	name = "chocolate pile"
	desc = "A pile of chocolate."
	icon = 'modular_bandastation/donor_jobs/icons/food.dmi'
	icon_state = "cocoa"
	food_reagents = list(/datum/reagent/consumable/donor_chocolate = 5)
	tastes = list("chocolate" = 1)
	foodtypes = SUGAR

/obj/item/food/donor_ectoplasm
	name = "ectoplasm"
	desc = "A luminescent blob of what scientists refer to as 'ghost goo'."
	icon = 'modular_bandastation/donor_jobs/icons/wizard.dmi'
	icon_state = "ectoplasm"
	food_reagents = list(/datum/reagent/donor_ectoplasm = 10)
	tastes = list("spookiness" = 1)
