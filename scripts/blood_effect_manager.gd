extends Node

# Blood Effect Manager
# Handles blood overlay effects when player takes damage or health is low

# Node references
@onready var damage_overlay: TextureRect
@onready var persistent_overlay: TextureRect

# Blood textures
var blood_textures: Array[Texture2D] = []
var current_damage_tween: Tween
var current_persistent_tween: Tween

# Effect settings
const DAMAGE_FADE_IN_TIME: float = 0.3
const DAMAGE_HOLD_TIME: float = 0.5
const DAMAGE_FADE_OUT_TIME: float = 0.8
const PERSISTENT_FADE_TIME: float = 1.0

# Health thresholds for persistent effects
const PERSISTENT_START_THRESHOLD: float = 0.7  # 70% health
const PERSISTENT_MAX_THRESHOLD: float = 0.1    # 10% health

func _ready():
	# Load blood textures
	_load_blood_textures()
	
	# Setup overlays
	_setup_overlays()
	
	# Connect to events
	Events.player_damaged.connect(_on_player_damaged)
	Events.health_updated.connect(_on_health_updated)

func _load_blood_textures():
	# Load all 5 blood textures
	for i in range(1, 6):
		var texture_path = "res://assets/images/blood/blood%d.png" % i
		var texture = load(texture_path)
		if texture:
			blood_textures.append(texture)
		else:
			print("Warning: Could not load blood texture: ", texture_path)

func _setup_overlays():
	# Find overlay nodes
	damage_overlay = get_node("DamageOverlay")
	persistent_overlay = get_node("PersistentOverlay")
	
	if not damage_overlay or not persistent_overlay:
		print("Error: Blood overlay nodes not found!")
		return
	
	# Initialize overlays
	damage_overlay.modulate.a = 0.0
	persistent_overlay.modulate.a = 0.0

func _on_player_damaged(damage_amount: float):
	_show_damage_effect(damage_amount)

func _on_health_updated(current_health: float, max_health: float):
	var health_percentage = current_health / max_health
	_update_persistent_effect(health_percentage)

func _show_damage_effect(damage_amount: float):
	if not damage_overlay or blood_textures.is_empty():
		return
	
	# Kill existing damage tween
	if current_damage_tween:
		current_damage_tween.kill()
	
	# Select random blood texture
	var random_texture = blood_textures[randi() % blood_textures.size()]
	damage_overlay.texture = random_texture
	
	# Calculate intensity based on damage (25 damage = 100% intensity)
	var intensity = clamp(damage_amount / 25.0, 0.3, 1.0)
	var max_opacity = 0.3 + (intensity * 0.5)  # Range: 0.3 to 0.8
	
	# Create fade in -> hold -> fade out sequence
	current_damage_tween = create_tween()
	current_damage_tween.set_parallel(false)
	
	# Fade in
	current_damage_tween.tween_property(damage_overlay, "modulate:a", max_opacity, DAMAGE_FADE_IN_TIME)
	# Hold (using tween_callback with delay)
	current_damage_tween.tween_callback(func(): pass).set_delay(DAMAGE_HOLD_TIME)
	# Fade out
	current_damage_tween.tween_property(damage_overlay, "modulate:a", 0.0, DAMAGE_FADE_OUT_TIME)

func _update_persistent_effect(health_percentage: float):
	if not persistent_overlay or blood_textures.is_empty():
		return
	
	# Only show persistent effect when health is below threshold
	if health_percentage > PERSISTENT_START_THRESHOLD:
		_fade_out_persistent_effect()
		return
	
	# Select blood texture for persistent effect (use first one)
	persistent_overlay.texture = blood_textures[0]
	
	# Calculate opacity based on health percentage
	var opacity = 0.0
	if health_percentage <= PERSISTENT_MAX_THRESHOLD:
		opacity = 0.8 + (health_percentage * 0.2)  # 0.8 to 1.0
	elif health_percentage <= 0.3:
		opacity = 0.6 + ((0.3 - health_percentage) / 0.2) * 0.2  # 0.6 to 0.8
	elif health_percentage <= 0.5:
		opacity = 0.3 + ((0.5 - health_percentage) / 0.2) * 0.3  # 0.3 to 0.6
	else:
		opacity = 0.1 + ((PERSISTENT_START_THRESHOLD - health_percentage) / 0.2) * 0.2  # 0.1 to 0.3
	
	# Animate to new opacity
	if current_persistent_tween:
		current_persistent_tween.kill()
	
	current_persistent_tween = create_tween()
	current_persistent_tween.tween_property(persistent_overlay, "modulate:a", opacity, PERSISTENT_FADE_TIME)

func _fade_out_persistent_effect():
	if not persistent_overlay:
		return
	
	if current_persistent_tween:
		current_persistent_tween.kill()
	
	current_persistent_tween = create_tween()
	current_persistent_tween.tween_property(persistent_overlay, "modulate:a", 0.0, PERSISTENT_FADE_TIME)

func _exit_tree():
	# Cleanup tweens
	if current_damage_tween:
		current_damage_tween.kill()
	if current_persistent_tween:
		current_persistent_tween.kill()
