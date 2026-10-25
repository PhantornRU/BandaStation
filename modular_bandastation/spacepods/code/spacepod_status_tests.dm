/// The HUD must follow the installed cell through real charging and inventory movement.
/datum/unit_test/spacepod_status_battery/Run()
	var/turf/origin = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/obj/vehicle/sealed/spacepod/civilian/pod = allocate(__IMPLIED_TYPE__, origin)
	var/obj/item/stock_parts/power_store/cell/cell = pod.battery
	var/list/data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["battery_present"], TRUE, "The installed battery is missing from the status data.")
	TEST_ASSERT_EQUAL(data["charge_percent"], 100, "A new fully charged cell does not report 100 percent.")
	TEST_ASSERT(cell.use(cell.charge * 0.123456), "The real battery failed to supply the test's energy draw.")
	data = pod.get_status_data()
	TEST_ASSERT(abs(data["charge_percent"] - 87.6544) < 0.001, "The HUD charge does not follow the cell's real remaining charge.")
	TEST_ASSERT_NOTEQUAL(data["charge_percent"], round(data["charge_percent"], 0.1), "The backend prematurely rounded battery measurements for display.")
	TEST_ASSERT(cell.use(cell.charge), "The real battery could not be exhausted.")
	data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["battery_present"], TRUE, "An exhausted installed battery is reported as absent.")
	TEST_ASSERT_EQUAL(data["charge_percent"], 0, "An exhausted cell does not report zero charge.")
	cell.give(cell.maxcharge)
	data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["charge_percent"], 100, "Recharging the existing battery did not update the HUD data.")
	var/mob/living/carbon/human/consistent/technician = allocate(__IMPLIED_TYPE__, get_step(origin, SOUTH))
	TEST_ASSERT(technician.put_in_active_hand(cell, forced = TRUE), "Native inventory movement could not remove the battery.")
	TEST_ASSERT_NULL(pod.battery, "Native battery removal left the installed battery reference behind.")
	data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["battery_present"], FALSE, "A removed battery is still reported as present.")
	TEST_ASSERT_NULL(data["charge_percent"], "A removed battery still exposes its previous charge.")
	pod.hatch_open = TRUE
	TEST_ASSERT(pod.item_interaction(technician, cell, list()) & ITEM_INTERACT_SUCCESS, "The technician could not reinstall the actual battery.")
	var/valid_capacity = cell.maxcharge
	for(var/invalid_capacity in list(0, -1))
		cell.maxcharge = invalid_capacity
		data = pod.get_status_data()
		TEST_ASSERT_EQUAL(data["battery_present"], TRUE, "An invalid-capacity cell was confused with a missing cell.")
		TEST_ASSERT_NULL(data["charge_percent"], "An invalid maximum charge produced a misleading percentage or division by zero.")
	cell.maxcharge = valid_capacity

/// Every hull variant uses its own native maximum, including real damage and repair.
/datum/unit_test/spacepod_status_integrity/Run()
	var/list/pod_maxima = list(/obj/vehicle/sealed/spacepod/civilian = 250, /obj/vehicle/sealed/spacepod/sec = 600)
	for(var/pod_type in pod_maxima)
		var/obj/vehicle/sealed/spacepod/pod = allocate(pod_type)
		var/expected_maximum = pod_maxima[pod_type]
		TEST_ASSERT_EQUAL(pod.max_integrity, expected_maximum, "The integrity fixture has an unexpected native maximum.")
		var/list/data = pod.get_status_data()
		TEST_ASSERT_EQUAL(data["integrity_percent"], 100, "A new hull does not report full integrity.")
		pod.take_damage(pod.max_integrity / 4, BRUTE, MELEE, sound_effect = FALSE)
		data = pod.get_status_data()
		TEST_ASSERT(abs(data["integrity_percent"] - 75) < 0.001, "The reported percentage used the wrong hull maximum or ignored native damage.")
		pod.repair_damage(pod.max_integrity)
		data = pod.get_status_data()
		TEST_ASSERT_EQUAL(data["integrity_percent"], 100, "Native repairs did not restore the reported integrity.")
		pod.take_damage(1, BRUTE, MELEE, sound_effect = FALSE)
		data = pod.get_status_data()
		TEST_ASSERT(abs(data["integrity_percent"] - 100 * (pod.max_integrity - 1) / pod.max_integrity) < 0.001, "The backend rounded away the real hull integrity.")
		pod.update_integrity(2 * pod.max_integrity)
		data = pod.get_status_data()
		TEST_ASSERT_EQUAL(data["integrity_percent"], 100, "An over-max integrity value escaped the HUD's percentage bounds.")
		pod.update_integrity(0)
		data = pod.get_status_data()
		TEST_ASSERT_EQUAL(data["integrity_percent"], 0, "A depleted hull does not report zero integrity.")
		pod.max_integrity = 0
		data = pod.get_status_data()
		TEST_ASSERT_EQUAL(data["integrity_percent"], 0, "A zero maximum hull integrity was not guarded.")
		pod.max_integrity = expected_maximum

/// Partial pressure and standard litres are different measurements of the same real oxygen.
/datum/unit_test/spacepod_status_cabin_measurements/Run()
	var/obj/vehicle/sealed/spacepod/civilian/pod = allocate(__IMPLIED_TYPE__)
	var/list/baseline = pod.get_status_data()
	TEST_ASSERT(abs(baseline["cabin_oxygen_kpa"] - 21.27825) < 0.01, "The initial cabin does not report approximately 21.3 kPa of oxygen.")
	TEST_ASSERT(abs(baseline["cabin_oxygen_liters"] - 42) < 0.05, "The 200 L cabin does not initially contain approximately 42 standard litres of oxygen.")
	TEST_ASSERT(abs(baseline["cabin_pressure_kpa"] - ONE_ATMOSPHERE) < 0.01, "Initial cabin total pressure is incorrect.")
	TEST_ASSERT_EQUAL(baseline["using_internal_air"], TRUE, "The initial internal-air mode is missing.")
	TEST_ASSERT_EQUAL(baseline["active_oxygen_kpa"], baseline["cabin_oxygen_kpa"], "Internal mode does not use the cabin's oxygen measurement.")
	pod.cabin_air.set_gas(/datum/gas/nitrogen, 2 * pod.cabin_air.moles[/datum/gas/nitrogen])
	var/list/data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["cabin_oxygen_kpa"], baseline["cabin_oxygen_kpa"], "Adding nitrogen changed the oxygen partial pressure despite unchanged oxygen, temperature and volume.")
	TEST_ASSERT(data["cabin_pressure_kpa"] > baseline["cabin_pressure_kpa"], "Adding nitrogen did not raise the reported total cabin pressure.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_liters"], baseline["cabin_oxygen_liters"], "Adding an inert gas changed the reported oxygen quantity.")
	pod.cabin_air.volume *= 2
	data = pod.get_status_data()
	TEST_ASSERT(abs(data["cabin_oxygen_kpa"] - baseline["cabin_oxygen_kpa"] / 2) < 0.001, "Oxygen partial pressure did not account for the actual cabin volume.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_liters"], baseline["cabin_oxygen_liters"], "Standard oxygen litres incorrectly depend on current cabin volume.")
	pod.cabin_air.temperature *= 2
	data = pod.get_status_data()
	TEST_ASSERT(abs(data["cabin_oxygen_kpa"] - baseline["cabin_oxygen_kpa"]) < 0.001, "Oxygen partial pressure did not account for the actual gas temperature.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_liters"], baseline["cabin_oxygen_liters"], "Standard oxygen litres incorrectly depend on current cabin temperature.")

/// Cabin oxygen must never be inferred from the reserve tank's pressure.
/datum/unit_test/spacepod_status_reserve_separation/Run()
	var/obj/vehicle/sealed/spacepod/civilian/pod = allocate(__IMPLIED_TYPE__)
	var/list/baseline = pod.get_status_data()
	var/datum/gas_mixture/tank_air = pod.internal_tank.return_air()
	qdel(pod.cabin_air.remove_ratio(1))
	pod.cabin_air.set_gas(/datum/gas/carbon_dioxide, ONE_ATMOSPHERE * pod.cabin_air.volume / (R_IDEAL_GAS_EQUATION * T20C))
	var/list/data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["tank_pressure_kpa"], baseline["tank_pressure_kpa"], "Replacing cabin air unexpectedly changed the full reserve tank.")
	TEST_ASSERT(data["tank_pressure_kpa"] > ONE_ATMOSPHERE, "The contamination fixture does not have a pressurized reserve tank.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_kpa"], 0, "A full tank concealed an oxygen-free CO2 cabin.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_liters"], 0, "An oxygen-free CO2 cabin falsely reports stored cabin oxygen.")
	TEST_ASSERT_EQUAL(data["active_oxygen_kpa"], 0, "The active oxygen measurement ignores cabin contamination in internal mode.")
	TEST_ASSERT(abs(data["cabin_pressure_kpa"] - ONE_ATMOSPHERE) < 0.01, "The CO2 cabin lost its full total pressure.")
	qdel(pod.cabin_air.remove_ratio(1))
	pod.cabin_air.set_gas(/datum/gas/oxygen, ONE_ATMOSPHERE * O2STANDARD * pod.cabin_air.volume / (R_IDEAL_GAS_EQUATION * T20C))
	pod.cabin_air.set_gas(/datum/gas/nitrogen, ONE_ATMOSPHERE * N2STANDARD * pod.cabin_air.volume / (R_IDEAL_GAS_EQUATION * T20C))
	qdel(tank_air.remove_ratio(1))
	data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["tank_pressure_kpa"], 0, "An exhausted reserve tank does not report zero pressure.")
	TEST_ASSERT(abs(data["cabin_oxygen_kpa"] - baseline["cabin_oxygen_kpa"]) < 0.01, "An empty reserve tank concealed the cabin's remaining oxygen.")
	TEST_ASSERT(abs(data["cabin_oxygen_liters"] - baseline["cabin_oxygen_liters"]) < 0.05, "Cabin oxygen quantity incorrectly follows reserve depletion.")

/// A real pilot's air-source toggle must expose vacuum without hiding the cabin's reserve.
/datum/unit_test/spacepod_status_external
	parent_type = /datum/unit_test/spacepod_vacuum

/datum/unit_test/spacepod_status_external/Run()
	TEST_ASSERT_NOTNULL(vacuum_block, "Could not reserve the real vacuum environment.")
	var/obj/vehicle/sealed/spacepod/civilian/pod = allocate(__IMPLIED_TYPE__, vacuum_origin)
	pod.enter_delay = 0
	var/mob/living/carbon/human/consistent/pilot = allocate(__IMPLIED_TYPE__, get_step(vacuum_origin, SOUTH))
	TEST_ASSERT(pod.mob_try_enter(pilot), "The status test's pilot could not board in vacuum.")
	var/list/baseline = pod.get_status_data()
	TEST_ASSERT(pod.toggle_internal_tank(pilot), "The pilot could not select real exterior air.")
	TEST_ASSERT_EQUAL(pod.return_air(), vacuum_origin.return_air(), "The exterior status fixture is not using the native exterior atmosphere.")
	var/list/data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["using_internal_air"], FALSE, "The HUD still reports internal air after the real toggle.")
	TEST_ASSERT_EQUAL(data["active_oxygen_kpa"], 0, "Exterior vacuum falsely reports breathable oxygen from the stored cabin air.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_kpa"], baseline["cabin_oxygen_kpa"], "Selecting exterior air discarded the cabin's oxygen measurement.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_liters"], baseline["cabin_oxygen_liters"], "Selecting exterior air discarded the cabin's stored oxygen quantity.")
	TEST_ASSERT(pod.toggle_internal_tank(pilot), "The pilot could not restore the cabin's air supply.")
	data = pod.get_status_data()
	TEST_ASSERT_EQUAL(data["using_internal_air"], TRUE, "The HUD did not restore internal-air mode.")
	TEST_ASSERT_EQUAL(data["active_oxygen_kpa"], data["cabin_oxygen_kpa"], "Restoring internal mode did not restore the actual cabin oxygen reading.")

/// Absent mixtures and invalid volumes remain unavailable; a real vacuum remains zero.
/datum/unit_test/spacepod_status_missing_sources/Run()
	var/obj/vehicle/sealed/spacepod/civilian/pod = allocate(__IMPLIED_TYPE__)
	var/list/baseline = pod.get_status_data()
	var/cabin_volume = pod.cabin_air.volume
	pod.cabin_air.volume = 0
	var/list/data = pod.get_status_data()
	TEST_ASSERT_NULL(data["cabin_oxygen_kpa"], "A zero-volume cabin produced an oxygen pressure reading.")
	TEST_ASSERT_NULL(data["cabin_pressure_kpa"], "A zero-volume cabin produced a total pressure reading.")
	TEST_ASSERT_NULL(data["active_oxygen_kpa"], "A zero-volume active mixture produced an oxygen pressure reading.")
	TEST_ASSERT_EQUAL(data["cabin_oxygen_liters"], baseline["cabin_oxygen_liters"], "A missing pressure denominator erased the independently measurable oxygen quantity.")
	pod.cabin_air.volume = cabin_volume
	var/datum/gas_mixture/tank_air = pod.internal_tank.return_air()
	var/tank_volume = tank_air.volume
	tank_air.volume = 0
	data = pod.get_status_data()
	TEST_ASSERT_NULL(data["tank_pressure_kpa"], "A zero-volume reserve tank produced a pressure reading.")
	tank_air.volume = tank_volume
	QDEL_NULL(pod.internal_tank)
	QDEL_NULL(pod.cabin_air)
	pod.moveToNullspace()
	data = pod.get_status_data()
	for(var/measurement in list("cabin_oxygen_kpa", "cabin_oxygen_liters", "cabin_pressure_kpa", "active_oxygen_kpa", "tank_pressure_kpa"))
		TEST_ASSERT_NULL(data[measurement], "Missing gas source produced a stale [measurement] measurement.")
