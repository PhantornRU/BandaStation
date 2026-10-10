/datum/job/donor/barber
	important_information = "Стригите и окрашивайте волосы посетителей с их согласия. Машинка для стрижки и спрей для волос находятся в карманах."
	title = "Barber"
	description = "Добровольные стрижки и уход за внешностью посетителей."
	donor_tier = 2
	config_tag = "DONOR_BARBER"
	total_positions = 1
	spawn_positions = 1
	display_order = 21
	outfit = /datum/outfit/job/donor/barber
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	donor_variant_specs = list(
		"default" = list("Парикмахер", /datum/outfit/job/donor/barber),
		"title_6f6165b91f" = list("Стилист", /datum/outfit/job/donor/barber),
		"title_2c81d24615" = list("Хозяин Студии Красоты", /datum/outfit/job/donor/barber),
		"title_9c317438ff" = list("Визажист", /datum/outfit/job/donor/barber),
		"title_23113d9e46" = list("Куафёр", /datum/outfit/job/donor/barber),
		"title_ccd298be8c" = list("Цирюльник", /datum/outfit/job/donor/barber),
		"title_fd889e9fdb" = list("Брадобрей", /datum/outfit/job/donor/barber),
	)
