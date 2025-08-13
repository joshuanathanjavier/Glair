extends Node
class_name ObjectiveManager

# Objective system for tracking player goals and progress

# Define objective types
enum ObjectiveType {
	COLLECT_KEYS,
	SURVIVE_TIME,
	ESCAPE,
	EXPLORE_AREA,
	AVOID_MONSTER,
	COMPLETE_TASK
}

# Objective status
enum ObjectiveStatus {
	ACTIVE,
	COMPLETED,
	FAILED,
	HIDDEN
}

# Objective data structure
class Objective:
	var id: String
	var type: ObjectiveType
	var title: String
	var description: String
	var current_progress: float = 0.0
	var target_progress: float = 1.0
	var status: ObjectiveStatus = ObjectiveStatus.ACTIVE
	var is_optional: bool = false
	var reward_message: String = ""
	var completion_time: float = 0.0
	
	func _init(obj_id: String, obj_type: ObjectiveType, obj_title: String, obj_desc: String, target: float = 1.0):
		id = obj_id
		type = obj_type
		title = obj_title
		description = obj_desc
		target_progress = target
	
	func get_progress_percentage() -> float:
		return (current_progress / target_progress) * 100.0
	
	func is_completed() -> bool:
		return current_progress >= target_progress
	
	func update_progress(amount: float):
		current_progress = min(current_progress + amount, target_progress)
		# Don't auto-complete here - let the manager handle completion

# Active objectives
var active_objectives: Array[Objective] = []
var completed_objectives: Array[Objective] = []
var failed_objectives: Array[Objective] = []

# Game state tracking
var game_start_time: float = 0.0
var player_alive: bool = true
var survival_time: float = 0.0
var keys_collected: int = 0
var areas_explored: int = 0

func _ready():
	# Connect to game events
	Events.player_died.connect(_on_player_died)
	Events.key_collected.connect(_on_key_collected)
	
	# Set game start time
	game_start_time = Time.get_ticks_msec() / 1000.0
	
	# Wait a frame to ensure everything is loaded before setting up objectives
	await get_tree().process_frame
	
	# Initialize starting objectives
	_setup_initial_objectives()
	
	# Start tracking survival time
	set_process(true)

func _process(delta):
	if player_alive:
		survival_time += delta
		
		# Update survival objectives
		for objective in active_objectives:
			if objective.type == ObjectiveType.SURVIVE_TIME and objective.status == ObjectiveStatus.ACTIVE:
				objective.update_progress(delta)
				Events.objective_progress_updated.emit(
					objective.title,
					objective.current_progress,
					objective.target_progress
				)
				if objective.is_completed():
					_complete_objective(objective)

func _setup_initial_objectives():
	# Primary objective: Collect keys to escape
	var collect_keys_objective = Objective.new(
		"collect_keys",
		ObjectiveType.COLLECT_KEYS,
		"Find the Way Out",
		"Collect 10 keys to escape the forest",
		10.0
	)
	collect_keys_objective.reward_message = "You've found the way to freedom!"
	add_objective(collect_keys_objective)
	
	# Secondary objective: Basic survival
	var survive_objective = Objective.new(
		"survive_2min",
		ObjectiveType.SURVIVE_TIME,
		"Stay Alive",
		"Survive while searching for keys",
		120.0  # 2 minutes in seconds
	)
	survive_objective.is_optional = true
	survive_objective.reward_message = "You're learning to survive the night!"
	add_objective(survive_objective)
	
	# Hidden objective: Extended survival
	var extended_survive = Objective.new(
		"survive_5min",
		ObjectiveType.SURVIVE_TIME,
		"Master of Survival",
		"Survive for 5 minutes (Challenge)",
		300.0  # 5 minutes
	)
	extended_survive.is_optional = true
	extended_survive.status = ObjectiveStatus.HIDDEN
	extended_survive.reward_message = "The darkness holds no fear for you!"
	add_objective(extended_survive)

func add_objective(objective: Objective):
	print("Adding objective: ", objective.title, " Target: ", objective.target_progress, " Status: ", objective.status)
	if objective.status != ObjectiveStatus.HIDDEN:
		active_objectives.append(objective)
		Events.objective_added.emit(objective.title, objective.description)
	else:
		# Store hidden objectives separately until revealed
		active_objectives.append(objective)
	_update_objective_display()

func remove_objective(objective_id: String):
	for i in range(active_objectives.size()):
		if active_objectives[i].id == objective_id:
			var obj = active_objectives[i]
			active_objectives.remove_at(i)
			failed_objectives.append(obj)
			obj.status = ObjectiveStatus.FAILED
			Events.objective_failed.emit(obj.title)
			_update_objective_display()
			break

func _complete_objective(objective: Objective):
	# Check if already completed to avoid double completion
	if objective.status == ObjectiveStatus.COMPLETED:
		return
		
	objective.status = ObjectiveStatus.COMPLETED
	objective.completion_time = Time.get_ticks_msec() / 1000.0
	completed_objectives.append(objective)
	
	# Remove from active objectives
	var index = active_objectives.find(objective)
	if index >= 0:
		active_objectives.remove_at(index)
	
	# Emit completion event
	Events.objective_completed.emit(objective.title, objective.reward_message)
	
	# Check for unlocking hidden objectives
	_check_unlock_conditions(objective)
	
	# Update display
	_update_objective_display()
	
	print("Objective completed: ", objective.title)

func _check_unlock_conditions(completed_objective: Objective):
	# Unlock extended survival after basic survival
	if completed_objective.id == "survive_2min":
		for obj in active_objectives:
			if obj.id == "survive_5min" and obj.status == ObjectiveStatus.HIDDEN:
				obj.status = ObjectiveStatus.ACTIVE
				Events.objective_revealed.emit(obj.title, obj.description)
				break
	
	# When collecting keys, reveal escape route hints
	if completed_objective.id == "collect_keys":
		# Add escape objective
		var escape_objective = Objective.new(
			"escape_forest",
			ObjectiveType.ESCAPE,
			"Break Free",
			"Find the exit and escape the forest",
			1.0
		)
		escape_objective.reward_message = "Freedom at last! You've escaped the nightmare!"
		add_objective(escape_objective)

func update_objective_progress(objective_id: String, progress_amount: float):
	for objective in active_objectives:
		if objective.id == objective_id and objective.status == ObjectiveStatus.ACTIVE:
			var old_progress = objective.current_progress
			objective.update_progress(progress_amount)
			
			# Emit progress update
			Events.objective_progress_updated.emit(
				objective.title, 
				objective.current_progress, 
				objective.target_progress
			)
			
			if objective.is_completed():
				_complete_objective(objective)
			else:
				_update_objective_display()
			break

func _update_objective_display():
	# Get visible objectives (not hidden)
	var visible_objectives = []
	for obj in active_objectives:
		if obj.status != ObjectiveStatus.HIDDEN:
			visible_objectives.append(obj)
	
	Events.objectives_updated.emit(visible_objectives)

# Event handlers
func _on_key_collected():
	keys_collected += 1
	print("Key collected! Total: ", keys_collected)
	
	# Update key collection objectives
	for objective in active_objectives:
		if objective.type == ObjectiveType.COLLECT_KEYS and objective.status == ObjectiveStatus.ACTIVE:
			print("Updating objective: ", objective.title, " Progress: ", objective.current_progress, "/", objective.target_progress)
			objective.update_progress(1.0)
			print("New progress: ", objective.current_progress, "/", objective.target_progress)
			
			Events.objective_progress_updated.emit(
				objective.title,
				objective.current_progress,
				objective.target_progress
			)
			
			if objective.is_completed():
				print("Objective should be completed now!")
				_complete_objective(objective)
			else:
				print("Objective not yet completed")
			break
	
	_update_objective_display()

func _on_player_died():
	player_alive = false
	
	# Fail all active survival objectives
	for objective in active_objectives:
		if objective.type == ObjectiveType.SURVIVE_TIME and objective.status == ObjectiveStatus.ACTIVE:
			objective.status = ObjectiveStatus.FAILED
			failed_objectives.append(objective)
			Events.objective_failed.emit(objective.title)
	
	# Clear active objectives of survival type
	active_objectives = active_objectives.filter(func(obj): return obj.type != ObjectiveType.SURVIVE_TIME)
	_update_objective_display()

# Utility functions
func get_active_objectives() -> Array[Objective]:
	return active_objectives.filter(func(obj): return obj.status == ObjectiveStatus.ACTIVE)

func get_completed_objectives() -> Array[Objective]:
	return completed_objectives

func get_objective_by_id(objective_id: String) -> Objective:
	for obj in active_objectives:
		if obj.id == objective_id:
			return obj
	for obj in completed_objectives:
		if obj.id == objective_id:
			return obj
	for obj in failed_objectives:
		if obj.id == objective_id:
			return obj
	return null

func get_completion_stats() -> Dictionary:
	return {
		"keys_collected": keys_collected,
		"survival_time": survival_time,
		"areas_explored": areas_explored,
		"objectives_completed": completed_objectives.size(),
		"objectives_failed": failed_objectives.size(),
		"total_objectives": completed_objectives.size() + failed_objectives.size() + active_objectives.size()
	}

# For debugging
func print_objectives_status():
	print("=== OBJECTIVES STATUS ===")
	print("Active: ", active_objectives.size())
	for obj in active_objectives:
		if obj.status != ObjectiveStatus.HIDDEN:
			print("  - ", obj.title, " (", obj.current_progress, "/", obj.target_progress, ")")
	print("Completed: ", completed_objectives.size())
	print("Failed: ", failed_objectives.size())
	print("Keys collected: ", keys_collected)
	print("Areas explored: ", areas_explored)
	print("Survival time: ", "%.1f" % survival_time, "s")
