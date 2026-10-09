///Cooldown for the Reset Lobby Menu HUD verb
#define RESET_HUD_INTERVAL 15 SECONDS
/mob/dead/new_player
	flags_1 = NONE
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	stat = DEAD
	hud_type = /datum/hud/new_player

	/// String Values tied to Defines that state whether the new_player is ready to play or not.
	/// Do try your best to compare this value directly against the defines for certainty but helper procs do exist in bulkier situations.
	var/ready = PLAYER_NOT_READY
	/// Referenced when you want to delete the new_player later on in the code.
	var/spawning = FALSE
	/// For instant transfer once the round is set up
	var/mob/living/new_character
	///Used to make sure someone doesn't get spammed with messages if they're ineligible for roles.
	var/ineligible_for_roles = FALSE
	/// Used to track if the player's jobs menu sent a message saying it successfully mounted.
	var/jobs_menu_mounted = FALSE
	///Cooldown for the Reset Lobby Menu HUD verb
	COOLDOWN_DECLARE(reset_hud_cooldown)

/mob/dead/new_player/Initialize(mapload)
	if(client && SSticker.state == GAME_STATE_STARTUP)
		var/atom/movable/screen/splash/fade_out = new(null, null, client, TRUE)
		fade_out.fade(TRUE)

	if(length(GLOB.newplayer_start))
		forceMove(pick(GLOB.newplayer_start))
	else
		forceMove(locate(1,1,1))

	. = ..()

	GLOB.new_player_list += src
	ASSIGN_GAME_VERB(src, /mob/dead/new_player, reset_menu_hud)

/mob/dead/new_player/Destroy()
	GLOB.new_player_list -= src
	// BANDASTATION EDIT START - Transient selection belongs to the lobby mob
	QDEL_NULL(assigned_character)
	// BANDASTATION EDIT END

	return ..()

/mob/dead/new_player/mob_negates_gravity()
	return TRUE //no need to calculate if they have gravity.

/mob/dead/new_player/prepare_huds()
	return

/mob/dead/new_player/Topic(href, href_list)
	if (usr != src)
		return

	if (!client)
		return

	if (client.interviewee)
		return

	if (href_list["viewpoll"])
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.polls
		poll_player(poll)

	if (href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.polls
		vote_on_poll_handler(poll, href_list)

/// Quickly gets a boolean of whether the new_player is ready to play or not in places where we would like the boolean logic.
/// The assertion is that readiness must be an opted in TRUE, while all other states (e.g. not ready, broken, etc) are FALSE.
/// We organize it this way to ensure the system is extensible for other possible ready states.
/mob/dead/new_player/proc/is_ready_to_play()
	return ready == PLAYER_READY_TO_PLAY

//When you cop out of the round (NB: this HAS A SLEEP FOR PLAYER INPUT IN IT)
/mob/dead/new_player/proc/make_me_an_observer()
	if(QDELETED(src) || !src.client)
		ready = PLAYER_NOT_READY
		return FALSE

	var/less_input_message
	if(SSlag_switch.measures[DISABLE_DEAD_KEYLOOP])
		less_input_message = " - Notice: Observer freelook is currently disabled."
	// Don't convert this to tgui please, it's way too important
	var/this_is_like_playing_right = alert(usr, "Are you sure you wish to observe? You will not be able to play this round![less_input_message]", "Observe", "Yes", "No")
	if(QDELETED(src) || !src.client || this_is_like_playing_right != "Yes")
		ready = PLAYER_NOT_READY
		return FALSE

	SStitle.hide_title_screen_from(client) // BANDASTATION ADDITION - HTML Title Screen
	var/mob/dead/observer/observer = new()
	spawning = TRUE

	observer.started_as_observer = TRUE
	var/obj/effect/landmark/observer_start/O = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	to_chat(src, span_notice("Now teleporting."))
	if (O)
		observer.forceMove(O.loc)
	else
		to_chat(src, span_notice("Teleporting failed. Ahelp an admin please"))
		stack_trace("There's no freaking observer landmark available on this map or you're making observers before the map is initialised")

	observer.PossessByPlayer(key)
	observer.client = client
	observer.set_ghost_appearance()
	if(observer.client && observer.client.prefs)
		observer.real_name = observer.client.prefs.read_preference(/datum/preference/name/real_name)
		observer.name = observer.real_name
		observer.client.init_verbs()
		observer.update_time_of_death(world.time) // BANDASTATION EDIT - Context-aware time_of_death updates

	observer.update_appearance()
	observer.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	deadchat_broadcast(" has observed.", "<b>[observer.real_name]</b>", follow_target = observer, turf_target = get_turf(observer), message_type = DEADCHAT_DEATHRATTLE)
	QDEL_NULL(mind)
	qdel(src)
	return TRUE

/proc/get_job_unavailable_error_message(retval, jobtitle)
	switch(retval)
		if(JOB_AVAILABLE)
			return "[job_title_ru(jobtitle)] доступна для выбора."
		if(JOB_UNAVAILABLE_GENERIC)
			return "[job_title_ru(jobtitle)] недоступна для выбора."
		if(JOB_UNAVAILABLE_BANNED)
			return "На данный момент вам выдан бан роли на [job_title_ru(jobtitle)]."
		if(JOB_UNAVAILABLE_PLAYTIME)
			return "У вас не наиграно достаточно часов для игры за [job_title_ru(jobtitle)]."
		if(JOB_UNAVAILABLE_ACCOUNTAGE)
			return "Ваш аккаунт недостаточно стар для игры за [job_title_ru(jobtitle)]."
		if(JOB_UNAVAILABLE_SLOTFULL)
			return "Роль [job_title_ru(jobtitle)] уже заполнена до максимума."
		if(JOB_UNAVAILABLE_ANTAG_INCOMPAT)
			return "[job_title_ru(jobtitle)] несовместим с некоторыми выбранными вами ролями антагонистов."
		if(JOB_UNAVAILABLE_AGE)
			return "Ваш персонаж недостаточно стар для игры за [job_title_ru(jobtitle)]."
		// BANDASTATION EDIT START - Server-backed donor/profile failures
		if(JOB_UNAVAILABLE_DONOR)
			return "Для профессии недоступен требуемый уровень подписки."
		if(JOB_UNAVAILABLE_CHARACTER_PROFILE)
			return "Назначенный персонаж не проходит условия профессии. Проверьте слот, возраст, вид и повторный вход."
		// BANDASTATION EDIT END

	return GENERIC_JOB_UNAVAILABLE_ERROR

/mob/dead/new_player/proc/IsJobUnavailable(rank, latejoin = FALSE)
	// BANDASTATION EDIT START - Canonical lookup and common capacity check
	var/client/requester = GET_CLIENT(src)
	if(!requester || !istext(rank))
		return JOB_UNAVAILABLE_GENERIC
	var/datum/job/job = SSjob.get_job(rank)
	if(!job || job.title != rank || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		return JOB_UNAVAILABLE_GENERIC
	if(IsJobSlotUnavailable(job))
		return JOB_UNAVAILABLE_SLOTFULL
	// BANDASTATION EDIT END

	var/eligibility_check = SSjob.check_job_eligibility(src, job, "Mob IsJobUnavailable", latejoin = latejoin) // BANDASTATION EDIT - Final character profile
	if(eligibility_check != JOB_AVAILABLE)
		return eligibility_check

	if(latejoin && !job.special_check_latejoin(requester))
		return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE

/mob/dead/new_player/proc/IsJobSlotUnavailable(datum/job/job) // BANDASTATION EDIT - Preserve native assistant overflow exception at commit
	if(job.total_positions < 0 || job.current_positions < job.total_positions)
		return FALSE
	if(!is_assistant_job(job))
		return TRUE
	var/client/requester = GET_CLIENT(src)
	if(isnum(requester?.player_age) && requester.player_age <= 14)
		return FALSE
	for(var/datum/job/other_job as anything in SSjob.joinable_occupations)
		if(other_job != job && !other_job.donor_lock_reason(requester) && (other_job.total_positions < 0 || other_job.current_positions < other_job.total_positions))
			return TRUE
	return FALSE

/mob/dead/new_player/proc/AttemptLateSpawn(rank)
	// BANDASTATION EDIT START - Native attempt state protects both menus, including yielding checks.
	var/client/requester = GET_CLIENT(src)
	if(spawning || !requester || SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		return FALSE
	spawning = TRUE
	var/error = IsJobUnavailable(rank, latejoin = TRUE)
	if(error != JOB_AVAILABLE)
		return reject_late_spawn(get_job_unavailable_error_message(error, rank))
	if(SSshuttle.arrivals)
		if(SSshuttle.arrivals.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
			return reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
		if(CONFIG_GET(flag/arrivals_shuttle_require_undocked))
			SSshuttle.arrivals.RequireUndocked(src)
	if(QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		return reject_late_spawn()
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return reject_late_spawn("Вход временно ограничен из-за нагрузки сервера.")
	if(!requester.holder && length(SSticker.queued_players) && SSticker.queued_players[1] != src)
		return reject_late_spawn("Дождитесь своей очереди на вход.")
	if(!(ckey(key) in GLOB.admin_datums) && SSjob.is_latejoin_population_full())
		return reject_late_spawn("Достигнут лимит живых игроков.")
	error = IsJobUnavailable(rank, latejoin = TRUE)
	if(error != JOB_AVAILABLE || QDELETED(src) || !requester || GET_CLIENT(src) != requester || requester.mob != src)
		return reject_late_spawn(get_job_unavailable_error_message(error, rank))
	if(SSticker.current_state != GAME_STATE_PLAYING || !SSticker.IsRoundInProgress())
		return reject_late_spawn("Раунд завершён; поздний вход недоступен.")
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		return reject_late_spawn("Вход временно ограничен из-за нагрузки сервера.")
	if(!requester.holder && length(SSticker.queued_players) && SSticker.queued_players[1] != src)
		return reject_late_spawn("Дождитесь своей очереди на вход.")
	if(SSshuttle.arrivals?.damaged && CONFIG_GET(flag/arrivals_shuttle_require_safe_latejoin))
		return reject_late_spawn("В данный момент шаттл прибытия сломан. Вы не сможете присоединиться.")
	var/datum/job/job = SSjob.get_job(rank)
	// No yielding eligibility lookup between the final shuttle checks and native vacancy assignment.
	if(!SSjob.assign_role(src, job, latejoin = TRUE, do_eligibility_checks = FALSE))
		return reject_late_spawn("Профессия больше недоступна; выберите её повторно.")
	mind.late_joiner = TRUE
	var/atom/destination = job.get_latejoin_spawn_point()
	var/mob/living/character = destination ? create_character(destination) : null
	if(!character)
		cancel_character_spawn()
		return reject_late_spawn("Персонаж не был создан; место профессии освобождено.")
	if(!transfer_character())
		cancel_character_spawn()
		return reject_late_spawn("Передача персонажа не состоялась; место профессии освобождено.")
	SSticker.queued_players -= src
	SSticker.queue_delay = 4
	var/latejoin_period = CEILING(STATION_TIME_PASSED() / (5 MINUTES), 5)
	SSblackbox.record_feedback("tally", "latejoin_time", 1, latejoin_period)
	// BANDASTATION EDIT END
	SSjob.equip_rank(character, job, character.client)
	job.after_latejoin_spawn(character)

	#define IS_NOT_CAPTAIN 0
	#define IS_ACTING_CAPTAIN 1
	#define IS_FULL_CAPTAIN 2
	var/is_captain = IS_NOT_CAPTAIN
	var/captain_sound = 'sound/announcer/notice/notice2.ogg'
	// If we already have a captain, are they a "Captain" rank and are we allowing multiple of them to be assigned?
	if(is_captain_job(job))
		is_captain = IS_FULL_CAPTAIN
		captain_sound = 'sound/announcer/announcement/announce.ogg'
	// If we don't have an assigned cap yet, check if this person qualifies for some from of captaincy.
	else if(!SSjob.assigned_captain && ishuman(character) && SSjob.chain_of_command[rank] && !is_banned_from(character.ckey, list(JOB_CAPTAIN)))
		is_captain = IS_ACTING_CAPTAIN
	if(is_captain != IS_NOT_CAPTAIN)
		minor_announce(job.get_captaincy_announcement(character), sound_override = captain_sound)
		SSjob.promote_to_captain(character, is_captain == IS_ACTING_CAPTAIN)
	#undef IS_NOT_CAPTAIN
	#undef IS_ACTING_CAPTAIN
	#undef IS_FULL_CAPTAIN

	SSticker.minds += character.mind
	character.client?.init_verbs() // BANDASTATION EDIT - Disconnect after handover keeps the body // init verbs for the late join
	var/mob/living/carbon/human/humanc
	if(ishuman(character))
		humanc = character //Let's retypecast the var to be human,

	if(humanc) //These procs all expect humans
		if(SSshuttle.arrivals)
			SSshuttle.arrivals.QueueAnnounce(humanc, rank)
		else
			announce_arrival(humanc, rank)
		AddEmploymentContract(humanc)

		humanc.increment_scar_slot()
		humanc.load_persistent_scars()

		if(GLOB.curse_of_madness_triggered)
			give_madness(humanc, GLOB.curse_of_madness_triggered)

	GLOB.joined_player_list += character.ckey

	if(CONFIG_GET(flag/allow_latejoin_antagonists) && !EMERGENCY_PAST_POINT_OF_NO_RETURN && humanc) //Borgs aren't allowed to be antags. Will need to be tweaked if we get true latejoin ais.
		SSdynamic.on_latejoin(humanc)

	if(humanc)
		if(job.job_flags & JOB_ASSIGN_QUIRKS)
			if(CONFIG_GET(flag/roundstart_traits))
				SSquirks.AssignQuirks(humanc, humanc.client)
		else // clear any personalities the prefs added since our job clearly does not want them
			humanc.clear_personalities()

	if(humanc) // Quirks may change manifest datapoints, so inject only after assigning quirks
		GLOB.manifest.inject(humanc, initial_spawn = TRUE) // BANDASTATION EDIT - Initial record callback
		SEND_SIGNAL(humanc, COMSIG_HUMAN_CHARACTER_SETUP_FINISHED)
	var/area/station/arrivals = GLOB.areas_by_type[/area/station/hallway/secondary/entry]
	if(humanc && arrivals && !arrivals.power_environ) //arrivals depowered
		humanc.put_in_hands(new /obj/item/crowbar/large/emergency(get_turf(humanc))) //if hands full then just drops on the floor
	log_manifest(character.mind.key, character.mind, character, latejoin = TRUE)


	return TRUE

/mob/dead/new_player/proc/AddEmploymentContract(mob/living/carbon/human/employee)
	//TODO:  figure out a way to exclude wizards/nukeops/demons from this.
	for(var/C in GLOB.employmentCabinets)
		var/obj/structure/filingcabinet/employment/employmentCabinet = C
		if(!employmentCabinet.virgin)
			employmentCabinet.addFile(employee)

/**
 * Creates, assigns and returns the new_character to spawn as.
 * Assumes a valid mind.assigned_role exists.
 *
 * * destination - where to spawn the character
 * * forced_slot - if provided, will load whatever character is in that slot instead of their active slot
 */
/mob/dead/new_player/proc/create_character(atom/destination, forced_slot)
	spawning = TRUE
	// BANDASTATION EDIT START - Resolve one profile before construction, leaving AI handover native.
	if(!client || !destination || !mind?.assigned_role)
		return null
	var/datum/job/assigned_job = mind.assigned_role
	var/datum/job_character_selection/selection = resolve_assigned_job_character(assigned_job, mind.late_joiner, forced_slot)
	if(selection.character_error(assigned_job, client, mind.late_joiner) || assigned_job.donor_lock_reason(client) || !load_assigned_job_character())
		return null
	// BANDASTATION EDIT END
	mind.active = FALSE //we wish to transfer the key manually
	var/mob/living/spawning_mob = assigned_job.get_spawn_mob(client, destination)
	if(QDELETED(src) || QDELETED(spawning_mob))
		return null
	var/client/player_client = src.client || spawning_mob.client // An AI constructor can take the client.
	if(!player_client)
		qdel(spawning_mob)
		return null
	if(assigned_job.donor_lock_reason(player_client) || selection.actual_body_error(assigned_job, spawning_mob)) // BANDASTATION EDIT - Recheck admission after the yielding appearance lookup.
		qdel(spawning_mob)
		return null
	if(!isAI(spawning_mob))
		var/datum/mind/preserved_mind = mind
		preserved_mind.original_character_slot_index = selection.slot // BANDASTATION EDIT - The committed profile, not the previously active slot.
		preserved_mind.transfer_to(spawning_mob)
		preserved_mind.set_original_character(spawning_mob)
	player_client.init_verbs()
	. = spawning_mob
	new_character = .

/mob/dead/new_player/proc/transfer_character()
	. = new_character
	if(!.)
		return
	SStitle.hide_title_screen_from(client) // BANDASTATION ADDITION - HTML Title Screen
	var/datum/persistent_client/connection = persistent_client || new_character.persistent_client // BANDASTATION EDIT - Preserve offline handover.
	new_character.PossessByPlayer(key) //Manually transfer the key to log them in,
	if(connection && assigned_character) // BANDASTATION EDIT - History follows the final profile after handover.
		LAZYADD(connection.joined_as_slots, "[assigned_character.slot]")
	new_character.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	var/area/joined_area = get_area(new_character.loc)
	if(joined_area)
		joined_area.on_joining_game(new_character)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREWMEMBER_JOINED, new_character, new_character.mind.assigned_role.title)
	new_character = null
	qdel(src)

// BANDASTATION ADDITION - Fail before equipment; the only disposable body belongs to this lobby mob.
/mob/dead/new_player/proc/cancel_character_spawn()
	if(new_character && !new_character.key)
		new_character.mind?.transfer_to(src)
		QDEL_NULL(new_character)
	var/datum/job/assigned_job = mind?.assigned_role || SSjob.get_job_type(assigned_character?.job_type)
	if(assigned_character && assigned_job && !is_unassigned_job(assigned_job))
		SSjob.free_job_position(assigned_job.title)
	if(mind)
		mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
	QDEL_NULL(assigned_character)
	ready = PLAYER_NOT_READY
	spawning = FALSE

/mob/dead/new_player/proc/reject_late_spawn(message)
	var/client/requester = GET_CLIENT(src)
	if(message && requester)
		to_chat(src, span_warning(message))
	spawning = FALSE
	if(!requester && !QDELETED(src))
		qdel(src)
	return FALSE

/mob/dead/new_player/proc/ViewManifest()
	if(!client)
		return
	GLOB.manifest.ui_interact(src)

/mob/dead/new_player/Move()
	return 0

// Used to make sure that a player has a valid job preference setup, used to knock players out of eligibility for anything if their prefs don't make sense.
// A "valid job preference setup" in this situation means at least having one job set to low, or not having "return to lobby" enabled
// Prevents "antag rolling" by setting antag prefs on, all jobs to never, and "return to lobby if preferences not available"
// Doing so would previously allow you to roll for antag, then send you back to lobby if you didn't get an antag role
// This also does some admin notification and logging as well, as well as some extra logic to make sure things don't go wrong
/mob/dead/new_player/proc/check_job_preferences(warn = TRUE)
	if(!client)
		return FALSE //Not sure how this would get run without the mob having a client, but let's just be safe.
	// BANDASTATION EDIT - Selected invaders/forced roles are admitted on their actual job.
	var/datum/job/forced_job = SSjob.get_job_type(LAZYACCESS(SSjob.forced_occupations, mind))
	if(forced_job)
		return SSjob.check_job_eligibility(src, forced_job, "Forced admission") == JOB_AVAILABLE
	if(client.prefs.read_preference(/datum/preference/choiced/jobless_role) != RETURNTOLOBBY)
		return TRUE
	// If they have antags enabled, they're potentially doing this on purpose instead of by accident. Notify admins if so.
	var/has_antags = length(client.prefs.be_special) > 0
	if(client.prefs.job_preferences.len == 0)
		if(warn)
			to_chat(src, span_danger("You have no jobs enabled, along with return to lobby if job is unavailable. \
				This makes you ineligible for any round start role, please update your job preferences."))
		ready = PLAYER_NOT_READY
		if(has_antags)
			log_admin("[src.ckey] has no jobs enabled, return to lobby if job is unavailable enabled and [client.prefs.be_special.len] \
				antag preferences enabled. The player has been forcefully returned to the lobby.")
			message_admins("[src.ckey] has no jobs enabled, return to lobby if job is unavailable enabled and [client.prefs.be_special.len] \
				antag preferences enabled. This is an old antag rolling technique. The player has been asked to update their job preferences \
				and has been forcefully returned to the lobby.")
		return FALSE //This is the only case someone should actually be completely blocked from antag rolling as well
	// BANDASTATION EDIT - Expired subscription/profile restrictions do not imply antag rolling.
	if(!has_eligible_crew_preference(null))
		if(warn)
			to_chat(src, span_warning("Ни одна выбранная профессия сейчас недоступна. Проверьте профиль и подписку."))
		ready = PLAYER_NOT_READY
		return FALSE
	return TRUE

/**
 * Prepares a client for the interview system, and provides them with a new interview
 *
 * This proc will both prepare the user by removing all verbs from them, as well as
 * giving them the interview form and forcing it to appear.
 */
/mob/dead/new_player/proc/register_for_interview()
	// First we detain them by removing all the verbs they have on client
	for (var/procpath/verb_path as anything in client.verbs)
		remove_verb(client, verb_path)

	// Then remove those on their mob as well
	for (var/procpath/verb_path as anything in verbs)
		remove_verb(src, verb_path)

	// Then we create the interview form and show it to the client
	var/datum/interview/I = GLOB.interviews.interview_for_client(client)
	if(I && SScentral.is_player_discord_linked(src.ckey)) // BANDASTATION EDIT - if(I) => if(I && SScentral.is_player_discord_linked(owner.ckey))
		I.ui_interact(src)

	// Add verb for re-opening the interview panel, fixing chat and re-init the verbs for the stat panel
	ASSIGN_GAME_VERB(src, /mob/dead/new_player, open_interview)
	add_verb(client, /client/verb/fix_tgui_panel)

///Resets the Lobby Menu HUD, recreating and reassigning it to the new player
GAME_VERB_PROC(/mob/dead/new_player, reset_menu_hud, "Reset Lobby Menu HUD", null) // BANDASTATION EDIT: Empty category
	var/mob/dead/new_player/new_player = usr
	if(!COOLDOWN_FINISHED(new_player, reset_hud_cooldown))
		to_chat(new_player, span_warning("You must wait <b>[DisplayTimeText(COOLDOWN_TIMELEFT(new_player, reset_hud_cooldown))]</b> before resetting the Lobby Menu HUD again!"))
		return
	if(!new_player?.client)
		return
	COOLDOWN_START(new_player, reset_hud_cooldown, RESET_HUD_INTERVAL)
	qdel(new_player.hud_used)
	create_mob_hud()
	to_chat(new_player, span_info("Lobby Menu HUD reset. You may reset the HUD again in <b>[DisplayTimeText(RESET_HUD_INTERVAL)]</b>."))
	hud_used.show_hud(hud_used.hud_version)

///Auto deadmins an admin when they click to toggle the ready button or join game button in the menu
/mob/dead/new_player/proc/auto_deadmin_on_ready_or_latejoin()
	if(!client?.holder) //If they aren't an admin we dont care
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_on_ready_or_latejoin) || (client.prefs.read_preference(/datum/preference/toggle/auto_deadmin_on_ready_or_latejoin)) || (client.prefs?.toggles & DEADMIN_ALWAYS))
		return client.holder.auto_deadmin()

#undef RESET_HUD_INTERVAL
