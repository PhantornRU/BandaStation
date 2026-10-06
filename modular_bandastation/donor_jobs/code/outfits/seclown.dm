/datum/outfit/job/donor/seclown
	name = "Security Clown"
	jobtype = /datum/job/donor/seclown
	id_trim = /datum/id_trim/job/donor_seclown
	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/color/red
	l_pocket = /obj/item/bikehorn
	suit_store = /obj/item/gun/energy/donor_honk
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/donor_service_security
	duffelbag = /obj/item/storage/backpack/duffelbag/clown
	belt = /obj/item/modular_computer/pda/crew/clown
	donor_kit = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/cup/glass/bottle/bottleofbanana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/restraints/handcuffs/fake = 1,
	)
	implants = list(/obj/item/implant/sad_trombone, /obj/item/implant/mindshield)

/datum/outfit/job/donor/seclown/detective
	name = "Security Clown (detective)"
	suit = /obj/item/clothing/suit/jacket/det_suit
	head = /obj/item/clothing/head/fedora

/datum/outfit/job/donor/seclown/warden
	name = "Security Clown (warden)"
	suit = /obj/item/clothing/suit/armor/vest/warden
	head = /obj/item/clothing/head/hats/warden
	suit_store = /obj/item/gun/energy/donor_honk/warden

/datum/outfit/job/donor/seclown/cadet
	name = "Security Clown (cadet)"
	head = /obj/item/clothing/head/soft/sec
