extends Node3D
class_name DoorSpawner

# Spawns an exit door when all keys are collected

@export var door_scene: PackedScene = preload("res://scenes/exit_door.tscn")
@export var spawn_radius: float = 60.0
@export var min_distance_from_player: float = 20.0
@export var max_spawn_attempts: int = 30

var door_spawned: bool = false
var spawned_door: Node3D = null

func _ready():
	# Connect to objective completion events
	Events.objective_completed.connect(_on_objective_completed)
	
	# Add to door spawners group
	add_to_group("door_spawners")

func _on_objective_completed(title: String, reward_message: String):
	print("DEBUG: Objective completed - Title: '", title, "', Reward: '", reward_message, "'")
	print("DEBUG: Door already spawned: ", door_spawned)
	
	# Check if the completed objective is key collection (updated to match actual objective titles)
	var title_lower = title.to_lower()
	if "keys" in title_lower or "escape" in title_lower or "way out" in title_lower or "find the way" in title_lower:
		print("DEBUG: Key collection/escape objective detected!")
		if not door_spawned:
			print("DEBUG: Proceeding to spawn door...")
			_spawn_exit_door()
		else:
			print("DEBUG: Door already spawned, skipping...")
	else:
		print("DEBUG: This objective is not related to key collection - Title: '", title, "'")

func _spawn_exit_door():
	print("Key collection objective completed! Spawning exit door...")
	print("DEBUG: Door spawned status before spawn: ", door_spawned)
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("ERROR: No player found for door spawning")
		return
	
	print("DEBUG: Player position: ", player.global_position)
	var spawn_position = _find_spawn_position(player.global_position)
	if spawn_position == Vector3.ZERO:
		print("ERROR: Failed to find suitable door spawn position after ", max_spawn_attempts, " attempts")
		return
	
	print("DEBUG: Attempting to spawn door at position: ", spawn_position)
	
	# Spawn the door
	spawned_door = door_scene.instantiate()
	get_parent().add_child(spawned_door)
	spawned_door.global_position = spawn_position
	
	door_spawned = true
	print("SUCCESS: Exit door spawned successfully!")
	print("DEBUG: Door global position: ", spawned_door.global_position)
	print("DEBUG: Door spawned status after spawn: ", door_spawned)
	print("DEBUG: Door instance valid: ", is_instance_valid(spawned_door))
	
	# Show notification
	Events.show_pickup_message.emit("An escape route has appeared!")

func _find_spawn_position(player_pos: Vector3) -> Vector3:
	var space_state = get_world_3d().direct_space_state
	print("DEBUG: Looking for door spawn position near player at: ", player_pos)
	print("DEBUG: Spawn radius: ", spawn_radius, ", Min distance: ", min_distance_from_player)
	
	for attempt in range(max_spawn_attempts):
		# Generate random position around the map
		var angle = randf() * TAU
		var distance = randf_range(min_distance_from_player, spawn_radius)
		var potential_pos = player_pos + Vector3(
			cos(angle) * distance,
			0,
			sin(angle) * distance
		)
		
		print("DEBUG: Attempt ", attempt + 1, "/", max_spawn_attempts, " - Testing position: ", potential_pos)
		
		# Raycast down to find ground
		var query = PhysicsRayQueryParameters3D.create(
			potential_pos + Vector3(0, 10, 0),
			potential_pos + Vector3(0, -10, 0)
		)
		query.collision_mask = 1  # Ground layer
		
		var result = space_state.intersect_ray(query)
		if result:
			var ground_pos = result.position
			ground_pos.y += 1.5  # Spawn door slightly above ground
			print("DEBUG: Ground found at: ", ground_pos)
			
			# Check if position is clear (no obstacles nearby) - simplified check
			if _is_position_clear_simple(ground_pos):
				print("DEBUG: Position is clear, using: ", ground_pos)
				return ground_pos
			else:
				print("DEBUG: Position blocked by obstacles")
		else:
			print("DEBUG: No ground found at this position")
	
	print("DEBUG: Failed to find spawn position after all attempts")
	return Vector3.ZERO

func _is_position_clear(pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	
	# Check for obstacles in a smaller radius around the position
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 1.0  # Reduced from 2.0 to be less strict
	query.shape = sphere
	query.transform.origin = pos
	query.collision_mask = 2  # Changed from 1 - avoid ground, only check actual obstacles
	
	var results = space_state.intersect_shape(query)
	
	# Allow small objects like grass, only block on large obstacles
	var blocking_results = 0
	for result in results:
		var collider = result.collider
		if collider and collider.has_method("get_name"):
			var name = collider.name.to_lower()
			# Skip small objects like grass, only count large obstacles
			if not ("grass" in name or "key" in name or "battery" in name):
				blocking_results += 1
	
	print("DEBUG: Position check - Total collisions: ", results.size(), ", Blocking objects: ", blocking_results)
	return blocking_results == 0  # Position is clear if no large blocking objects

func _is_position_clear_simple(pos: Vector3) -> bool:
	# Much simpler check - just make sure we're not inside a tree trunk
	var space_state = get_world_3d().direct_space_state
	
	# Small raycast check around the position
	var clear_count = 0
	var test_positions = [
		pos,
		pos + Vector3(0.5, 0, 0),
		pos + Vector3(-0.5, 0, 0),
		pos + Vector3(0, 0, 0.5),
		pos + Vector3(0, 0, -0.5)
	]
	
	for test_pos in test_positions:
		var query = PhysicsRayQueryParameters3D.create(
			test_pos,
			test_pos + Vector3(0, 0.1, 0)  # Very short ray
		)
		query.collision_mask = 2  # Avoid ground layer
		
		var result = space_state.intersect_ray(query)
		if not result:
			clear_count += 1
	
	# If at least 3 out of 5 positions are clear, accept it
	var is_clear = clear_count >= 3
	print("DEBUG: Simple position check - Clear positions: ", clear_count, "/5, Result: ", is_clear)
	return is_clear
