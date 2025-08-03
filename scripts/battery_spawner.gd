extends Node3D
class_name BatterySpawner

# Configuration for spawning batteries realistically around the environment
@export var battery_scene: PackedScene = preload("res://scenes/battery_pickup.tscn")
@export var spawn_count: int = 15
@export var spawn_radius: float = 100.0
@export var min_distance_between_batteries: float = 8.0
@export var spawn_height_offset: float = 0.5  # How high above ground to spawn
@export var max_spawn_attempts: int = 100

# Map-wide spawning settings
@export_group("Map Coverage")
@export var use_multiple_zones: bool = true
@export var zone_count: int = 4
@export var zone_radius: float = 30.0
@export var min_zone_distance: float = 40.0

# Respawn system settings
@export_group("Respawn System")
@export var enable_respawn: bool = true
@export var respawn_delay: float = 10.0  # Seconds before respawning
@export var maintain_battery_count: bool = true
@export var respawn_in_different_zone: bool = true

# Realistic placement settings
@export_group("Placement Logic")
@export var prefer_corners: bool = true
@export var avoid_open_areas: bool = true
@export var place_near_walls: bool = true
@export var wall_detection_distance: float = 3.0
@export var max_raycast_distance: float = 20.0

var spawned_batteries: Array[Node3D] = []
var spawn_zones: Array[Vector3] = []
var active_battery_count: int = 0
var respawn_timers: Array[float] = []

func _ready():
	# Add to battery spawners group for communication
	add_to_group("battery_spawners")
	
	# Connect to battery pickup events
	Events.battery_pickup_collected.connect(_on_battery_picked_up)
	
	# Spawn batteries after a short delay to ensure the level is loaded
	call_deferred("setup_spawn_zones")
	call_deferred("spawn_batteries")

func setup_spawn_zones():
	if use_multiple_zones:
		print("Setting up ", zone_count, " spawn zones...")
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
		var distance = randf_range(min_zone_distance, spawn_radius * 0.8)
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
				print("Created spawn zone at: ", zone_pos)
	
	print("Generated ", spawn_zones.size(), " spawn zones")

func _process(delta):
	# Handle respawn timers
	if enable_respawn:
		_update_respawn_timers(delta)

func spawn_batteries():
	print("Spawning ", spawn_count, " batteries across ", spawn_zones.size(), " zones...")
	
	var attempts = 0
	var spawned_count = 0
	var batteries_per_zone = spawn_count / spawn_zones.size()
	var remaining_batteries = spawn_count % spawn_zones.size()
	
	# Distribute batteries across zones
	for i in range(spawn_zones.size()):
		var zone_center = spawn_zones[i]
		var zone_battery_count = batteries_per_zone
		
		# Add remaining batteries to first zones
		if i < remaining_batteries:
			zone_battery_count += 1
		
		print("Spawning ", zone_battery_count, " batteries in zone ", i + 1)
		
		# Spawn batteries for this zone
		var zone_spawned = 0
		var zone_attempts = 0
		
		while zone_spawned < zone_battery_count and zone_attempts < max_spawn_attempts:
			zone_attempts += 1
			attempts += 1
			
			var spawn_position = _find_realistic_spawn_position_in_zone(zone_center)
			if spawn_position != Vector3.INF:
				_spawn_battery_at_position(spawn_position)
				zone_spawned += 1
				spawned_count += 1
				active_battery_count += 1
				print("Spawned battery ", spawned_count, " at ", spawn_position)
	
	print("Battery spawning complete. Spawned ", spawned_count, " out of ", spawn_count, " batteries across ", spawn_zones.size(), " zones.")

func _find_realistic_spawn_position_in_zone(zone_center: Vector3) -> Vector3:
	var world_space = get_world_3d().direct_space_state
	
	for i in range(15):  # Try multiple positions per zone
		# Generate random position within zone
		var angle = randf() * TAU
		var distance = randf() * zone_radius
		var base_position = zone_center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Raycast down to find ground
		var ground_position = _find_ground_position(base_position)
		if ground_position == Vector3.INF:
			continue
		
		# Check if position is valid (not too close to other batteries)
		if not _is_position_valid(ground_position):
			continue
		
		# If we want realistic placement, check for walls/corners
		if prefer_corners or place_near_walls:
			var wall_nearby = _check_for_nearby_walls(ground_position)
			if place_near_walls and not wall_nearby:
				# Try a few more times before giving up on wall requirement
				if i < 10:
					continue
		
		return ground_position + Vector3(0, spawn_height_offset, 0)
	
	return Vector3.INF  # Failed to find position in this zone

func _find_realistic_spawn_position() -> Vector3:
	var world_space = get_world_3d().direct_space_state
	
	for i in range(10):  # Try multiple positions
		# Generate random position in radius
		var angle = randf() * TAU
		var distance = randf() * spawn_radius
		var base_position = global_position + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Raycast down to find ground
		var ground_position = _find_ground_position(base_position)
		if ground_position == Vector3.INF:
			continue
		
		# Check if position is valid (not too close to other batteries)
		if not _is_position_valid(ground_position):
			continue
		
		# If we want realistic placement, check for walls/corners
		if prefer_corners or place_near_walls:
			var wall_nearby = _check_for_nearby_walls(ground_position)
			if place_near_walls and not wall_nearby:
				continue
		
		return ground_position + Vector3(0, spawn_height_offset, 0)
	
	return Vector3.INF  # Failed to find position

func _find_ground_position(start_position: Vector3) -> Vector3:
	var world_space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		start_position + Vector3(0, 20, 0),  # Start higher for larger maps
		start_position + Vector3(0, -20, 0)  # Raycast down further
	)
	query.collision_mask = 1  # Ground layer
	
	var result = world_space.intersect_ray(query)
	if result:
		return result.position
	
	return Vector3.INF

func _is_position_valid(position: Vector3) -> bool:
	# Check distance from other batteries
	for battery in spawned_batteries:
		if battery and is_instance_valid(battery):
			if position.distance_to(battery.global_position) < min_distance_between_batteries:
				return false
	
	# Check if not too close to any spawn zone center (but allow some proximity)
	for zone in spawn_zones:
		if position.distance_to(zone) < 3.0:
			return false
	
	return true

func _check_for_nearby_walls(position: Vector3) -> bool:
	var world_space = get_world_3d().direct_space_state
	var directions = [
		Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT
	]
	
	for direction in directions:
		var query = PhysicsRayQueryParameters3D.create(
			position + Vector3(0, 0.5, 0),  # Start slightly above ground
			position + Vector3(0, 0.5, 0) + direction * wall_detection_distance
		)
		query.collision_mask = 1  # Wall layer
		
		var result = world_space.intersect_ray(query)
		if result:
			return true  # Found a wall nearby
	
	return false

func _spawn_battery_at_position(position: Vector3):
	if not battery_scene:
		print("Error: Battery scene not set!")
		return
	
	var battery_instance = battery_scene.instantiate()
	get_tree().current_scene.add_child(battery_instance)
	battery_instance.global_position = position
	
	# Add some random rotation for realism
	battery_instance.rotation_degrees.y = randf() * 360
	
	# Randomize battery charge amount
	var charge_variants = [15.0, 25.0, 35.0, 50.0]  # Different battery types
	battery_instance.battery_charge = charge_variants[randi() % charge_variants.size()]
	
	# Update interaction text based on charge
	var charge_text = str(int(battery_instance.battery_charge)) + "%"
	battery_instance.interaction_text = "Press E to pick up battery (" + charge_text + ")"
	
	spawned_batteries.append(battery_instance)

# Function to manually spawn a battery at a specific location
func spawn_battery_at(position: Vector3, charge: float = 25.0):
	var battery_instance = battery_scene.instantiate()
	get_tree().current_scene.add_child(battery_instance)
	battery_instance.global_position = position
	battery_instance.battery_charge = charge
	
	var charge_text = str(int(charge)) + "%"
	battery_instance.interaction_text = "Press E to pick up battery (" + charge_text + ")"
	
	spawned_batteries.append(battery_instance)

# Function to manually add spawn zones for complex maps
func add_spawn_zone(position: Vector3):
	spawn_zones.append(position)
	print("Added manual spawn zone at: ", position)

# Function to set up batteries across the entire map bounds
func setup_map_wide_spawning(map_bounds_min: Vector3, map_bounds_max: Vector3):
	spawn_zones.clear()
	use_multiple_zones = true
	
	# Calculate map size
	var map_size = map_bounds_max - map_bounds_min
	var map_center = (map_bounds_min + map_bounds_max) * 0.5
	
	# Create grid of spawn zones across the map
	var zones_per_axis = max(2, int(sqrt(zone_count)))
	var zone_spacing_x = map_size.x / zones_per_axis
	var zone_spacing_z = map_size.z / zones_per_axis
	
	for x in range(zones_per_axis):
		for z in range(zones_per_axis):
			if spawn_zones.size() >= zone_count:
				break
			
			var zone_pos = map_bounds_min + Vector3(
				x * zone_spacing_x + zone_spacing_x * 0.5,
				0,
				z * zone_spacing_z + zone_spacing_z * 0.5
			)
			
			# Verify this zone has valid ground
			var ground_pos = _find_ground_position(zone_pos)
			if ground_pos != Vector3.INF:
				spawn_zones.append(zone_pos)
				print("Added map-wide zone at: ", zone_pos)
	
	print("Set up ", spawn_zones.size(), " zones for map-wide spawning")

# Debug function to visualize spawn zones
func debug_show_spawn_zones():
	for i in range(spawn_zones.size()):
		var zone = spawn_zones[i]
		print("Zone ", i + 1, ": ", zone)
		
		# You can add debug spheres here if needed
		# var debug_sphere = preload("res://debug/debug_sphere.tscn").instantiate()
		# get_tree().current_scene.add_child(debug_sphere)
		# debug_sphere.global_position = zone

# Clean up function
func clear_all_batteries():
	for battery in spawned_batteries:
		if battery and is_instance_valid(battery):
			battery.queue_free()
	spawned_batteries.clear()
	active_battery_count = 0

# --- Respawn System ---
func _on_battery_picked_up(charge_amount: float):
	if not enable_respawn:
		return
	
	active_battery_count -= 1
	print("Battery picked up. Active count: ", active_battery_count)
	
	if maintain_battery_count:
		# Add respawn timer
		respawn_timers.append(respawn_delay)
		print("Battery will respawn in ", respawn_delay, " seconds")

func _update_respawn_timers(delta: float):
	var i = 0
	while i < respawn_timers.size():
		respawn_timers[i] -= delta
		
		if respawn_timers[i] <= 0.0:
			# Time to respawn a battery
			_respawn_battery()
			respawn_timers.remove_at(i)
		else:
			i += 1

func _respawn_battery():
	print("Attempting to respawn battery...")
	
	var respawn_position = Vector3.INF
	var attempts = 0
	var max_respawn_attempts = 30
	
	# Try to find a new spawn position
	while respawn_position == Vector3.INF and attempts < max_respawn_attempts:
		attempts += 1
		
		if respawn_in_different_zone and spawn_zones.size() > 1:
			# Choose a random zone that doesn't have too many batteries
			var zone_index = _find_best_respawn_zone()
			var zone_center = spawn_zones[zone_index]
			respawn_position = _find_realistic_spawn_position_in_zone(zone_center)
		else:
			# Use any valid spawn position
			if spawn_zones.size() > 0:
				var random_zone = spawn_zones[randi() % spawn_zones.size()]
				respawn_position = _find_realistic_spawn_position_in_zone(random_zone)
	
	if respawn_position != Vector3.INF:
		_spawn_battery_at_position(respawn_position)
		active_battery_count += 1
		print("Battery respawned at: ", respawn_position, " (Active count: ", active_battery_count, ")")
		
		# Show respawn notification to player
		Events.show_pickup_message.emit("New battery appeared somewhere...")
	else:
		print("Failed to find respawn location after ", max_respawn_attempts, " attempts")
		# Retry after a short delay
		respawn_timers.append(5.0)

func _find_best_respawn_zone() -> int:
	# Count batteries in each zone and find the zone with fewest batteries
	var zone_battery_counts = []
	
	for i in range(spawn_zones.size()):
		zone_battery_counts.append(0)
	
	# Count batteries per zone
	for battery in spawned_batteries:
		if battery and is_instance_valid(battery):
			var closest_zone_index = _find_closest_zone(battery.global_position)
			if closest_zone_index >= 0:
				zone_battery_counts[closest_zone_index] += 1
	
	# Find zone with minimum batteries (prefer zones with fewer batteries)
	var available_zones = []
	var min_count = zone_battery_counts.min()
	
	for i in range(zone_battery_counts.size()):
		if zone_battery_counts[i] == min_count:
			available_zones.append(i)
	
	# Return random zone from the ones with minimum batteries
	return available_zones[randi() % available_zones.size()]

func _find_closest_zone(position: Vector3) -> int:
	var closest_distance = INF
	var closest_index = -1
	
	for i in range(spawn_zones.size()):
		var distance = position.distance_to(spawn_zones[i])
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i
	
	return closest_index

# --- Utility Functions ---
func get_active_battery_count() -> int:
	return active_battery_count

func set_respawn_enabled(enabled: bool):
	enable_respawn = enabled

func set_respawn_delay(delay: float):
	respawn_delay = delay

func force_respawn_battery():
	if active_battery_count < spawn_count:
		_respawn_battery()

# Function to remove battery from spawned list (called when battery is destroyed)
func remove_battery_from_list(battery_instance):
	var index = spawned_batteries.find(battery_instance)
	if index >= 0:
		spawned_batteries.remove_at(index)
		print("Removed battery from spawned list. List size: ", spawned_batteries.size())
