/mob/dead/new_player/Logout()
	ready = PLAYER_NOT_READY
	..()
	if(!spawning)//Here so that if they are spawning and log out, the other procs can play out and they will have a mob to come back to.
		// BANDASTATION EDIT - Release an assigned roundstart vacancy on disconnect.
		if(assigned_character && mind?.assigned_role)
			SSjob.free_job_position(mind.assigned_role.title)
		key = null//We null their key before deleting the mob, so they are properly kicked out.
		QDEL_NULL(mind) //Clean out mind, yes this fucking sucks
		qdel(src)
	return
