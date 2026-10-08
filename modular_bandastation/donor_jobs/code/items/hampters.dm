/obj/item/toy/donor_hampter
	name = "хамптер"
	desc = "Просто плюшевый хамптер. Самый обычный."
	icon = 'modular_bandastation/donor_jobs/icons/hampter.dmi'
	icon_state = "hampter"
	worn_icon = 'modular_bandastation/donor_jobs/icons/hampter_head.dmi'
	lefthand_file = 'modular_bandastation/donor_jobs/icons/hampter_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/hampter_righthand.dmi'
	slot_flags = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_TINY
	var/next_squeeze = 0

/obj/item/toy/donor_hampter/Initialize(mapload)
	. = ..()
	var/datum/component/squeak/squeak = AddComponent(/datum/component/squeak, list('modular_bandastation/donor_jobs/sound/squeaktoy.ogg' = 1), 50, use_delay_override = 1 SECONDS, extrarange = -10)
	// Crushing uses the source bone-break sound, without a preceding squeak.
	squeak.UnregisterSignal(src, COMSIG_ITEM_ATTACK_SELF)

/obj/item/toy/donor_hampter/attack_self(mob/user)
	if(world.time < next_squeeze)
		return
	next_squeeze = world.time + 1 SECONDS
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/holder = user
	if(!holder.combat_mode)
		playsound(src, 'modular_bandastation/donor_jobs/sound/squeaktoy.ogg', 50, TRUE, -10)
		return ..()
	holder.visible_message(span_warning("[holder] раздавил хамптера в своей руке!"), span_warning("Вы раздавили хамптера в своей руке!"))
	playsound(src, pick(
		'modular_bandastation/donor_jobs/sound/bone_break_1.ogg',
		'modular_bandastation/donor_jobs/sound/bone_break_2.ogg',
		'modular_bandastation/donor_jobs/sound/bone_break_3.ogg',
		'modular_bandastation/donor_jobs/sound/bone_break_4.ogg',
		'modular_bandastation/donor_jobs/sound/bone_break_5.ogg',
		'modular_bandastation/donor_jobs/sound/bone_break_6.ogg',
	), 50, TRUE, -10)
	holder.add_blood_DNA_to_items(list("Plush hampter's paint" = get_blood_type(/datum/blood_type/donor_hampter_paint)), ITEM_SLOT_GLOVES | ITEM_SLOT_HANDS)
	holder.blood_in_hands = 1
	holder.update_worn_gloves()
	qdel(src)

/datum/blood_type/donor_hampter_paint
	name = "hampter paint"
	dna_string = "Plush hampter's paint"
	color = "#d42929"
	blood_flags = BLOOD_ADD_DNA | BLOOD_COVER_ALL

/obj/item/toy/donor_hampter/assistant
	name = "хамптер ассистент"
	desc = "Плюшевый хамптер ассистент. Зачем ему изольки?"
	icon_state = "hampter_ass"

/obj/item/toy/donor_hampter/security
	name = "хамптер офицер"
	desc = "Плюшевый хамптер офицер службы безопасности. У него станбатон!"
	icon_state = "hampter_sec"

/obj/item/toy/donor_hampter/medical
	name = "хамптер врач"
	desc = "Плюшевый хамптер врач. Тащите дефибриллятор!"
	icon_state = "hampter_med"

/obj/item/toy/donor_hampter/janitor
	name = "хамптер уборщик"
	desc = "Плюшевый хамптер уборщик. Переключись на шаг."
	icon_state = "hampter_jan"

/obj/item/toy/donor_hampter/old_captain
	name = "хамптер старый капитан"
	desc = "Плюшевый хамптер капитан в старой униформе. Это какой год?"
	icon_state = "hampter_old-cap"

/obj/item/toy/donor_hampter/captain
	name = "хамптер капитан"
	desc = "Плюшевый хамптер капитан. Где его запасная карта?"
	icon_state = "hampter_cap"

/obj/item/toy/donor_hampter/syndicate
	name = "хамптер Синдиката"
	desc = "Плюшевый хамптер агент Синдиката. Ваши активы пострадают."
	icon_state = "hampter_sdy"

/obj/item/toy/donor_hampter/deadsquad
	name = "хамптер Дедсквада"
	desc = "Плюшевый хамптер Отряда Смерти. Все контракты расторгнуты."
	icon_state = "hampter_ded"

/obj/item/toy/donor_hampter/ert
	name = "хамптер ОБР"
	desc = "Плюшевый хамптер ОБР. Доложите о ситуации на станции."
	icon_state = "hampter_ert"
