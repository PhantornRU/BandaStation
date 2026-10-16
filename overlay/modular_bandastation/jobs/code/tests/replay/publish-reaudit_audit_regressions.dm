// External overlay only; product sources and the native controllers remain unchanged by these fixtures.

/obj/item/card/id/publish_audit_template_card
	var/list/template_operations = list()
	var/template_access_mode
	var/template_wildcard_mode
	var/template_reta_department
	var/template_reta_duration

/obj/item/card/id/publish_audit_template_card/clear_access()
	template_operations += "clear"
	return ..()

/obj/item/card/id/publish_audit_template_card/add_access(list/add_accesses, try_wildcard = null, mode = ERROR_ON_FAIL)
	template_operations += "access"
	template_access_mode = mode
	return ..()

/obj/item/card/id/publish_audit_template_card/add_wildcards(list/wildcard_list, try_wildcard = null, mode = ERROR_ON_FAIL)
	template_operations += "wildcards"
	template_wildcard_mode = mode
	return ..()

// Observe the real active-grant dispatcher without creating a timer or changing unrelated RETA state.
/obj/item/card/id/publish_audit_template_card/grant_reta_access(dept, duration_ds)
	template_operations += "reta"
	template_reta_department = dept
	template_reta_duration = duration_ds
	return TRUE

/datum/unit_test/publish_audit_id_template_boundary
	var/list/grants_before
	var/list/reta_trims_before
	var/trim_entry_before
	var/trim_entry_existed = FALSE
	var/trim_key = "external-publish-audit-template"
	var/obj/item/card/id/publish_audit_template_card/card
	var/datum/bank_account/card_account

/datum/unit_test/publish_audit_id_template_boundary/Run()
	grants_before = GLOB.reta_active_grants
	reta_trims_before = GLOB.reta_job_trims
	trim_entry_existed = trim_key in SSid_access.trim_singletons_by_path
	trim_entry_before = SSid_access.trim_singletons_by_path[trim_key]
	GLOB.reta_active_grants = list("External target" = list("External origin" = world.time + 1 MINUTES))
	GLOB.reta_job_trims = list("External target" = list(/datum/id_trim))
	var/datum/id_trim/job/job_trim = allocate(/datum/id_trim/job)
	job_trim.job = SSjob.get_job_type(/datum/job/assistant)
	job_trim.access = list(ACCESS_BAR)
	job_trim.wildcard_access = list(ACCESS_MEDICAL)
	var/datum/id_trim/plain_trim = allocate(/datum/id_trim)
	plain_trim.access = list(ACCESS_BAR)
	plain_trim.wildcard_access = list(ACCESS_MEDICAL)
	var/datum/id_trim/visual_trim = allocate(/datum/id_trim)
	visual_trim.access = list(ACCESS_BAR)
	card = allocate(/obj/item/card/id/publish_audit_template_card)
	card_account = card.registered_account
	TEST_ASSERT_NOTNULL(card_account, "Native ID initialization did not create its replaceable account")
	card.trim = visual_trim
	card.assignment = "Original public assignment"
	for(var/scenario in list("unregistered-job", "registered-job", "non-job"))
		card.clear_account()
		if(scenario == "registered-job")
			card.set_account(card_account)
		card_account.account_job = SSjob.get_job_type(/datum/job/captain)
		SSid_access.trim_singletons_by_path[trim_key] = scenario == "non-job" ? plain_trim : job_trim
		card.access = list(ACCESS_BRIG)
		card.wildcard_slots = list(WILDCARD_NAME_ALL = list("limit" = 1, "usage" = list(ACCESS_BRIG)))
		card.template_operations = list()
		card.template_reta_department = null
		TEST_ASSERT(isnull(SSid_access.add_trim_access_to_card(card, trim_key)), "[scenario] changed the native void return")
		TEST_ASSERT_EQUAL(jointext(card.template_operations, ","), "clear,access,wildcards,reta", "[scenario] changed the operation order or repeated an effect")
		TEST_ASSERT_EQUAL(card.template_access_mode, TRY_ADD_ALL_NO_WILDCARD, "[scenario] changed ordinary access allocation")
		TEST_ASSERT_EQUAL(card.template_wildcard_mode, TRY_ADD_ALL, "[scenario] changed wildcard allocation")
		TEST_ASSERT(!(ACCESS_BRIG in card.access), "[scenario] retained access from the previous template")
		TEST_ASSERT(ACCESS_BAR in card.access, "[scenario] lost ordinary template access")
		TEST_ASSERT(ACCESS_MEDICAL in card.access, "[scenario] lost template wildcard access")
		var/list/wildcard_slot = card.wildcard_slots[WILDCARD_NAME_ALL]
		var/list/wildcard_usage = wildcard_slot["usage"]
		TEST_ASSERT_EQUAL(length(wildcard_usage), 1, "[scenario] did not clear prior wildcard usage")
		TEST_ASSERT(ACCESS_MEDICAL in wildcard_usage, "[scenario] did not allocate the template wildcard")
		TEST_ASSERT_EQUAL(card.trim, visual_trim, "[scenario] replaced the card's visual trim")
		TEST_ASSERT_EQUAL(card.assignment, "Original public assignment", "[scenario] replaced the public assignment")
		TEST_ASSERT_EQUAL(card.template_reta_department, "External origin", "[scenario] skipped the real active RETA grant dispatcher")
		TEST_ASSERT(card.template_reta_duration > 0 && card.template_reta_duration <= 1 MINUTES, "[scenario] changed the active RETA grant duration")
		if(scenario == "registered-job")
			TEST_ASSERT_EQUAL(card.registered_account, card_account, "The ordinary parent replaced its bank account")
			TEST_ASSERT_EQUAL(card_account.account_job, job_trim.job, "The ordinary parent did not update the paycheck job")
		else
			TEST_ASSERT_NULL(card.registered_account, "[scenario] created an account to bypass native bookkeeping")
			TEST_ASSERT_EQUAL(card_account.account_job, SSjob.get_job_type(/datum/job/captain), "[scenario] changed an unrelated bank account")

/datum/unit_test/publish_audit_id_template_boundary/Destroy()
	GLOB.reta_active_grants = grants_before
	GLOB.reta_job_trims = reta_trims_before
	if(trim_entry_existed)
		SSid_access.trim_singletons_by_path[trim_key] = trim_entry_before
	else
		SSid_access.trim_singletons_by_path -= trim_key
	card?.clear_account()
	QDEL_NULL(card_account)
	return ..()

/datum/job/publish_audit_greeting
	title = "External publish greeting fixture"
	job_flags = NONE
	var/greeting_reads = 0
	var/mob/greeted_body

/datum/job/publish_audit_greeting/config_check()
	return FALSE

/datum/job/publish_audit_greeting/get_spawn_message_information(mob/spawned)
	. = ..()
	greeting_reads++
	greeted_body = spawned
	. += "Committed body: [spawned?.real_name]"

/datum/unit_test/publish_audit_committed_body_greeting
	var/datum/mind/character_mind
	var/datum/job/publish_audit_greeting/greeting_job
	var/datum/job/fallback_job
	var/target_signals = 0
	var/fallback_signals = 0
	var/change_role_on_signal = FALSE
	var/mob/living/carbon/human/body

/datum/unit_test/publish_audit_committed_body_greeting/proc/observe_role(datum/source, datum/job/new_role)
	SIGNAL_HANDLER
	if(new_role == greeting_job)
		target_signals++
		if(change_role_on_signal)
			character_mind.set_assigned_role(fallback_job)
	else if(new_role == fallback_job)
		fallback_signals++

/datum/unit_test/publish_audit_committed_body_greeting/Run()
	body = allocate(/mob/living/carbon/human/consistent)
	body.real_name = "Committed Greeting Body"
	character_mind = allocate(/datum/mind)
	character_mind.set_current(body)
	fallback_job = SSjob.get_job_type(/datum/job/assistant)
	greeting_job = allocate(/datum/job/publish_audit_greeting)
	character_mind.set_assigned_role(fallback_job)
	RegisterSignal(body, COMSIG_MOB_MIND_SET_ROLE, PROC_REF(observe_role))
	// A headless fixture has no real /client recipient; transport stays covered by the unchanged to_chat callsite.
	TEST_ASSERT_EQUAL(character_mind.set_assigned_role_with_greeting(greeting_job, null), fallback_job, "The replacement lost the native previous-role return")
	TEST_ASSERT_EQUAL(target_signals, 1, "A single assignment emitted duplicate or missing target-role signals")
	TEST_ASSERT_EQUAL(greeting_job.greeting_reads, 1, "A single assignment constructed duplicate or missing greetings")
	TEST_ASSERT_EQUAL(greeting_job.greeted_body, body, "The greeting did not receive the committed mind body")
	var/message = greeting_job.get_spawn_message(body)
	TEST_ASSERT(findtext(message, body.real_name), "The greeting formatter discarded the committed body's information")
	character_mind.set_assigned_role(fallback_job)
	target_signals = 0
	fallback_signals = 0
	change_role_on_signal = TRUE
	var/reads_before = greeting_job.greeting_reads
	TEST_ASSERT_EQUAL(character_mind.set_assigned_role_with_greeting(greeting_job, null), fallback_job, "A reentrant role change lost the original return value")
	TEST_ASSERT_EQUAL(target_signals, 1, "The replacement assigned the requested role more than once")
	TEST_ASSERT_EQUAL(fallback_signals, 1, "The fixture did not execute the real reentrant role setter")
	TEST_ASSERT_EQUAL(character_mind.assigned_role, fallback_job, "The greeting replacement undid a listener's role veto")
	TEST_ASSERT_EQUAL(greeting_job.greeting_reads, reads_before, "A vetoed role still constructed its greeting")

/datum/unit_test/publish_audit_committed_body_greeting/Destroy()
	if(body)
		UnregisterSignal(body, COMSIG_MOB_MIND_SET_ROLE)
	return ..()
