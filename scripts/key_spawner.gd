extends Node3D
class_name KeySpawner

# Configuration for spawning keys throughout the forest
@export var key_scene: PackedScene = preload("res://scenes/key_pickup.tscn")
@export var spawn_count: int = 10
@export var spawn_radius: float = 80.0
@export var min_distance_between_keys: float = 15.0
@export var spawn_height_offset: float = 0.8  # Keys spawn higher than batteries
@export var max_spawn_attempts: int = 50

# Map-wide spawning settings
@export_group("Map Coverage")
@export var use_multiple_zones: bool = true
@export var zone_count: int = 5
@export var zone_radius: float = 25.0
@export var min_zone_distance: float = 30.0

# Placement settings
@export_group("Placement Logic")
@export var prefer_hidden_spots: bool = true
@export var avoid_open_areas: bool = true
@export var place_near_trees: bool = true
@export var tree_detection_distance: float = 5.0
@export var max_raycast_distance: float = 20.0

var spawned_keys: Array[Node3D] = []
var spawn_zones: Array[Vector3] = []
var keys_remaining: int = 0

func _ready():
	# Add to key spawners group for communication
	add_to_group("key_spawners")
	
	# Connect to key pickup events
	Events.key_collected.connect(_on_key_collected)
	
	# Spawn keys after a short delay to ensure the level is loaded
	call_deferred("setup_spawn_zones")
	call_deferred("spawn_keys")

func setup_spawn_zones():
	if use_multiple_zones:
		print("Setting up ", zone_count, " key spawn zones...")
		_generate_spawn_zones()
	else:
		# Single zone at spawner position
		spawn_zones = [global_position]

func _generate_spawn_zones():
	spawn_zones.clear()
	var attempts = 0
	var max_zone_attempts = zone_count * 10
	
	# Always include the spawner position as first zone
	spawn_zones.append(global_position)
	
	while spawn_zones.size() < zone_count and attempts < max_zone_attempts:
		attempts += 1
		
		# Generate random zone position
		var angle = randf() * TAU
		var distance = randf_range(min_zone_distance, spawn_radius * 0.9)
		var zone_pos = global_position + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Check if zone is far enough from other zones
		var valid_zone = true
		for existing_zone in spawn_zones:
			if zone_pos.distance_to(existing_zone) < min_zone_distance:
				valid_zone = false
				break
		
		if valid_zone:
			# Check if zone has valid ground
			var ground_pos = _find_ground_position(zone_pos)
			if ground_pos != Vector3.INF:
				spawn_zones.append(zone_pos)
				print("Created key spawn zone at: ", zone_pos)
	
	print("Generated ", spawn_zones.size(), " key spawn zones")

func spawn_keys():
	print("Spawning ", spawn_count, " keys across ", spawn_zones.size(), " zones...")
	
	var spawned_count = 0
	var keys_per_zone = spawn_count / spawn_zones.size()
	var remaining_keys = spawn_count % spawn_zones.size()
	
	# Distribute keys across zones
	for i in range(spawn_zones.size()):
		var zone_center = spawn_zones[i]
		var zone_key_count = keys_per_zone
		
		# Add remaining keys to first zones
		if i < remaining_keys:
			zone_key_count += 1
		
		print("Spawning ", zone_key_count, " keys in zone ", i + 1)
		
		# Spawn keys for this zone
		var zone_spawned = 0
		var zone_attempts = 0
		
		while zone_spawned < zone_key_count and zone_attempts < max_spawn_attempts:
			zone_attempts += 1
			
			var spawn_position = _find_key_spawn_position_in_zone(zone_center)
			if spawn_position != Vector3.INF:
				_spawn_key_at_position(spawn_position, spawned_count + 1)
				zone_spawned += 1
				spawned_count += 1
				print("Spawned key ", spawned_count, " at ", spawn_position)
	
	keys_remaining = spawned_count
	print("Key spawning complete. Spawned ", spawned_count, " out of ", spawn_count, " keys.")

func _find_key_spawn_position_in_zone(zone_center: Vector3) -> Vector3:
	var world_space = get_world_3d().direct_space_state
	
	for i in range(20):  # Try multiple positions per zone
		# Generate random position within zone
		var angle = randf() * TAU
		var distance = randf() * zone_radius
		var base_position = zone_center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Raycast down to find ground
		var ground_position = _find_ground_position(base_position)
		if ground_position == Vector3.INF:
			continue
		
		# Check if position is valid (not too close to other keys)
		if not _is_position_valid(ground_position):
			continue
		
		# If we want hidden placement, check for trees/cover
		if prefer_hidden_spots and place_near_trees:
			var tree_nearby = _check_for_nearby_trees(ground_position)
			if not tree_nearby and i < 15:  # Give preference to hidden spots
				continue
		
		return ground_position + Vector3(0, spawn_height_offset, 0)
	
	return Vector3.INF  # Failed to find position

func _find_ground_position(start_position: Vector3) -> Vector3:
	var world_space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		start_position + Vector3(0, 20, 0),  # Start higher
		start_position + Vector3(0, -20, 0)  # Raycast down
	)
	query.collision_mask = 1  # Ground layer
	
	var result = world_space.intersect_ray(query)
	if result:
		return result.position
	
	return Vector3.INF

func _is_position_valid(position: Vector3) -> bool:
	# Check distance from other keys
	for key in spawned_keys:
		if key and is_instance_valid(key):
			if position.distance_to(key.global_position) < min_distance_between_keys:
				return false
	
	# Check if not too close to spawn zone centers
	for zone in spawn_zones:
		if position.distance_to(zone) < 5.0:
			return false
	
	return true

func _check_for_nearby_trees(position: Vector3) -> bool:
	var world_space = get_world_3d().direct_space_state
	var directions = [
		Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT,
		Vector3.FORWARD + Vector3.LEFT, Vector3.FORWARD + Vector3.RIGHT,
		Vector3.BACK + Vector3.LEFT, Vector3.BACK + Vector3.RIGHT
	]
	
	for direction in directions:
		var query = PhysicsRayQueryParameters3D.create(
			position + Vector3(0, 1.0, 0),  # Start above ground
			position + Vector3(0, 1.0, 0) + direction.normalized() * tree_detection_distance
		)
		query.collision_mask = 1  # Should detect trees/walls
		
		var result = world_space.intersect_ray(query)
		if result:
			return true  # Found cover nearby
	
	return false

func _spawn_key_at_position(position: Vector3, key_number: int):
	if not key_scene:
		print("Error: Key scene not set!")
		return
	
	var key_instance = key_scene.instantiate()
	get_tree().current_scene.add_child(key_instance)
	key_instance.global_position = position
	
	# Set unique key ID
	key_instance.key_id = key_number
	key_instance.interaction_text = "Press E to pick up key " + str(key_number)
	
	# Add some random rotation for realism
	key_instance.rotation_degrees.y = randf() * 360
	
	spawned_keys.append(key_instance)

func _on_key_collected():
	keys_remaining -= 1
	print("Key collected! Keys remaining: ", keys_remaining)
	
	if keys_remaining <= 0:
		print("All keys collected! Player can now escape!")
		# Could trigger escape route activation here

# Utility functions
func get_keys_remaining() -> int:
	return keys_remaining

func get_keys_collected() -> int:
	return spawn_count - keys_remaining

# Clean up function
func clear_all_keys():
	for key in spawned_keys:
		if key and is_instance_valid(key):
			key.queue_free()
	spawned_keys.clear()
	keys_remaining = 0
