// Inherit native access and canonical job identity; only the HUD glyph differs.
/datum/id_trim/job/prisoner
	sechud_icon = 'modular_bandastation/donor_jobs/icons/job_hud.dmi'
	sechud_icon_state = "hudprisoner"

/datum/id_trim/job/cargo_technician/donor_deliverer
	sechud_icon = 'modular_bandastation/donor_jobs/icons/job_hud.dmi'
	sechud_icon_state = "huddeliverer"
	template_access = null

/datum/id_trim/job/donor_actor/painter
	sechud_icon_state = "hudpainter"
	centcom_template = FALSE

/datum/id_trim/job/donor_cleaning_manager/apprentice
	sechud_icon_state = "hudapprentice"
	centcom_template = FALSE

/datum/id_trim/job/donor_adjutant/butler
	sechud_icon_state = "hudbutler"
	centcom_template = FALSE

/datum/id_trim/job/donor_adjutant/maid
	sechud_icon_state = "hudmaid"
	centcom_template = FALSE
