/datum/job/donor/bath
	title = "Bath"
	description = "Баня, встречи и разговоры. Отдельной системы нагрева/пара в коде роли нет."
	donor_tier = 2
	config_tag = "DONOR_BATH"
	total_positions = 1
	spawn_positions = 1
	display_order = 22
	outfit = /datum/outfit/job/donor/bath
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Банщик", /datum/outfit/job/donor/bath),
		"title_59b875790f" = list("Хозяин Бани", /datum/outfit/job/donor/bath),
		"title_4bed95ffa5" = list("Парильщик", /datum/outfit/job/donor/bath),
		"title_298399a251" = list("Пармейстер", /datum/outfit/job/donor/bath),
	)
