#define DONOR_ROLE_RP_NOTICE "Ваша должность нацелена на свободный РП-отыгрыш и не разрешает нарушать правила сервера."

/datum/job
	var/important_information

/datum/job/donor
	var/list/variant_information

/datum/job/donor/get_spawn_message_information(mob/spawned)
	. = ..()
	var/information = important_information
	if(ishuman(spawned) && length(variant_information))
		var/mob/living/carbon/human/human = spawned
		var/datum/job_variant/variant = resolve_donor_variant(human.donor_spawn_context?.variant_id)
		if(variant_information[variant?.outfit_type])
			information = variant_information[variant.outfit_type]
	if(information)
		. += DONOR_ROLE_RP_NOTICE
		. += information

/datum/job/prisoner/get_spawn_message_information(mob/spawned)
	. = ..()
	if(!CONFIG_GET(flag/donor_prisoner_gate))
		return
	. += DONOR_ROLE_RP_NOTICE
	. += important_information

/datum/job/cargo_technician/get_spawn_message_information(mob/spawned)
	. = ..()
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/human = spawned
	var/datum/job_variant/variant = resolve_donor_variant(human.donor_spawn_context?.variant_id)
	if(ispath(variant?.outfit_type, /datum/outfit/job/cargo_tech/donor_deliverer))
		. += DONOR_ROLE_RP_NOTICE
		. += important_information

#undef DONOR_ROLE_RP_NOTICE
