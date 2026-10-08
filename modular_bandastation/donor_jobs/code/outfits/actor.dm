/datum/outfit/job/donor/actor
	name = "Actor"
	jobtype = /datum/job/donor/actor
	id_trim = /datum/id_trim/job/donor_actor
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/red
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/hats/bowler
	gloves = /obj/item/clothing/gloves/color/white
	glasses = /obj/item/clothing/glasses/regular
	ears = /obj/item/radio/headset/headset_srv
	donor_kit = list(
		/obj/item/clothing/under/donor/iaa/purple = 1,
		/obj/item/clothing/suit/toggle/lawyer/purple = 1,
		/obj/item/clothing/under/suit/black_really = 1,
		/obj/item/clothing/under/costume/cuban_suit = 1,
		/obj/item/clothing/head/cuban_hat = 1,
	)
	var/female_uniform = /obj/item/clothing/under/rank/civilian/lawyer/red/skirt
	var/female_suit

/datum/outfit/job/donor/actor/prepare_for_character(mob/living/carbon/human/human, visuals_only)
	. = ..()
	if(human.gender != FEMALE)
		return
	if(female_uniform)
		uniform = female_uniform
	if(female_suit)
		suit = female_suit

/datum/outfit/job/donor/actor/painter
	name = "Actor (painter)"
	uniform = /obj/item/clothing/under/donor/amish
	shoes = /obj/item/clothing/shoes/sneakers/white
	head = /obj/item/clothing/head/beret/donor_white
	glasses = /obj/item/clothing/glasses/regular/hipster
	suit = /obj/item/clothing/suit/apron
	donor_kit = list(
		/obj/item/stack/cable_coil/random = 1,
		/obj/item/camera = 1,
		/obj/item/camera_film = 2,
		/obj/item/storage/photo_album = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/stack/medical/wrap/sticky_tape = 1,
		/obj/item/paper = 4,
		/obj/item/storage/crayons = 1,
		/obj/item/pen/fountain = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/painter = 1,
	)
	female_uniform = null

/datum/outfit/job/donor/actor/artist
	name = "Actor (artist)"
	uniform = /obj/item/clothing/under/donor/victorian/red
	female_uniform = /obj/item/clothing/under/donor/victorian_dress/red
	female_suit = /obj/item/clothing/suit/donor/victorian/red

/datum/outfit/job/donor/actor/comedian
	name = "Actor (comedian)"
	uniform = /obj/item/clothing/under/rank/civilian/clown/jester
	head = /obj/item/clothing/head/costume/jester
	female_uniform = null

/datum/outfit/job/donor/actor/stage
	name = "Actor (stage)"
	uniform = /obj/item/clothing/under/donor/victorian/red_black
	suit = /obj/item/clothing/suit/donor/dracula
	female_uniform = /obj/item/clothing/under/donor/evening_gown
