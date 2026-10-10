/datum/unit_test
	var/list/job_fixture_species_before

// Saved-profile scenarios need these species even when CI allows only humans.
/datum/unit_test/proc/allow_job_fixture_species(list/species_types)
	var/datum/preference/choiced/species/preference = GLOB.preference_entries[/datum/preference/choiced/species]
	job_fixture_species_before ||= preference.get_choices()
	preference.cached_values = preference.get_choices() | species_types

// Mock clients and lobby mobs retain these references after their native Destroy().
/datum/unit_test/proc/release_job_player_fixtures()
	if(job_fixture_species_before)
		var/datum/preference/choiced/species/preference = GLOB.preference_entries[/datum/preference/choiced/species]
		preference.cached_values = job_fixture_species_before
		job_fixture_species_before = null
	for(var/datum/client_interface/player in allocated)
		player.prefs = null
		player.mob = null
	for(var/datum/preferences/preferences in allocated)
		preferences.parent = null
		preferences.savefile = null
	for(var/datum/mind/mind in allocated)
		mind.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
		mind.set_current(null)
	for(var/mob/mob in allocated)
		mob.key = null
		mob.mock_client = null
		mob.mind = null
