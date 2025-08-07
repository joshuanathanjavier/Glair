extends CharacterBody3D

# --- Monster Configuration ---
@export var patrol_speed: float = 2.0
@export var chase_speed: float = 4.5
@export var detection_range: float = 15.0
@export var attack_range: float = 1.5
@export var max_health: float = 100.0

# --- AI States ---
enum AIState {
	IDLE,
	PATROLLING,
	CHASING,
	ATTACKING
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

# --- Node References ---
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var model: Node3D = $MonsterModel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
	
	# Start patrolling
	_change_state(AIState.PATROLLING)
	
	# Start with idle animation
	_play_animation("idle")

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
		
		# Manual detection as backup
		var tree = get_tree()
		if tree != null:
			var players = tree.get_nodes_in_group("player")
			if players.size() > 0:
				var player = players[0]
				var distance = global_position.distance_to(player.global_position)
				print("Manual check - Player distance: ", distance, " Detection range: ", detection_range)
				if distance <= detection_range and current_state == AIState.PATROLLING:
					print("Manual detection triggered!")
					current_target = player
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

func _handle_idle_state() -> void:
	_play_animation("idle")
	if state_timer > 2.0:
		_change_state(AIState.PATROLLING)

func _handle_patrol_state() -> void:
	_play_animation("walk")
	
	if patrol_points.is_empty():
		print("Monster: No patrol points!")
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

func _handle_chase_state() -> void:
	_play_animation("chase")
	
	if current_target and is_instance_valid(current_target):
		var distance_to_player = global_position.distance_to(current_target.global_position)
		
		# Attack if close enough
		if distance_to_player <= attack_range:
			_change_state(AIState.ATTACKING)
		# Lose target if too far
		elif distance_to_player > detection_range * 2.0:
			current_target = null
			_change_state(AIState.PATROLLING)
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
	
	# Get target position based on state
	if current_state == AIState.CHASING and current_target:
		target_position = current_target.global_position
	elif current_state == AIState.ATTACKING and current_target:
		# Keep moving towards player even while attacking
		target_position = current_target.global_position
	elif current_state == AIState.PATROLLING and not patrol_points.is_empty():
		target_position = patrol_points[current_patrol_index]
	else:
		velocity.x = 0
		velocity.z = 0
		return
	
	# Calculate direction to target (simple direct movement)
	var direction = (target_position - global_position).normalized()
	direction.y = 0  # Only move horizontally
	
	var speed = chase_speed if (current_state == AIState.CHASING or current_state == AIState.ATTACKING) else patrol_speed
	
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
		print("Monster: Player detected!")
		current_target = body
		_change_state(AIState.CHASING)
		
		# Add fear to player
		if body.has_method("add_fear"):
			body.add_fear(20.0)
	else:
		print("Monster: Not a player, ignoring")

func _on_detection_area_exited(body: Node3D) -> void:
	if body.is_in_group("player") and body == current_target:
		print("Monster: Player lost")
		# Don't immediately lose target, keep chasing for a bit

func _perform_attack() -> void:
	if current_target and is_instance_valid(current_target):
		var distance = global_position.distance_to(current_target.global_position)
		print("Monster: Attacking player! Distance: ", distance, " Attack range: ", attack_range)
		
		# Play attack animation
		animation_player.play("attack")
		
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

func _generate_default_patrol_points() -> void:
	var center = global_position
	patrol_points = [
		center + Vector3(1, 0, 1),    # Scale down for small monster
		center + Vector3(-1, 0, 1),
		center + Vector3(-1, 0, -1),
		center + Vector3(1, 0, -1)
	]
	print("Monster: Generated patrol points around ", center)

# --- Public Methods ---
func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	print("Monster: Died")
	queue_free()

# --- Animation Functions ---
func _play_animation(animation_name: String) -> void:
	if animation_player and current_animation != animation_name:
		current_animation = animation_name
		animation_player.play(animation_name)
		print("Monster: Playing animation - ", animation_name)
