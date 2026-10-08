/proc/donor_toy_choices(category)
	var/static/list/choices
	if(!choices)
		choices = list(
			"mech" = subtypesof(/obj/item/toy/figure/donor/mech),
			"carp" = typesof(/obj/item/toy/plush/donor/carpplushie) + /obj/item/toy/plush/carpplushie/dehy_carp,
			"plush" = subtypesof(/obj/item/toy/plush/donor) - typesof(/obj/item/toy/plush/donor/carpplushie) - typesof(/obj/item/toy/plush/donor/fluff),
			"figure" = subtypesof(/obj/item/toy/figure/donor/crew),
			"therapy" = subtypesof(/obj/item/toy/donor_therapy),
			"crayon" = list(
				/obj/item/toy/crayon/red,
				/obj/item/toy/crayon/orange,
				/obj/item/toy/crayon/yellow,
				/obj/item/toy/crayon/green,
				/obj/item/toy/crayon/blue,
				/obj/item/toy/crayon/purple,
			),
		)
		choices["random"] = list(
			/obj/item/gun/ballistic/shotgun/toy/crossbow,
			/obj/item/toy/waterballoon,
			/obj/item/toy/spinningtoy,
			/obj/item/reagent_containers/spray/waterflower,
		) + choices["mech"]
	var/list/result = choices[category]
	if(!length(result))
		CRASH("Unknown donor toy category: [category]")
	return result

/proc/donor_loot_type(entry)
	if(istext(entry))
		entry = pick(donor_toy_choices(entry))
	if(!ispath(entry, /obj/item))
		CRASH("Invalid donor loot declaration: [entry]")
	return entry

/obj/item/toy/donor_prizeball
	name = "prize ball"
	desc = "A toy is a toy, but a prize ball could be anything! It could even be a toy!"
	icon = 'modular_bandastation/donor_jobs/icons/arcade.dmi'
	icon_state = "prizeball_1"
	var/opening = FALSE
	var/prize_dispensed = FALSE
	var/list/possible_contents = list("carp", "plush", "figure", /obj/item/toy/donor_eight_ball, /obj/item/stack/arcadeticket/donor)
	var/datum/weakref/opened_by

/obj/item/toy/donor_prizeball/Initialize(mapload)
	. = ..()
	icon_state = pick("prizeball_1", "prizeball_2", "prizeball_3")

/obj/item/toy/donor_prizeball/attack_self(mob/user)
	if(opening)
		return
	opening = TRUE
	opened_by = WEAKREF(user)
	playsound(src, 'sound/items/bubblewrap.ogg', 30, TRUE)
	icon_state = "prizeconfetti"
	color = pick(COLOR_RED, COLOR_ORANGE, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PURPLE)
	addtimer(CALLBACK(src, PROC_REF(release_prize)), 1 SECONDS)

/obj/item/toy/donor_prizeball/proc/release_prize()
	if(!opening || prize_dispensed)
		return
	var/turf/drop_turf = get_turf(src)
	if(!drop_turf)
		return
	prize_dispensed = TRUE
	var/prize_type = donor_loot_type(pick(possible_contents))
	if(ispath(prize_type, /obj/item/stack))
		new prize_type(drop_turf, pick(5, 10, 15, 25, 50))
	else
		new prize_type(drop_turf)
	var/mob/user = opened_by?.resolve()
	user?.temporarilyRemoveItemFromInventory(src, force = TRUE)
	qdel(src)

/obj/item/toy/donor_prizeball/mech
	name = "mecha figure capsule"
	desc = "Contains one collectible mecha figure!"
	possible_contents = list("mech")

/obj/item/toy/donor_prizeball/carp_plushie
	name = "carp plushie capsule"
	desc = "Contains one space carp plushie!"
	possible_contents = list("carp")

/obj/item/toy/donor_prizeball/plushie
	name = "plushie capsule"
	desc = "Contains one cuddly plushie!"
	possible_contents = list("plush")

/obj/item/toy/donor_prizeball/figure
	name = "action figure capsule"
	desc = "Contains one action figure!"
	possible_contents = list("figure")

/obj/item/toy/donor_prizeball/therapy
	name = "therapy doll capsule"
	desc = "Contains one squishy therapy doll."
	possible_contents = list("therapy")

/obj/item/stack/arcadeticket/donor
	name = "prize ticket"
	desc = "Prize tickets from the arcade. Exchange them for fabulous prizes!"
	singular_name = "prize ticket"
	icon = 'modular_bandastation/donor_jobs/icons/arcade.dmi'
	icon_state = "tickets_1"
	force = 0
	throwforce = 0
	throw_speed = 1
	throw_range = 1
	max_amount = 9999
	merge_type = /obj/item/stack/arcadeticket/donor

/obj/item/stack/arcadeticket/donor/update_icon_state()
	. = ..()
	switch(get_amount())
		if(1 to 3)
			icon_state = "tickets_1"
		if(4 to 24)
			icon_state = "tickets_2"
		if(25 to 74)
			icon_state = "tickets_3"
		else
			icon_state = "tickets_4"
