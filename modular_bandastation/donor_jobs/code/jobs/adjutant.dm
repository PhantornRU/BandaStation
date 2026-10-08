/datum/job/donor/adjutant
	important_information = "Вы Адъютант. Данная роль нацелена на помощь главам в соблюдении их СРП и заполнении бумаг.  Вы тот, кто поможет \
		капитану нужным советом или своевременно принесет ему чашечку кофе, чтобы он  легче перенес работу. Вы тот, кто \
		следит за ментальным здоровьем глав и помощи в исполнении их обязанностей.  \nВы не являетесь АВД или НТР'ом и \
		можете не исполнять их обязанности. Но вы можете работать сообща с Юридическим Отделом."
	variant_information = list(
		/datum/outfit/job/donor/adjutant/butler = "Вы ДВОРЕЦКИЙ. Данная роль нацелена на обеспечение глав в удовлетворении физических потребностей, а мостик в \
			чистоте.",
		/datum/outfit/job/donor/adjutant/maid = "Вы ГОРНИЧНАЯ. Данная роль нацелена на обеспечение глав в удовлетворении физических потребностей, а мостик в \
			чистоте.",
	)
	title = "Adjutant"
	description = "Помощник глав по документам, советам и бытовым вопросам. Подчинён HoP и капитану. Не АВД и не представитель NT."
	donor_tier = 4
	config_tag = "DONOR_ADJUTANT"
	total_positions = 3
	spawn_positions = 3
	display_order = 36
	outfit = /datum/outfit/job/donor/adjutant
	supervisors = "главой персонала и капитаном"
	departments_list = list(/datum/job_department/service)
	job_flags = (STATION_JOB_FLAGS & ~JOB_CAN_BE_INTERN) | JOB_CANNOT_OPEN_SLOTS | JOB_ANTAG_BLACKLISTED
	paycheck_department = ACCOUNT_SRV
	donor_variant_specs = list(
		"default" = list("Адъютант", /datum/outfit/job/donor/adjutant),
		"title_676e2d10c4" = list("Butler", /datum/outfit/job/donor/adjutant/butler),
		"title_194cb4f395" = list("Дворецкий", /datum/outfit/job/donor/adjutant/butler),
		"title_7076a8eeb7" = list("Maid", /datum/outfit/job/donor/adjutant/maid),
		"title_45cfde778e" = list("Горничная", /datum/outfit/job/donor/adjutant/maid),
	)
