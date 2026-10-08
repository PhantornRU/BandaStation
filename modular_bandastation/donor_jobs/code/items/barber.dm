/obj/item/storage/box/donor_barber
	name = "barber starter kit"
	desc = "Ножницы, краска и всё необходимое для ухода за волосами."

/obj/item/storage/box/donor_barber/PopulateContents()
	new /obj/item/razor/donor_scissors(src)
	new /obj/item/donor_hair_dye(src)
	new /obj/item/reagent_containers/cup/bottle/donor_hairgrowth(src)
	new /obj/item/reagent_containers/cup/bottle/donor_hair_dye(src)
	new /obj/item/reagent_containers/cup/bottle(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/clothing/mask/fakemoustache(src)

/obj/item/razor/donor_scissors
	name = "barber's scissors"
	desc = "Ножницы для стрижки волос и бороды."
	icon = 'modular_bandastation/donor_jobs/icons/barber.dmi'
	icon_state = "bscissor"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	sharpness = SHARP_POINTY

/obj/item/razor/donor_scissors/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.combat_mode || !ishuman(target_mob))
		return ..()
	var/mob/living/carbon/human/customer = target_mob
	var/obj/item/bodypart/head/head = customer.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !user.can_perform_action(customer, FORBID_TELEKINESIS_REACH))
		return
	var/beard_style
	var/hair_style
	if((head.head_flags & HEAD_FACIAL_HAIR) && !HAS_TRAIT(customer, TRAIT_SHAVED))
		beard_style = tgui_input_list(user, "Выберите стиль бороды", "Стрижка", SSaccessories.facial_hairstyles_list)
	if((head.head_flags & HEAD_HAIR) && !HAS_TRAIT(customer, TRAIT_BALD))
		hair_style = tgui_input_list(user, "Выберите причёску", "Стрижка", SSaccessories.hairstyles_list)
	if(QDELETED(src) || !user.is_holding(src) || (!hair_style && !beard_style))
		return
	balloon_alert(user, "стрижём...")
	if(!do_after(user, 3.75 SECONDS, target = customer) || QDELETED(src) || !user.is_holding(src) || customer.get_bodypart(BODY_ZONE_HEAD) != head)
		return
	if(beard_style && !customer.is_mouth_covered())
		customer.set_facial_hairstyle(beard_style, update = FALSE)
	if(hair_style && customer.is_location_accessible(BODY_ZONE_HEAD))
		customer.set_hairstyle(hair_style, update = FALSE)
	customer.update_body_parts()
	customer.dna.update_dna_identity()
	balloon_alert(user, "готово")

/obj/item/donor_hair_dye
	name = "hair dye bottle"
	desc = "Многоразовый флакон краски для волос. Нажмите на него, чтобы выбрать цвет."
	icon = 'modular_bandastation/donor_jobs/icons/barber.dmi'
	icon_state = "hairdyebottle"
	w_class = WEIGHT_CLASS_TINY
	var/selected_dye_color = COLOR_WHITE

/obj/item/donor_hair_dye/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/donor_hair_dye/update_overlays()
	. = ..()
	var/mutable_appearance/dye = mutable_appearance(icon, "hairdyebottle-overlay")
	dye.color = selected_dye_color
	. += dye

/obj/item/donor_hair_dye/attack_self(mob/living/user)
	var/new_color = tgui_color_picker(user, "Цвет краски", "Краска", selected_dye_color)
	if(!new_color || QDELETED(src) || !user.is_holding(src))
		return
	selected_dye_color = sanitize_hexcolor(new_color)
	update_appearance()

/obj/item/donor_hair_dye/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.combat_mode || !ishuman(target_mob))
		return ..()
	var/mob/living/carbon/human/customer = target_mob
	var/obj/item/bodypart/head/head = customer.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		return
	var/list/options = list()
	if(head.head_flags & HEAD_HAIR)
		options += list("Волосы", "Градиент волос")
	if(head.head_flags & HEAD_FACIAL_HAIR)
		options += list("Борода", "Градиент бороды")
	if(HAS_TRAIT(customer, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(customer, TRAIT_FIXED_MUTANT_COLORS))
		options += "Тело"
	var/area_to_dye = tgui_input_list(user, "Что покрасить?", "Краска", options)
	if(!area_to_dye || QDELETED(src) || !user.is_holding(src) || !do_after(user, 5 SECONDS, target = customer))
		return
	if(QDELETED(src) || !user.is_holding(src) || customer.get_bodypart(BODY_ZONE_HEAD) != head)
		return
	switch(area_to_dye)
		if("Волосы")
			customer.set_haircolor(selected_dye_color)
		if("Борода")
			customer.set_facial_haircolor(selected_dye_color)
		if("Градиент волос")
			customer.set_hair_gradient_color(selected_dye_color)
		if("Градиент бороды")
			customer.set_facial_hair_gradient_color(selected_dye_color)
		if("Тело")
			customer.dna.features[FEATURE_MUTANT_COLOR] = selected_dye_color
			customer.update_body(is_creating = TRUE)
	customer.dna.update_dna_identity()

/obj/item/reagent_containers/cup/bottle/donor_hairgrowth
	name = "hairgrownium bottle"
	list_reagents = list(/datum/reagent/barbers_aid = 30)

/obj/item/reagent_containers/cup/bottle/donor_hair_dye
	name = "quantum hair dye bottle"
	list_reagents = list(/datum/reagent/hair_dye = 30)
