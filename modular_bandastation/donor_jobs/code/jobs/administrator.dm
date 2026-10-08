/datum/job/donor/administrator
	important_information = "Вы АДМИНИСТРАТОР. Данная роль нацелена для налаживания работы в Отделе Обслуживания. Наладьте производство, \
		помогите главе персонала пока он занимается бумагами, убедитесь что каждый работник выполняет свою работу и \
		делает это КАЧЕСТВЕННО!  А если всё замечательно, значит устройте новое развлечение или событие для экипажа. \
		Довольный экипаж - работоспособный экипаж.  \nВы не являетесь заменой главы персонала и подчиняетесь ему \
		напрямую. Вы не являетесь главой сервисного отдела.  Вы помощник, ассистент, консультант, наблюдатель, \
		организатор."
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
