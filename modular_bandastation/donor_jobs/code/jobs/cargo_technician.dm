/datum/job/cargo_technician
	important_information = "Вы ДОСТАВЩИК. Данная роль нацелена на доставку товаров от одного отдела до другого. Ваше призвание - доставлять \
		ресурсы от отдела до отдела или еду от самого ШЕФа."
	donor_variant_specs = list(
		"default" = list(JOB_CARGO_TECHNICIAN_RU, /datum/outfit/job/cargo_tech),
		"title_c3e626e8a5" = list("Deliverer", /datum/outfit/job/cargo_tech/donor_deliverer),
		"title_9bc06590d6" = list("Доставщик", /datum/outfit/job/cargo_tech/donor_deliverer),
		"title_1044de84e6" = list("Переносчик", /datum/outfit/job/cargo_tech/donor_deliverer),
	)
