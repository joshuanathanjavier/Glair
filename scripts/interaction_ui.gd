extends Control
class_name InteractionUI

@onready var interaction_label: Label = $InteractionLabel
@onready var pickup_message_label: Label = $PickupMessageLabel

var pickup_message_timer: float = 0.0
var pickup_message_duration: float = 2.0

func _ready():
	# Connect to global events
	Events.interaction_available.connect(_on_interaction_available)
	Events.interaction_cleared.connect(_on_interaction_cleared)
	Events.show_pickup_message.connect(_on_show_pickup_message)
	
	# Hide labels initially
	interaction_label.visible = false
	pickup_message_label.visible = false

func _process(delta):
	# Handle pickup message timer
	if pickup_message_timer > 0.0:
		pickup_message_timer -= delta
		if pickup_message_timer <= 0.0:
			_hide_pickup_message()

func _on_interaction_available(interaction_text: String):
	interaction_label.text = interaction_text
	interaction_label.visible = true
	
	# Add subtle animation
	var tween = create_tween()
	interaction_label.modulate.a = 0.0
	tween.tween_property(interaction_label, "modulate:a", 1.0, 0.2)

func _on_interaction_cleared():
	if interaction_label.visible:
		var tween = create_tween()
		tween.tween_property(interaction_label, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func(): interaction_label.visible = false)

func _on_show_pickup_message(message: String):
	pickup_message_label.text = message
	pickup_message_label.visible = true
	pickup_message_timer = pickup_message_duration
	
	# Animate the pickup message
	var tween = create_tween()
	pickup_message_label.modulate.a = 0.0
	pickup_message_label.scale = Vector2(0.8, 0.8)
	
	tween.parallel().tween_property(pickup_message_label, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(pickup_message_label, "scale", Vector2(1.0, 1.0), 0.3)

func _hide_pickup_message():
	if pickup_message_label.visible:
		var tween = create_tween()
		tween.parallel().tween_property(pickup_message_label, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(pickup_message_label, "scale", Vector2(1.2, 1.2), 0.3)
		tween.tween_callback(func(): pickup_message_label.visible = false)
