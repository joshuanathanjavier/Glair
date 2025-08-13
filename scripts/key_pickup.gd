extends RigidBody3D
class_name KeyPickup

# Key pickup configuration
@export var key_id: int = 1
@export var interaction_text: String = "Press E to pick up key"
@export var glow_intensity: float = 0.5

# Internal variables
var is_interactable: bool = true
var original_position: Vector3
var hover_amplitude: float = 0.03
var hover_frequency: float = 1.5
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
	
	# Add glow effect
	if glow_light:
		glow_light.light_energy = glow_intensity
		glow_light.light_color = Color(1.0, 0.8, 0.3, 1.0)  # Golden glow

func _setup_hover_effect():
	# Wait a moment for the key to settle, then enable hover
	await get_tree().create_timer(1.0).timeout
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
		var pulse = (sin(time_alive * 2.0) * 0.3 + 0.7)
		glow_light.light_energy = glow_intensity * pulse

# Interaction system
func can_interact() -> bool:
	return is_interactable

func get_interaction_text() -> String:
	return interaction_text

func interact(player):
	if not can_interact():
		return
	
	print("Key ", key_id, " collected!")
	
	# Play pickup sound
	if pickup_audio:
		pickup_audio.pitch_scale = randf_range(0.9, 1.1)
		pickup_audio.play()
	
	# Create pickup effect
	_create_pickup_effect()
	
	# Emit signal for objective system
	Events.key_collected.emit()
	
	# Show pickup message
	Events.show_pickup_message.emit("Key collected: " + str(key_id) + "/10")
	
	# Clear interaction immediately
	Events.interaction_cleared.emit()
	
	# Disable interaction and start removal process
	is_interactable = false
	_start_disappear_animation()

func _create_pickup_effect():
	# Create a bright flash effect
	if glow_light:
		var tween = create_tween()
		tween.tween_property(glow_light, "light_energy", glow_intensity * 5.0, 0.1)
		tween.tween_property(glow_light, "light_energy", 0.0, 0.4)

func _start_disappear_animation():
	var tween = create_tween()
	tween.parallel().tween_property(mesh_instance, "scale", Vector3.ZERO, 0.5)
	
	# Fade out the mesh material if possible
	if mesh_instance.get_surface_override_material(0):
		var material = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
		if material:
			tween.parallel().tween_property(material, "albedo_color", Color.TRANSPARENT, 0.5)
	
	tween.tween_callback(queue_free)

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
			var tween = create_tween()
			tween.tween_property(material, "emission_energy", 0.5, 0.2)
			tween.tween_property(material, "emission_energy", 0.1, 0.2)

func unhighlight():
	if mesh_instance and is_interactable:
		var material = mesh_instance.get_surface_override_material(0)
		if material:
			var tween = create_tween()
			tween.tween_property(material, "emission_energy", 0.1, 0.1)
