extends CharacterBody3D

# --- Monster Configuration ---
@export var patrol_speed: float = 2.0
@export var chase_speed: float = 4.5
@export var detection_range: float = 15.0
@export var attack_range: float = 1.5
@export var max_health: float = 100.0

# --- Enhanced Detection Configuration ---
@export var line_of_sight_range: float = 20.0
@export var sound_detection_range: float = 12.0
@export var light_detection_multiplier: float = 1.5
@export var cover_detection_penalty: float = 0.3
@export var fog_detection_penalty: float = 0.7
@export var memory_duration: float = 8.0
@export var investigation_radius: float = 5.0
@export var stealth_detection_penalty: float = 0.2  # Much harder to detect when player is stealthy
@export var crouch_sound_reduction: float = 0.3  # Crouching reduces sound by 70%
@export var flashlight_off_visibility_reduction: float = 0.4  # No flashlight reduces visibility by 60%

# --- AI States ---
enum AIState {
	IDLE,
	PATROLLING,
	CHASING,
	ATTACKING,
	INVESTIGATING,
	STALKING,
	ALERTED
}

# --- State Variables ---
var current_state: AIState = AIState.IDLE
var current_target: Node3D = null
var patrol_points: Array = []
var current_patrol_index: int = 0
var state_timer: float = 0.0
var health: float
var gravity: float = 20.0
var y_velocity: float = 0.0

# --- Enhanced Detection State Variables ---
var last_known_player_position: Vector3
var memory_timer: float
var is_player_visible: bool = false
var player_light_level: float = 0.0
var sound_alert_level: float = 0.0
var investigation_target: Vector3
var cover_positions: Array[Vector3] = []
var investigation_points: Array[Vector3] = []
var current_investigation_index: int = 0

# --- Node References ---
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var model: Node3D = $MonsterModel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var monster_audio: AudioStreamPlayer3D = $MonsterAudio

# --- Animation State ---
var current_animation: String = ""

# --- Initialization ---
func _ready() -> void:
	health = max_health
	add_to_group("monsters")
	add_to_group("enemies")
	
	print("=== MONSTER DEBUG ===")
	print("Monster spawned at position: ", global_position)
	print("Monster scale: ", scale)
	print("Detection range: ", detection_range)
	print("Line of sight range: ", line_of_sight_range)
	print("Sound detection range: ", sound_detection_range)
	
	# Initialize enhanced detection variables
	memory_timer = 0.0
	last_known_player_position = Vector3.ZERO
	investigation_target = Vector3.ZERO
	current_investigation_index = 0
	
	# Generate patrol points around spawn position
	_generate_default_patrol_points()
	
	# Connect signals
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)
		print("Monster: Detection area signals connected")
		print("Detection area monitoring: ", detection_area.monitoring)
	else:
		print("ERROR: Detection area not found!")
	
	# Connect to player events for sound detection
	var tree = get_tree()
	if tree != null:
		# Connect to Events singleton if it exists
		if Events:
			Events.player_movement_detected.connect(_on_player_movement_detected)
			Events.flashlight_toggled.connect(_on_flashlight_toggled)
			Events.player_interaction_started.connect(_on_player_interaction_started)
			print("Monster: Connected to player events")
	
	# Start patrolling
	_change_state(AIState.PATROLLING)
	
	# Start with idle animation
	_play_animation("idle")

# Public method to initialize monster when spawned by spawner
func initialize_spawned_monster(spawn_position: Vector3) -> void:
	global_position = spawn_position
	print("=== MONSTER SPAWNED BY SPAWNER ===")
	print("📍 Spawn position: ", spawn_position)
	print("🎯 Monster ID: ", get_instance_id())
	print("🌍 Current state: ", AIState.keys()[current_state])
	print("📏 Detection range: ", detection_range)
	print("👁️ Line of sight range: ", line_of_sight_range)
	print("🔊 Sound detection range: ", sound_detection_range)
	
	# Regenerate patrol points around new spawn position
	_generate_default_patrol_points()
	
	# Reset all state variables
	current_state = AIState.PATROLLING
	current_target = null
	state_timer = 0.0
	memory_timer = 0.0
	last_known_player_position = Vector3.ZERO
	investigation_target = Vector3.ZERO
	current_investigation_index = 0
	sound_alert_level = 0.0
	player_light_level = 0.0
	is_player_visible = false
	
	print("✅ Monster successfully initialized as spawned monster")
	print("🔄 Starting patrol behavior...")

func _physics_process(delta: float) -> void:
	# Skip processing if not properly in tree
	if not is_inside_tree() or get_tree() == null:
		return
		
	# Apply gravity
	if not is_on_floor():
		y_velocity -= gravity * delta
		print("Monster falling: ", y_velocity)
	else:
		y_velocity = 0.0
	
	velocity.y = y_velocity
	
	# Update enhanced detection systems
	_update_sound_detection(delta)
	_update_memory_system(delta)
	
	# Update player visibility
	if current_target and is_instance_valid(current_target):
		is_player_visible = _check_line_of_sight_to_player()
		player_light_level = _get_player_light_level()
	
	# Update AI state machine
	_update_ai_state(delta)
	
	# Move the monster
	_handle_movement(delta)
	
	# Apply movement and check if actually moved
	var old_position = global_position
	move_and_slide()
	var new_position = global_position
	
	# Debug output every few seconds
	if int(Time.get_unix_time_from_system()) % 3 == 0 and state_timer < 0.1:
		print("Monster status - Position: ", global_position, " On floor: ", is_on_floor(), " State: ", AIState.keys()[current_state])
		if current_target:
			print("Target: ", current_target.global_position, " Distance: ", global_position.distance_to(current_target.global_position))
			print("Visibility: ", _calculate_visibility_score(), " Sound Alert: ", sound_alert_level)
		
		# Manual detection as backup with enhanced visibility
		var tree = get_tree()
		if tree != null:
			var players = tree.get_nodes_in_group("player")
			if players.size() > 0:
				var player = players[0]
				var distance = global_position.distance_to(player.global_position)
				var adjusted_range = _adjust_detection_range_for_environment()
				var visibility = _calculate_visibility_score()
				
				print("Manual check - Player distance: ", distance, " Adjusted range: ", adjusted_range, " Visibility: ", visibility)
				if distance <= adjusted_range and visibility > 0.3 and current_state == AIState.PATROLLING:
					print("Manual detection triggered!")
					current_target = player
					last_known_player_position = player.global_position
					memory_timer = memory_duration
					_change_state(AIState.CHASING)

# --- AI State Machine ---
func _update_ai_state(delta: float) -> void:
	state_timer += delta
	
	match current_state:
		AIState.IDLE:
			_handle_idle_state()
		AIState.PATROLLING:
			_handle_patrol_state()
		AIState.CHASING:
			_handle_chase_state()
		AIState.ATTACKING:
			_handle_attack_state()
		AIState.INVESTIGATING:
			_handle_investigation_state()
		AIState.STALKING:
			_handle_stalking_state()
		AIState.ALERTED:
			_handle_alerted_state()

func _handle_idle_state() -> void:
	_play_animation("idle")
	if state_timer > 2.0:
		_change_state(AIState.PATROLLING)

func _handle_patrol_state() -> void:
	_play_animation("walk")
	
	if patrol_points.is_empty():
		print("Monster: No patrol points!")
		# Generate smart patrol route
		patrol_points = _calculate_optimal_patrol_route()
		if patrol_points.is_empty():
			_generate_default_patrol_points()
		return
	
	var target_point = patrol_points[current_patrol_index]
	
	# Debug patrol every few seconds
	if int(Time.get_unix_time_from_system()) % 3 == 0 and state_timer < 0.1:
		print("Monster patrolling to point ", current_patrol_index, ": ", target_point)
		print("Current position: ", global_position, " Distance: ", global_position.distance_to(target_point))
	
	# Check if we've reached the patrol point
	if global_position.distance_to(target_point) < 1.5:
		print("Monster: Reached patrol point ", current_patrol_index)
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		state_timer = 0.0
		
		# Occasionally update patrol route based on environment
		if current_patrol_index == 0 and randf() < 0.3:
			patrol_points = _calculate_optimal_patrol_route()

func _handle_chase_state() -> void:
	_play_animation("chase")
	
	if current_target and is_instance_valid(current_target):
		var distance_to_player = global_position.distance_to(current_target.global_position)
		var visibility = _calculate_visibility_score()
		
		# Attack if close enough
		if distance_to_player <= attack_range:
			_change_state(AIState.ATTACKING)
		# If visibility is poor, switch to stalking
		elif visibility < 0.3 and distance_to_player > attack_range:
			_change_state(AIState.STALKING)
			print("Monster: Poor visibility during chase - switching to stalking")
		# Lose target if too far and no visibility (easier to escape when stealthy)
		elif distance_to_player > detection_range * 1.5 and visibility < 0.2:
			current_target = null
			_change_state(AIState.PATROLLING)
			print("Monster: Lost target - player escaped successfully!")
			# Emit escape signal
			Events.player_escaped_from_monster.emit()
		# Update last known position if we can see the player
		elif visibility > 0.2:
			last_known_player_position = current_target.global_position
			memory_timer = memory_duration
	else:
		_change_state(AIState.PATROLLING)

func _handle_attack_state() -> void:
	_play_animation("attack")
	
	if current_target and is_instance_valid(current_target):
		var distance_to_player = global_position.distance_to(current_target.global_position)
		
		if distance_to_player <= attack_range:
			# Attack every 0.8 seconds (faster)
			if state_timer > 0.8:
				_perform_attack()
				state_timer = 0.0
		else:
			_change_state(AIState.CHASING)
	else:
		_change_state(AIState.PATROLLING)

# --- Movement ---
func _handle_movement(delta: float) -> void:
	var target_position: Vector3
	var speed = patrol_speed  # Default speed
	
	# Get target position based on state
	if current_state == AIState.CHASING and current_target:
		target_position = current_target.global_position
		speed = chase_speed
	elif current_state == AIState.ATTACKING and current_target:
		# Keep moving towards player even while attacking
		target_position = current_target.global_position
		speed = chase_speed
	elif current_state == AIState.PATROLLING and not patrol_points.is_empty():
		target_position = patrol_points[current_patrol_index]
	elif current_state == AIState.INVESTIGATING and not investigation_points.is_empty():
		# Move towards current investigation point
		target_position = investigation_points[current_investigation_index]
	elif current_state == AIState.STALKING and current_target:
		# Stalking movement - move towards player while using cover
		if cover_positions.size() > 0:
			# Move towards nearest cover position
			var nearest_cover = cover_positions[0]
			target_position = nearest_cover
			speed = patrol_speed * 0.7  # Slower stalking speed
		else:
			# No cover available, move slowly towards player
			target_position = current_target.global_position
			speed = patrol_speed * 0.5
	elif current_state == AIState.ALERTED and last_known_player_position != Vector3.ZERO:
		# Move towards last known player position
		target_position = last_known_player_position
		speed = patrol_speed * 0.8
	else:
		velocity.x = 0
		velocity.z = 0
		return
	
	# Calculate direction to target (simple direct movement)
	var direction = (target_position - global_position).normalized()
	direction.y = 0  # Only move horizontally
	
	if direction.length() > 0.1:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Rotate towards movement direction
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)
		
		# Debug movement
		if int(Time.get_unix_time_from_system()) % 2 == 0 and state_timer < 0.1:
			print("Monster moving - Direction: ", direction, " Speed: ", speed, " Velocity: ", Vector2(velocity.x, velocity.z))
	else:
		velocity.x = 0
		velocity.z = 0

# --- Detection ---
func _on_detection_area_entered(body: Node3D) -> void:
	print("Monster: Something entered detection area: ", body.name, " Groups: ", body.get_groups())
	if body.is_in_group("player"):
		print("Monster: Player detected in area!")
		
		# Set current target
		current_target = body
		
		# Check line of sight and visibility
		var visibility = _calculate_visibility_score()
		var distance = global_position.distance_to(body.global_position)
		var adjusted_range = _adjust_detection_range_for_environment()
		
		print("Monster: Visibility score: ", visibility, " Distance: ", distance, " Adjusted range: ", adjusted_range)
		
		# Only chase if we have good visibility or player is very close
		if visibility > 0.3 or distance <= adjusted_range * 0.5:
			last_known_player_position = body.global_position
			memory_timer = memory_duration
			_change_state(AIState.CHASING)
			
			# Play monster growl when starting chase
			_play_monster_growl()
			
			# Add fear to player
			if body.has_method("add_fear"):
				body.add_fear(20.0)
		else:
			# Player detected but not clearly visible - start stalking
			last_known_player_position = body.global_position
			memory_timer = memory_duration
			_change_state(AIState.STALKING)
			
			# Play monster growl when stalking
			_play_monster_growl()
			
			print("Monster: Player detected but not clearly visible - stalking mode")
	else:
		print("Monster: Not a player, ignoring")

func _on_detection_area_exited(body: Node3D) -> void:
	if body.is_in_group("player") and body == current_target:
		print("Monster: Player left detection area")
		# Don't immediately lose target, keep memory and continue current behavior
		# The memory system will handle when to stop chasing/investigating

func _perform_attack() -> void:
	if current_target and is_instance_valid(current_target):
		var distance = global_position.distance_to(current_target.global_position)
		print("Monster: Attacking player! Distance: ", distance, " Attack range: ", attack_range)
		
		# Play attack animation
		animation_player.play("attack")
		
		# Play monster growl during attack
		_play_monster_growl()
		
		# Damage player
		if current_target.has_method("take_damage"):
			current_target.take_damage(25.0)
			print("Monster: Dealt 25 damage to player")
		
		# Add fear to player
		if current_target.has_method("add_fear"):
			current_target.add_fear(30.0)

# --- Utility Functions ---
func _change_state(new_state: AIState) -> void:
	print("Monster changing state to: ", AIState.keys()[new_state])
	current_state = new_state
	state_timer = 0.0
	
	# Update animation based on state
	match new_state:
		AIState.IDLE:
			_play_animation("idle")
		AIState.PATROLLING:
			_play_animation("walk")
		AIState.CHASING:
			_play_animation("chase")
		AIState.ATTACKING:
			_play_animation("attack")
		AIState.INVESTIGATING:
			_play_animation("walk")
		AIState.STALKING:
			_play_animation("walk")
		AIState.ALERTED:
			_play_animation("walk")

func _generate_default_patrol_points() -> void:
	# Use smart patrol generation instead of simple circle
	patrol_points = _calculate_optimal_patrol_route()
	
	# Fallback to simple circle if smart generation fails
	if patrol_points.is_empty():
		var center = global_position
		patrol_points = [
			center + Vector3(1, 0, 1),    # Scale down for small monster
			center + Vector3(-1, 0, 1),
			center + Vector3(-1, 0, -1),
			center + Vector3(1, 0, -1)
		]
	
	print("Monster: Generated patrol points around ", global_position)

# --- Public Methods ---
func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	print("Monster: Died")
	# Emit death signal
	monster_died.emit(self)
	queue_free()

# Death signal
signal monster_died(monster: Node3D)

# --- Audio Functions ---
func _play_monster_growl() -> void:
	if monster_audio and not monster_audio.playing:
		monster_audio.pitch_scale = randf_range(0.8, 1.2)
		monster_audio.volume_db = -8.0 + randf_range(-2.0, 2.0)
		monster_audio.play()
		print("Monster: Playing growl sound")

# --- Animation Functions ---
func _play_animation(animation_name: String) -> void:
	if animation_player and current_animation != animation_name:
		current_animation = animation_name
		animation_player.play(animation_name)
		print("Monster: Playing animation - ", animation_name)

# --- Enhanced Detection Functions ---
func _check_line_of_sight_to_player() -> bool:
	if not current_target or not is_instance_valid(current_target):
		return false
	
	var space_state = get_world_3d().direct_space_state
	var monster_position = global_position + Vector3(0, 1.5, 0)  # Monster eye level
	var player_position = current_target.global_position + Vector3(0, 1.0, 0)  # Player chest level
	var distance = monster_position.distance_to(player_position)
	
	# Check if player is within line of sight range
	if distance > line_of_sight_range:
		return false
	
	# Create raycast query
	var query = PhysicsRayQueryParameters3D.create(monster_position, player_position)
	query.collision_mask = 1  # Ground and obstacles layer
	query.exclude = [self]  # Exclude self from collision check
	
	var result = space_state.intersect_ray(query)
	
	# If raycast hits something before reaching player, line of sight is blocked
	if result and result.position.distance_to(player_position) > 0.5:
		return false
	
	return true

func _calculate_visibility_score() -> float:
	if not current_target or not is_instance_valid(current_target):
		return 0.0
	
	var base_visibility = 1.0
	
	# Check line of sight
	if not _check_line_of_sight_to_player():
		base_visibility *= 0.1  # Very low visibility if no line of sight
	
	# Apply cover penalty
	if _check_for_cover_between_monster_and_player():
		base_visibility *= cover_detection_penalty
	
	# Apply fog penalty
	base_visibility *= fog_detection_penalty
	
	# Apply light multiplier
	var light_multiplier = _get_player_light_level()
	base_visibility *= light_multiplier
	
	# Apply stealth penalties
	if current_target.has_method("is_crouching"):
		if current_target.is_crouching:
			base_visibility *= stealth_detection_penalty  # Much harder to see when crouching
	
	# Apply flashlight off penalty
	if current_target.has_method("flashlight_on"):
		if not current_target.flashlight_on:
			base_visibility *= flashlight_off_visibility_reduction  # Harder to see in darkness
	
	return clamp(base_visibility, 0.0, 1.0)

func _get_player_light_level() -> float:
	if not current_target or not is_instance_valid(current_target):
		return 1.0
	
	# Check if player has flashlight and if it's on
	if current_target.has_method("flashlight_on"):
		if current_target.flashlight_on:
			return light_detection_multiplier
	
	return 1.0

func _check_for_cover_between_monster_and_player() -> bool:
	if not current_target or not is_instance_valid(current_target):
		return false
	
	var space_state = get_world_3d().direct_space_state
	var monster_position = global_position + Vector3(0, 1.5, 0)
	var player_position = current_target.global_position + Vector3(0, 1.0, 0)
	
	# Check multiple points between monster and player
	var direction = (player_position - monster_position).normalized()
	var distance = monster_position.distance_to(player_position)
	var check_points = 5
	
	for i in range(1, check_points):
		var check_position = monster_position + direction * (distance * i / check_points)
		
		# Raycast from check position to player
		var query = PhysicsRayQueryParameters3D.create(check_position, player_position)
		query.collision_mask = 1
		query.exclude = [self]
		
		var result = space_state.intersect_ray(query)
		if result and result.position.distance_to(player_position) > 0.5:
			return true  # Found cover
	
	return false

# --- Sound Detection System ---
func _update_sound_detection(delta: float) -> void:
	# Decay sound alert level over time
	sound_alert_level = max(0.0, sound_alert_level - delta * 2.0)
	
	# Check for nearby players and their activities
	var tree = get_tree()
	if tree != null:
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			var distance = global_position.distance_to(player.global_position)
			
			if distance <= sound_detection_range:
				# Calculate sound intensity based on player actions
				var sound_intensity = _calculate_player_sound_intensity(player)
				if sound_intensity > 0.0:
					_on_player_movement_detected(player.global_position, sound_intensity)

func _calculate_player_sound_intensity(player: Node3D) -> float:
	var intensity = 0.0
	
	# Check if player is moving
	if player.has_method("velocity"):
		var velocity = player.velocity
		var speed = Vector2(velocity.x, velocity.z).length()
		
		if speed > 0.1:
			intensity += speed * 0.1  # Movement sound
		
		if speed > 3.0:
			intensity += 0.3  # Running sound
	
	# Apply crouching sound reduction
	if player.has_method("is_crouching"):
		if player.is_crouching:
			intensity *= crouch_sound_reduction  # Much quieter when crouching
	
	# Check if player is using flashlight
	if player.has_method("flashlight_on"):
		if player.flashlight_on:
			intensity += 0.1  # Flashlight sound
	
	# Check if player is interacting
	if player.has_method("current_interactable"):
		if player.current_interactable != null:
			intensity += 0.2  # Interaction sound
	
	return intensity

func _on_player_movement_detected(position: Vector3, intensity: float) -> void:
	sound_alert_level = min(1.0, sound_alert_level + intensity)
	
	# If sound is strong enough and we don't have a target, become alerted
	if sound_alert_level > 0.5 and not current_target:
		var tree = get_tree()
		if tree != null:
			var players = tree.get_nodes_in_group("player")
			if players.size() > 0:
				current_target = players[0]
				last_known_player_position = position
				memory_timer = memory_duration
				_change_state(AIState.ALERTED)
				print("Monster: Alerted by sound at position: ", position)

func _on_flashlight_toggled(is_on: bool) -> void:
	if is_on and current_target:
		# Flashlight makes player more visible
		player_light_level = light_detection_multiplier
		print("Monster: Player flashlight turned on - increased visibility")
	else:
		player_light_level = 1.0

func _on_player_interaction_started(interaction_type: String) -> void:
	# Player interaction creates sound
	var interaction_intensity = 0.3  # Base interaction sound
	if "key" in interaction_type.to_lower() or "battery" in interaction_type.to_lower():
		interaction_intensity = 0.5  # Louder for important items
	
	# Get player position and emit movement detection
	var tree = get_tree()
	if tree != null:
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			_on_player_movement_detected(player.global_position, interaction_intensity)

func _calculate_sound_alert_level() -> float:
	return sound_alert_level

func _is_player_stealthy() -> bool:
	if not current_target or not is_instance_valid(current_target):
		return false
	
	var is_stealthy = false
	
	# Check if player is crouching
	if current_target.has_method("is_crouching"):
		if current_target.is_crouching:
			is_stealthy = true
	
	# Check if player has flashlight off
	if current_target.has_method("flashlight_on"):
		if not current_target.flashlight_on:
			is_stealthy = true
	
	# Check if player is moving slowly
	if current_target.has_method("velocity"):
		var velocity = current_target.velocity
		var speed = Vector2(velocity.x, velocity.z).length()
		if speed < 1.0:  # Moving slowly
			is_stealthy = true
	
	return is_stealthy

# --- Environmental Awareness System ---
func _analyze_environment() -> Dictionary:
	var analysis = {
		"tree_density": 0.0,
		"cover_available": false,
		"fog_density": 0.15,  # Default fog density
		"lighting_level": 0.02,  # Default ambient light
		"elevation_change": 0.0
	}
	
	# Analyze tree density around monster
	var space_state = get_world_3d().direct_space_state
	var tree_count = 0
	var directions = 8
	
	for i in range(directions):
		var angle = (i * TAU) / directions
		var direction = Vector3(cos(angle), 0, sin(angle))
		var query = PhysicsRayQueryParameters3D.create(
			global_position + Vector3(0, 1.5, 0),
			global_position + Vector3(0, 1.5, 0) + direction * 10.0
		)
		query.collision_mask = 1
		
		var result = space_state.intersect_ray(query)
		if result:
			var collider = result.get("collider")
			if collider and "Tree" in collider.name:
				tree_count += 1
	
	analysis.tree_density = float(tree_count) / directions
	
	# Check for available cover
	analysis.cover_available = _find_cover_positions().size() > 0
	
	# Get fog density from environment (if available)
	var world_env = get_tree().get_first_node_in_group("world_environment")
	if world_env and world_env.environment:
		analysis.fog_density = world_env.environment.fog_density
	
	return analysis

func _find_cover_positions() -> Array[Vector3]:
	var cover_positions: Array[Vector3] = []
	var space_state = get_world_3d().direct_space_state
	
	# Search for cover in a radius around monster
	var search_radius = 8.0
	var directions = 12
	
	for i in range(directions):
		var angle = (i * TAU) / directions
		var direction = Vector3(cos(angle), 0, sin(angle))
		var search_position = global_position + direction * search_radius
		
		# Check if this position provides cover from player
		if current_target and is_instance_valid(current_target):
			var cover_query = PhysicsRayQueryParameters3D.create(
				search_position + Vector3(0, 1.5, 0),
				current_target.global_position + Vector3(0, 1.0, 0)
			)
			cover_query.collision_mask = 1
			
			var result = space_state.intersect_ray(cover_query)
			if result and result.position.distance_to(current_target.global_position) > 0.5:
				# This position provides cover
				cover_positions.append(search_position)
	
	return cover_positions

func _calculate_optimal_patrol_route() -> Array[Vector3]:
	var route: Array[Vector3] = []
	var center = global_position
	
	# Find areas of interest
	var areas_of_interest = _find_areas_of_interest()
	
	# Create patrol route that includes areas of interest
	for area in areas_of_interest:
		route.append(area)
	
	# Add some random patrol points if not enough areas of interest
	while route.size() < 4:
		var angle = randf() * TAU
		var distance = randf_range(3.0, 8.0)
		var point = center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		route.append(point)
	
	return route

func _find_areas_of_interest() -> Array[Vector3]:
	var areas: Array[Vector3] = []
	
	# Add spawn position as area of interest
	areas.append(global_position)
	
	# Look for key spawners and other important objects
	var tree = get_tree()
	if tree != null:
		var key_spawners = tree.get_nodes_in_group("key_spawner")
		for spawner in key_spawners:
			areas.append(spawner.global_position)
		
		var battery_spawners = tree.get_nodes_in_group("battery_spawner")
		for spawner in battery_spawners:
			areas.append(spawner.global_position)
	
	return areas

func _adjust_detection_range_for_environment() -> float:
	var analysis = _analyze_environment()
	var adjusted_range = detection_range
	
	# Reduce range in dense forest
	if analysis.tree_density > 0.5:
		adjusted_range *= 0.8
	
	# Reduce range in heavy fog
	if analysis.fog_density > 0.2:
		adjusted_range *= 0.7
	
	# Increase range in open areas
	if analysis.tree_density < 0.2:
		adjusted_range *= 1.2
	
	return adjusted_range

# --- Memory and Investigation System ---
func _update_memory_system(delta: float) -> void:
	if memory_timer > 0.0:
		memory_timer -= delta
		
		# If memory expires and we're not currently chasing, start investigating
		if memory_timer <= 0.0 and current_state != AIState.CHASING and current_state != AIState.ATTACKING:
			if last_known_player_position != Vector3.ZERO:
				_start_investigation(last_known_player_position)

func _start_investigation(position: Vector3) -> void:
	investigation_target = position
	investigation_points = _generate_investigation_points(position)
	current_investigation_index = 0
	
	if investigation_points.size() > 0:
		_change_state(AIState.INVESTIGATING)
		print("Monster: Starting investigation at position: ", position)

func _generate_investigation_points(center: Vector3) -> Array[Vector3]:
	var points: Array[Vector3] = []
	
	# Create spiral search pattern
	var spiral_radius = 2.0
	var spiral_spacing = 1.5
	var max_points = 8
	
	for i in range(max_points):
		var angle = i * 0.8  # Spiral angle
		var radius = spiral_radius + (i * spiral_spacing)
		var point = center + Vector3(
			cos(angle) * radius,
			0,
			sin(angle) * radius
		)
		points.append(point)
	
	return points

func _evaluate_investigation_success() -> bool:
	# Check if we found the player during investigation
	if current_target and is_instance_valid(current_target):
		var distance = global_position.distance_to(current_target.global_position)
		var visibility = _calculate_visibility_score()
		
		if distance <= line_of_sight_range and visibility > 0.3:
			return true
	
	return false

func _handle_investigation_state() -> void:
	_play_animation("walk")
	
	if investigation_points.is_empty():
		_change_state(AIState.PATROLLING)
		return
	
	# Move to current investigation point
	var target_point = investigation_points[current_investigation_index]
	var distance_to_point = global_position.distance_to(target_point)
	
	if distance_to_point < 1.5:
		# Reached investigation point, check for player
		if _evaluate_investigation_success():
			print("Monster: Found player during investigation!")
			_change_state(AIState.CHASING)
			return
		
		# Move to next investigation point
		current_investigation_index += 1
		if current_investigation_index >= investigation_points.size():
			# Investigation complete, return to patrol
			print("Monster: Investigation complete, returning to patrol")
			_change_state(AIState.PATROLLING)
			return

func _handle_stalking_state() -> void:
	_play_animation("walk")
	
	if not current_target or not is_instance_valid(current_target):
		_change_state(AIState.PATROLLING)
		return
	
	var distance_to_player = global_position.distance_to(current_target.global_position)
	var visibility = _calculate_visibility_score()
	
	# If we can see the player clearly, switch to chasing
	if visibility > 0.7 and distance_to_player <= line_of_sight_range:
		_change_state(AIState.CHASING)
		return
	
	# If we lose the player completely, start investigating (easier to escape when stealthy)
	if distance_to_player > line_of_sight_range * 1.2 and visibility < 0.3:
		_start_investigation(last_known_player_position)
		print("Monster: Lost player during stalking - starting investigation")
		# Emit escape signal
		Events.player_escaped_from_monster.emit()
		return
	
	# Update cover positions for stalking behavior
	cover_positions = _find_cover_positions()
	
	# Movement is handled by _handle_movement function
	# This state focuses on tactical positioning and cover usage

func _handle_alerted_state() -> void:
	_play_animation("walk")
	
	# Check if we've reached the alert position
	if last_known_player_position != Vector3.ZERO:
		var distance_to_alert = global_position.distance_to(last_known_player_position)
		if distance_to_alert < 2.0:
			# Start investigating the area
			_start_investigation(last_known_player_position)
			return
	
	# If no last known position, return to patrol
	if last_known_player_position == Vector3.ZERO:
		_change_state(AIState.PATROLLING)
