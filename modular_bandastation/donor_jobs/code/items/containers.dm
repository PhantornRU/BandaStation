/obj/item/storage/box/survival/engineer/donor/PopulateContents()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		internal_type = /obj/item/tank/internals/emergency_oxygen/double
	. = ..()
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/flashlight/donor_emergency_glowstick(src)

/obj/item/storage/box/survival/engineer/donor/mining
	mask_type = /obj/item/clothing/mask/gas/explorer/folded

/obj/item/storage/bag/garment/chaplain
	name = "chaplain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chaplain."

/obj/item/storage/toolbox/mechanical/donor_preview/PopulateContents()
	return

/obj/item/storage/bag/garment/chaplain/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/chaplain(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/suit/hooded/abaya(src)
	new /obj/item/clothing/suit/hooded/nun(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/donor(src)
	new /obj/item/clothing/suit/hooded/monk(src)
	new /obj/item/clothing/suit/donor/witchhunter(src)
	new /obj/item/clothing/head/donor/witchhunter(src)
	new /obj/item/clothing/suit/donor/holidaypriest(src)
	new /obj/item/clothing/under/donor/wedding(src)
	new /obj/item/clothing/head/helmet/chaplain/donor_templar(src)
	new /obj/item/clothing/suit/chaplainsuit/armor/templar/donor(src)
	new /obj/item/clothing/suit/toggle/labcoat(src)
	for(var/i in 1 to 2)
		new /obj/item/clothing/accessory/gloves_accessory/ring/silver(src)
		new /obj/item/clothing/accessory/gloves_accessory/ring(src)
