/obj/item/organ/cyberimp/brain/donor_clown_voice
	name = "comical implant"
	desc = "Uh oh."
	icon_state = "brain_implant"
	slot = "brain_clownvoice"

/obj/item/organ/cyberimp/brain/donor_clown_voice/on_mob_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignal(receiver, COMSIG_MOB_SAY, PROC_REF(comical_speech))

/obj/item/organ/cyberimp/brain/donor_clown_voice/on_mob_remove(mob/living/carbon/implant_owner)
	UnregisterSignal(implant_owner, COMSIG_MOB_SAY)
	return ..()

/obj/item/organ/cyberimp/brain/donor_clown_voice/proc/comical_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_SANS
