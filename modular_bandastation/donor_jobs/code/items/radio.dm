/obj/item/encryptionkey/donor_service_command
	channels = list(RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_JUSTICE = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/donor_service_security
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/donor_service_cargo
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_SUPPLY = 1)

/obj/item/radio/headset/donor_service_command
	parent_type = /obj/item/radio/headset/headset_sec/alt
	name = "adjutant's bowman headset"
	keyslot = /obj/item/encryptionkey/donor_service_command

/obj/item/radio/headset/donor_service_security
	name = "security clown headset"
	keyslot = /obj/item/encryptionkey/donor_service_security

/obj/item/radio/headset/donor_service_cargo
	name = "courier headset"
	keyslot = /obj/item/encryptionkey/donor_service_cargo
