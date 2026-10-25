/obj/vehicle/sealed/spacepod/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/spacepod/status)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/spacepod/eject)
	initialize_controller_action_type(/datum/action/vehicle/sealed/spacepod/internals, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/spacepod/lights, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/spacepod/fire, VEHICLE_CONTROL_EQUIPMENT)
	initialize_controller_action_type(/datum/action/vehicle/sealed/spacepod/systems, VEHICLE_CONTROL_SETTINGS)

/datum/action/vehicle/sealed/spacepod
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	/// The native vehicle owns the action and clears it on the occupant's exit.
	var/obj/vehicle/sealed/spacepod/pod

/obj/vehicle/sealed/spacepod/generate_action_type(actiontype)
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/spacepod))
		var/datum/action/vehicle/sealed/spacepod/pod_action = .
		pod_action.pod = src

/datum/action/vehicle/sealed/spacepod/Destroy()
	pod = null
	return ..()

/datum/action/vehicle/sealed/spacepod/IsAvailable(feedback = FALSE)
	return ..() && !QDELETED(pod) && pod.is_occupant(owner) && owner.loc == pod

/datum/action/vehicle/sealed/spacepod/status
	name = "Состояние челнока"
	desc = "Открывает бортовой монитор: батарея, прочность корпуса и атмосфера салона."
	button_icon_state = "mech_view_stats"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/vehicle/sealed/spacepod/status/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(.)
		pod.ui_interact(owner)

/datum/action/vehicle/sealed/spacepod/eject
	name = "Выйти из челнока"
	button_icon_state = "mech_eject"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/vehicle/sealed/spacepod/eject/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(.)
		pod.exit_pod(owner)

/datum/action/vehicle/sealed/spacepod/internals
	name = "Переключить баллон"
	desc = "Переключает дыхание между внутренней кабиной и внешней атмосферой."
	button_icon_state = "mech_cabin_closed"

/datum/action/vehicle/sealed/spacepod/internals/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(. && pod.toggle_internal_tank(owner))
		button_icon_state = pod.use_internal_tank ? "mech_cabin_closed" : "mech_cabin_open"
		build_all_button_icons()

/datum/action/vehicle/sealed/spacepod/lights
	name = "Переключить прожектор"
	button_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/spacepod/lights/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(. && pod.toggleLights(owner))
		button_icon_state = "mech_lights_[pod.lights ? "on" : "off"]"
		build_all_button_icons()

/datum/action/vehicle/sealed/spacepod/fire
	name = "Стрелять"
	desc = "Стреляет установленным оружием вперёд по курсу челнока."
	button_icon_state = "mech_safeties_off"

/datum/action/vehicle/sealed/spacepod/fire/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(.)
		pod.fireWeapon(owner)

/datum/action/vehicle/sealed/spacepod/systems
	name = "Дополнительные системы"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/vehicle/sealed/spacepod/systems/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!. || !pod.can_control(owner))
		return
	var/selection = tgui_input_list(owner, "Выберите систему", "Управление челноком", list("Блокировка дверей", "Шлюз отсека", "Сбросить груз", "Проверить под сиденьем", "Сканировать сектор"))
	if(!selection || QDELETED(src) || QDELETED(pod) || !pod.can_control(owner))
		return
	switch(selection)
		if("Блокировка дверей")
			pod.lock_pod(owner)
		if("Шлюз отсека")
			pod.toggleDoors(owner)
		if("Сбросить груз")
			pod.unload(owner)
		if("Проверить под сиденьем")
			pod.checkSeat(owner)
		if("Сканировать сектор")
			pod.startScan(owner)
