/obj/item/clothing/under/donor
	abstract_type = /obj/item/clothing/under/donor
	icon = 'modular_bandastation/donor_jobs/icons/clothing/uniforms.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_uniforms.dmi'
	can_adjust = FALSE
	female_sprite_flags = NO_FEMALE_UNIFORM
	inhand_icon_state = null

/obj/item/clothing/under/rank/civilian/barber
	parent_type = /obj/item/clothing/under/donor
	name = "barber's uniform"
	desc = "A barber's uniform."
	icon_state = "barber"

/obj/item/clothing/under/rank/civilian/bartender
	parent_type = /obj/item/clothing/under/donor
	name = "bartender's uniform"
	desc = "It looks like it could use some more flair."
	icon_state = "ba_suit"

/obj/item/clothing/under/donor/iaa
	name = "internal affairs uniform"
	desc = "Plain, professional attire with an immaculately starched collar."
	icon_state = "iaa"

/obj/item/clothing/under/donor/iaa/purple
	name = "purple suit"
	desc = "Purple slacks with a black waistcoat and puffy white tie."
	icon_state = "iaa_purple"

/obj/item/clothing/under/donor/iaa/blue
	name = "blue suit"
	desc = "Blue suit pants, a white ironed shirt and a red tie."
	icon_state = "iaa_blue"

/obj/item/clothing/under/donor/amish
	name = "amish suit"
	desc = "A very amish looking suit."
	icon_state = "sl_suit"

/obj/item/clothing/under/donor/victorian
	name = "victorian suit"
	desc = "A fancy Victorian suit."
	icon_state = "victorianvest"
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/under/donor/victorian/red
	name = "red victorian suit"
	icon_state = "victorianredvest"

/obj/item/clothing/under/donor/victorian/red_black
	name = "red and black victorian suit"
	icon_state = "victorianblred"

/obj/item/clothing/under/donor/victorian_dress
	name = "black victorian dress"
	desc = "A fancy Victorian dress."
	icon_state = "victorianblackdress"
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/under/donor/victorian_dress/red
	name = "red victorian dress"
	icon_state = "victorianreddress"

/obj/item/clothing/under/donor/evening_gown
	name = "red evening gown"
	desc = "A fancy dress for space bar singers."
	icon_state = "red_evening_gown"

/obj/item/clothing/under/costume/cuban_suit
	parent_type = /obj/item/clothing/under/donor
	name = "rhumba outfit"
	desc = "A satin shirt and high-waisted pants for rhumba dancers."
	icon_state = "cuban_suit"

/obj/item/clothing/under/donor/maid
	name = "maid uniform"
	desc = "A simple maid uniform for housekeeping."
	icon_state = "janimaid"
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/under/pants/white
	name = "white pants"
	desc = "Plain white pants. Boring."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/uniforms.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_uniforms.dmi'
	icon_state = "whitepants"
	can_adjust = FALSE
	inhand_icon_state = null

/obj/item/clothing/under/donor/tsf
	name = "\improper Trans-Solar Federation marine uniform"
	desc = "A comfortable and durable uniform worn by Trans-Solar Federation marines."
	icon_state = "solgov"
	armor_type = /datum/armor/donor_tsf_uniform

/datum/armor/donor_tsf_uniform
	melee = 5
	fire = 20
	acid = 20

/obj/item/clothing/under/donor/tsf/representative
	name = "\improper Trans-Solar Federation representative's uniform"
	desc = "A formal uniform worn by diplomatic representatives of the Trans-Solar Federation."
	icon_state = "solgovr"

/obj/item/clothing/under/donor/ussp
	name = "\improper Soviet uniform"
	desc = "A standard U.S.S.P. military uniform."
	icon_state = "soviet"

/obj/item/clothing/under/donor/ussp/officer
	name = "\improper Soviet officer uniform"
	desc = "A U.S.S.P. commanding officer's uniform."
	icon_state = "sovietofficer"

/obj/item/clothing/under/rank/security/officer/donor_clown
	name = "security clown suit"
	desc = "<i>HONK THE LAW!</i>"
	icon = 'modular_bandastation/donor_jobs/icons/clothing/uniforms.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_uniforms.dmi'
	icon_state = "security_clown"
	can_adjust = FALSE
	female_sprite_flags = NO_FEMALE_UNIFORM
	inhand_icon_state = "clown"
	armor_type = /datum/armor/donor_security_uniform
	random_sensor = TRUE
	sensor_mode = SENSOR_OFF

/datum/armor/donor_security_uniform
	melee = 5
	fire = 20
	acid = 20

/obj/item/clothing/head/donor
	abstract_type = /obj/item/clothing/head/donor
	icon = 'modular_bandastation/donor_jobs/icons/clothing/hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_hats.dmi'
	inhand_icon_state = null

/obj/item/clothing/head/boaterhat
	parent_type = /obj/item/clothing/head/donor
	name = "boater hat"
	desc = "A stiff straw hat with a flat crown and brim."
	icon_state = "boater_hat"

/obj/item/clothing/head/fez
	parent_type = /obj/item/clothing/head/donor
	name = "fez"
	desc = "Put it on your monkey, make lots of cash money."
	icon_state = "fez"

/obj/item/clothing/head/cuban_hat
	parent_type = /obj/item/clothing/head/donor
	name = "rhumba hat"
	desc = "Now just to find some maracas!"
	icon_state = "cuban_hat"

/obj/item/clothing/head/soft/donor_tsf
	name = "\improper Trans-Solar Federation marine cap"
	desc = "A soft cap worn by Trans-Solar Federation marines."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_hats.dmi'
	icon_state = "solgovsoft_flipped"
	soft_type = "solgov"
	flipped = TRUE
	dog_fashion = null
	strip_delay = 6 SECONDS
	armor_type = /datum/armor/donor_tsf_hat

/datum/armor/donor_tsf_hat
	melee = 10
	bullet = 20
	laser = 20
	energy = 5
	bomb = 15
	fire = 50
	acid = 75

/obj/item/clothing/head/donor/tsf_beret
	name = "\improper Trans-Solar Federation lieutenant's beret"
	desc = "A marine beret bearing a lieutenant's insignia."
	icon_state = "solgovcberet"
	strip_delay = 8 SECONDS
	armor_type = /datum/armor/donor_tsf_hat

/obj/item/clothing/head/donor/ussp
	name = "\improper Soviet side cap"
	desc = "A simple military cap with a Soviet star on the front."
	icon_state = "sovietsidecap"

/obj/item/clothing/head/donor/ussp/officer
	name = "\improper Soviet officer hat"
	desc = "An officer's hat designed to stand out among conscripts."
	icon_state = "sovietofficerhat"

/obj/item/clothing/head/beanie/green
	name = "green beanie"
	greyscale_colors = "#5C9E54#5C9E54"

/obj/item/clothing/head/beanie/purple
	name = "purple beanie"
	greyscale_colors = "#9557C5#9557C5"

/obj/item/clothing/head/beanie/cyan
	name = "cyan beanie"
	greyscale_colors = "#54A3CE#54A3CE"

/obj/item/clothing/head/beret/donor_white
	name = "white beret"
	greyscale_colors = "#FFFFFF"

/obj/item/clothing/head/beret/donor_purple
	name = "purple beret"
	greyscale_colors = "#9557C5"

/obj/item/clothing/suit/donor
	abstract_type = /obj/item/clothing/suit/donor
	icon = 'modular_bandastation/donor_jobs/icons/clothing/suits.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_suits.dmi'
	inhand_icon_state = null

/obj/item/clothing/suit/mantle
	parent_type = /obj/item/clothing/suit/donor
	name = "mantle"
	desc = "A heavy quilted mantle for warm, stylish shoulders."
	icon_state = "mantle"
	body_parts_covered = CHEST|ARMS
	cold_protection = CHEST|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/mantle/old
	name = "old wrap"
	desc = "A tattered fabric wrap that smells faintly of cigars."
	icon_state = "old_mantle"

/obj/item/clothing/suit/unathi/mantle
	parent_type = /obj/item/clothing/suit/donor
	name = "hide mantle"
	desc = "Cured hides and skin sewn into a ragged mantle."
	icon_state = "mantle-unathi"
	body_parts_covered = CHEST

/obj/item/clothing/suit/pirate_black
	parent_type = /obj/item/clothing/suit/donor
	name = "black pirate coat"
	desc = "Yarr."
	icon_state = "pirate"

/obj/item/clothing/suit/pirate_black/brown
	name = "brown pirate coat"
	icon_state = "pirate_old"

/obj/item/clothing/suit/chef/classic
	parent_type = /obj/item/clothing/suit/donor
	name = "classic chef's apron"
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/knife)

/obj/item/clothing/suit/donor/victorian
	name = "ladies victorian coat"
	desc = "A fancy Victorian coat."
	icon_state = "ladiesvictoriancoat"

/obj/item/clothing/suit/donor/victorian/red
	name = "ladies red victorian coat"
	icon_state = "ladiesredvictoriancoat"

/obj/item/clothing/suit/donor/dracula
	name = "transylvanian coat"
	desc = "<i>What is a spessman? A miserable little pile of secrets.</i>"
	icon_state = "draculacoat"

/obj/item/clothing/suit/donor/ussp
	name = "\improper Soviet greatcoat"
	desc = "A thick wool military overcoat that protects against the elements."
	icon_state = "sovietcoat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/donor_ussp_coat
	allowed = list(/obj/item/flashlight, /obj/item/gun, /obj/item/ammo_box)

/datum/armor/donor_ussp_coat
	melee = 15
	bullet = 15
	laser = 15
	energy = 5
	bomb = 15
	fire = 30
	acid = 30

/obj/item/clothing/suit/donor/ussp/officer
	name = "\improper Soviet officer's greatcoat"
	desc = "An expensive wool overcoat with a U.S.S.P. armband."
	icon_state = "sovietofficercoat"
	armor_type = /datum/armor/donor_ussp_officer_coat

/datum/armor/donor_ussp_officer_coat
	melee = 25
	bullet = 25
	laser = 25
	energy = 10
	bomb = 20
	fire = 30
	acid = 30

/obj/item/clothing/suit/hooded/donor_religious
	abstract_type = /obj/item/clothing/suit/hooded/donor_religious
	icon = 'modular_bandastation/donor_jobs/icons/clothing/suits.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_suits.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	hood_up_affix = "_hood"
	auto_deploy_hood_on_outfit_equip = FALSE
	allowed = list(/obj/item/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/cup/glass/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/flashlight/flare/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/hooded/monk
	parent_type = /obj/item/clothing/suit/hooded/donor_religious
	name = "monk robe"
	desc = "Wooden board not included."
	icon_state = "monkrobe"
	hoodtype = /obj/item/clothing/head/hooded/donor_monk

/obj/item/clothing/head/hooded/donor_religious
	abstract_type = /obj/item/clothing/head/hooded/donor_religious
	icon = 'modular_bandastation/donor_jobs/icons/clothing/hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_hats.dmi'
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES
	inhand_icon_state = null

/obj/item/clothing/head/hooded/donor_monk
	parent_type = /obj/item/clothing/head/hooded/donor_religious
	name = "monk hood"
	desc = "Wooden board not included."
	icon_state = "monk_hood"

/obj/item/clothing/suit/hooded/hoodie/blue
	name = "blue hoodie"
	desc = "A hoodie with a hood, as most hoodies have."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/suits.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_suits.dmi'
	icon_state = "blue_hoodie"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	hoodtype = /obj/item/clothing/head/hooded/donor_blue
	hood_up_affix = "_hood"
	auto_deploy_hood_on_outfit_equip = FALSE
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/head/hooded/donor_blue
	name = "blue hood"
	desc = "A hood attached to a hoodie."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_hats.dmi'
	icon_state = "bluehood"
	cold_protection = HEAD
	flags_inv = HIDEHAIR|HIDEEARS
	inhand_icon_state = null

/obj/item/clothing/glasses/goggles
	name = "goggles"
	desc = "Basic, rather fashionable goggles."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/glasses.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_glasses.dmi'
	icon_state = "goggles"
	inhand_icon_state = null

/obj/item/clothing/shoes/footwraps
	name = "cloth footwraps"
	desc = "Treated canvas for wrapping claws or paws."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/shoes.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_shoes.dmi'
	icon_state = "clothwrap"
	inhand_icon_state = null
	force = 0
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/jackboots/noisy
	name = "heavy jackboots"
	desc = "Outdated, heavier Nanotrasen combat boots. Pick up that can."

/obj/item/clothing/shoes/jackboots/noisy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('modular_bandastation/donor_jobs/sound/jackboot1.ogg' = 1, 'modular_bandastation/donor_jobs/sound/jackboot2.ogg' = 1), 50, falloff_exponent = 20)

/obj/item/clothing/shoes/cowboy/black/laced/donor_preview
	snake_spawn_chance = 0

/obj/item/clothing/shoes/cowboy/laced/donor_preview
	snake_spawn_chance = 0

/obj/item/clothing/head/blob
	parent_type = /obj/item/clothing/head/donor
	name = "blob hat"
	desc = "A collectable hat from the latest Blob Family Reunion."
	icon_state = "blobhat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH

/obj/item/clothing/suit/donor/religious
	abstract_type = /obj/item/clothing/suit/donor/religious
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/cup/glass/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/flashlight/flare/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/donor/witchhunter
	parent_type = /obj/item/clothing/suit/donor/religious
	name = "witchhunter garb"
	desc = "Doesn't weigh the same as a duck."
	icon_state = "witchhunter"

/obj/item/clothing/head/donor/witchhunter
	name = "witchhunter hat"
	desc = "This hat saw much use back in the day."
	icon_state = "witchhunterhat"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/donor/holidaypriest
	parent_type = /obj/item/clothing/suit/donor/religious
	name = "holiday priest"
	desc = "This is a nice holiday, my son."
	icon_state = "holidaypriest"
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/under/donor/wedding
	name = "white wedding dress"
	desc = "A white wedding gown made from the finest silk."
	icon_state = "bride_white"
	flags_inv = HIDESHOES

/obj/item/clothing/head/helmet/chaplain/donor_templar
	armor_type = /datum/armor/donor_templar_helmet

/datum/armor/donor_templar_helmet
	melee = 10
	bullet = 5
	laser = 5
	energy = 5
	bomb = 5
	fire = 200
	acid = 200

/obj/item/clothing/suit/chaplainsuit/armor/templar/donor
	armor_type = /datum/armor/donor_templar_suit
	slowdown = 1

/obj/item/clothing/suit/chaplainsuit/armor/templar/donor/Initialize(mapload)
	. = ..()
	allowed = list(/obj/item/nullrod/claymore, /obj/item/book/bible)

/datum/armor/donor_templar_suit
	melee = 15
	bullet = 5
	laser = 5
	energy = 5
	fire = 200
	acid = 200

/obj/item/clothing/suit/hooded/nun
	parent_type = /obj/item/clothing/suit/hooded/donor_religious
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	hoodtype = /obj/item/clothing/head/hooded/donor_nun

/obj/item/clothing/head/hooded/donor_nun
	parent_type = /obj/item/clothing/head/hooded/donor_religious
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"

/obj/item/clothing/suit/hooded/chaplain_hoodie/donor
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon = 'modular_bandastation/donor_jobs/icons/clothing/suits.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_suits.dmi'
	hoodtype = /obj/item/clothing/head/hooded/donor_chaplain
	hood_up_affix = "_hood"
	auto_deploy_hood_on_outfit_equip = FALSE

/obj/item/clothing/suit/hooded/chaplain_hoodie/donor/Initialize(mapload)
	. = ..()
	allowed = /obj/item/clothing/suit/donor/religious::allowed

/obj/item/clothing/head/hooded/donor_chaplain
	parent_type = /obj/item/clothing/head/hooded/donor_religious
	name = "chaplain's hood"
	desc = "A hood to keep your head warm during space winters."
	icon_state = "chaplain_hood"

/obj/item/clothing/suit/hooded/abaya
	name = "abaya"
	desc = "Modest, unrevealing attire fitted with a veil."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/suits.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_suits.dmi'
	icon_state = "abaya"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/donor_niqab
	hood_up_affix = ""
	auto_deploy_hood_on_outfit_equip = FALSE
	allowed = /obj/item/clothing/suit/donor/religious::allowed
	var/reskinned = FALSE

/obj/item/clothing/suit/hooded/abaya/attack_self(mob/living/user)
	. = ..()
	if(reskinned)
		return
	var/list/colors = list("Чёрный" = "", "Красный" = "red", "Оранжевый" = "orange", "Жёлтый" = "yellow", "Зелёный" = "green", "Синий" = "blue", "Фиолетовый" = "purple", "Белый" = "white", "Радужный" = "rainbow")
	var/choice = tgui_input_list(user, "Цвет можно выбрать один раз.", "Цвет абайи", colors)
	if(isnull(choice) || !(choice in colors) || QDELETED(src) || QDELETED(user) || reskinned || !user.can_perform_action(src, NEED_DEXTERITY|ALLOW_RESTING))
		return
	reskinned = TRUE
	var/datum/component/toggle_attached_clothing/hood_component = GetComponent(/datum/component/toggle_attached_clothing)
	hood_component.remove_deployable()
	icon_state = "[colors[choice]]abaya"
	if(hood)
		hood.icon_state = "[icon_state]_hood"
		hood.update_appearance()
	update_appearance()
	if(ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		wearer.update_worn_oversuit()

/obj/item/clothing/suit/hooded/abaya/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	hood.icon_state = "[icon_state]_hood"

/obj/item/clothing/suit/hooded/abaya/on_hood_up(obj/item/clothing/head/hooded/hood)
	. = ..()
	worn_icon_state = "[icon_state]_hood"

/obj/item/clothing/suit/hooded/abaya/on_hood_down(obj/item/clothing/head/hooded/hood)
	. = ..()
	worn_icon_state = null

/obj/item/clothing/head/hooded/donor_niqab
	name = "screened niqab"
	desc = "A niqab with an eye mesh. The wearer can see you, but you can't see them."
	icon = 'modular_bandastation/donor_jobs/icons/clothing/hats.dmi'
	worn_icon = 'modular_bandastation/donor_jobs/icons/clothing/worn_hats.dmi'
	icon_state = "abaya_hood"
	inhand_icon_state = null
	cold_protection = HEAD
	flags_inv = HIDEHAIR|HIDEEARS|HIDEMASK|HIDEFACE|HIDEEYES

/obj/item/clothing/under/syndicate/donor_tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	armor_type = /datum/armor/donor_tacticool

/datum/armor/donor_tacticool
	fire = 50
	acid = 35

/obj/item/clothing/suit/armor/vest/old/donor
	armor_type = /datum/armor/donor_vest
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/armor/vest/alt/sec/donor
	armor_type = /datum/armor/donor_vest
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/armor/vest/warden/alt/donor
	armor_type = /datum/armor/donor_vest

/datum/armor/donor_vest
	melee = 20
	bullet = 20
	laser = 20
	energy = 5
	bomb = 15
	fire = 50
	acid = 50

/obj/item/clothing/head/helmet/donor
	armor_type = /datum/armor/donor_security_helmet

/datum/armor/donor_security_helmet
	melee = 25
	bullet = 20
	laser = 20
	energy = 5
	bomb = 15
	fire = 50
	acid = 50

/obj/item/clothing/head/hats/warden/red/donor
	armor_type = /datum/armor/donor_security_cap

/obj/item/clothing/head/soft/sec/donor
	armor_type = /datum/armor/donor_security_cap

/datum/armor/donor_security_cap
	melee = 25
	bullet = 20
	laser = 20
	energy = 5
	fire = 10
	acid = 50

/obj/item/clothing/suit/toggle/jacket/det_trench/donor
	armor_type = /datum/armor/donor_detective_coat
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS

/datum/armor/donor_detective_coat
	melee = 15
	bullet = 5
	laser = 15
	energy = 5
	acid = 40

/obj/item/clothing/head/fedora/donor_detective
	name = "detective's fedora"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	inhand_icon_state = "detective"
	armor_type = /datum/armor/donor_detective_hat

/obj/item/clothing/head/fedora/donor_detective/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/food/candy_corn, /obj/item/pen))

/datum/armor/donor_detective_hat
	melee = 15
	bullet = 5
	laser = 15
	energy = 5
	fire = 20
	acid = 50
