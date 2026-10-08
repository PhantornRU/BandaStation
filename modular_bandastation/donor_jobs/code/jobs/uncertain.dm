/datum/job/donor/uncertain
	important_information = "Вы БЕЗРАБОТНЫЙ. Данная роль нацелена на бездумное брождение по техническим тоннелям. Вас когда-то оставили без \
		работы,  возможно эвакуационный шаттл улетел без вас, возможно технологии заменили вашу работу, причины могут \
		быть разные.  Но суть всего этого одна - вы были брошены и занимаетесь собственным выживанием."
	title = "Uncertain"
	description = "Забытый работник и выживание в технических тоннелях. Не автоматический антагонист."
	donor_tier = 3
	config_tag = "DONOR_UNCERTAIN"
	total_positions = -1
	spawn_positions = -1
	display_order = 35
	outfit = /datum/outfit/job/donor/uncertain
	supervisors = JOB_HEAD_OF_PERSONNEL_RU
	departments_list = list(/datum/job_department/assistant)
	donor_variant_specs = list(
		"default" = list("Безработный", /datum/outfit/job/donor/uncertain),
		"title_56a54c66c1" = list("Безработный Ассистент", /datum/outfit/job/donor/uncertain),
		"title_991a8712f0" = list("Свободный Ассистент", /datum/outfit/job/donor/uncertain),
		"title_243891c037" = list("Отрабатыващий Ассистент", /datum/outfit/job/donor/uncertain),
		"title_72948e94fd" = list("Ассистент Технических Тоннелей", /datum/outfit/job/donor/uncertain),
	)
