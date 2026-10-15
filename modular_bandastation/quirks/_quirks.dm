/datum/modpack/quirks
	/// A string name for the modpack. Used for looking up other modpacks in init.
	name = "Quirks"
	/// A string desc for the modpack. Can be used for modpack verb list as description.
	desc = "Добавляет кастомные квирки (например для выбора в профиле персонажа)"
	/// A string with authors of this modpack.
	author = "Undesired"

/// Native handover can lose its client before the caller assigns quirks.
/datum/controller/subsystem/processing/quirks/AssignQuirks(mob/living/user, client/applied_client)
	if(!applied_client)
		return
	return ..()
