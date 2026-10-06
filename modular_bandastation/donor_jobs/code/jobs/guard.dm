/datum/job/donor/guard
	title = "Guard"
	description = "Порядок в баре и на кухне. Не сотрудник СБ и не охотник на антагонистов."
	donor_tier = 3
	config_tag = "DONOR_GUARD"
	total_positions = 1
	spawn_positions = 1
	display_order = 33
	outfit = /datum/outfit/job/donor/guard
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Охранник сервиса", /datum/outfit/job/donor/guard),
		"title_80a6d55193" = list("Охранник", /datum/outfit/job/donor/guard),
		"title_d56e622369" = list("Сторож Сервиса", /datum/outfit/job/donor/guard),
		"title_02173d4901" = list("Охранник Сервиса", /datum/outfit/job/donor/guard),
		"title_82bdb3534d" = list("Вышибала Сервиса", /datum/outfit/job/donor/guard),
	)
