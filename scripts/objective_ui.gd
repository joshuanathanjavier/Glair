extends Control
class_name ObjectiveUI

# UI for displaying current objectives to the player

@onready var objectives_container: VBoxContainer = $ObjectivesContainer
@onready var objectives_title: Label = $ObjectivesContainer/ObjectivesTitle
@onready var objectives_list: VBoxContainer = $ObjectivesContainer/ObjectivesList
@onready var completion_label: Label = $"CompletionNotification#CompletionLabel"
@onready var completion_reward: Label = $"CompletionNotification#CompletionReward"

# Notification settings
var notification_duration: float = 3.0
var notification_timer: float = 0.0
var notification_queue: Array = []
var showing_notification: bool = false

# Animation settings
var fade_tween: Tween
var slide_tween: Tween
var game_started: bool = false

# Escape prompt settings
var show_escape_prompt: bool = false

func _ready():
	# Connect to objective events
	Events.objectives_updated.connect(_on_objectives_updated)
	Events.objective_completed.connect(_on_objective_completed)
	Events.objective_failed.connect(_on_objective_failed)
	Events.objective_revealed.connect(_on_objective_revealed)
	Events.objective_progress_updated.connect(_on_objective_progress_updated)
	
	# Listen for exit door spawns
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	# Try to connect to any existing exit door
	_connect_to_exit_door()
	
	# Initialize UI
	completion_label.visible = false
	completion_label.modulate.a = 0.0
	completion_reward.visible = false
	completion_reward.modulate.a = 0.0
	
	# Start with no objectives visible
	objectives_container.visible = false
	
	# Force immediate UI refresh
	call_deferred("_force_ui_refresh")
	
	# Prevent initial notifications during game setup
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout  # Wait 1 second after game starts
	game_started = true

func _force_ui_refresh():
	print("Forcing UI refresh...")
	objectives_container.visible = true
	objectives_container.queue_redraw()

func _process(delta):
	# Handle notification timer
	if showing_notification:
		notification_timer -= delta
		if notification_timer <= 0.0:
			_hide_notification()
	
	# Show escape prompt if player is near exit door
	if show_escape_prompt:
		completion_label.text = "Press E to Escape!"
		completion_label.visible = true
		completion_label.modulate.a = 1.0
	elif not showing_notification:
		completion_label.visible = false

func _on_objectives_updated(objectives: Array):
	print("Updating objectives UI. Objective count: ", objectives.size())
	
	# Clear existing objective displays immediately
	for child in objectives_list.get_children():
		objectives_list.remove_child(child)
		child.queue_free()
	
	# Force update the layout
	objectives_list.call_deferred("queue_sort")
	
	# If no objectives, hide the container
	if objectives.is_empty():
		objectives_container.visible = false
		return
	
	objectives_container.visible = true
	
	# Create UI for each objective
	for obj in objectives:
		if obj.status == ObjectiveManager.ObjectiveStatus.ACTIVE:  # ObjectiveStatus.ACTIVE
			_create_objective_display(obj)

func _create_objective_display(objective):
	print("Creating objective display for: ", objective.title, " with no background")
	
	# Create simple container without background panel
	var objective_container = VBoxContainer.new()
	objective_container.name = "Objective_" + objective.id
	objective_container.custom_minimum_size = Vector2(280, 60)
	objective_container.add_theme_constant_override("separation", 4)
	
	# Objective title
	var title_label = Label.new()
	title_label.text = objective.title
	title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.clip_contents = true
	title_label.custom_minimum_size = Vector2(250, 16)
	objective_container.add_child(title_label)
	
	# Objective description
	var desc_label = Label.new()
	desc_label.text = objective.description
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.clip_contents = true
	desc_label.custom_minimum_size = Vector2(250, 14)
	objective_container.add_child(desc_label)
	
	# Progress bar (for objectives that have numerical progress)
	if objective.target_progress > 1.0:
		var progress_container = HBoxContainer.new()
		progress_container.add_theme_constant_override("separation", 8)
		objective_container.add_child(progress_container)
		
		var progress_bar = ProgressBar.new()
		progress_bar.min_value = 0.0
		progress_bar.max_value = objective.target_progress
		progress_bar.value = objective.current_progress
		progress_bar.custom_minimum_size = Vector2(160, 20)
		progress_bar.show_percentage = false
		
		# Style the progress bar
		var progress_style = StyleBoxFlat.new()
		progress_style.bg_color = Color(0.25, 0.25, 0.25, 1.0)
		progress_style.corner_radius_top_left = 3
		progress_style.corner_radius_top_right = 3
		progress_style.corner_radius_bottom_left = 3
		progress_style.corner_radius_bottom_right = 3
		progress_bar.add_theme_stylebox_override("background", progress_style)
		
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color(0.4, 0.8, 0.4, 1.0)
		fill_style.corner_radius_top_left = 3
		fill_style.corner_radius_top_right = 3
		fill_style.corner_radius_bottom_left = 3
		fill_style.corner_radius_bottom_right = 3
		progress_bar.add_theme_stylebox_override("fill", fill_style)
		
		progress_container.add_child(progress_bar)
		
		# Progress text
		var progress_label = Label.new()
		progress_label.text = "%d/%d" % [objective.current_progress, objective.target_progress]
		progress_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
		progress_label.add_theme_font_size_override("font_size", 12)
		progress_label.custom_minimum_size = Vector2(50, 0)
		progress_container.add_child(progress_label)
	
	# Optional tag
	if objective.is_optional:
		var optional_label = Label.new()
		optional_label.text = "[OPTIONAL]"
		optional_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.4, 1.0))
		optional_label.add_theme_font_size_override("font_size", 10)
		objective_container.add_child(optional_label)
	
	objectives_list.add_child(objective_container)

func _on_objective_completed(title: String, reward_message: String):
	if not game_started:
		return  # Don't show notifications during game initialization
	_show_notification("OBJECTIVE COMPLETED", title, reward_message, Color(0.4, 0.9, 0.4, 1.0))

func _on_objective_failed(title: String):
	if not game_started:
		return  # Don't show notifications during game initialization
	_show_notification("OBJECTIVE FAILED", title, "", Color(0.9, 0.4, 0.4, 1.0))

func _on_objective_revealed(title: String, description: String):
	if not game_started:
		return  # Don't show notifications during game initialization
	_show_notification("NEW OBJECTIVE", title, description, Color(0.4, 0.7, 0.9, 1.0))

func _on_objective_progress_updated(title: String, current: float, target: float):
	# Update the progress bar for this objective
	var objective_container = objectives_list.get_node_or_null("Objective_" + _get_objective_id_from_title(title))
	if objective_container:
		var progress_bar = _find_progress_bar(objective_container)
		if progress_bar:
			progress_bar.value = current
			# Update progress label
			var progress_container = progress_bar.get_parent()
			if progress_container and progress_container.get_child_count() > 1:
				var progress_label = progress_container.get_child(1)
				if progress_label is Label:
					progress_label.text = "%d/%d" % [current, target]

func _get_objective_id_from_title(title: String) -> String:
	# This is a simple mapping - in a real game you'd want a better system
	match title:
		"Find the Way Out": return "collect_keys"
		"Stay Alive": return "survive_2min"
		"Master of Survival": return "survive_5min"
		"Break Free": return "escape_forest"
		_: return title.to_lower().replace(" ", "_")

func _find_progress_bar(container: Node) -> ProgressBar:
	# Recursively find the progress bar in the container
	for child in container.get_children():
		if child is ProgressBar:
			return child
		elif child.get_child_count() > 0:
			var result = _find_progress_bar_recursive(child)
			if result:
				return result
	return null

func _find_progress_bar_recursive(node: Node) -> ProgressBar:
	for child in node.get_children():
		if child is ProgressBar:
			return child
		elif child.get_child_count() > 0:
			var result = _find_progress_bar_recursive(child)
			if result:
				return result
	return null

func _show_notification(type: String, title: String, message: String, color: Color):
	var notification = {
		"type": type,
		"title": title,
		"message": message,
		"color": color
	}
	
	if showing_notification:
		notification_queue.append(notification)
	else:
		_display_notification(notification)

func _display_notification(notification: Dictionary):
	showing_notification = true
	notification_timer = notification_duration
	
	# Set notification content
	completion_label.text = notification.type + "\n" + notification.title
	completion_reward.text = notification.message
	completion_label.add_theme_color_override("font_color", notification.color)
	
	# Show and animate notification
	completion_label.visible = true
	completion_reward.visible = true
	
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.parallel().tween_property(completion_label, "modulate:a", 1.0, 0.3)
	fade_tween.parallel().tween_property(completion_reward, "modulate:a", 1.0, 0.3)

func _hide_notification():
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.parallel().tween_property(completion_label, "modulate:a", 0.0, 0.3)
	fade_tween.parallel().tween_property(completion_reward, "modulate:a", 0.0, 0.3)
	fade_tween.tween_callback(_on_notification_hidden)

func _on_notification_hidden():
	completion_label.visible = false
	completion_reward.visible = false
	showing_notification = false
	
	# Show next notification in queue if any
	if not notification_queue.is_empty():
		var next_notification = notification_queue.pop_front()
		call_deferred("_display_notification", next_notification)

func _on_player_near_exit_door(is_near: bool):
	show_escape_prompt = is_near

func _on_node_added(node):
	if node is Area3D and node.has_signal("player_near_exit_door"):
		node.connect("player_near_exit_door", Callable(self, "_on_player_near_exit_door"))

func _connect_to_exit_door():
	for node in get_tree().get_nodes_in_group("door_spawners"):
		if node.has_signal("player_near_exit_door"):
			node.connect("player_near_exit_door", Callable(self, "_on_player_near_exit_door"))
