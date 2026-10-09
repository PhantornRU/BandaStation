/datum/job/prisoner
	important_information = "Вы ЗАКЛЮЧЕННЫЙ. Вы не являетесь антагонистом на сервере и данная роль не позволяет вам нарушать правила сервера. \
		Вы находитесь на временном содержании в бриге станции принадлежащей Нанотрейзен за преступление против \
		корпорации и теперь отбываете свой срок.  Вы заинтересованы в том чтобы попасть на волю за хорошее поведение, но \
		если выдастся случай для побега - вам никто не запретит этим воспользоваться, верно?  Избегайте любых действий \
		которые могут привести к вашей гибели. Вы не служите Синдикату и не заинтересованы помогать им, если не \
		являетесь антагонистом, но если они помогут вам - то почему бы и да."
	donor_variant_specs = list(
		"default" = list("Заключённый", /datum/outfit/job/prisoner),
		"title_f095933019" = list("Заключенный", /datum/outfit/job/prisoner),
		"title_b4b118ef86" = list("Уголовник", /datum/outfit/job/prisoner),
		"title_d49f7780c4" = list("Законопреступник", /datum/outfit/job/prisoner),
		"title_3f92b3561f" = list("Пермазаключенный", /datum/outfit/job/prisoner),
		"title_ccb8d414fd" = list("Нелегальный Мигрант", /datum/outfit/job/prisoner),
		"title_fb54083629" = list("Нелегальный Работник", /datum/outfit/job/prisoner),
		"title_5aaf5a10d4" = list("Пожизненно-Заключенный", /datum/outfit/job/prisoner),
		"title_efc5efc07d" = list("Политический Заключенный", /datum/outfit/job/prisoner),
		"title_12ea21d982" = list("Заключенный Преступник", /datum/outfit/job/prisoner),
		"title_51658087b8" = list("Заключенный Бандит", /datum/outfit/job/prisoner),
		"title_7fd85bb83b" = list("Заключенный Мошенник", /datum/outfit/job/prisoner),
		"title_29e731561e" = list("Заключенный Вор", /datum/outfit/job/prisoner),
		"title_2c9f46ef15" = list("Заключенный Убийца", /datum/outfit/job/prisoner),
		"title_80cc8cd7d4" = list("Заключенный Наркоторговец", /datum/outfit/job/prisoner),
		"title_a8be352fd0" = list("Заключенный Рецидивист", /datum/outfit/job/prisoner),
		"title_3c5e9af02c" = list("Заключенный Саботер", /datum/outfit/job/prisoner),
		"title_f3e52e13db" = list("Заключенный Мучитель", /datum/outfit/job/prisoner),
		"title_224ed57414" = list("Заключенный Жулик", /datum/outfit/job/prisoner),
		"title_fa2a83402f" = list("Заключенный Негодяй", /datum/outfit/job/prisoner),
		"title_68303ec240" = list("Заключенный Хулиган", /datum/outfit/job/prisoner),
		"title_c298f2d33f" = list("Заключенный Враг-NT", /datum/outfit/job/prisoner),
		"title_17b4c084eb" = list("Заключенный Мафиози", /datum/outfit/job/prisoner),
		"title_52e5e8a719" = list("Заключенный Коррупционер", /datum/outfit/job/prisoner),
		"title_af200c4bc2" = list("Заключенный Психопат", /datum/outfit/job/prisoner),
		"title_3c00350498" = list("Заключенный Фальшивокредитчик", /datum/outfit/job/prisoner),
		"title_1aca9d1c4c" = list("Заключенный Работорговец", /datum/outfit/job/prisoner),
	)

/datum/job/prisoner/config_check()
	if(CONFIG_GET(flag/donor_prisoner_gate))
		if(isnull(CHECK_MAP_JOB_CHANGE(title, "total_positions")))
			total_positions = 5
		if(isnull(CHECK_MAP_JOB_CHANGE(title, "spawn_positions")))
			spawn_positions = 3
		random_spawns_possible = FALSE
	return ..()

/datum/job/prisoner/get_donor_variants()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return list()
	return ..()

/datum/job/prisoner/requires_explicit_preference()
	return CONFIG_GET(flag/donor_prisoner_gate)
