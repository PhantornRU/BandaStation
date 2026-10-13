/datum/outfit/job/donor/seclown
	parent_type = /datum/outfit/job/clown
	name = "Security Clown"
	jobtype = /datum/job/donor/seclown
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/donor_seclown
	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	duffelbag = /obj/item/storage/backpack/duffelbag/clown
	uniform = /obj/item/clothing/under/rank/civilian/clown/security
	suit = /obj/item/clothing/suit/armor/vest/alt/sec
	head = /obj/item/clothing/head/helmet
	suit_store = /obj/item/gun/energy/donor_honk
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/color/red
	l_pocket = /obj/item/bikehorn
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/headset_sec
	belt = /obj/item/modular_computer/pda/crew/clown
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
	)
	implants = list(/obj/item/implant/sad_trombone, /obj/item/implant/mindshield)

/// Retain the donor supply operation while inheriting the native clown effects.
/datum/outfit/job/donor/seclown/equip_backpack_item(mob/living/carbon/human/user, item_path)
	return equip_backpack_item_preserving_overflow(user, item_path)

/datum/outfit/job/donor/seclown/detective
	name = "Security Clown (detective)"
	suit = /obj/item/clothing/suit/toggle/jacket/det_trench
	head = /obj/item/clothing/head/fedora/det_hat

/datum/outfit/job/donor/seclown/warden
	name = "Security Clown (warden)"
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	head = /obj/item/clothing/head/hats/warden/red
	suit_store = /obj/item/gun/energy/donor_honk/warden

/datum/outfit/job/donor/seclown/cadet
	name = "Security Clown (cadet)"
	head = /obj/item/clothing/head/soft/sec
