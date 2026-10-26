// One-to-one donor appearance adapters. Native parents supply supported equipment behavior.

/obj/structure/san_francisco_compat/cargocrate
	parent_type = /obj/structure/closet/crate/large
	name = "cargocrate"
	desc = "It delivers a lot of things."
	icon = 'modular_bandastation/san_francisco/icons/compat/798645789f_containers.dmi'
	icon_state = "1"
	base_icon_state = "1"
	density = FALSE
	anchored = TRUE

/obj/structure/san_francisco_compat/cargocrate/update_icon_state()
	. = ..()
	// The donor shipping container has no native crate opening frames.
	icon_state = initial(icon_state)

/obj/item/san_francisco_compat/item_bong
	parent_type = /obj/item/hookah
	name = "bong"
	desc = "Technically known as a water pipe."
	icon = 'modular_bandastation/san_francisco/icons/compat/99674c0cc6_items.dmi'
	icon_state = "bulbulator"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_bong/update_overlays()
	// Native hoses and coals belong to the hookah atlas, not the donor bong atlas.
	var/donor_icon = icon
	icon = /obj/item/hookah::icon
	. = ..()
	for(var/index in 1 to length(.))
		if(istext(.[index]))
			.[index] = mutable_appearance(icon, .[index])
	for(var/mutable_appearance/overlay in .)
		// Parent-generated base blockers must follow the donor base, not the native accessories.
		if(overlay.icon == icon && overlay.icon_state == initial(icon_state))
			overlay.icon = donor_icon
	icon = donor_icon

/obj/item/san_francisco_compat/item_chair_stool_bar_darkpack_red
	parent_type = /obj/item/chair/stool/bar
	name = "bar stool"
	desc = "Bar brawl essential."
	icon = 'modular_bandastation/san_francisco/icons/compat/6653ba25c4_chairs.dmi'
	icon_state = "bar_red_toppled"
	inhand_icon_state = "stool_bar"
	lefthand_file = 'icons/mob/inhands/items/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/chairs_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_chair_wood_darkpack_red
	parent_type = /obj/item/chair/wood
	name = "wooden chair"
	desc = "Bar brawl essential."
	icon = 'modular_bandastation/san_francisco/icons/compat/6653ba25c4_chairs.dmi'
	icon_state = "wooden_chair_red_toppled"
	inhand_icon_state = "woodenchair"
	lefthand_file = 'icons/mob/inhands/items/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/chairs_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_claymore_longsword
	parent_type = /obj/item/claymore
	name = "longsword"
	desc = "A classic weapon of the knight, the longsword is a versatile weapon that can be used for both cutting and thrusting."
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "longsword"
	worn_icon = 'modular_bandastation/san_francisco/icons/compat/73a7b3dbbd_worn_melee.dmi'
	inhand_icon_state = "longsword"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_claymore_longsword_keeper
	parent_type = /obj/item/claymore
	name = "The Brother's Keeper"
	desc = "The ancient yet classic weapon of times gone, this is a longsword. This exemplar is surprisingly well taken care of, despite its age, to the point that whatever blood or vitae it may have drawn in the past is not visible at all, while still functioning as well as it first did however long ago. Upon the flat side of this blade, a simple well-worn inscription is engraved in Latin. 'In Death, I Rise.'"
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "longsword"
	color = "#C0C0C0"
	worn_icon = 'modular_bandastation/san_francisco/icons/compat/73a7b3dbbd_worn_melee.dmi'
	inhand_icon_state = "longsword"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_food_pizzaslice_square
	parent_type = /obj/item/food/pizzaslice/margherita
	name = "square pizza slice"
	desc = "This slice of pizza should not be"
	icon = 'modular_bandastation/san_francisco/icons/compat/aae2e68d49_items.dmi'
	icon_state = "pizza"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_gas_can
	parent_type = /obj/item/reagent_containers/cup/jerrycan
	name = "gas can"
	desc = "Stores gasoline or pure fire death."
	icon = 'modular_bandastation/san_francisco/icons/compat/dfe516e04e_items.dmi'
	icon_state = "gasoline"
	inhand_icon_state = "gasoline"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	fill_icon_thresholds = null
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_gas_can_full
	parent_type = /obj/item/reagent_containers/cup/jerrycan/oil
	name = "gas can"
	desc = "Stores gasoline or pure fire death."
	icon = 'modular_bandastation/san_francisco/icons/compat/dfe516e04e_items.dmi'
	icon_state = "gasoline"
	inhand_icon_state = "gasoline"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	fill_icon_thresholds = null
	list_reagents = list(/datum/reagent/fuel = 200)
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_gas_can/update_overlays()
	var/donor_icon = icon
	icon = /obj/item/reagent_containers/cup/jerrycan::icon
	. = ..()
	for(var/mutable_appearance/overlay in .)
		if(overlay.icon == icon && overlay.icon_state == initial(icon_state))
			overlay.icon = donor_icon
	icon = donor_icon

/obj/item/san_francisco_compat/item_gas_can_full/update_overlays()
	var/donor_icon = icon
	icon = /obj/item/reagent_containers/cup/jerrycan::icon
	. = ..()
	for(var/mutable_appearance/overlay in .)
		if(overlay.icon == icon && overlay.icon_state == initial(icon_state))
			overlay.icon = donor_icon
	icon = donor_icon

/obj/item/san_francisco_compat/item_gas_can_full/worn_overlays(mutable_appearance/standing, isinhands, icon_file, bodyshape = NONE)
	// Only the cap overlay uses the native atlas; the held can keeps its donor sprite.
	if(isinhands)
		icon_file = icon_file == lefthand_file ? /obj/item/reagent_containers/cup/jerrycan::lefthand_file : /obj/item/reagent_containers/cup/jerrycan::righthand_file
	return ..(standing, isinhands, icon_file, bodyshape)

/obj/item/san_francisco_compat/item_gas_can_rand
	parent_type = /obj/item/reagent_containers/cup/jerrycan
	name = "gas can"
	desc = "Stores gasoline or pure fire death."
	icon = 'modular_bandastation/san_francisco/icons/compat/dfe516e04e_items.dmi'
	icon_state = "gasoline"
	inhand_icon_state = "gasoline"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	fill_icon_thresholds = null
	list_reagents = list()
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_gas_can_rand/update_overlays()
	var/donor_icon = icon
	icon = /obj/item/reagent_containers/cup/jerrycan::icon
	. = ..()
	for(var/mutable_appearance/overlay in .)
		if(overlay.icon == icon && overlay.icon_state == initial(icon_state))
			overlay.icon = donor_icon
	icon = donor_icon

/obj/item/san_francisco_compat/item_guts
	parent_type = /obj/item/organ/stomach
	name = "guts"
	desc = "Just blood and guts..."
	icon = 'modular_bandastation/san_francisco/icons/compat/798fb2b9a5_flesh_items.dmi'
	icon_state = "guts"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_spine
	parent_type = /obj/item/stack/sheet/bone
	name = "spine"
	desc = "If only I had control..."
	icon = 'modular_bandastation/san_francisco/icons/compat/798fb2b9a5_flesh_items.dmi'
	icon_state = "spine"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_laser_pointer_upgraded
	parent_type = /obj/item/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "pointer"
	worn_icon_state = "pen"
	inhand_icon_state = "pen"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_liquid_flamethrower
	parent_type = /obj/item/flamethrower/full/tank
	name = "flamethrower"
	desc = "Well fire weapon."
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "flamethrower4"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_melee_sabre_rapier
	parent_type = /obj/item/melee/sabre
	name = "rapier"
	desc = "A thin, elegant sword, the rapier is a weapon of the duelist, designed for thrusting."
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "rapier"
	worn_icon = 'modular_bandastation/san_francisco/icons/compat/73a7b3dbbd_worn_melee.dmi'
	inhand_icon_state = "rapier"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_molotov
	parent_type = /obj/item/reagent_containers/cup/glass/bottle/molotov
	name = "molotov cocktail"
	desc = "A throwing weapon used to ignite things, typically filled with an accelerant. Recommended highly by rioters and revolutionaries. Light and toss."
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "molotov"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_occult_artifact_vampire_key_of_alamut
	parent_type = /obj/item
	name = "unidentified occult fetish"
	desc = "Who knows what secrets it could contain..."
	icon = 'modular_bandastation/san_francisco/icons/compat/119b4f73b4_artifacts.dmi'
	icon_state = "k_alamut"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_radio_headset_darkpack_police
	parent_type = /obj/item/radio/headset/headset_sec
	name = "police radio"
	desc = "A portable radio headset operating on the P25 digital standard."
	icon = 'modular_bandastation/san_francisco/icons/compat/fd1d2a4a61_radio.dmi'
	icon_state = "pp25"
	worn_icon_state = "headset"
	inhand_icon_state = "headset"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_reagent_containers_cup_glass_bottle_beer_vampire_blue_stripe
	parent_type = /obj/item/reagent_containers/cup/glass/bottle/beer
	name = "blue stripe"
	desc = "Blue stripe beer, brought to you by King Breweries and Distilleries!"
	icon = 'modular_bandastation/san_francisco/icons/compat/aae2e68d49_items.dmi'
	icon_state = "beer_blue"
	// This donor bottle already includes its opaque contents in the base sprite.
	fill_icon_thresholds = null
	worn_icon_state = "bottle"
	inhand_icon_state = "beer"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_reagent_containers_cup_glass_vampirecola
	parent_type = /obj/item/reagent_containers/cup/soda_cans/cola
	name = "two liter cola bottle"
	desc = "Coca cola espuma..."
	icon = 'modular_bandastation/san_francisco/icons/compat/aae2e68d49_items.dmi'
	icon_state = "colared"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_reagent_containers_cup_mixing_bowl
	parent_type = /obj/item/reagent_containers/cup/bowl
	name = "mixing bowl"
	desc = "A mixing bowl. It can hold up to 50 units. Perfect for cooking"
	icon = 'modular_bandastation/san_francisco/icons/compat/aae2e68d49_items.dmi'
	icon_state = "mixingbowl"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_reagent_containers_cup_watering_can_metal
	parent_type = /obj/item/reagent_containers/cup/watering_can
	name = "watering can"
	desc = "It's a watering can. It is scientifically proved that using a watering can to simulate rain increases plant happiness!"
	icon = 'modular_bandastation/san_francisco/icons/compat/99674c0cc6_items.dmi'
	icon_state = "bailer"
	inhand_icon_state = "watering_can"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_ashtray
	parent_type = /obj/item/storage
	name = "ashtray"
	desc = "A small bowl for holding and disposing of smokestuffs."
	icon = 'modular_bandastation/san_francisco/icons/compat/adece606d7_ashtray.dmi'
	icon_state = "ashtray"
	base_icon_state = "ashtray"
	color = "#303030"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_belt_security_police
	parent_type = /obj/item/storage/belt/security
	name = "duty belt"
	desc = "A black leather belt for holding patrol gear."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "security"
	worn_icon_state = "security"
	inhand_icon_state = "security"//Could likely use a better one.
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_belt_sheath_vamp_rapier
	parent_type = /obj/item/storage/belt/sheath/sabre
	name = "sheath"
	desc = "An ornate sheath designed to hold a duelist's blade."
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "rapier_sheathe"
	base_icon_state = "rapier_sheathe"
	worn_icon = 'modular_bandastation/san_francisco/icons/compat/73a7b3dbbd_worn_melee.dmi'
	worn_icon_state = "rapier_sheathe"
	inhand_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_belt_sheath_vamp_sword
	parent_type = /obj/item/storage/belt/sheath/katana/empty
	name = "sheath"
	desc = "An ornate sheath designed to hold a knight's blade."
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "longsword_sheathe"
	base_icon_state = "longsword_sheathe"
	worn_icon = 'modular_bandastation/san_francisco/icons/compat/73a7b3dbbd_worn_melee.dmi'
	worn_icon_state = "longsword_sheathe"
	inhand_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_fancy_hardcase
	parent_type = /obj/item/storage/briefcase/empty
	name = "magazine hardcase"
	desc = "A small metal hardcase designed to carry magazines."
	icon = 'modular_bandastation/san_francisco/icons/compat/ed22a5b0db_storage.dmi'
	icon_state = "hardcasebox"
	base_icon_state = "hardcasebox"
	inhand_icon_state = "ammobox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_fancy_hardcase_mag_mp5
	parent_type = /obj/item/storage/briefcase/empty
	name = "mp5 magazine hardcase"
	desc = "A small metal hardcase specifically designed to carry mp5 magazines."
	icon = 'modular_bandastation/san_francisco/icons/compat/ed22a5b0db_storage.dmi'
	icon_state = "hardcasebox"
	base_icon_state = "hardcasebox"
	inhand_icon_state = "ammobox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_pill_bottle_estrogen
	parent_type = /obj/item/storage/pill_bottle
	name = "estrogen pill bottle"
	desc = "There are boobs on the top."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "pill_canister"
	worn_icon_state = "nothing"
	inhand_icon_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_toy_plush_argemia
	parent_type = /obj/item/toy/plush/abductor
	name = "strange plushie"
	desc = "Voiding..."
	icon = 'modular_bandastation/san_francisco/icons/compat/0f39fc590b_toys.dmi'
	icon_state = "argemia"
	worn_icon_state = "plushie"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_toy_rubberpig
	parent_type = /obj/item/toy/plush/pig
	name = "rubberpig"
	desc = "Do not."
	icon = 'modular_bandastation/san_francisco/icons/compat/54dd1d54ef_icons.dmi'
	icon_state = "rubberpig"
	worn_icon_state = "nothing"
	inhand_icon_state = "rubberpig"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/0126c35bab_lefthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/da20699a8d_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_trash_vampirebar
	parent_type = /obj/item/trash/candy
	name = "chocolate bar wrapper"
	desc = "This is rubbish."
	icon = 'modular_bandastation/san_francisco/icons/compat/aae2e68d49_items.dmi'
	icon_state = "bar0"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_trash_vampirenugget
	parent_type = /obj/item/trash/cheesie
	name = "chicken wing bone"
	desc = "This is rubbish."
	icon = 'modular_bandastation/san_francisco/icons/compat/aae2e68d49_items.dmi'
	icon_state = "nugget0"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_vampire_stake
	parent_type = /obj/item/knife
	name = "stake"
	desc = "Paralyzes blank-bodies if aimed straight to the heart."
	icon = 'modular_bandastation/san_francisco/icons/compat/b93cb3d7f1_weapons.dmi'
	icon_state = "stake"
	worn_icon = 'modular_bandastation/san_francisco/icons/compat/73a7b3dbbd_worn_melee.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_watch
	parent_type = /obj/item/toy/clockwork_watch
	name = "wrist watch"
	desc = "A portable device to check time."
	icon = 'modular_bandastation/san_francisco/icons/compat/c1dab43ea6_clock.dmi'
	icon_state = "watch"
	worn_icon = 'modular_bandastation/san_francisco/icons/compat/cb9da1310f_worn.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_wirecutters_pliers_bad
	parent_type = /obj/item/wirecutters
	name = "pliers"
	desc = "Meant for pulling wires but you could definitely crush something with these."
	icon = 'modular_bandastation/san_francisco/icons/compat/41259403a3_pliers.dmi'
	icon_state = "ripper"
	worn_icon_state = "cutters"
	inhand_icon_state = "ripper"
	lefthand_file = 'modular_bandastation/san_francisco/icons/compat/da52fd6995_melee_lefthand.dmi'
	righthand_file = 'modular_bandastation/san_francisco/icons/compat/190e081921_melee_righthand.dmi'
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	density = FALSE
	anchored = FALSE

/obj/structure/san_francisco_compat/machinery_atm
	parent_type = /obj/structure
	name = "\improper ATM machine"
	desc = "Check your balance or make a transaction."
	icon = 'modular_bandastation/san_francisco/icons/compat/e7e71d1d3b_atm.dmi'
	icon_state = "atm"
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	density = FALSE

/obj/structure/san_francisco_compat/machinery_bitcoin_miner
	parent_type = /obj/structure
	name = "bitcoin miner"
	desc = "It's a rig designed to mine cryptocurrency with a monitor connected to it.\nIt has an output for withdrawing the cash obtained from mining, somehow."
	icon = 'modular_bandastation/san_francisco/icons/compat/a192ed3875_bitcoinminer.dmi'
	icon_state = "miner_off"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER


/obj/structure/san_francisco_compat/machinery_computer_stockexchange
	parent_type = /obj/structure
	name = "stock exchange computer"
	desc = "A console that connects to the galactic stock market. Stocks trading involves substantial risk of loss and is not suitable for every cargo technician."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = MAP_SWITCH("oldcomp", "/obj/machinery/computer/pod/old")
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER


/obj/machinery/san_francisco_compat/machinery_hydroponics_simple_plastic
	parent_type = /obj/machinery/hydroponics/constructable
	name = "plastic planter box"
	desc = "A plastic plant tray"
	icon = 'modular_bandastation/san_francisco/icons/compat/07c968eebb_tray.dmi'
	icon_state = "plastic_tray"
	pixel_z = 8
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_hydroponics_simple_wooden
	parent_type = /obj/machinery/hydroponics/soil
	name = "wooden planter box"
	desc = "A wooden plant tray"
	icon = 'modular_bandastation/san_francisco/icons/compat/07c968eebb_tray.dmi'
	icon_state = "wooden_tray"
	pixel_z = 8
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/structure/san_francisco_compat/machinery_logging_machine
	parent_type = /obj/structure
	name = "surveillance machine"
	desc = "It seems to be a contraption of sorts that stores a variety of logs. It seems to be connected to the city's mobile phone antenna."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "relay"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER


/obj/machinery/san_francisco_compat/machinery_porta_turret_pentex
	parent_type = /obj/machinery/porta_turret
	name = "turret"
	desc = "A ballistic machine gun auto-turret."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "syndie_off"
	base_icon_state = "syndie"
	density = TRUE
	anchored = TRUE
	layer = OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_reagentgrinder_kitchen
	parent_type = /obj/machinery/reagentgrinder
	name = "kitchen mixer"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "juicer"
	base_icon_state = "juicer"
	anchored_tabletop_offset = 8
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/structure/san_francisco_compat/machinery_sprinkler
	parent_type = /obj/structure
	name = "fire sprinkler"
	desc = "Some kind of machine."
	icon = 'modular_bandastation/san_francisco/icons/compat/ce4dbbe3c4_sprinkler.dmi'
	icon_state = "sprinkler"
	pixel_y = 8
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	density = FALSE

/obj/structure/san_francisco_compat/machinery_sprinkler_area_managed
	parent_type = /obj/structure
	name = "fire sprinkler"
	desc = "Some kind of machine."
	icon = 'modular_bandastation/san_francisco/icons/compat/ce4dbbe3c4_sprinkler.dmi'
	icon_state = "sprinkler"
	pixel_y = 8
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	density = FALSE

/obj/machinery/san_francisco_compat/machinery_telecomms_allinone_public
	parent_type = /obj/machinery/telecomms/allinone
	name = "global telecommunications mainframe"
	desc = "A mainframe that allows for the processing of priority radio telecommunications."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "comm_server"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_vending_cigarette_shelf
	parent_type = /obj/machinery/vending/cigarette
	name = "cigarette shelf"
	desc = "Every variety, except for the one you really like."
	icon = 'modular_bandastation/san_francisco/icons/compat/caf396def7_cigarette_shelf.dmi'
	icon_state = "ciggies1"
	base_icon_state = "ciggies"
	// The original shelf has no ShadyCigs emissive mask.
	light_mask = null
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/structure/san_francisco_compat/structure_cargo_put
	parent_type = /obj/structure
	name = "cargo"
	desc = "Take and place boxes."
	icon = 'modular_bandastation/san_francisco/icons/compat/b05f968256_box.dmi'
	icon_state = "box_put"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER


/obj/structure/san_francisco_compat/structure_cargo_take
	parent_type = /obj/structure
	name = "cargo"
	desc = "Take and place boxes."
	icon = 'modular_bandastation/san_francisco/icons/compat/b05f968256_box.dmi'
	icon_state = "box_take"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER


/obj/structure/san_francisco_compat/lombard
	parent_type = /obj/structure
	name = "pawnshop"
	desc = "Sell your stuff."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "sell"
	anchored = TRUE
	density = FALSE

/obj/structure/san_francisco_compat/lombard_blackmarket
	parent_type = /obj/structure
	name = "black market"
	desc = "Sell illegal goods."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "sell_d"
	anchored = TRUE
	density = FALSE

/obj/item/san_francisco_compat/vampire_computer
	parent_type = /obj/item/modular_computer/laptop/preset/civilian
	name = "old computer"
	desc = "For some reason its just stuck on the lock screen and all the buttons dont seem to do anything... (We have yet to reimplement vampire computers! Sorry!)"
	icon = 'modular_bandastation/san_francisco/icons/compat/7348e7d4f2_props.dmi'
	icon_state = "computer"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/vampire_computer_box
	parent_type = /obj/item/modular_computer/laptop/preset/civilian
	name = "old computer"
	desc = "For some reason its just stuck on the lock screen and all the buttons dont seem to do anything... (We have yet to reimplement vampire computers! Sorry!)"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "oldcomp"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/vampire_computer_prince
	parent_type = /obj/item/modular_computer/laptop/preset/civilian
	name = "old computer"
	desc = "For some reason its just stuck on the lock screen and all the buttons dont seem to do anything... (We have yet to reimplement vampire computers! Sorry!)"
	icon = 'modular_bandastation/san_francisco/icons/compat/7348e7d4f2_props.dmi'
	icon_state = "computerprince"
	density = FALSE
	anchored = FALSE

/obj/structure/san_francisco_compat/lettermachine
	parent_type = /obj/structure
	name = "letter machine"
	desc = "Work as letterman! Find a job!"
	icon = 'modular_bandastation/san_francisco/icons/compat/a151baa545_letters.dmi'
	icon_state = "mail"
	density = TRUE
	anchored = TRUE
	layer = 4.65 // Original donor CAR_LAYER.
	plane = GAME_PLANE


/obj/machinery/san_francisco_compat/warehouse_generator
	parent_type = /obj/machinery/power/port_gen/pacman
	name = "generator"
	desc = "Power the controlled area with pure electricity."
	icon = 'modular_bandastation/san_francisco/icons/compat/31b722c357_electricity.dmi'
	icon_state = "gen"
	density = TRUE
	anchored = TRUE
	layer = 4.65 // Original donor CAR_LAYER.
	plane = GAME_PLANE

/obj/machinery/san_francisco_compat/structure_methlab
	parent_type = /obj/machinery/chem_heater
	name = "chemical laboratory"
	desc = "\"Jesse... It's not about style, it's about science...\""
	icon = 'modular_bandastation/san_francisco/icons/compat/1fd1d605fc_32x48.dmi'
	icon_state = "methlab"
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/warehouse_generator/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)

/obj/machinery/san_francisco_compat/warehouse_generator/update_overlays()
	var/donor_icon = icon
	icon = /obj/machinery/power/port_gen/pacman::icon
	. = ..()
	for(var/mutable_appearance/overlay in .)
		if(overlay.icon == icon && overlay.icon_state == initial(icon_state))
			overlay.icon = donor_icon
	icon = donor_icon

/obj/machinery/san_francisco_compat/structure_methlab/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/san_francisco_compat/structure_reagent_dispensers_cleaningfluid
	parent_type = /obj/structure/reagent_dispensers/watertank
	name = "cleaning fluid tank"
	desc = "A container filled with cleaning fluid."
	icon = 'icons/obj/medical/chemical_tanks.dmi'
	icon_state = "water"
	reagent_id = /datum/reagent/space_cleaner
	density = TRUE
	anchored = FALSE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_aasimites
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	fax_name = "Chubby Lion Coffee Shop"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_admin_fbi
	parent_type = /obj/machinery/fax
	name = "CentCom Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	fax_name = "FBI National Headquarters"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_anarch
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	fax_name = "Anarchy Rose Bar"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_camarilla
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	fax_name = "Millenium Tower"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_clinic
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	fax_name = "Saint John's Clinic"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_endron
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_glasswalker
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	fax_name = "Nightwolf Tech Shop"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_police
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_fax_tremere
	parent_type = /obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy."
	icon = 'icons/obj/machines/fax.dmi'
	icon_state = "fax"
	anchored_tabletop_offset = 6
	fax_name = "Library"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_radio_tranceiver_anarch
	parent_type = /obj/machinery/telecomms/allinone
	name = "radio transceiver"
	desc = "A machine used for connecting and managing radios on its designated network."
	icon = 'modular_bandastation/san_francisco/icons/compat/fd1d2a4a61_radio.dmi'
	icon_state = "walkietalkie"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_radio_tranceiver_camarilla
	parent_type = /obj/machinery/telecomms/allinone
	name = "radio transceiver"
	desc = "A machine used for connecting and managing radios on its designated network."
	icon = 'modular_bandastation/san_francisco/icons/compat/fd1d2a4a61_radio.dmi'
	icon_state = "walkietalkie"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_radio_tranceiver_clinic
	parent_type = /obj/machinery/telecomms/allinone
	name = "radio transceiver"
	desc = "A machine used for connecting and managing radios on its designated network."
	icon = 'modular_bandastation/san_francisco/icons/compat/fd1d2a4a61_radio.dmi'
	icon_state = "walkietalkie"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_radio_tranceiver_endron
	parent_type = /obj/machinery/telecomms/allinone
	name = "radio transceiver"
	desc = "A machine used for connecting and managing radios on its designated network."
	icon = 'modular_bandastation/san_francisco/icons/compat/fd1d2a4a61_radio.dmi'
	icon_state = "walkietalkie"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/machinery/san_francisco_compat/machinery_radio_tranceiver_police
	parent_type = /obj/machinery/telecomms/allinone
	name = "radio transceiver"
	desc = "A machine used for connecting and managing radios on its designated network."
	icon = 'modular_bandastation/san_francisco/icons/compat/fd1d2a4a61_radio.dmi'
	icon_state = "walkietalkie"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER

/obj/item/san_francisco_compat/item_fish_darkpack_shark
	parent_type = /obj/item/fish/pike
	fish_id = "darkpack_shark"
	name = "leopard shark"
	desc = "Often found in groups foraging for clams, crabs, shrimp, and worms in intertidal mudflats found along the west coast, these sharks are rarely found bigger than 2 meters."
	icon = 'modular_bandastation/san_francisco/icons/compat/c973a4a45b_fish48x32.dmi'
	icon_state = "shark"
	pixel_w = -16
	lefthand_file = 'icons/mob/inhands/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/fish_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_carnivore
	parent_type = /obj/item/storage/box/ingredients/american
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "carnivore"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_exotic
	parent_type = /obj/item/storage/box/ingredients/wildcard
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "exotic"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_fruity
	parent_type = /obj/item/storage/box/ingredients/wildcard
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "fruity"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_grains
	parent_type = /obj/item/storage/box/ingredients/american
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "grains"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_italian
	parent_type = /obj/item/storage/box/ingredients/american
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "italian"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_seafood
	parent_type = /obj/item/storage/box/ingredients/wildcard
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "seafood"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_sweets
	parent_type = /obj/item/storage/box/ingredients/wildcard
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "sweets"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_vegetarian
	parent_type = /obj/item/storage/box/ingredients/wildcard
	name = "ingredients box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "vegetarian"
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_box_ingredients_random
	parent_type = /obj/item/storage/box/ingredients/wildcard
	name = "ingredients box"
	desc = "This box should not exist, contact the proper authorities."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	theme_name = "random"
	density = FALSE
	anchored = FALSE

/obj/structure/san_francisco_compat/structure_retail_antique
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A store where antique weapons are sold. Fedoras not included."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_art_store
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "Unleash your inner artist!"
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_bacotell_menu
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_black_market
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_bubway_menu
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_camping
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A store for camping supplies. Smores not included."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_clothing_store
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "Purchase all the finest outfits.. Or don't wagie.."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_costume_store
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "Purchase a mask for that ugly mug."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_flower_shop
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "The only 24hr flower shop in SanFran."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_gas_station
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_general
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A general store for general needs."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_grocery_store
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A small grocery store."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_gummaguts_menu
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_gun_store
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "Boom! Booom!! BOOOOOOM!!!!"
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_hardware_store
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_junkfood_menu
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "Purchase junkfood and crap."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_library
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_music
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A music store. If you play Stairway to Heaven..."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_occult
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "Use your occult research to reap the benefits of safeguarded knowledge and artifacts."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "menu"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_occult_baali
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "Infernal Rune"
	desc = "Use your demonic knowledge to ask for favors of Infernal. "
	icon = 'modular_bandastation/san_francisco/icons/compat/4f8004414f_64x64.dmi'
	icon_state = "baali"
	pixel_z = -16
	pixel_w = -16
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_pharmacy
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_police_equipment
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_red_dragon_menu
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_skate_shop
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/structure/san_francisco_compat/structure_retail_smoke_menu
	parent_type = /obj/structure/san_francisco_retail_compat
	name = "retail outlet"
	desc = "A counter for partaking in wretched capitalism. Takes cash or card."
	icon = 'modular_bandastation/san_francisco/icons/compat/c33943f26e_vendors_shops.dmi'
	icon_state = "register"
	anchored_tabletop_offset = 6
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	take_area_name = TRUE

/obj/item/san_francisco_compat/item_reagent_containers_cup_silver_goblet_vaulderie_goblet
	parent_type = /obj/item/reagent_containers/cup
	name = "Vaulderie Goblet"
	desc = "An obsidian-black goblet used in ancient vampire rites."
	icon = 'modular_bandastation/san_francisco/icons/compat/0c8d21e1a6_vaulderie_goblet.dmi'
	icon_state = "vaulderie_goblet"
	base_icon_state = "vaulderie_goblet"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	volume = 80
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_stack_sheet_mineral_diamond_crown
	parent_type = /obj/item/clothing/head/costume/crown/fancy
	name = "The Crown Diamond"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-diamond"
	worn_icon_state = "purified_soulstone"
	inhand_icon_state = "sheet-diamond"
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	density = FALSE
	anchored = FALSE

/obj/item/san_francisco_compat/item_storage_ashtray/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 16
	atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
	atom_storage.set_holdable(list(/obj/item/match, /obj/item/cigbutt, /obj/item/cigarette, /obj/item/rollingpaper), list(/obj/item/cigarette/pipe))

/obj/item/san_francisco_compat/item_watch/attack_self(mob/user)
	return

/obj/item/san_francisco_compat/vampire_computer/update_icon_state()
	icon_state = initial(icon_state)

/obj/item/san_francisco_compat/vampire_computer_box/update_icon_state()
	icon_state = initial(icon_state)

/obj/item/san_francisco_compat/vampire_computer_prince/update_icon_state()
	icon_state = initial(icon_state)

// The donor register takes its visible name from the existing mapped shop area.
/obj/structure/san_francisco_retail_compat
	var/take_area_name = TRUE

/obj/structure/san_francisco_retail_compat/Initialize(mapload)
	. = ..()
	if(take_area_name)
		name = get_area_name(src, TRUE)

// Original donor infrastructure props.

/obj/structure/san_francisco_compat/fusebox
	parent_type = /obj/structure
	name = "fuse box"
	desc = "Power the controlled area with pure electricity."
	icon = 'modular_bandastation/san_francisco/icons/compat/31b722c357_electricity.dmi'
	icon_state = "fusebox"
	base_icon_state = "fusebox"
	pixel_y = 32
	layer = SIGN_LAYER
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	density = FALSE
	anchored = TRUE

/obj/structure/san_francisco_compat/fusebox_transformer
	parent_type = /obj/structure
	name = "transformer"
	desc = "Power the controlled area with pure electricity."
	icon = 'modular_bandastation/san_francisco/icons/compat/31b722c357_electricity.dmi'
	icon_state = "sstation"
	base_icon_state = "sstation"
	pixel_y = 0
	layer = SIGN_LAYER
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	density = 1
	anchored = TRUE

/obj/structure/san_francisco_compat/keypad_armory
	parent_type = /obj/structure
	name = "keypad"
	desc = "Requires a password to open."
	icon = 'modular_bandastation/san_francisco/icons/compat/b7bdd3ddf9_keypad.dmi'
	icon_state = "keypad"
	layer = SIGN_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	density = FALSE
	anchored = TRUE

/obj/structure/san_francisco_compat/keypad_panic_room
	parent_type = /obj/structure
	name = "keypad"
	desc = "Requires a password to open."
	icon = 'modular_bandastation/san_francisco/icons/compat/b7bdd3ddf9_keypad.dmi'
	icon_state = "keypad"
	layer = SIGN_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	density = FALSE
	anchored = TRUE

/obj/structure/san_francisco_compat/weapon_showcase
	parent_type = /obj/structure
	name = "weapon showcase"
	desc = "Look, a gun."
	icon = 'modular_bandastation/san_francisco/icons/compat/01107ebfdb_showcase.dmi'
	icon_state = "showcase"
	layer = BELOW_OBJ_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	density = TRUE
	anchored = TRUE

/obj/structure/san_francisco_compat/weapon_showcase/Initialize(mapload)
	. = ..()
	icon_state = "showcase[rand(1, 7)]"
