/datum/job/donor/seclown
	important_information = "Вы КЛОУН СЛУЖБЫ БЕЗОПАСНОСТИ. Данная роль нацелена на обеспечения сотрудников службы безопасности ментальным \
		здоровьем и  поддерживать моральный облик вашего отдела. Вы не имеете права выступать против вашего отдела, ведь \
		вас тренировали для этого.  Корпорация NT вложило много денег чтобы сделать из клоуна... вас. Так не подведите \
		её. Вы то, что можно назвать корпоративным клоуном.  Ваша душа принадлежит NT, но ваше сердце по прежнему верно \
		Хонкомаме.  \nВ вас присутствует ген клоуна. Не занимайтесь охотой антагонистов если есть действующие сотрудники \
		службы безопасности.  Вы не являетесь офицером. Вы по прежнему клоун с полномочиями и гигантскими обязанностями. \
		Это непростая роль, ведь вы из-за своего положения  не можете творить множество вещей и действий нарушающие \
		Космический Закон."
	title = "Security Clown"
	description = "Поддерживайте мораль сотрудников СБ и подчиняйтесь начальнику отдела. Вы остаётесь клоуном: не охотьтесь за антагонистами, пока есть действующие офицеры."
	donor_tier = 5
	config_tag = "DONOR_SECLOWN"
	total_positions = 1
	spawn_positions = 1
	display_order = 42
	outfit = /datum/outfit/job/donor/seclown
	supervisors = JOB_HEAD_OF_SECURITY_RU
	departments_list = list(/datum/job_department/security)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	donor_languages = list(/datum/language/donor_clownish)
	plasmaman_outfit = /datum/outfit/plasmaman/clown
	paycheck_department = ACCOUNT_SEC
	donor_variant_specs = list(
		"default" = list("Клоун СБ", /datum/outfit/job/donor/seclown),
		"title_8cd08702d6" = list("Клоун Службы Безопасности", /datum/outfit/job/donor/seclown),
		"title_190bf220ef" = list("Клоун-Детектив", /datum/outfit/job/donor/seclown/detective),
		"title_a22b40d7a4" = list("Клоун-Смотритель", /datum/outfit/job/donor/seclown/warden),
		"title_2384147c33" = list("Хонкектив", /datum/outfit/job/donor/seclown/detective),
		"title_410a1ecab5" = list("Клоун Кадет", /datum/outfit/job/donor/seclown/cadet),
	)

/datum/job/donor/seclown/after_spawn(mob/living/spawned, client/player_client)
	if(ishuman(spawned))
		var/mob/living/carbon/human/human = spawned
		if(!human.donor_spawn_context?.identity_applied)
			human.apply_pref_name(/datum/preference/name/clown, player_client)
	return ..()
