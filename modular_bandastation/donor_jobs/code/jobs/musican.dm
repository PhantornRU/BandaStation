/datum/job/donor/musican
	important_information = "Играйте музыку, устраивайте концерты и выступайте вместе с другими артистами."
	title = "Musician"
	description = "Музыкальная атмосфера."
	donor_tier = 2
	config_tag = "DONOR_MUSICAN"
	total_positions = 1
	spawn_positions = 1
	display_order = 27
	outfit = /datum/outfit/job/donor/musican
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Музыкант", /datum/outfit/job/donor/musican),
		"title_1d6c0e0483" = list("Маэстро", /datum/outfit/job/donor/musican),
		"title_89d350c8f3" = list("Гитарист", /datum/outfit/job/donor/musican),
		"title_5369d65484" = list("Барабанщик", /datum/outfit/job/donor/musican),
		"title_8e41d8e8c6" = list("Пианист", /datum/outfit/job/donor/musican),
		"title_01a03ad63b" = list("Волынщик", /datum/outfit/job/donor/musican),
		"title_77f89f1bf1" = list("Скрипач", /datum/outfit/job/donor/musican),
		"title_0a2f7ed94c" = list("Скоморох", /datum/outfit/job/donor/musican),
		"title_80547d2c80" = list("Саксофонист", /datum/outfit/job/donor/musican),
		"title_524b7f6098" = list("Солист", /datum/outfit/job/donor/musican),
		"title_686160ec02" = list("Певец", /datum/outfit/job/donor/musican),
		"title_32be51e83f" = list("Гастролер", /datum/outfit/job/donor/musican),
	)
