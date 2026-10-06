/datum/job/donor/administrator
	title = "Administrator"
	description = "Координация сервиса, помощь HoP и организация мероприятий. Не глава отдела, не замена HoP, не администратор сервера."
	donor_tier = 3
	config_tag = "DONOR_ADMINISTRATOR"
	total_positions = 1
	spawn_positions = 1
	display_order = 29
	outfit = /datum/outfit/job/donor/administrator
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/service)
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Сервис-администратор", /datum/outfit/job/donor/administrator),
		"title_d20908b6e6" = list("Сервис-Администратор", /datum/outfit/job/donor/administrator),
		"title_1e7d8aded0" = list("Сервис-Управитель", /datum/outfit/job/donor/administrator),
		"title_b4112b1abe" = list("Помпадур", /datum/outfit/job/donor/administrator),
		"title_e3c0153ea3" = list("Сервис-Менеджер", /datum/outfit/job/donor/administrator),
	)
