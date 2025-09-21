/mob/living/basic/hostile/lizard
	name = "игуана"
	desc = "Грациозный предок космодраконов. Её взгляд не вызывает никаких враждебных подозрений... Но она по прежнему хочет съесть вас."
	icon = 'modular_bandastation/mobs/icons/mob/animal.dmi'
	icon_state = "iguana"
	icon_living = "iguana"
	icon_dead = "iguana_dead"
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs","grumbles","grawls")
	emote_see = list("stares ferociously", "stomps")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/monstermeat/lizardmeat = 3, /obj/item/stack/sheet/animalhide/lizard = 1)
	response_help_continuous = "гладит"
	response_help_simple = "погладил"
	response_disarm_continuous = "толкает"
	response_disarm_simple = "аккуратно оттолкнул"
	response_harm_continuous = "колошматит"
	response_harm_simple = "ударил"
	stop_automated_movement_when_pulled = 0
	speed = 2
	maxHealth = 40
	health = 40
	blood_volume = BLOOD_VOLUME_NORMAL
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_verb_continuous = "терзает"
	attack_verb_simple = "терзает"
	attack_sound = 'sound/weapons/bite.ogg'
	death_sound = 'modular_bandastation/mobs/sound/lizard_death_big.ogg'
	talk_sound = list('modular_bandastation/mobs/sound/lizard_angry1.ogg', 'modular_bandastation/mobs/sound/lizard_angry2.ogg', 'modular_bandastation/mobs/sound/lizard_angry3.ogg')
	damaged_sound = list('modular_bandastation/mobs/sound/lizard_damaged.ogg')

	minimum_survivable_temperature = 250 //Weak to cold
	maximum_survivable_temperature = T0C + 200

	gold_core_spawnable = HOSTILE_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/lizard/evil

/mob/living/basic/hostile/lizard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

/mob/living/basic/hostile/lizard/gator
	name = "аллигатор"
	desc = "Величавый аллигатор, так и норовящийся оторвать от вас самый лакомый кусочек. Или кусок. Не путать с крокодилом!"
	icon_state = "gator"
	icon_living = "gator"
	icon_dead = "gator_dead"
	butcher_results = list(/obj/item/food/monstermeat/lizardmeat = 7, /obj/item/stack/sheet/animalhide/lizard = 5)
	speed = 4
	maxHealth = 200
	health = 200
	obj_damage = 80
	melee_damage_lower = 30
	melee_damage_upper = 80

/mob/living/basic/hostile/lizard/croco
	name = "крокодил"
	desc = "Не стоит сувать голову ему в пасть! Это негативно сказывается на умственных способностях"
	icon_state = "steppy"
	icon_living = "steppy"
	icon_dead = "steppy_dead"
	butcher_results = list(/obj/item/food/monstermeat/lizardmeat = 5, /obj/item/stack/sheet/animalhide/lizard = 3)
	maxHealth = 100
	health = 100
	obj_damage = 80
	melee_damage_lower = 20
	melee_damage_upper = 50







