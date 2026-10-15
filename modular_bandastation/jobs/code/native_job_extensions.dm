/// Select a live or preview variant before the native loadout equips its items.
/mob/living/carbon/human/dress_up_as_job(datum/job/equipping, visual_only = FALSE, client/player_client, consistent = FALSE)
	dna.species.pre_equip_species_outfit(equipping, src, visual_only)
	equip_outfit_and_loadout(equipping.get_spawn_outfit(src, player_client?.prefs, visual_only, consistent), player_client?.prefs, visual_only)

/// Keep the final native greeting proc intact while supplying a recipient to modular job instructions.
/datum/job/proc/get_character_spawn_message(mob/spawned)
	return boxed_message(span_infoplain(jointext(get_spawn_message_information(spawned), "\n&bull; ")))

/// Replace only the short construction boundary: calling the original would apply preferences too early.
/datum/job/get_spawn_mob(client/player_client, atom/spawn_point)
	var/mob/dead/new_player/requester = isnewplayer(player_client.mob) ? player_client.mob : null
	var/mob/living/spawn_instance
	if(ispath(spawn_type, /mob/living/silicon/ai))
		spawn_instance = new spawn_type(get_turf(spawn_point), player_client.mob, null, null, TRUE)
	else
		spawn_instance = spawn_point.JoinPlayerHere(spawn_type, TRUE)
	if(player_client)
		prepare_spawn_character(spawn_instance, player_client.prefs)
		spawn_instance.apply_prefs_job(player_client, src)
	if(!player_client || (requester?.assigned_character && player_client.prefs.default_slot != requester.assigned_character.slot))
		// AI initialization has already transferred the lobby mind to this unfinished body.
		if(isAI(spawn_instance) && !QDELETED(requester))
			spawn_instance.mind?.transfer_to(requester)
		qdel(spawn_instance)
		return
	return spawn_instance

/// The name/appearance lookup may disconnect the player before the remaining AI preferences run.
/mob/living/silicon/ai/apply_prefs_job(client/player_client, datum/job/job)
	if(GLOB.current_anonymous_theme)
		fully_replace_character_name(real_name, GLOB.current_anonymous_theme.anonymous_ai_name(TRUE))
		return
	apply_pref_name(/datum/preference/name/ai, player_client)
	if(!player_client)
		return
	set_core_display_icon(null, player_client)
	apply_pref_emote_display(player_client)
	apply_pref_hologram_display(player_client)

/// Replace both effects once: the global signal may disconnect the client before the overlay call.
/datum/job/after_latejoin_spawn(mob/living/spawning)
	SHOULD_CALL_PARENT(FALSE)
	// Calling the original would repeat the signal or dereference its now-missing client.
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, src, spawning)
	spawning.client?.show_spawn_text_overlay()
