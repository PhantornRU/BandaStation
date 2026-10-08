/datum/job/donor/tourist_ussp
	important_information = "Вы ТУРИСТ СССП. Вы прибыли сюда для отдыха и возможно для подработок. На вас по прежнему действует КЗ НТ, не \
		смотря на то  что вы являетесь гражданином СССП. ТСФ и СССП недоброжелательно относятся друг к другу, но это по \
		прежнему не дает нарушать правила сервера."
	title = "Tourist USSP"
	description = "Отдых и подработки иностранного посетителя; законы NT действуют, дипломатического иммунитета нет."
	donor_tier = 3
	config_tag = "DONOR_TOURIST_USSP"
	total_positions = -1
	spawn_positions = -1
	display_order = 31
	outfit = /datum/outfit/job/donor/tourist_ussp
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	donor_languages = list(/datum/language/donor_neorusskiya)
	donor_variant_specs = list(
		"default" = list("Турист СССП", /datum/outfit/job/donor/tourist_ussp),
		"title_7edf192313" = list("Посетитель СССП", /datum/outfit/job/donor/tourist_ussp),
	)
