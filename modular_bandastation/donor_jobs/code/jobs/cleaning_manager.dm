/datum/job/donor/cleaning_manager
	important_information = "Поддерживайте чистоту станции. Для ключа уборщика требуется штатная временная авторизация через устройство аутентификации глав."
	variant_information = list(
		/datum/outfit/job/donor/cleaning_manager/apprentice = "Работайте с инструментами, обустройте мастерскую и помогайте станции. Для работ в отделах согласуйте доступ и задачи с их сотрудниками.",
	)
	title = "Cleaning Manager"
	description = "Уборка станции, обслуживание освещения и организация чистоты."
	donor_tier = 3
	config_tag = "DONOR_CLEANING_MANAGER"
	total_positions = 2
	spawn_positions = 2
	display_order = 32
	outfit = /datum/outfit/job/donor/cleaning_manager
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Менеджер по клинингу", /datum/outfit/job/donor/cleaning_manager),
		"title_af28e87894" = list("Менеджер по Клинингу", /datum/outfit/job/donor/cleaning_manager),
		"title_699f9246d9" = list("Ловец Крыс", /datum/outfit/job/donor/cleaning_manager),
		"title_2182b9664c" = list("Уборщик I-разряда", /datum/outfit/job/donor/cleaning_manager),
		"title_b00e6b3ad8" = list("Уборщик II-разряда", /datum/outfit/job/donor/cleaning_manager),
		"title_e84a0954fc" = list("Уборщик III-разряда", /datum/outfit/job/donor/cleaning_manager),
		"title_e0b933da94" = list("Уборщик IV-разряда", /datum/outfit/job/donor/cleaning_manager),
		"title_a3e33fb604" = list("Уборщик V-разряда", /datum/outfit/job/donor/cleaning_manager),
		"title_fb98757975" = list("Подмастерье", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"title_35f098909c" = list("Ассистент-Механик", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"title_5e938821f0" = list("Ассистент I-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"title_d28fdcea7d" = list("Ассистент II-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"title_aebaad8051" = list("Ассистент III-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"title_f9f1c4fee5" = list("Ассистент IV-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
		"title_8a2af0d4de" = list("Ассистент V-го разряда", /datum/outfit/job/donor/cleaning_manager/apprentice),
	)
