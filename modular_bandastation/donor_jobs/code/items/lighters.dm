/obj/item/lighter/donor_zippo
	name = "zippo lighter"
	desc = "The zippo."
	icon = 'modular_bandastation/donor_jobs/icons/lighters.dmi'
	icon_state = "zippo"
	heat_while_on = 700
	tool_behaviour = NONE
	spawns_with_reagent = FALSE

/obj/item/lighter/donor_zippo/create_lighter_overlay()
	return null

// Original Zippos burn indefinitely; they do not provide extractable welding fuel.
/obj/item/lighter/donor_zippo/get_fuel()
	return maximum_fuel

/obj/item/lighter/donor_zippo/use(used = 0)
	return lit

/obj/item/lighter/donor_zippo/process(seconds_per_tick)
	if(lit)
		var/turf/location = get_turf(src)
		location?.hotspot_expose(700, 5)

/obj/item/lighter/donor_zippo/nt_rep
	name = "gold engraved zippo"
	desc = "An engraved golden Zippo lighter with the letters NT on it."
	icon_state = "zippo-nt"
	inhand_icon_state = "zippo-gold"

/obj/item/lighter/donor_zippo/blue
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon_state = "zippo-blue"
	inhand_icon_state = "zippo-blue"

/obj/item/lighter/donor_zippo/black
	name = "black zippo lighter"
	desc = "A black zippo lighter."
	icon_state = "zippo-black"
	inhand_icon_state = "zippo-black"

/obj/item/lighter/donor_zippo/engraved
	name = "engraved zippo lighter"
	desc = "A intricately engraved zippo lighter."
	icon_state = "zippo-engraved"

/obj/item/lighter/donor_zippo/gonzofist
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon_state = "zippo-gonzo"
	inhand_icon_state = "zippo-red"

/obj/item/lighter/donor_zippo/contractor
	name = "contractor zippo lighter"
	desc = "An unique black and gold zippo commonly carried by elite Syndicate agents."
	icon_state = "zippo-contractor"
	inhand_icon_state = "zippo-black"

/obj/item/lighter/donor_zippo/fluff
	name = "custom zippo"
	desc = "A custom made zippo lighter."
	icon = 'modular_bandastation/donor_jobs/icons/icons_obj_custom_items.dmi'

/obj/item/lighter/donor_zippo/fluff/purple
	name = "purple engraved zippo"
	desc = "All craftsspacemanship is of the highest quality. It is encrusted with refined plasma sheets. On the item is an image of a dwarf and the words 'Strike the Earth!' etched onto the side."
	icon_state = "zippo-purple"
	inhand_icon_state = "zippo-purple"

/obj/item/lighter/donor_zippo/fluff/michael_guess_1
	name = "engraved lighter"
	desc = "A golden lighter, engraved with some ornaments and a G."
	icon_state = "zippo-guess"
	inhand_icon_state = "zippo-gold"

/obj/item/lighter/donor_zippo/fluff/duckchan
	name = "Monogrammed Zippo"
	desc = " A shiny purple zippo lighter, engraved with Rybys Romney and BuzzPing's name, with a festive green flame."
	icon_state = "zippo-duckchan"
	inhand_icon_state = "zippo-purple"

/obj/item/lighter/donor_zippo/fluff/warriorstar
	name = "zippo"
	desc = "The lighter is made of a pastel purple metal which seems to glimmer even in complete darkness."
	icon_state = "zippo-warriorstar"
	inhand_icon_state = "zippo-purple"

/obj/item/lighter/donor_zippo/cap
	name = "\improper Captain's zippo"
	desc = "A limited edition gold Zippo espesially for NT Captains. Looks extremely expensive."
	icon_state = "zippo-cap"
	inhand_icon_state = "zippo-cap"
	icon = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_zippo.dmi'
	lefthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_righthand.dmi'

/obj/item/lighter/donor_zippo/hop
	name = "\improper Head of Personnel's zippo"
	desc = "A limited edition Zippo for NT Heads. Tries it best to look like captain's."
	icon_state = "zippo-hop"
	inhand_icon_state = "zippo-hop"
	icon = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_zippo.dmi'
	lefthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_righthand.dmi'

/obj/item/lighter/donor_zippo/hos
	name = "\improper Head of Security's zippo"
	desc = "A limited edition Zippo for NT Heads. Fuel it with clown's tears."
	icon_state = "zippo-hos"
	inhand_icon_state = "zippo-hos"
	icon = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_zippo.dmi'
	lefthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_righthand.dmi'

/obj/item/lighter/donor_zippo/cmo
	name = "\improper Chief Medical Officer's zippo"
	desc = "A limited edition Zippo for NT Heads. Made of hypoallergenic steel."
	icon_state = "zippo-cmo"
	inhand_icon_state = "zippo-cmo"
	icon = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_zippo.dmi'
	lefthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_righthand.dmi'

/obj/item/lighter/donor_zippo/ce
	name = "\improper Chief Engineer's zippo"
	desc = "A limited edition Zippo for NT Heads. Somebody've tried to repair cover with blue tape."
	icon_state = "zippo-ce"
	inhand_icon_state = "zippo-ce"
	icon = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_zippo.dmi'
	lefthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_righthand.dmi'

/obj/item/lighter/donor_zippo/rd
	name = "\improper Research Director's zippo"
	desc = "A limited edition Zippo for NT Heads. Uses advanced tech to make fire from plasma."
	icon_state = "zippo-rd"
	inhand_icon_state = "zippo-rd"
	icon = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_zippo.dmi'
	lefthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_lefthand.dmi'
	righthand_file = 'modular_bandastation/donor_jobs/icons/modular_ss220_aesthetics_zippo_icons_items_righthand.dmi'
