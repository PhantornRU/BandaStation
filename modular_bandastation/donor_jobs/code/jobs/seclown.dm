/datum/job/donor/seclown
	title = "Security Clown"
	description = "Моральная поддержка СБ. Подчинён HoS, принадлежит Security, но по тексту не офицер. Не охотиться за антагонистами при действующих офицерах."
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
