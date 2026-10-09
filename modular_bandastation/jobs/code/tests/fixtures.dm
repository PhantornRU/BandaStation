// Mock clients and lobby mobs retain these references after their native Destroy().
/datum/unit_test/proc/release_job_player_fixtures()
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
