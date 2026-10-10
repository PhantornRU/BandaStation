/datum/job/donor/wrestler
	important_information = "Проводите дружеские соревнования, тренировки и спортивные представления с согласными участниками."
	title = "Wrestler"
	description = "Дружеские соревнования, тренировки и спортивные представления."
	donor_tier = 2
	config_tag = "DONOR_WRESTLER"
	total_positions = 4
	spawn_positions = 4
	display_order = 26
	outfit = /datum/outfit/job/donor/wrestler
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Борец", /datum/outfit/job/donor/wrestler),
		"title_fa0e90435e" = list("Рефери", /datum/outfit/job/donor/wrestler),
		"title_894d7eccc6" = list("Тренер", /datum/outfit/job/donor/wrestler),
		"title_1fac104508" = list("Боксёр", /datum/outfit/job/donor/wrestler),
		"title_0b7ca27e25" = list("Спортсмен", /datum/outfit/job/donor/wrestler),
	)
