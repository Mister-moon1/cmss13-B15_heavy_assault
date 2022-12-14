// --------------------------------------------
// *** Basic retrieve item and get it to an area ***
// --------------------------------------------
/datum/cm_objective/retrieve_item
	var/obj/target_item
	var/list/area/target_areas
	var/area/initial_location
	controller = TREE_MARINE
	display_category = "Item Retrieval"

/datum/cm_objective/retrieve_item/New(var/T)
	..()
	if(T)
		target_item = T
		initial_location = get_area(target_item)
	RegisterSignal(target_item, COMSIG_PARENT_PREQDELETED, .proc/clean_up_ref)

/datum/cm_objective/retrieve_item/Destroy()
	target_item = null
	target_areas = null
	initial_location = null
	return ..()

/datum/cm_objective/retrieve_item/proc/clean_up_ref()
	SIGNAL_HANDLER
	target_item = null

/datum/cm_objective/retrieve_item/get_clue()
	return SPAN_DANGER("[target_item] in <u>[initial_location]</u>")

/datum/cm_objective/retrieve_item/check_completion()
	. = ..()

	message_admins("Checking completion for [target_item]...")
	if(!target_item)
		active = FALSE
		message_admins("FAILED: NO TARGET ITEM")
		return FALSE
	for(var/T in target_areas)
		var/area/target_area = T //not sure why the cast is necessary (rather than casting in the loop), but it doesn't work without it... ~ThePiachu
		message_admins("Checking area: [T], current area [get_area(target_item.loc)]")
		if(istype(get_area(target_item.loc), target_area))
			message_admins("Found in above area!")
			complete()
			return TRUE

/datum/cm_objective/retrieve_item/almayer
	target_areas = list(
		/area/almayer/command/securestorage,
		/area/almayer/command/computerlab,
		/area/almayer/medical/medical_science
	)
	value = OBJECTIVE_EXTREME_VALUE

// --------------------------------------------
// *** Get communications up ***
// --------------------------------------------
/datum/cm_objective/communications
	name = "Restore Colony Communications"
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_AT_END
	value = OBJECTIVE_EXTREME_VALUE
	controller = TREE_MARINE
	var/last_contact_time = NONE // Time of last loss of comms to notify of

/datum/cm_objective/communications/get_readable_progress()
	if(complete)
		return "<span class='objectivegreen'>Comms are up!</span>"
	return "<span class='objectivered'>Comms are down!</span>"

/datum/cm_objective/communications/check_completion()
	. = ..()

	for(var/obj/structure/machinery/telecomms/relay/T in machines)
		if(is_ground_level(T.loc.z) && T.operable() && T.on)
			complete()
			return TRUE
	return FALSE

/datum/cm_objective/communications/complete()
	. = ..()
	if(. && !last_contact_time)
		last_contact_time = world.time
		ai_silent_announcement("SYSTEMS REPORT: Colony communications link online.", ":v")


// /datum/cm_objective/retrieve_item/fulton
// 	name = "Recover a lost fulton"
// 	priority = OBJECTIVE_NO_VALUE
// 	target_areas = list(
// 		/area/almayer,
// 	)

// /datum/cm_objective/retrieve_item/fulton/get_clue()
// 	return SPAN_DANGER("Retrieve lost fulton of [target_item] in [initial_location]")


// /datum/cm_objective/retrieve_item/fulton/fail()
// 	. = ..()
// 	//Objective is failed, doesn't need to be here anymore
// 	qdel(src)

// /datum/cm_objective/retrieve_item/fulton/complete()
// 	. = ..()
// 	//Objective is complete, doesn't need to be here anymore
// 	qdel(src)
