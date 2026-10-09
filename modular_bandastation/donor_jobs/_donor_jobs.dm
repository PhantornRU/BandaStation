/datum/modpack/donor_jobs
	name = "Donor jobs"
	desc = "Нативные профессии для подписчиков и варианты штатных профессий."
	author = "PhantornRU"

/datum/modpack/donor_jobs/initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))
	GLOB.job_titles_ru += list(
		"Barber" = "Парикмахер",
		"Bath" = "Банщик",
		"Casino" = "Крупье",
		"Waiter" = "Официант",
		"Acolyte" = "Послушник",
		"Wrestler" = "Борец",
		"Musician" = "Музыкант",
		"Actor" = "Актёр",
		"Administrator" = "Сервис-администратор",
		"Tourist TSF" = "Турист ТСФ",
		"Tourist USSP" = "Турист СССП",
		"Cleaning Manager" = "Менеджер по клинингу",
		"Guard" = "Охранник сервиса",
		"Migrant" = "Мигрант",
		"Uncertain" = "Безработный",
		"Adjutant" = "Адъютант",
		"Representative TSF" = "Представитель ТСФ",
		"Representative USSP" = "Представитель СССП",
		"Dealer" = "Торговец",
		"VIP Corporate Guest" = "VIP-гость корпорации",
		"Banker" = "Банкир",
		"Security Clown" = "Клоун СБ",
	)
	GLOB.job_titles_ru_to_en.Cut()

/datum/modpack/donor_jobs/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	job.apply_donor_spawn_context(spawned)

/datum/modpack/donor_jobs/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN)
	return ..()
