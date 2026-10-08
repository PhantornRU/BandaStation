/obj/item/modular_computer/pda/crew/donor
	starting_programs = list(/datum/computer_file/program/atmosscan)

/obj/item/modular_computer/pda/crew/bar/donor
	starting_programs = list(/datum/computer_file/program/atmosscan)

/obj/item/modular_computer/pda/crew/cook/donor
	starting_programs = list(/datum/computer_file/program/atmosscan)

/obj/item/modular_computer/pda/crew/chaplain/donor
	starting_programs = list(/datum/computer_file/program/atmosscan)

/obj/item/modular_computer/pda/crew/curator/donor
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/emojipedia,
		/datum/computer_file/program/newscaster,
		/datum/computer_file/program/portrait_printer,
	)

/obj/item/modular_computer/pda/crew/janitor/donor
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/skill_tracker,
		/datum/computer_file/program/radar/custodial_locator,
	)

/obj/item/modular_computer/pda/crew/lawyer/donor
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/records/security,
	)

/obj/item/modular_computer/pda/crew/cargo/donor
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/restock_tracker,
	)

/obj/item/modular_computer/pda/crew/clown/donor
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/donor_honk,
	)

/datum/computer_file/program/donor_honk
	filename = "honk"
	filedesc = "HONK"
	program_icon = "bullhorn"
	can_run_on_flags = PROGRAM_PDA
	program_flags = NONE
	size = 1

/datum/computer_file/program/donor_honk/on_start(mob/living/user)
	if(!..())
		return FALSE
	playsound(computer, 'sound/items/bikehorn.ogg', 50, TRUE)
	// This is a menu action: there is no running program to keep open.
	return FALSE
