/datum/job/donor/acolyte
	important_information = "Помогайте священнику проводить богослужения. Его религиозные способности и право освящать воду не передаются вам автоматически."
	title = "Acolyte"
	description = "Помощник священника. Не получает его религиозные способности и право освящать воду автоматически."
	donor_tier = 2
	config_tag = "DONOR_ACOLYTE"
	total_positions = 5
	spawn_positions = 5
	display_order = 25
	outfit = /datum/outfit/job/donor/acolyte
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Послушник", /datum/outfit/job/donor/acolyte),
		"title_fa2ad154cb" = list("Монах", /datum/outfit/job/donor/acolyte),
		"title_1678dcfc2b" = list("Приспешник", /datum/outfit/job/donor/acolyte),
		"title_5bf3063650" = list("Последователь", /datum/outfit/job/donor/acolyte),
		"title_ad3bbe9dea" = list("Обрядчик", /datum/outfit/job/donor/acolyte),
	)
