/obj/item/donor_payment_terminal
	name = "portable payment terminal"
	desc = "Переносной терминал для выставления счетов через банковский счёт вашей ID-карты."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/donor_payment_terminal/attack_self(mob/living/user)
	. = ..()
	var/obj/item/card/id/card = user.get_idcard(hand_first = FALSE)
	if(!card?.registered_account)
		balloon_alert(user, "нужна ID со счётом")
		return
	card.try_project_paystand(user, get_turf(user))

/obj/item/door_remote/donor_janitor
	name = "janitor's keyring"
	desc = "Связка ключей от входов в отделы и помещений сервиса. Подбор нужного ключа требует времени."
	icon = 'modular_bandastation/donor_jobs/icons/keyring.dmi'
	icon_state = "keyring"
	var/busy = FALSE
	COOLDOWN_DECLARE(jangle_cooldown)

/obj/item/door_remote/donor_janitor/update_icon_state()
	icon_state = "keyring"

/obj/item/door_remote/donor_janitor/LateInitialize()
	. = ..()
	access_list = list(ACCESS_MEDICAL, ACCESS_SCIENCE, ACCESS_CONSTRUCTION, ACCESS_CARGO, ACCESS_MINING, ACCESS_KITCHEN, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE)

/obj/item/door_remote/donor_janitor/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, jangle_cooldown))
		return
	playsound(src, 'modular_bandastation/donor_jobs/sound/keyring_shake.ogg', 50, TRUE)
	COOLDOWN_START(src, jangle_cooldown, 10 SECONDS)

/obj/item/door_remote/donor_janitor/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/item/door_remote/donor_janitor/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!user.Adjacent(interacting_with) || busy || !istype(interacting_with, /obj/machinery/door))
		return ITEM_INTERACT_BLOCKING
	var/obj/machinery/door/door = interacting_with
	if(!door.opens_with_door_remote || !door.density || !door.hasPower() || !door.check_access_list(access_list))
		balloon_alert(user, "не подходит ключ")
		return ITEM_INTERACT_BLOCKING
	busy = TRUE
	playsound(src, 'modular_bandastation/donor_jobs/sound/keyring_unlock.ogg', 50, TRUE)
	var/delay = istype(user.mind?.assigned_role, /datum/job/janitor) ? rand(5, 20) SECONDS : rand(30, 60) SECONDS
	var/finished = do_after(user, delay, target = door)
	busy = FALSE
	if(!finished || QDELETED(door) || QDELETED(src) || !user.is_holding(src))
		return ITEM_INTERACT_BLOCKING
	if(!door.opens_with_door_remote || !door.hasPower() || !door.check_access_list(access_list))
		return ITEM_INTERACT_BLOCKING
	if(door.density)
		door.add_hiddenprint(user)
		door.open()
	return ITEM_INTERACT_SUCCESS
