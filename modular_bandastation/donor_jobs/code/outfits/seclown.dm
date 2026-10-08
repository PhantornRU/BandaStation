/datum/outfit/job/donor/seclown
	name = "Security Clown"
	jobtype = /datum/job/donor/seclown
	id_trim = /datum/id_trim/job/donor_seclown
	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	uniform = /obj/item/clothing/under/rank/security/officer/donor_clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	suit = /obj/item/clothing/suit/armor/vest/alt/sec/donor
	head = /obj/item/clothing/head/helmet/donor
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/color/red
	l_pocket = /obj/item/bikehorn
	suit_store = /obj/item/gun/energy/donor_honk
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	ears = /obj/item/radio/headset/donor_service_security
	duffelbag = /obj/item/storage/backpack/duffelbag/clown
	belt = /obj/item/modular_computer/pda/crew/clown/donor
	donor_kit = list(
		/obj/item/food/grown/banana = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/cup/donor_banana_jug = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/restraints/handcuffs/fake = 1,
	)
	implants = list(/obj/item/implant/sad_trombone, /obj/item/implant/mindshield)

/datum/outfit/job/donor/seclown/post_equip(mob/living/carbon/human/human, visuals_only = FALSE)
	. = ..()
	if(visuals_only)
		return
	human.dna.add_mutation(/datum/mutation/clumsy, MUTATION_SOURCE_CLOWN_CLUMSINESS)
	human.AddComponent(/datum/component/slippery, 8 SECONDS, GALOSHES_DONT_HELP|SLIPPERY_WHEN_LYING_DOWN)
	if(isandroid(human))
		if(!human.get_organ_slot(/obj/item/organ/cyberimp/brain/donor_clown_voice::slot))
			var/obj/item/organ/cyberimp/brain/donor_clown_voice/voice = new
			voice.Insert(human)
	else
		human.dna.add_mutation(/datum/mutation/wacky, MUTATION_SOURCE_MUTATOR)

/datum/outfit/job/donor/seclown/detective
	name = "Security Clown (detective)"
	suit = /obj/item/clothing/suit/toggle/jacket/det_trench/donor
	head = /obj/item/clothing/head/fedora/donor_detective

/datum/outfit/job/donor/seclown/warden
	name = "Security Clown (warden)"
	suit = /obj/item/clothing/suit/armor/vest/warden/alt/donor
	head = /obj/item/clothing/head/hats/warden/red/donor
	suit_store = /obj/item/gun/energy/donor_honk/warden

/datum/outfit/job/donor/seclown/cadet
	name = "Security Clown (cadet)"
	head = /obj/item/clothing/head/soft/sec/donor
