/obj/item/toy/figure/donor
	icon = 'modular_bandastation/donor_jobs/icons/toys.dmi'
	icon_state = "nuketoy"
	w_class = WEIGHT_CLASS_TINY
	desc = "A Space Life brand... wait, what the hell is this thing?"

/obj/item/toy/figure/donor/Initialize(mapload)
	. = ..()
	desc = initial(desc)

/obj/item/toy/figure/donor/attack_self(mob/user)
	if(cooldown > world.time)
		return
	cooldown = world.time + 3 SECONDS
	to_chat(user, span_notice("[src] says: [toysay]"))
	playsound(user, toysound, 20, TRUE)

/obj/item/toy/figure/donor/crew
	icon_state = "assistant"
	toysay = "What the fuck did you do?"

/obj/item/toy/figure/donor/crew/cmo
	name = "\improper Chief Medical Officer action figure"
	desc = "The ever-suffering CMO, from Space Life's SS12 figurine collection."
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/donor/crew/assistant
	name = "\improper Assistant action figure"
	desc = "The faceless, hairless scourge of the station, from Space Life's SS12 figurine collection."
	icon_state = "assistant"
	toysay = "Grey tide station wide!"

/obj/item/toy/figure/donor/crew/atmos
	name = "\improper Atmospheric Technician action figure"
	desc = "The faithful atmospheric technician, from Space Life's SS12 figurine collection."
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/donor/crew/bartender
	name = "\improper Bartender action figure"
	desc = "The suave bartender, from Space Life's SS12 figurine collection."
	icon_state = "bartender"
	toysay = "Wheres my monkey?"

/obj/item/toy/figure/donor/crew/borg
	name = "\improper Cyborg action figure"
	desc = "The iron-willed cyborg, from Space Life's SS12 figurine collection."
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."

/obj/item/toy/figure/donor/crew/botanist
	name = "\improper Botanist action figure"
	desc = "The drug-addicted botanist, from Space Life's SS12 figurine collection."
	icon_state = "botanist"
	toysay = "Dude, I see colors..."

/obj/item/toy/figure/donor/crew/captain
	name = "\improper Captain action figure"
	desc = "The inept captain, from Space Life's SS12 figurine collection."
	icon_state = "captain"
	toysay = "Crew, the Nuke Disk is safely up my ass."

/obj/item/toy/figure/donor/crew/cargotech
	name = "\improper Cargo Technician action figure"
	desc = "The hard-working cargo tech, from Space Life's SS12 figurine collection."
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/donor/crew/ce
	name = "\improper Chief Engineer action figure"
	desc = "The expert Chief Engineer, from Space Life's SS12 figurine collection."
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/donor/crew/chaplain
	name = "\improper Chaplain action figure"
	desc = "The obsessed Chaplain, from Space Life's SS12 figurine collection."
	icon_state = "chaplain"
	toysay = "Gods make me a killing machine please!"

/obj/item/toy/figure/donor/crew/chef
	name = "\improper Chef action figure"
	desc = "The cannibalistic chef, from Space Life's SS12 figurine collection."
	icon_state = "chef"
	toysay = "I swear it's not human meat."

/obj/item/toy/figure/donor/crew/chemist
	name = "\improper Chemist action figure"
	desc = "The legally dubious Chemist, from Space Life's SS12 figurine collection."
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/donor/crew/clown
	name = "\improper Clown action figure"
	desc = "The mischievous Clown, from Space Life's SS12 figurine collection."
	icon_state = "clown"
	toysay = "Honk!"

/obj/item/toy/figure/donor/crew/ian
	name = "\improper Ian action figure"
	desc = "The adorable corgi, from Space Life's SS12 figurine collection."
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/donor/crew/detective
	name = "\improper Detective action figure"
	desc = "The clever detective, from Space Life's SS12 figurine collection."
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/donor/crew/dsquad
	name = "\improper Death Squad Officer action figure"
	desc = "It's a member of the DeathSquad, a TV drama where loose-cannon ERT officers face up against the threats of the galaxy! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "dsquad"
	toysay = "Eliminate all threats!"

/obj/item/toy/figure/donor/crew/engineer
	name = "\improper Engineer action figure"
	desc = "The frantic engineer, from Space Life's SS12 figurine collection."
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/donor/crew/geneticist
	name = "\improper Geneticist action figure"
	desc = "The balding geneticist, from Space Life's SS12 figurine collection."
	icon_state = "geneticist"
	toysay = "I'm not qualified for this job."

/obj/item/toy/figure/donor/crew/hop
	name = "\improper Head of Personnel action figure"
	desc = "The officious Head of Personnel, from Space Life's SS12 figurine collection."
	icon_state = "hop"
	toysay = "Papers, please!"

/obj/item/toy/figure/donor/crew/hos
	name = "\improper Head of Security action figure"
	desc = "The bloodlust-filled Head of Security, from Space Life's SS12 figurine collection."
	icon_state = "hos"
	toysay = "Space law? What?"

/obj/item/toy/figure/donor/crew/qm
	name = "\improper Quartermaster action figure"
	desc = "The nationalistic Quartermaster, from Space Life's SS12 figurine collection."
	icon_state = "qm"
	toysay = "Hail Cargonia!"

/obj/item/toy/figure/donor/crew/janitor
	name = "\improper Janitor action figure"
	desc = "The water-using Janitor, from Space Life's SS12 figurine collection."
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/donor/crew/lawyer
	name = "\improper Internal Affairs Agent action figure"
	desc = "The unappreciated Internal Affairs Agent, from Space Life's SS12 figurine collection."
	icon_state = "lawyer"
	toysay = "Standard Operating Procedure says they're guilty! Hacking is proof they're an Enemy of the Corporation!"

/obj/item/toy/figure/donor/crew/librarian
	name = "\improper Librarian action figure"
	desc = "The quiet Librarian, from Space Life's SS12 figurine collection."
	icon_state = "librarian"
	toysay = "One day while..."

/obj/item/toy/figure/donor/crew/md
	name = "\improper Medical Doctor action figure"
	desc = "The stressed-out doctor, from Space Life's SS12 figurine collection."
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/donor/crew/mime
	name = "\improper Mime action figure"
	desc = "... from Space Life's SS12 figurine collection."
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/donor/crew/miner
	name = "\improper Shaft Miner action figure"
	desc = "The gun-toting Shaft Miner, from Space Life's SS12 figurine collection."
	icon_state = "miner"
	toysay = "Oh god it's eating my intestines!"

/obj/item/toy/figure/donor/crew/ninja
	name = "\improper Ninja action figure"
	desc = "It's the mysterious ninja! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/donor/crew/wizard
	name = "\improper Wizard action figure"
	desc = "It's the deadly, spell-slinging wizard! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/donor/crew/rd
	name = "\improper Research Director action figure"
	desc = "The ambitious RD, from Space Life's SS12 figurine collection."
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/donor/crew/roboticist
	name = "\improper Roboticist action figure"
	desc = "The skillful Roboticist, from Space Life's SS12 figurine collection."
	icon_state = "roboticist"
	toysay = "He asked to be borged!"

/obj/item/toy/figure/donor/crew/scientist
	name = "\improper Scientist action figure"
	desc = "The mad Scientist, from Space Life's SS12 figurine collection."
	icon_state = "scientist"
	toysay = "Someone else must have made those bombs!"

/obj/item/toy/figure/donor/crew/syndie
	name = "\improper Nuclear Operative action figure"
	desc = "It's the red-suited Nuclear Operative! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/donor/crew/secofficer
	name = "\improper Security Officer action figure"
	desc = "The power-tripping Security Officer, from Space Life's SS12 figurine collection."
	icon_state = "secofficer"
	toysay = "I am the law!"

/obj/item/toy/figure/donor/crew/virologist
	name = "\improper Virologist action figure"
	desc = "The pandemic-starting Virologist, from Space Life's SS12 figurine collection."
	icon_state = "virologist"
	toysay = "It's not my virus!"

/obj/item/toy/figure/donor/crew/warden
	name = "\improper Warden action figure"
	desc = "The amnesiac Warden, from Space Life's SS12 figurine collection."
	icon_state = "warden"
	toysay = "Execute him for breaking in!"

/obj/item/toy/figure/donor/mech
	icon_state = "ripleytoy"

/obj/item/toy/figure/donor/mech/attack_self(mob/user)
	if(cooldown > world.time)
		return
	cooldown = world.time + 0.8 SECONDS
	to_chat(user, span_notice("You play with [src]."))
	playsound(user, 'modular_bandastation/donor_jobs/sound/sound_mecha_mechstep.ogg', 20, TRUE)

/obj/item/toy/figure/donor/mech/ripley
	name = "toy Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11. This one is a ripley, a mining and engineering mecha."

/obj/item/toy/figure/donor/mech/fireripley
	name = "toy Firefighting Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11. This one is a firefighter ripley, a fireproof mining and engineering mecha."
	icon_state = "fireripleytoy"

/obj/item/toy/figure/donor/mech/deathripley
	name = "toy Deathsquad Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11. This one is the black ripley used by the hero of Deathsquad, that TV drama about loose-cannon ERT officers!"
	icon_state = "deathripleytoy"

/obj/item/toy/figure/donor/mech/gygax
	name = "toy Gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11. This one is the speedy gygax combat mecha. Zoom zoom, pew pew!"
	icon_state = "gygaxtoy"

/obj/item/toy/figure/donor/mech/durand
	name = "toy Durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11. This one is the heavy durand combat mecha. Stomp stomp!"
	icon_state = "durandprize"

/obj/item/toy/figure/donor/mech/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11. This one is the infamous H.O.N.K mech!"
	icon_state = "honkprize"

/obj/item/toy/figure/donor/mech/marauder
	name = "toy Marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11. This one is the powerful marauder combat mecha! Run for cover!"
	icon_state = "marauderprize"

/obj/item/toy/figure/donor/mech/seraph
	name = "toy Seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11. This one is the powerful seraph combat mecha! Someone's in trouble!"
	icon_state = "seraphprize"

/obj/item/toy/figure/donor/mech/mauler
	name = "toy Mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11. This one is the deadly mauler combat mecha! Look out!"
	icon_state = "maulerprize"

/obj/item/toy/figure/donor/mech/odysseus
	name = "toy Odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11. This one is the spindly, syringe-firing odysseus medical mecha."
	icon_state = "odysseusprize"

/obj/item/toy/figure/donor/mech/phazon
	name = "toy Phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11. This one is the mysterious Phazon combat mecha! Nobody's safe!"
	icon_state = "phazonprize"
