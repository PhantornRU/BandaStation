/datum/job/donor/dealer
	important_information = "Вы ТОРГОВЕЦ. Данная роль нацелена на продажу всячины, хлама и вещей экипажу. Обустройте себе торговую точку или \
		продавайте всё из ширмы.  Найдите любыми способами предметы у экипажа и продайте его им же! Либо же продайте \
		барахло которое вы привезли с собой.  Богатый торговец - успешный торговец!  \nВам выдан личный EFTPOS для \
		снятия средств с карт."
	title = "Dealer"
	description = "Продажа привезённого и найденного товара, торговая точка и расчёты через EFTPOS."
	donor_tier = 4
	config_tag = "DONOR_DEALER"
	total_positions = 2
	spawn_positions = 2
	display_order = 39
	outfit = /datum/outfit/job/donor/dealer
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	donor_languages = list(/datum/language/donor_tradeband)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Торговец", /datum/outfit/job/donor/dealer),
		"title_5b94e95f0b" = list("Независимый Торговец", /datum/outfit/job/donor/dealer/brown),
		"title_1c1fc9e1f6" = list("Сдельщик", /datum/outfit/job/donor/dealer/brown),
		"title_548b9257d9" = list("Барахольщик", /datum/outfit/job/donor/dealer/brown),
		"title_2fe62dd819" = list("Меценат", /datum/outfit/job/donor/dealer),
		"title_e4a058f1e6" = list("Коммерсант", /datum/outfit/job/donor/dealer),
	)
