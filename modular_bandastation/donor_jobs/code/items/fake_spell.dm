/obj/item/book/granter/action/spell/donor_fake_gib
	name = "spellbook of disintegrate"
	desc = "This book feels like it will rip stuff apart."
	icon_state = "bookfireball"
	granted_action = /datum/action/cooldown/spell/touch/donor_fake_gib
	action_name = "disintegrate"
	pages_to_mastery = 0
	reading_time = 0

/datum/action/cooldown/spell/touch/donor_fake_gib
	name = "Disintegrate"
	desc = "This spell charges your hand with vile energy that can be used to violently explode victims."
	button_icon_state = "gib"
	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation = "EI NATH!!"
	sound = 'sound/effects/magic/disintegrate.ogg'
	hand_path = /obj/item/melee/touch_attack/donor_fake_gib

/datum/action/cooldown/spell/touch/donor_fake_gib/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	do_sparks(4, FALSE, get_turf(victim))
	playsound(victim, 'modular_bandastation/donor_jobs/sound/fake_gib.ogg', 50, TRUE)
	return TRUE

/obj/item/melee/touch_attack/donor_fake_gib
	name = "toy plastic hand"
	desc = "This hand of mine glows with an awesome power! Ok, maybe just batteries."
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	item_flags = ABSTRACT | HAND_ITEM
