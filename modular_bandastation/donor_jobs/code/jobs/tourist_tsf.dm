/datum/job/donor/tourist_tsf
	important_information = "Вы ТУРИСТ ТСФ. Вы прибыли сюда для отдыха и возможно для подработок. На вас по прежнему действует КЗ НТ, не \
		смотря на то  что вы являетесь гражданином ТСФ. ТСФ и СССП недоброжелательно относятся друг к другу, но это по \
		прежнему не дает нарушать правила сервера."
	title = "Tourist TSF"
	description = "Отдых и подработки иностранного посетителя; законы NT действуют. Вражда государств не разрешает нарушать правила."
	donor_tier = 3
	config_tag = "DONOR_TOURIST_TSF"
	total_positions = -1
	spawn_positions = -1
	display_order = 30
	outfit = /datum/outfit/job/donor/tourist_tsf
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	donor_languages = list(/datum/language/donor_tradeband)
	donor_variant_specs = list(
		"default" = list("Турист ТСФ", /datum/outfit/job/donor/tourist_tsf),
		"title_60a05c3bd2" = list("Посетитель ТСФ", /datum/outfit/job/donor/tourist_tsf),
	)
