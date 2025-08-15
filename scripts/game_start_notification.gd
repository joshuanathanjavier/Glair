extends Control
class_name GameStartNotification

# Game start notification that displays the main objective
@onready var notification_label: Label = $NotificationLabel
@onready var background_panel: Panel = $BackgroundPanel

# Notification settings
var display_duration: float = 2.5
var fade_in_duration: float = 0.5
var fade_out_duration: float = 0.5
var notification_timer: float = 0.0
var is_showing: bool = false

# Animation tweens
var fade_tween: Tween

func _ready():
	# Hide initially
	notification_label.visible = false
	notification_label.modulate.a = 0.0
	background_panel.visible = false
	background_panel.modulate.a = 0.0
	
	# Wait for the game to fully load
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout  # Small delay to ensure everything is loaded
	
	# Show the game start notification
	show_game_start_notification()

func _process(delta):
	if is_showing:
		notification_timer -= delta
		if notification_timer <= 0.0:
			hide_notification()

func show_game_start_notification():
	# Get the number of keys from the key spawner
	var key_count = get_key_count()
	
	# Set the notification text
	notification_label.text = "Collect " + str(key_count) + " Keys and Escape the Forest"
	
	# Show the notification
	notification_label.visible = true
	background_panel.visible = true
	
	# Animate in
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.parallel().tween_property(notification_label, "modulate:a", 1.0, fade_in_duration)
	fade_tween.parallel().tween_property(background_panel, "modulate:a", 0.8, fade_in_duration)
	
	is_showing = true
	notification_timer = display_duration

func hide_notification():
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.parallel().tween_property(notification_label, "modulate:a", 0.0, fade_out_duration)
	fade_tween.parallel().tween_property(background_panel, "modulate:a", 0.0, fade_out_duration)
	fade_tween.tween_callback(_on_notification_hidden)
	
	is_showing = false

func _on_notification_hidden():
	notification_label.visible = false
	background_panel.visible = false

func get_key_count() -> int:
	# Try to find the key spawner and get the spawn count
	for node in get_tree().get_nodes_in_group("key_spawners"):
		if node.has_method("get_spawn_count"):
			return node.get_spawn_count()
	
	# Fallback to default value if spawner not found
	return 10
