/obj/item/donor_id_skin
	name = "наклейка на карту"
	desc = "Этим можно изменить внешний вид своей карты! Покажи службе безопасности какой ты стильный."
	icon = 'modular_bandastation/donor_jobs/icons/id_skins.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/info = "На ней наклейка."

/obj/item/donor_id_skin/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/card/id/advanced))
		return NONE
	var/obj/item/card/id/advanced/card = interacting_with
	if(card.GetComponent(/datum/component/sticker/donor_id_skin))
		balloon_alert(user, "сначала снимите наклейку")
		return ITEM_INTERACT_BLOCKING
	if(!do_after(user, 2 SECONDS, target = card))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(src) || QDELETED(card) || card.GetComponent(/datum/component/sticker/donor_id_skin) || !user.transferItemToLoc(src, card))
		return ITEM_INTERACT_BLOCKING
	card.AddComponent(/datum/component/sticker/donor_id_skin, src, NORTH, 16, 16, examine_text = "[info] Alt-click, чтобы снять наклейку.")
	return ITEM_INTERACT_SUCCESS

/datum/component/sticker/donor_id_skin
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/sticker/donor_id_skin/RegisterWithParent()
	..()
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_alt_click))

/datum/component/sticker/donor_id_skin/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	return ..()

/datum/component/sticker/donor_id_skin/Destroy(force)
	if(our_sticker)
		UnregisterSignal(our_sticker, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
		QDEL_NULL(our_sticker)
	return ..()

/datum/component/sticker/donor_id_skin/proc/on_alt_click(datum/source, mob/user)
	SIGNAL_HANDLER
	if(user.can_perform_action(parent, FORBID_TELEKINESIS_REACH))
		INVOKE_ASYNC(src, PROC_REF(remove_skin), user)
	return CLICK_ACTION_BLOCKING

/datum/component/sticker/donor_id_skin/proc/remove_skin(mob/living/user)
	var/obj/item/card/id/advanced/card = parent
	if(user.combat_mode)
		playsound(card, 'sound/items/poster/poster_ripped.ogg', 50, TRUE)
		qdel(src)
		return
	if(!do_after(user, 5 SECONDS, target = card) || QDELETED(src) || QDELETED(card))
		return
	var/obj/item/peeled_skin = our_sticker
	peel()
	user.put_in_hands(peeled_skin)

/obj/item/donor_id_skin/colored
	name = "голо-наклейка на карту"
	desc = "Голографическая наклейка на карту. Вы можете выбрать цвет который она примет."
	icon_state = "colored"
	info = "На ней голо-наклейка."
	var/static/list/skin_colours = list(
		"Красный" = "#FA8282",
		"Зелёный" = LIGHT_COLOR_GREEN,
		"Синий" = "#0099FF",
		"Жёлтый" = LIGHT_COLOR_HOLY_MAGIC,
		"Оранжевый" = LIGHT_COLOR_ORANGE,
		"Фиолетовый" = LIGHT_COLOR_LAVENDER,
		"Голубой" = LIGHT_COLOR_LIGHT_CYAN,
		"Циановый" = LIGHT_COLOR_CYAN,
		"Аквамариновый" = LIGHT_COLOR_BLUEGREEN,
		"Розовый" = LIGHT_COLOR_PINK,
	)

/obj/item/donor_id_skin/colored/Initialize(mapload)
	. = ..()
	if(!color)
		color = skin_colours[pick(skin_colours)]

/obj/item/donor_id_skin/colored/attack_self(mob/user)
	var/choice = tgui_input_list(user, "Какой цвет предпочитаете?", name, list("Предустановленный", "Вручную"))
	if(!choice || QDELETED(src) || !user.is_holding(src))
		return
	var/new_colour
	if(choice == "Предустановленный")
		var/preset = tgui_input_list(user, "Выберите цвет", name, skin_colours)
		new_colour = skin_colours[preset]
	else
		new_colour = tgui_color_picker(user, "Выберите цвет", name, color)
	if(new_colour && !QDELETED(src) && user.is_holding(src))
		color = sanitize_hexcolor(new_colour)

/obj/item/donor_id_skin/donut
	name = "\improper пончиковая наклейка на карту"
	icon_state = "donut"
	info = "На ней пончиковая наклейка. С глазурью!"

/obj/item/donor_id_skin/silver
	name = "\improper серебрянная наклейка на карту"
	icon_state = "silver"
	info = "На ней серебрянная наклейка."

/obj/item/donor_id_skin/colored/silver
	name = "\improper серебрянная голо-наклейка"
	desc = "Голографическая наклейка на карту, изготовленная из специального материала, похожего на серебро. Вы можете выбрать цвет который она примет."
	icon_state = "colored_shiny"
	info = "На ней металлическая голо-наклейка."

/obj/item/donor_id_skin/gold
	name = "\improper золотая наклейка на карту"
	desc = "Можно продать какому-то дураку за баснословные деньги. Ой..."
	icon_state = "gold"
	info = "На ней золотая наклейка."

/obj/item/donor_id_skin/business
	name = "\improper бизнесменская наклейка на карту"
	desc = "Осталось раздобыть портмоне и стильный костюм."
	icon_state = "business"
	info = "На ней бизнесменская наклейка."

/obj/item/donor_id_skin/lifetime
	name = "\improper стильная наклейка на карту"
	desc = "Ничего особенного, но что-то в этом есть..."
	icon_state = "lifetime"
	info = "На ней стильная наклейка."

/obj/item/donor_id_skin/ussp
	name = "\improper коммунистическая наклейка на карту"
	desc = "Партия гордится вами! Возьмите своя миска-рис в ближайшем баре."
	icon_state = "ussp"
	info = "На ней коммунистическая наклейка."

/obj/item/donor_id_skin/clown
	name = "\improper клоунская наклейка на карту"
	desc = "HONK!"
	icon_state = "clown"
	info = "На ней клоунская наклейка. HONK!"

/obj/item/donor_id_skin/neon
	name = "\improper неоновая наклейка на карту"
	desc = "Неоновая наклейка в цианово-розовых цветах."
	icon_state = "neon"
	info = "Кажется будто она светится."

/obj/item/donor_id_skin/colored/neon
	name = "\improper неоновая голо-наклейка на карту"
	desc = "Какая же она яркая... Ещё и цвета меняет!"
	icon_state = "colored_neon"
	info = "Кажется будто она светится."

/obj/item/donor_id_skin/missing
	name = "\improper чёрно-розовая наклейка на карту"
	desc = "Текстура пропала..."
	icon_state = "missing"
	info = "А где?"

/obj/item/donor_id_skin/ouija
	name = "\improper Уиджи наклейка на карту"
	desc = "Ходят легенты, что тот кто наклеит это на карту, может общаться с духами..."
	icon_state = "ouija"
	info = "Умеет ли он общаться с призраками?"

/obj/item/donor_id_skin/paradise
	name = "\improper пляжная наклейка на карту"
	desc = "Хола!"
	icon_state = "paradise"
	info = "На ней пляжная наклейка."

/obj/item/donor_id_skin/rainbow
	name = "\improper радужная наклейка на карту"
	desc = "Переливается всеми цветами радуги!"
	icon_state = "rainbow"
	info = "На ней радужная наклейка. Одобряемо."

/obj/item/donor_id_skin/space
	name = "\improper КОСМИЧЕСКАЯ наклейка на карту"
	desc = "Яркая, блестящая и бескрайняя. Прямо как хозяин карты на которую её приклеят."
	icon_state = "space"
	info = "Есть 3 вещи на которые можно смотреть вечно. Это четвёртая."

/obj/item/donor_id_skin/kitty
	name = "\improper кото-клейка на карту"
	desc = "Прекрасная наклейка, которая делает вашу карту похожей на котика. UwU."
	icon_state = "kitty"
	info = "Так и хочется погладить, жаль это всего-лишь наклейка..."

/obj/item/donor_id_skin/colored/kitty
	name = "\improper голо-кото-клейка на карту"
	desc = "Прекрасная наклейка, которая делает вашу карту похожей на котика. Эта может менять цвет."
	icon_state = "colored_kitty"

/obj/item/donor_id_skin/cursedmiku
	name = "\improper аниме наклейка на карту"
	desc = "Kawaii!!!"
	icon_state = "cursedmiku"
	info = "На ней анимешная наклейка. AYAYA!"

/obj/item/donor_id_skin/colored/snake
	name = "\improper бегущая наклейка на карту"
	desc = "Она что-то загружает?"
	icon_state = "snake"
	info = "Бегает и бегает..."

/obj/item/donor_id_skin/magic
	name = "\improper магическая наклейка на карту"
	desc = "EI NATH!"
	icon_state = "magic"
	info = "Кто-то до сих пор девственник..."

/obj/item/donor_id_skin/terminal
	name = "\improper наклейка на карту в виде терминала"
	desc = "HACKERMAN."
	icon_state = "terminal"
	info = "Эта карта похожа на терминал."

/obj/item/donor_id_skin/jokerge
	name = "\improper джокерге наклейка на карту"
	desc = "Jokerge."
	icon_state = "jokerge"
	info = "Jokerge."

/obj/item/donor_id_skin/boykisser
	name = "\improper бойкиссерская наклейка на карту"
	desc = "Наклеив её на карту, у вас с почти 100% вероятностью, появится желание целовать мальчиков."
	icon_state = "boykisser"
	info = "Он любит целовать мальчиков."

/obj/item/donor_id_skin/decal
	name = "identification card decal"
	desc = "A nano-cellophane wrap that molds to an ID card to make it look snazzy."
	icon = 'modular_bandastation/donor_jobs/icons/id_cards.dmi'
	icon_state = "id"

/obj/item/donor_id_skin/decal/gold
	name = "gold ID card decal"
	desc = "Make your ID look like the Captain's or a self-centered HOP's. Applies to any ID."
	icon_state = "gold"
	info = "A golden card which shows power and might."

/obj/item/donor_id_skin/decal/silver
	name = "silver ID card decal"
	desc = "Make your ID look like HOP's because they wouldn't change it officially. Applies to any ID."
	icon_state = "silver"
	info = "A silver card which shows honour and dedication."

/obj/item/donor_id_skin/decal/prisoner
	name = "prisoner ID card decal"
	desc = "All the cool kids have an ID that's this color. Applies to any ID."
	icon_state = "prisoner"
	info = "You are a number, you are not a free man."

/obj/item/donor_id_skin/decal/centcom
	name = "centcom ID card decal"
	desc = "All the prestige without the responsibility or the access. Applies to any ID."
	icon_state = "centcom"
	info = "An ID straight from Cent. Com."

/obj/item/donor_id_skin/decal/emag
	name = "cryptographic sequencer ID card decal"
	desc = "A bundle of wires that you can tape to your ID to look very suspect. Applies to any ID."
	icon_state = "emag"
	info = "It's a card with a magnetic strip attached to some circuitry."
