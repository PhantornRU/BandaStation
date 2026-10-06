/datum/outfit/job/donor/actor
	name = "Actor"
	jobtype = /datum/job/donor/actor
	id_trim = /datum/id_trim/job/donor_actor
	uniform = /obj/item/clothing/under/suit/burgundy
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/hats/bowler
	gloves = /obj/item/clothing/gloves/color/white
	glasses = /obj/item/clothing/glasses/regular
	ears = /obj/item/radio/headset/headset_srv
	donor_kit = list(
		/obj/item/clothing/under/suit/burgundy = 1,
		/obj/item/clothing/suit/toggle/lawyer/greyscale = 1,
		/obj/item/clothing/under/suit/black = 1,
		/obj/item/clothing/under/costume/cuban_suit = 1,
		/obj/item/clothing/head/cuban_hat = 1,
	)

/datum/outfit/job/donor/actor/painter
	name = "Actor (painter)"
	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/sneakers/white
	head = /obj/item/clothing/head/beret
	glasses = /obj/item/clothing/glasses/regular/hipster
	suit = /obj/item/clothing/suit/apron
	donor_kit = list(
		/obj/item/stack/cable_coil/random = 1,
		/obj/item/camera = 1,
		/obj/item/camera_film = 2,
		/obj/item/storage/photo_album = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/stack/sticky_tape = 1,
		/obj/item/paper = 4,
		/obj/item/storage/crayons = 1,
		/obj/item/pen/fountain = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/toy/crayon/spraycan = 1,
	)

/datum/outfit/job/donor/actor/artist
	name = "Actor (artist)"
	suit = /obj/item/clothing/suit/jacket/fancy

/datum/outfit/job/donor/actor/comedian
	name = "Actor (comedian)"
	uniform = /obj/item/clothing/under/rank/civilian/clown/jester
	head = /obj/item/clothing/head/costume/jester

/datum/outfit/job/donor/actor/stage
	name = "Actor (stage)"
	suit = /obj/item/clothing/suit/jacket/fancy
