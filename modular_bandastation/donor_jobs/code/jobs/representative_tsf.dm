/datum/job/donor/representative_tsf
	important_information = "Вы ПРЕДСТАВИТЕЛЬ ТСФ. Вы прибыли сюда для отдыха и возможно для переговоров. На вас по прежнему действует КЗ НТ, \
		не смотря на то  что вы являетесь гражданином ТСФ. ТСФ и СССП недоброжелательно относятся друг к другу, но это \
		по прежнему не дает нарушать правила сервера."
	title = "Representative TSF"
	description = "Гость для отдыха и переговоров; законы NT действуют, иммунитета нет."
	donor_tier = 4
	config_tag = "DONOR_REPRESENTATIVE_TSF"
	total_positions = 1
	spawn_positions = 1
	display_order = 37
	outfit = /datum/outfit/job/donor/representative_tsf
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	donor_languages = list(/datum/language/donor_tradeband)
	donor_variant_specs = list(
		"default" = list("Представитель ТСФ", /datum/outfit/job/donor/representative_tsf),
		"title_ca11487592" = list("Дипломат ТСФ", /datum/outfit/job/donor/representative_tsf),
		"title_7f78932f04" = list("Публицист ТСФ", /datum/outfit/job/donor/representative_tsf),
	)
