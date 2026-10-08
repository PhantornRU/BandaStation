/obj/item/food/doshik
	name = "дошик"
	desc = "Вкусная сухая лапша быстрого приготовления с курицей. Её можно приготовить, залив водой."
	icon = 'modular_bandastation/donor_jobs/icons/food.dmi'
	icon_state = "doshik"
	bite_consumption = 3
	trash_type = /obj/item/trash/donor_doshik
	food_reagents = list(/datum/reagent/consumable/dry_ramen = 30)
	tastes = list("курица" = 1, "лапша" = 1)
	foodtypes = GRAIN | JUNKFOOD

/obj/item/food/doshik_spicy
	parent_type = /obj/item/food/doshik
	name = "острый дошик"
	desc = "Вкусная сухая лапша быстрого приготовления с говядиной. Её можно приготовить, залив водой."
	icon_state = "doshikspicy"
	food_reagents = list(/datum/reagent/consumable/dry_ramen = 30, /datum/reagent/consumable/capsaicin = 5)
	tastes = list("говядина" = 1, "лапша" = 1)

/obj/item/trash/donor_doshik
	name = "упаковка из-под дошика"
	desc = "Вы уже съели дошик."
	icon = 'modular_bandastation/donor_jobs/icons/food.dmi'
	icon_state = "doshik-empty"

/obj/item/reagent_containers/cup/donor_banana_jug
	name = "Jolly Jug"
	desc = "A jug filled with banana juice."
	icon = 'modular_bandastation/donor_jobs/icons/drinks.dmi'
	icon_state = "bottleofjolly"
	inhand_icon_state = "bottleofjolly"
	volume = 100
	list_reagents = list(/datum/reagent/consumable/banana = 100)

/obj/item/stack/cable_coil/random

/obj/item/stack/cable_coil/random/Initialize(mapload, new_amount, merge = TRUE, list/mat_override = null, mat_amt = 1)
	. = ..()
	set_cable_color(pick(GLOB.cable_colors))

/obj/item/food/donor_toast
	name = "toast"
	desc = "Yeah! Toast!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "toast"
	bite_consumption = 3
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("toast" = 1)
	foodtypes = GRAIN
