/proc/get_donor_dealer_stock()
	var/static/list/stock
	if(stock)
		return stock
	// Keep the original seed order and duplicate entries before the source's union.
	stock = list(
		/obj/item/toy/waterballoon,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/soap/donor/deluxe,
		/obj/item/soap/donor/ducttape,
		/obj/item/soap/donor/nanotrasen,
		/obj/item/soap/donor/homemade,
		/obj/item/soap/donor/syndie,
		/obj/item/pickaxe/silver,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/bikehorn,
		/obj/item/toy/beach_ball/donor,
		/obj/item/toy/beach_ball/donor/holoball,
		/obj/item/banhammer,
		/obj/item/toy/waterballoon,
		/obj/item/toy/donor_blink,
		/obj/item/toy/katana,
		"mech",
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/dualsaber/toy,
		/obj/item/pai_card,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/neck/tie/horrible,
		"carp",
		"plush",
		"figure",
		/obj/item/toy/cards/deck,
		/obj/item/toy/cards/deck/donor_tiny,
		/obj/item/toy/cards/deck/kotahi,
		/obj/item/toy/minimeteor/donor,
		/obj/item/toy/redbutton,
		/obj/item/toy/talking/owl,
		/obj/item/toy/talking/griffin,
		/obj/item/clothing/head/blob,
		/obj/item/donor_id_skin/decal/gold,
		/obj/item/donor_id_skin/decal/silver,
		/obj/item/donor_id_skin/decal/prisoner,
		/obj/item/donor_id_skin/decal/centcom,
		/obj/item/donor_id_skin/decal/emag,
		/obj/item/book/granter/action/spell/donor_fake_gib,
		/obj/item/toy/foamblade,
		/obj/item/toy/donor_flash,
		/obj/item/toy/donor_minigibber,
		/obj/item/toy/nuke/donor,
		/obj/item/toy/talking/ai,
		/obj/item/clothing/under/syndicate/donor_tacticool,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/gun/ballistic/shotgun/toy/donor_tommygun,
		/obj/item/stack/tile/fakespace/loaded,
		/obj/item/stack/tile/bronze/donor_fifty,
		/obj/item/sord,
		/obj/item/toy/donor_prizeball/figure,
		/obj/item/toy/donor_prizeball/therapy,
		/obj/item/gun/ballistic/automatic/toy/donor,
		/obj/item/gun/ballistic/automatic/pistol/toy/donor,
		/obj/item/gun/ballistic/shotgun/toy,
		/obj/item/ammo_box/foambox,
		/obj/item/toy/foamblade,
		/obj/item/toy/donor_syndicateballoon,
		/obj/item/clothing/suit/syndicatefake,
		/obj/item/clothing/head/syndicatefake,
		/obj/item/gun/ballistic/shotgun/toy/crossbow,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot/donor,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/riot,
		/obj/item/gun/ballistic/automatic/donor_toy_sniper,
		/obj/item/ammo_box/foambox/riot,
		/obj/item/toy/cards/deck/syndicate,
	)
	// Native toy families contain later additions; only the historical families belong here.
	var/list/toys = list(
		/obj/item/toy/crayon,
		/obj/item/toy/crayon/red,
		/obj/item/toy/crayon/orange,
		/obj/item/toy/crayon/yellow,
		/obj/item/toy/crayon/green,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crayon/purple,
		"crayon",
		/obj/item/toy/crayon/black,
		/obj/item/toy/crayon/white,
		/obj/item/toy/crayon/mime,
		/obj/item/toy/crayon/rainbow,
		/obj/item/toy/crayon/spraycan,
		"random",
		/obj/item/toy/waterballoon,
		/obj/item/toy/donor_syndicateballoon,
		/obj/item/toy/donor_syndicateballoon/contractor,
		/obj/item/toy/donor_blink,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/toy/sword/donor_chaosprank,
		/obj/item/toy/katana,
		/obj/item/toy/snappop,
		/obj/item/toy/snappop/donor_virus,
		/obj/item/toy/snappop/phoenix,
		/obj/item/toy/nuke/donor,
		/obj/item/toy/minimeteor/donor,
		/obj/item/toy/plush/carpplushie/dehy_carp,
		/obj/item/toy/foamblade,
		/obj/item/toy/windup_toolbox,
		/obj/item/toy/donor_flash,
		/obj/item/toy/redbutton,
		/obj/item/toy/talking/ai,
		/obj/item/toy/talking/codex_gigas,
		/obj/item/toy/donor_pet_rock,
		/obj/item/toy/donor_pet_rock/fred,
		/obj/item/toy/donor_pet_rock/roxie,
		/obj/item/toy/donor_minigibber,
		/obj/item/toy/donor_russian_revolver,
		/obj/item/toy/donor_russian_revolver/trick_revolver,
		/obj/item/toy/donor_chainsaw,
		/obj/item/toy/cattoy,
		/obj/item/toy/toy_xeno,
		/obj/item/toy/talking/owl,
		/obj/item/toy/talking/griffin,
		/obj/item/toy/donor_eight_ball,
		/obj/item/toy/donor_eight_ball/conch,
		/obj/item/toy/xmas_cracker,
		/obj/item/toy/seashell,
	)
	toys += typesof(/obj/item/toy/donor_therapy) + typesof(/obj/item/toy/plush/donor) + typesof(/obj/item/toy/donor_character)
	toys += typesof(/obj/item/toy/figure/donor) + typesof(/obj/item/toy/donor_prizeball) + typesof(/obj/item/toy/donor_hampter) + typesof(/obj/item/toy/donor_desk)
	var/list/collectable_hats = list(
		/obj/item/clothing/head/collectable/petehat,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/xenom,
		/obj/item/clothing/head/collectable/chef,
		/obj/item/clothing/head/collectable/paper,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/collectable/captain,
		/obj/item/clothing/head/collectable/police,
		/obj/item/clothing/head/collectable/beret,
		/obj/item/clothing/head/collectable/welding,
		/obj/item/clothing/head/collectable/flatcap,
		/obj/item/clothing/head/collectable/pirate,
		/obj/item/clothing/head/collectable/kitty,
		/obj/item/clothing/head/collectable/rabbitears,
		/obj/item/clothing/head/collectable/wizard,
		/obj/item/clothing/head/collectable/hardhat,
		/obj/item/clothing/head/collectable/hos,
		/obj/item/clothing/head/collectable/hop,
		/obj/item/clothing/head/collectable/thunderdome,
		/obj/item/clothing/head/collectable/swat,
	)
	var/list/posters = list(/obj/item/poster/random_contraband, /obj/item/poster/random_official, /obj/item/poster/donor_syndicate_recruitment)
	var/list/id_skins = subtypesof(/obj/item/donor_id_skin) - typesof(/obj/item/donor_id_skin/decal)
	stock |= toys + collectable_hats + posters + subtypesof(/obj/item/storage/fancy/cigarettes/donor) + subtypesof(/obj/item/lighter/donor_zippo) + id_skins
	return stock

/obj/item/storage/box/donor_stock
	name = "коробка всячины"
	desc = "Коробка с легальными вещами или фальшивками. Распакуйте её в руке; крупные вещи окажутся рядом."
	icon = 'modular_bandastation/donor_jobs/icons/boxes.dmi'
	icon_state = "thief_box"
	illustration = null
	var/loot_amount = 30
	var/unpacked = FALSE

/obj/item/storage/box/donor_stock/PopulateContents()
	return

/obj/item/storage/box/donor_stock/attack_self(mob/user)
	if(unpacked)
		return ..()
	var/turf/drop_turf = get_turf(user)
	if(!drop_turf)
		return
	unpacked = TRUE
	for(var/index in 1 to loot_amount)
		var/loot_type = donor_loot_type(pick(get_donor_dealer_stock()))
		var/obj/item/loot
		if(ispath(loot_type, /obj/item/stack))
			var/obj/item/stack/stack_type = loot_type
			loot = new stack_type(drop_turf, initial(stack_type.amount), FALSE)
		else
			loot = new loot_type(drop_turf)
		atom_storage.attempt_insert(loot, user, messages = FALSE)
	balloon_alert(user, "распаковано: [loot_amount]")
	atom_storage.show_contents(user)

/obj/item/storage/box/donor_stock/amount_1
	loot_amount = 1

/obj/item/storage/box/donor_stock/amount_2
	loot_amount = 2

/obj/item/storage/box/donor_stock/amount_5
	loot_amount = 5

/obj/item/storage/box/donor_stock/amount_10
	loot_amount = 10

/obj/item/storage/box/donor_stock/amount_15
	loot_amount = 15

/obj/item/storage/box/donor_stock/amount_20
	loot_amount = 20

/obj/item/storage/box/donor_stock/amount_30
	loot_amount = 30

/obj/item/storage/box/donor_stock/amount_40
	loot_amount = 40

/obj/item/storage/box/donor_stock/amount_50
	loot_amount = 50
