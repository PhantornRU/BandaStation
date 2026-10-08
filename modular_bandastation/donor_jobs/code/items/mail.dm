/obj/item/mail
	/// A delivery is reimbursed once, independently of which scanner was used.
	var/donor_delivery_claimed = FALSE

/obj/item/donor_mail_scanner
	name = "mail scanner"
	desc = "Отсканируйте письмо и его получателя, чтобы подтвердить доставку и пополнить бюджет снабжения."
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/datum/weakref/scanned_mail

/obj/item/donor_mail_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/mail))
		var/obj/item/mail/letter = interacting_with
		if(letter.donor_delivery_claimed || !letter.postmarked || !letter.recipient_ref?.resolve())
			balloon_alert(user, "неподходящее письмо")
			return ITEM_INTERACT_BLOCKING
		scanned_mail = WEAKREF(letter)
		balloon_alert(user, "письмо записано")
		playsound(src, 'sound/machines/beep/twobeep_high.ogg', 50, TRUE)
		return ITEM_INTERACT_SUCCESS
	if(!isliving(interacting_with))
		return NONE
	var/mob/living/recipient = interacting_with
	var/obj/item/mail/letter = scanned_mail?.resolve()
	if(!letter || letter.donor_delivery_claimed || recipient.stat == DEAD || !recipient.client || letter.recipient_ref?.resolve() != recipient.mind)
		balloon_alert(user, "доставка не подтверждена")
		return ITEM_INTERACT_BLOCKING
	var/datum/bank_account/department/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(!cargo)
		return ITEM_INTERACT_BLOCKING
	letter.donor_delivery_claimed = TRUE
	scanned_mail = null
	cargo.adjust_money(100, "Mail delivery: [recipient.real_name]")
	SSblackbox.record_feedback("amount", "successful_mail_delivery", 1)
	balloon_alert(user, "доставка: 100 кредитов")
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/storage/bag/mail/donor
	w_class = WEIGHT_CLASS_TINY
	storage_type = /datum/storage/bag/mail/donor

/datum/storage/bag/mail/donor/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(list(/obj/item/mail, /obj/item/delivery/small, /obj/item/paper, /obj/item/bounty_cube, /obj/item/donor_mail_scanner, /obj/item/pen, /obj/item/stamp))
