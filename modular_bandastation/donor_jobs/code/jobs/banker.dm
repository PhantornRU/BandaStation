/datum/job/donor/banker
	important_information = "Начните своё дело со стартовыми 5000 кредитами: откройте банк или мастерскую, договоритесь с сотрудниками и клиентами."
	title = "Banker"
	description = "Богатый предприниматель: банк, мастерская, найм и бизнес через РП."
	donor_tier = 5
	config_tag = "DONOR_BANKER"
	total_positions = 2
	spawn_positions = 2
	display_order = 41
	outfit = /datum/outfit/job/donor/banker
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	donor_variant_specs = list(
		"default" = list("Банкир", /datum/outfit/job/donor/banker),
		"title_a9bad37f6c" = list("Независимый Банкир", /datum/outfit/job/donor/banker),
		"title_be26aa1f6c" = list("Корпорат", /datum/outfit/job/donor/banker),
		"title_8186c90396" = list("Бизнесмен", /datum/outfit/job/donor/banker),
		"title_dfd2a4023a" = list("Банкир NT", /datum/outfit/job/donor/banker),
		"title_9b812edd4a" = list("Корпорат NT", /datum/outfit/job/donor/banker),
		"title_cffc8f2bc5" = list("Бизнесмен NT", /datum/outfit/job/donor/banker),
	)
