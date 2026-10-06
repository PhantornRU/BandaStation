/datum/preferences
	var/donor_entry_locked = FALSE

/mob/dead/new_player
	var/datum/job_character_selection/assigned_character
	var/datum/donor_spawn_context/pending_donor_context

/datum/job_character_selection
	var/job_type
	var/slot
	var/randomized = FALSE
	var/age
	var/species
	var/variant_id
	var/prisoner_crime
	var/error

/// Inspect saved profiles without switching the character while jobs are evaluated.
/datum/preferences/proc/select_job_character(datum/job/job, latejoin = FALSE, forced_slot)
	var/datum/job_character_selection/result = new
	result.slot = default_slot
	result.job_type = job.type
	var/use_current = latejoin ? read_preference(/datum/preference/toggle/late_join_always_current_slot) : read_preference(/datum/preference/toggle/round_start_always_join_current_slot)
	if(!isnull(forced_slot))
		result.slot = forced_slot
	else if(!use_current)
		var/requested = pref_job_slots[job.title]
		if(isnull(requested))
			requested = LAZYACCESS(job_assigned_profiles, job.title)
		if(requested == -1)
			result.randomized = TRUE
		else if(!isnull(requested) && requested != 0)
			result.slot = requested
	if(!isnum(result.slot) || round(result.slot) != result.slot || result.slot < 1 || result.slot > max_save_slots)
		result.error = "Некорректный слот персонажа."
		return result
	var/list/variants
	if(result.slot == default_slot)
		result.age = read_preference(/datum/preference/numeric/age)
		result.species = read_preference(/datum/preference/choiced/species)
		variants = read_preference(/datum/preference/job_outfit_variants)
		if(istype(job, /datum/job/prisoner))
			result.prisoner_crime = read_preference(/datum/preference/choiced/prisoner_crime)
	else
		var/list/saved = savefile.get_entry("character[result.slot]")
		if(!islist(saved) || !saved["real_name"])
			result.error = "Назначенный профиль отсутствует; выберите существующий слот."
			return result
		var/datum/preference/age_pref = GLOB.preference_entries[/datum/preference/numeric/age]
		var/datum/preference/species_pref = GLOB.preference_entries[/datum/preference/choiced/species]
		if(isnull(saved[age_pref.savefile_key]) || isnull(saved[species_pref.savefile_key]))
			result.error = "Откройте и сохраните назначенный профиль перед входом."
			return result
		result.age = age_pref.deserialize(saved[age_pref.savefile_key], src)
		result.species = species_pref.deserialize(saved[species_pref.savefile_key], src)
		var/datum/preference/variants_pref = GLOB.preference_entries[/datum/preference/job_outfit_variants]
		variants = variants_pref.deserialize(saved[variants_pref.savefile_key], src)
		if(istype(job, /datum/job/prisoner))
			var/datum/preference/crime_pref = GLOB.preference_entries[/datum/preference/choiced/prisoner_crime]
			result.prisoner_crime = crime_pref.deserialize(saved[crime_pref.savefile_key], src)
	result.variant_id = variants?[job.title] || "default"
	return result

/datum/job_character_selection/proc/character_error(datum/job/job, client/player, latejoin)
	if(error)
		return error
	if(isnum(job.required_character_age) && (!isnum(age) || age < job.required_character_age))
		return "Персонаж назначенного профиля слишком молод."
	if(ispath(job.spawn_type, /mob/living/carbon/human))
		var/species_error = job.character_species_error(species)
		if(species_error)
			return species_error
	if(latejoin && CONFIG_GET(flag/allow_respawn) == RESPAWN_FLAG_NEW_CHARACTER)
		if("[slot]" in player.persistent_client.joined_as_slots)
			return "Вы уже играли на назначенном персонаже в этом раунде."
	return null

/datum/job/proc/character_species_error(species_type)
	var/list/restricted = CONFIG_GET(str_list/job_restrictions)
	var/list/allowed = CONFIG_GET(str_list/allowed_species)
	if(!(locate(/datum/station_trait/xenobureaucracy_error) in GLOB.lobby_station_traits) && (title in restricted) && length(allowed) && !("[species_type]" in allowed))
		return "Вид назначенного персонажа несовместим с профессией."
	return null

/datum/job_character_selection/proc/actual_body_error(datum/job/job, mob/living/body, datum/mind/player_mind)
	if(!ishuman(body))
		return null
	var/mob/living/carbon/human/human_body = body
	if(isnum(job.required_character_age) && human_body.age < job.required_character_age)
		return "Созданный персонаж не проходит возрастное ограничение."
	var/species_error = job.character_species_error(human_body.dna.species.type)
	if(species_error)
		return species_error
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in SSdynamic.queued_rulesets)
		if((player_mind in ruleset.selected_minds) && !ruleset.accepts_job_body(human_body))
			return "Созданный персонаж несовместим с выбранной ролью антагониста."
	return null

/mob/dead/new_player/proc/resolve_assigned_job_character(datum/job/job, latejoin = FALSE, forced_slot)
	if(assigned_character?.job_type == job.type && (isnull(forced_slot) || assigned_character.slot == forced_slot))
		return assigned_character
	QDEL_NULL(assigned_character)
	assigned_character = client.prefs.select_job_character(job, latejoin, forced_slot)
	return assigned_character

/mob/dead/new_player/proc/load_assigned_job_character()
	if(!assigned_character || assigned_character.error || !client)
		return FALSE
	if(client.prefs.default_slot != assigned_character.slot)
		// load_character reports obsolete/missing saves; switch_to_slot would create a replacement.
		if(!client.prefs.load_character(assigned_character.slot))
			return FALSE
	QDEL_NULL(pending_donor_context)
	if(mind.assigned_role.uses_donor_spawn_context())
		pending_donor_context = new(mind.assigned_role, assigned_character)
	return TRUE

/mob/dead/new_player/proc/attach_donor_spawn_context(mob/living/body)
	new_character = body
	if(client?.job_entry_guard)
		client.job_entry_guard.created_body = body
	if(!ishuman(body))
		return
	var/mob/living/carbon/human/human_body = body
	human_body.donor_spawn_context = pending_donor_context
	pending_donor_context = null
