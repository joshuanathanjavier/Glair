extends CharacterBody3D


# --- Movement Settings ---
@export var move_speed: float = 3.0
@export var mouse_sensitivity: float = 0.002
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var sprint_multiplier: float = 1.8

# --- Stamina Settings ---
@export var max_stamina: float = 5.0
@export var stamina_depletion_rate: float = 1.0
@export var stamina_recovery_rate: float = 1.5

# --- Crouch Settings ---
@export var crouch_speed_multiplier: float = 0.5
@export var crouch_offset: float = -0.6  # How far camera drops when crouching

# --- Head Bobbing Settings ---
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.08
@export var bob_intensity: float = 0.1

# --- Advanced Movement Settings ---
@export var acceleration: float = 10.0
@export var friction: float = 12.0
@export var air_control: float = 0.3
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

# --- Interaction Settings ---
@export var interaction_range: float = 2.5
@export var interaction_ray_length: float = 3.0

# --- Fear/Stress System ---
@export var max_fear: float = 100.0
@export var fear_decay_rate: float = 5.0
@export var stress_breathing_threshold: float = 60.0

# --- State Variables ---
var y_velocity: float = 0.0
var stamina: float = max_stamina
var is_sprinting: bool = false
var is_crouching: bool = false
var camera_default_position: Vector3
var flashlight_on = false
var flashlight_battery: float = 100.0
var max_flashlight_battery: float = 100.0

# --- Advanced State Variables ---
var bob_time: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false
var fear_level: float = 0.0
var breathing_intensity: float = 0.0
var horizontal_velocity: Vector3 = Vector3.ZERO
var last_position: Vector3 = Vector3.ZERO
var current_interactable = null
var footstep_timer: float = 0.0

# --- Node References ---
@onready var camera: Camera3D = $Camera3D
@onready var flashlight = $Camera3D/Flashlight
@onready var flashlight_model = $Camera3D/FlashlightModel
@onready var pause_menu = $"../UI/PauseMenu"

# --- Audio References ---
@onready var footstep_player = $Camera3D/AudioSystem/FootstepPlayer
@onready var breathing_player = $Camera3D/AudioSystem/BreathingPlayer
@onready var heartbeat_player = $Camera3D/AudioSystem/HeartbeatPlayer

# --- Initialization ---
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_default_position = camera.position
	flashlight.visible = flashlight_on
	flashlight_model.visible = true  # Model is always visible
	last_position = global_position
	
	# Add player to group for interaction detection
	add_to_group("player")
	
	# Ensure interact input exists
	_setup_input_map()
	
	# Initialize flashlight appearance
	_update_flashlight_appearance()
	
	# Connect to settings changes
	Events.settings_changed.connect(_on_settings_changed)

# --- Main Physics Logic ---
func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var forward = -transform.basis.z
	var right = transform.basis.x
	
	# Update timers
	_update_timers(delta)
	
	# Update UI via signals
	Events.stamina_updated.emit(stamina, max_stamina)
	Events.battery_updated.emit(flashlight_battery, max_flashlight_battery)

	# Flashlight Input
	if Input.is_action_just_pressed("flashlight_toggle"):
		flashlight_on = !flashlight_on
		flashlight.visible = flashlight_on
		_update_flashlight_appearance()

	# Flashlight battery drain
	if flashlight_on:
		flashlight_battery = max(0.0, flashlight_battery - delta * 5.0) # drains at 5 units per second
		if flashlight_battery == 0.0:
			flashlight_on = false
			flashlight.visible = false
		_update_flashlight_appearance()

	# Movement input
	if Input.is_action_pressed("move_forward"):
		direction += forward
	if Input.is_action_pressed("move_backward"):
		direction -= forward
	if Input.is_action_pressed("move_left"):
		direction -= right
	if Input.is_action_pressed("move_right"):
		direction += right

	direction = direction.normalized()

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	# Enhanced jumping with coyote time and jump buffer
	var can_jump = (is_on_floor() or coyote_timer > 0.0) and jump_buffer_timer > 0.0 and not is_crouching
	
	if not is_on_floor():
		y_velocity -= gravity * delta
		# Air control
		if direction != Vector3.ZERO:
			horizontal_velocity = horizontal_velocity.move_toward(direction * move_speed, acceleration * air_control * delta)
	else:
		coyote_timer = coyote_time  # Reset coyote time when on floor
		if can_jump:
			y_velocity = jump_velocity
			jump_buffer_timer = 0.0  # Consume jump buffer
		else:
			y_velocity = 0.0
		
		# Ground movement with acceleration and friction
		if direction != Vector3.ZERO:
			horizontal_velocity = horizontal_velocity.move_toward(direction * move_speed, acceleration * delta)
		else:
			horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, friction * delta)

	# Crouch and camera adjustment with head bobbing
	is_crouching = Input.is_action_pressed("crouch")
	var target_camera_y = camera_default_position.y
	if is_crouching:
		target_camera_y += crouch_offset

	# Head bobbing effect
	var head_bob_offset = _calculate_head_bob(delta, horizontal_velocity.length())
	target_camera_y += head_bob_offset.y
	
	camera.position.y = lerp(camera.position.y, target_camera_y, 10 * delta)
	camera.position.x = lerp(camera.position.x, camera_default_position.x + head_bob_offset.x, 10 * delta)

	# Sprint and stamina logic
	is_sprinting = Input.is_action_pressed("run") and not is_crouching and stamina > 0.0 and direction != Vector3.ZERO

	var speed_multiplier = 1.0
	if is_crouching:
		speed_multiplier *= crouch_speed_multiplier
	if is_sprinting:
		speed_multiplier *= sprint_multiplier
		stamina = max(0.0, stamina - stamina_depletion_rate * delta)
	elif not Input.is_action_pressed("run"):
		stamina = min(max_stamina, stamina + stamina_recovery_rate * delta)

	# Apply final movement
	var final_speed = move_speed * speed_multiplier
	if is_on_floor():
		velocity = horizontal_velocity * speed_multiplier
	else:
		velocity.x = horizontal_velocity.x * speed_multiplier
		velocity.z = horizontal_velocity.z * speed_multiplier
	
	velocity.y = y_velocity
	
	# Update fear system
	_update_fear_system(delta)
	
	# Update audio effects
	_update_audio_effects(delta)
	
	# Check for interactions
	_check_interactions()
	
	# Store floor state for coyote time
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
func _input(event):
	if event.is_action_pressed("esc"):  # default is Escape key
		if get_tree().paused:
			pause_menu.close()
		else:
			pause_menu.open()
	
	# Interaction input
	if event.is_action_pressed("interact") and current_interactable:
		_interact_with_object(current_interactable)

func _on_settings_changed(settings_data: Dictionary):
	# Update mouse sensitivity when settings change
	if "mouse_sensitivity" in settings_data:
		mouse_sensitivity = settings_data.mouse_sensitivity * 0.002

# --- Enhanced Movement Functions ---
func _update_timers(delta: float):
	# Update coyote time
	if was_on_floor and not is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
	
	# Update jump buffer
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

func _calculate_head_bob(delta: float, speed: float) -> Vector2:
	if speed < 0.1 or not is_on_floor():
		bob_time = 0.0
		return Vector2.ZERO
	
	bob_time += delta * bob_frequency * speed
	
	var bob_x = sin(bob_time) * bob_amplitude * bob_intensity
	var bob_y = sin(bob_time * 2.0) * bob_amplitude * bob_intensity * 0.5
	
	# Reduce bobbing when crouching
	if is_crouching:
		bob_x *= 0.5
		bob_y *= 0.5
	
	# Increase bobbing when sprinting
	if is_sprinting:
		bob_x *= 1.5
		bob_y *= 1.5
	
	return Vector2(bob_x, bob_y)

func _update_fear_system(delta: float):
	# Increase fear in darkness (when flashlight is off or low battery)
	if not flashlight_on or flashlight_battery < 20.0:
		fear_level = min(max_fear, fear_level + 15.0 * delta)
	else:
		fear_level = max(0.0, fear_level - fear_decay_rate * delta)
	
	# Update breathing intensity based on fear and stamina
	var stress_factor = (fear_level / max_fear) + (1.0 - (stamina / max_stamina))
	breathing_intensity = stress_factor
	
	# Apply subtle camera shake when highly stressed
	if breathing_intensity > 0.7:
		var shake_intensity = (breathing_intensity - 0.7) * 0.3
		var shake_x = sin(Time.get_ticks_msec() * 0.01) * shake_intensity * 0.001
		var shake_y = cos(Time.get_ticks_msec() * 0.013) * shake_intensity * 0.001
		camera.position.x += shake_x
		camera.position.y += shake_y

# --- Utility Functions ---
func get_fear_level() -> float:
	return fear_level

func get_breathing_intensity() -> float:
	return breathing_intensity

func add_fear(amount: float):
	fear_level = min(max_fear, fear_level + amount)

func is_highly_stressed() -> bool:
	return breathing_intensity > stress_breathing_threshold / 100.0

# --- Battery System ---
func add_battery_charge(amount: float) -> float:
	var old_battery = flashlight_battery
	flashlight_battery = min(max_flashlight_battery, flashlight_battery + amount)
	var actual_added = flashlight_battery - old_battery
	
	# Update flashlight appearance immediately
	_update_flashlight_appearance()
	
	# Emit UI update
	Events.battery_updated.emit(flashlight_battery, max_flashlight_battery)
	
	# Show feedback message
	if actual_added > 0:
		Events.show_pickup_message.emit("Battery charged: +" + str(int(actual_added)) + "%")
	
	return actual_added

func get_battery_level() -> float:
	return flashlight_battery

func get_max_battery() -> float:
	return max_flashlight_battery

# --- Input Setup ---
func _setup_input_map():
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var event = InputEventKey.new()
		event.keycode = KEY_E
		InputMap.action_add_event("interact", event)
		print("Added 'interact' action to input map with E key")

# --- Audio System ---
func _update_audio_effects(delta: float):
	# Footstep sounds
	if is_on_floor() and horizontal_velocity.length() > 0.1:
		footstep_timer += delta
		var footstep_interval = 0.5 / (horizontal_velocity.length() / move_speed)
		if is_sprinting:
			footstep_interval *= 0.7  # Faster footsteps when running
		if is_crouching:
			footstep_interval *= 1.5  # Slower footsteps when crouching
		
		if footstep_timer >= footstep_interval:
			_play_footstep()
			footstep_timer = 0.0
	
	# Breathing sounds based on stress
	if breathing_intensity > 0.3:
		if not breathing_player.playing:
			breathing_player.volume_db = -20.0 + (breathing_intensity * 10.0)
			breathing_player.pitch_scale = 0.8 + (breathing_intensity * 0.4)
			# breathing_player.play()  # Uncomment when you have breathing audio
	else:
		if breathing_player.playing:
			breathing_player.stop()
	
	# Heartbeat when highly stressed
	if breathing_intensity > 0.7:
		if not heartbeat_player.playing:
			heartbeat_player.volume_db = -25.0 + (breathing_intensity * 15.0)
			heartbeat_player.pitch_scale = 0.9 + (breathing_intensity * 0.3)
			# heartbeat_player.play()  # Uncomment when you have heartbeat audio

func _play_footstep():
	if footstep_player:
		var volume_modifier = 0.0
		if is_crouching:
			volume_modifier = -10.0  # Quieter when crouching
		elif is_sprinting:
			volume_modifier = 5.0   # Louder when running
		
		footstep_player.volume_db = -5.0 + volume_modifier
		footstep_player.pitch_scale = randf_range(0.8, 1.2)  # Random pitch variation
		# footstep_player.play()  # Uncomment when you have footstep audio

# --- Interaction System ---
func _check_interactions():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		camera.global_position,
		camera.global_position + (-camera.global_transform.basis.z * interaction_ray_length)
	)
	query.collision_mask = 4  # Assuming interaction objects are on layer 3 (mask 4)
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.get("collider")
		if collider and collider.has_method("can_interact"):
			if current_interactable != collider:
				current_interactable = collider
				Events.interaction_available.emit(collider.get_interaction_text())
		else:
			_clear_interaction()
	else:
		_clear_interaction()

func _clear_interaction():
	if current_interactable:
		current_interactable = null
		Events.interaction_cleared.emit()

func _interact_with_object(interactable):
	if interactable and interactable.has_method("interact"):
		interactable.interact(self)

# --- Enhanced Mouse Look with Stress Effects ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sensitivity_modifier = mouse_sensitivity
		
		# Reduce sensitivity when highly stressed (shaky hands effect)
		if breathing_intensity > 0.6:
			var shake_factor = 1.0 + (breathing_intensity - 0.6) * 0.5
			sensitivity_modifier *= shake_factor
			
			# Add subtle random movement when very stressed
			if breathing_intensity > 0.8:
				var stress_shake = Vector2(
					randf_range(-0.1, 0.1) * breathing_intensity,
					randf_range(-0.1, 0.1) * breathing_intensity
				)
				event.relative += stress_shake
		
		rotate_y(-event.relative.x * sensitivity_modifier)
		camera.rotate_x(-event.relative.y * sensitivity_modifier)
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90.0, 90.0)

# --- Flashlight Appearance Management ---
func _update_flashlight_appearance():
	if not flashlight_model:
		return
	
	var flashlight_lens = flashlight_model.get_node("FlashlightLens")
	var flashlight_button = flashlight_model.get_node("FlashlightButton")
	
	if not flashlight_lens:
		return
	
	var lens_material = flashlight_lens.get_surface_override_material(0) as StandardMaterial3D
	if not lens_material:
		return
	
	# Calculate battery level as percentage
	var battery_percentage = flashlight_battery / max_flashlight_battery
	
	# Update lens emission based on flashlight state and battery level
	if flashlight_on and flashlight_battery > 0:
		# Bright emission when on, dimmer as battery drains
		var emission_strength = 0.5 * battery_percentage
		lens_material.emission = Color(1, 0.964706, 0.819608, emission_strength)
		lens_material.emission_enabled = true
		
		# Update flashlight light intensity based on battery
		flashlight.light_energy = 5.0 * battery_percentage
		
		# Add flickering effect when battery is low
		if battery_percentage < 0.2:
			var flicker = sin(Time.get_ticks_msec() * 0.02) * 0.1 + 0.9
			flashlight.light_energy *= flicker
			lens_material.emission *= flicker
	else:
		# No emission when off
		lens_material.emission = Color(0.1, 0.1, 0.1, 0.1)
		lens_material.emission_enabled = false
	
	# Update power button appearance
	if flashlight_button:
		var button_material = flashlight_button.get_surface_override_material(0) as StandardMaterial3D
		if button_material:
			if flashlight_on:
				# Green when on
				button_material.albedo_color = Color(0.2, 0.8, 0.2, 1)
				button_material.emission_enabled = true
				button_material.emission = Color(0.2, 0.8, 0.2, 0.3)
			else:
				# Red when off
				button_material.albedo_color = Color(0.8, 0.2, 0.2, 1)
				button_material.emission_enabled = false
