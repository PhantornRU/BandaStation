/datum/job/donor/actor
	title = "Actor"
	description = "Шоу, сцена и совместные представления с другими артистами."
	donor_tier = 2
	config_tag = "DONOR_ACTOR"
	total_positions = 5
	spawn_positions = 5
	display_order = 28
	outfit = /datum/outfit/job/donor/actor
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Актёр", /datum/outfit/job/donor/actor),
		"title_980bd5882d" = list("Актер", /datum/outfit/job/donor/actor),
		"title_e639ea25de" = list("Артист", /datum/outfit/job/donor/actor/artist),
		"title_666e779ffe" = list("Стендапер", /datum/outfit/job/donor/actor),
		"title_402e7e66c9" = list("Комедиант", /datum/outfit/job/donor/actor/comedian),
		"title_b7d6ec5648" = list("Эстрадный Артист", /datum/outfit/job/donor/actor/stage),
		"title_6f18f1d35f" = list("Художник", /datum/outfit/job/donor/actor/painter),
		"title_3e555ea0d3" = list("Творец", /datum/outfit/job/donor/actor/painter),
		"title_2e5c5324c9" = list("Искусствовед", /datum/outfit/job/donor/actor/painter),
		"title_461c5e40dd" = list("Пейзажист", /datum/outfit/job/donor/actor/painter),
		"title_404e8c6af6" = list("Фотореалист", /datum/outfit/job/donor/actor/painter),
		"title_ca1e1a3fe6" = list("Перфоманс-Артист", /datum/outfit/job/donor/actor/painter),
	)
