/datum/job/donor/waiter
	important_information = "Принимайте заказы, доставляйте еду и поддерживайте ресторанную атмосферу."
	title = "Waiter"
	description = "Обслуживание посетителей и ресторанная атмосфера."
	donor_tier = 2
	config_tag = "DONOR_WAITER"
	total_positions = 2
	spawn_positions = 2
	display_order = 24
	outfit = /datum/outfit/job/donor/waiter
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Официант", /datum/outfit/job/donor/waiter),
		"title_c86b39312d" = list("Хост Сервиса", /datum/outfit/job/donor/waiter),
	)
