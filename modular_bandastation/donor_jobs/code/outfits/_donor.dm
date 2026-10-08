/datum/outfit/job
	/// Supplies issued after live job equipment and loadout, never in preview.
	var/list/donor_kit

/datum/outfit/job/donor
	belt = /obj/item/modular_computer/pda/crew/donor
	preserve_backpack_overflow = TRUE
