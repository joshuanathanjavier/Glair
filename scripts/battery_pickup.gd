extends RigidBody3D
class_name BatteryPickup

# Battery pickup configuration
@export var battery_charge: float = 25.0  # How much battery this gives
@export var pickup_sound_pitch_variation: float = 0.2
@export var glow_intensity: float = 0.3
@export var interaction_text: String = "Press E to pick up battery"

# Internal variables
var is_interactable: bool = true
var original_position: Vector3
var hover_amplitude: float = 0.02
var hover_frequency: float = 2.0
var time_alive: float = 0.0

# Node references
@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@onready var interaction_area = $InteractionArea
@onready var pickup_audio = $PickupAudio
@onready var glow_light = $GlowLight

func _ready():
	# Set up physics
	gravity_scale = 1.0
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	# Store original position for hover effect once settled
	call_deferred("_setup_hover_effect")
	
	# Set up interaction area
	interaction_area.body_entered.connect(_on_player_entered_area)
	interaction_area.body_exited.connect(_on_player_exited_area)
	
	# Add subtle glow effect
	if glow_light:
		glow_light.light_energy = glow_intensity
		glow_light.light_color = Color(0.8, 0.9, 1.0, 1.0)  # Cool blue tint

func _setup_hover_effect():
	# Wait a moment for the battery to settle, then enable hover
	await get_tree().create_timer(2.0).timeout
	freeze = true  # Stop physics simulation
	original_position = global_position

func _physics_process(delta):
	time_alive += delta
	
	# Gentle hover effect when settled
	if freeze and original_position != Vector3.ZERO:
		var hover_offset = sin(time_alive * hover_frequency) * hover_amplitude
		global_position = original_position + Vector3(0, hover_offset, 0)
	
	# Pulsing glow effect
	if glow_light and is_interactable:
		var pulse = (sin(time_alive * 3.0) * 0.2 + 0.8)
		glow_light.light_energy = glow_intensity * pulse

# Interaction system
func can_interact() -> bool:
	return is_interactable

func get_interaction_text() -> String:
	return interaction_text

func interact(player):
	if not can_interact():
		return
	
	# Add battery charge to player
	if player.has_method("add_battery_charge"):
		var actual_charge_added = player.add_battery_charge(battery_charge)
		
		# Play pickup sound with random pitch
		if pickup_audio:
			pickup_audio.pitch_scale = randf_range(1.0 - pickup_sound_pitch_variation, 1.0 + pickup_sound_pitch_variation)
			pickup_audio.play()
		
		# Create pickup effect
		_create_pickup_effect()
		
		# Emit signal for UI feedback
		Events.battery_pickup_collected.emit(actual_charge_added)
		
		# Clear interaction immediately
		Events.interaction_cleared.emit()
		
		# Disable interaction and start removal process
		is_interactable = false
		_start_disappear_animation()
	
func _create_pickup_effect():
	# Create particles or visual effect here
	# For now, we'll create a simple flash effect
	if glow_light:
		var tween = create_tween()
		tween.tween_property(glow_light, "light_energy", glow_intensity * 3.0, 0.1)
		tween.tween_property(glow_light, "light_energy", 0.0, 0.3)

func _start_disappear_animation():
	var tween = create_tween()
	tween.parallel().tween_property(mesh_instance, "scale", Vector3.ZERO, 0.5)
	# Fix: Use mesh_instance modulate instead of self modulate
	if mesh_instance.get_surface_override_material(0):
		var material = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
		if material:
			tween.parallel().tween_property(material, "albedo_color", Color.TRANSPARENT, 0.5)
	
	# Notify spawner that this battery is being destroyed
	_notify_spawner_of_removal()
	
	tween.tween_callback(queue_free)

func _notify_spawner_of_removal():
	# Find the battery spawner and remove this battery from its list
	var spawners = get_tree().get_nodes_in_group("battery_spawners")
	for spawner in spawners:
		if spawner.has_method("remove_battery_from_list"):
			spawner.remove_battery_from_list(self)

# Area detection for interaction prompts
func _on_player_entered_area(body):
	if body.is_in_group("player") and is_interactable:
		Events.interaction_available.emit(get_interaction_text())

func _on_player_exited_area(body):
	if body.is_in_group("player"):
		Events.interaction_cleared.emit()

# Visual feedback when player looks at it
func highlight():
	if mesh_instance and is_interactable:
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			material.emission_enabled = true
			material.emission = Color(0.3, 0.3, 0.8, 1.0)

func unhighlight():
	if mesh_instance:
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			material.emission_enabled = false
