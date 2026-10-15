/// Whether automatic staffing and random latejoin require an enabled job preference.
/datum/job/proc/requires_explicit_preference()
	return FALSE

/// Additional job admission rules. A null reason preserves ordinary admission.
/datum/job/proc/get_join_lock_reason(client/player)
	SHOULD_CALL_PARENT(TRUE)
	return null

/// Runs before preference application, appearance checks and the greeting; must not yield.
/datum/job/proc/prepare_spawn_character(mob/living/body, datum/preferences/preferences)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	return

/// A character-specific outfit. Native jobs still dispatch through get_outfit().
/datum/job/proc/get_spawn_outfit(mob/living/carbon/human/body, datum/preferences/preferences, visual_only, consistent)
	return get_outfit(consistent)

/// Display metadata only; never replace a canonical job title, trim or ban key.
/datum/job/proc/get_character_job_title(datum/job_character_selection/character)
	return job_title_ru(title)

/// Isolated HUD glyph for the selected character; display metadata only.
/datum/job/proc/get_character_job_icon(datum/job_character_selection/character)
	return get_job_hud_icon(src)

/// Outfits may replace one backpack insertion while ordinary outfits retain native overflow deletion.
/datum/outfit/proc/equip_backpack_item(mob/living/carbon/human/user, item_path)
	return user.equip_to_storage(SSwardrobe.provide_type(item_path, user), ITEM_SLOT_BACK, indirect_action = TRUE, del_on_fail = TRUE)

/datum/id_trim/job
	/// Expose a registered job template only through native CentCom authentication.
	var/centcom_template = FALSE
