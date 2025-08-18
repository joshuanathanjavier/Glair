extends Node3D
class_name MonsterSpawner

# Configuration for spawning monsters randomly throughout the forest
@export var monster_scene: PackedScene = preload("res://scenes/character/creepy_monster.tscn")
@export var spawn_count: int = 5  # Spawn 5 monsters
@export var spawn_radius: float = 120.0  # Large radius to spread across map
@export var min_distance_from_player: float = 30.0  # Don't spawn too close to player
@export var max_distance_from_player: float = 100.0  # Don't spawn too far from player
@export var spawn_height_offset: float = 1.0  # Spawn slightly above ground
@export var max_spawn_attempts: int = 100

# Map-wide spawning settings
@export_group("Map Coverage")
@export var use_multiple_zones: bool = true
@export var zone_count: int = 3  # Fewer zones for monster
@export var zone_radius: float = 40.0
@export var min_zone_distance: float = 50.0

# Placement settings
@export_group("Placement Logic")
@export var prefer_hidden_spots: bool = true
@export var avoid_open_areas: bool = true
@export var place_near_trees: bool = true
@export var tree_detection_distance: float = 8.0
@export var max_raycast_distance: float = 25.0
@export var avoid_player_start_area: bool = true
@export var player_start_safe_radius: float = 20.0

var spawned_monsters: Array[Node3D] = []
var spawn_zones: Array[Vector3] = []
var player_start_position: Vector3 = Vector3.ZERO

func _ready():
	# Add to monster spawners group for communication
	add_to_group("monster_spawners")
	
	print("=== MONSTER SPAWNER INITIALIZED ===")
	print("📍 Spawner position: ", global_position)
	print("🎯 Spawn count: ", spawn_count)
	print("📏 Spawn radius: ", spawn_radius)
	print("🌍 Zone count: ", zone_count)
	print("🛡️ Player safe radius: ", player_start_safe_radius)
	print("🌳 Prefer hidden spots: ", prefer_hidden_spots)
	print("🌲 Place near trees: ", place_near_trees)
	
	# Find player start position
	_find_player_start_position()
	
	# Spawn monsters after a short delay to ensure the level is loaded
	call_deferred("setup_spawn_zones")
	call_deferred("spawn_monsters")

func _find_player_start_position():
	var tree = get_tree()
	if tree != null:
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			player_start_position = players[0].global_position
			print("🎮 Found player at start position: ", player_start_position)
			print("📏 Distance from spawner: ", player_start_position.distance_to(global_position))
		else:
			# Default to origin if no player found
			player_start_position = Vector3.ZERO
			print("⚠️ No player found, using origin as player start position")
			print("📍 Player start position set to: ", player_start_position)

func setup_spawn_zones():
	if use_multiple_zones:
		print("Setting up ", zone_count, " monster spawn zones...")
		_generate_spawn_zones()
	else:
		# Single zone at spawner position
		spawn_zones = [global_position]

func _generate_spawn_zones():
	spawn_zones.clear()
	var attempts = 0
	var max_zone_attempts = zone_count * 15
	
	print("=== GENERATING MONSTER SPAWN ZONES ===")
	print("🎯 Target zones: ", zone_count)
	print("📍 Spawner position: ", global_position)
	print("🛡️ Player safe radius: ", player_start_safe_radius)
	
	while spawn_zones.size() < zone_count and attempts < max_zone_attempts:
		attempts += 1
		
		# Generate random zone position around the map
		var angle = randf() * TAU
		var distance = randf_range(min_zone_distance, spawn_radius * 0.8)
		var zone_pos = global_position + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Check if zone is far enough from player start area
		if avoid_player_start_area:
			if zone_pos.distance_to(player_start_position) < player_start_safe_radius:
				continue
		
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
				print("✅ Created monster spawn zone #", spawn_zones.size(), " at: ", zone_pos)
				print("   📏 Distance from spawner: ", zone_pos.distance_to(global_position))
				print("   🎮 Distance from player start: ", zone_pos.distance_to(player_start_position))
	
	print("=== ZONE GENERATION COMPLETE ===")
	print("✅ Generated ", spawn_zones.size(), " monster spawn zones")
	print("📊 Zone generation attempts: ", attempts)
	
	# Show all zone coordinates
	for i in range(spawn_zones.size()):
		print("   Zone ", i + 1, ": ", spawn_zones[i])

func spawn_monsters():
	print("=== MONSTER SPAWNING STARTED ===")
	print("Attempting to spawn ", spawn_count, " monsters across ", spawn_zones.size(), " zones...")
	
	if spawn_zones.is_empty():
		print("❌ ERROR: No spawn zones available!")
		return
	
	var monsters_spawned = 0
	var attempts = 0
	var max_total_attempts = spawn_count * 50
	
	while monsters_spawned < spawn_count and attempts < max_total_attempts:
		attempts += 1
		
		# Select a random spawn zone
		var selected_zone = spawn_zones[randi() % spawn_zones.size()]
		
		# Find a valid spawn position in this zone
		var spawn_position = _find_monster_spawn_position_in_zone(selected_zone)
		
		if spawn_position != Vector3.INF:
			# Create and spawn the monster
			var monster_instance = monster_scene.instantiate()
			get_tree().current_scene.add_child(monster_instance)
			monster_instance.global_position = spawn_position
			
			# Initialize the monster with the spawn position
			if monster_instance.has_method("initialize_spawned_monster"):
				monster_instance.initialize_spawned_monster(spawn_position)
			
			# Connect to monster events
			_connect_to_monster_events(monster_instance)
			
			spawned_monsters.append(monster_instance)
			monsters_spawned += 1
			
			print("✅ MONSTER SPAWNED SUCCESSFULLY!")
			print("   📍 Position: ", spawn_position)
			print("   🎯 Zone: ", selected_zone)
			print("   🔢 Monster ID: ", monsters_spawned)
			print("   📊 Total spawned: ", monsters_spawned, "/", spawn_count)
		else:
			print("❌ Failed to find valid spawn position in zone: ", selected_zone)
	
	print("=== MONSTER SPAWNING COMPLETE ===")
	print("✅ Successfully spawned ", monsters_spawned, " monsters")
	print("📊 Spawn attempts: ", attempts)
	
	# Emit signal when spawning is complete
	Events.random_spawning_complete.emit()

func _find_monster_spawn_position_in_zone(zone_center: Vector3) -> Vector3:
	var world_space = get_world_3d().direct_space_state
	
	for i in range(25):  # Try multiple positions per zone
		# Generate random position within zone
		var angle = randf() * TAU
		var distance = randf() * zone_radius
		var base_position = zone_center + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Raycast down to find ground
		var ground_position = _find_ground_position(base_position)
		if ground_position == Vector3.INF:
			continue
		
		# Check if position is valid (not too close to player start)
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
	# Check distance from player start area
	if avoid_player_start_area:
		if position.distance_to(player_start_position) < player_start_safe_radius:
			return false
	
	# Check distance from other monsters
	for monster in spawned_monsters:
		if monster and is_instance_valid(monster):
			if position.distance_to(monster.global_position) < 20.0:  # Minimum distance between monsters
				return false
	
	# Check if not too close to spawn zone centers
	for zone in spawn_zones:
		if position.distance_to(zone) < 5.0:
			return false
	
	return true

func _check_for_nearby_trees(position: Vector3) -> bool:
	var world_space = get_world_3d().direct_space_state
	
	# Check in multiple directions for trees
	var directions = 8
	for i in range(directions):
		var angle = (i * TAU) / directions
		var direction = Vector3(cos(angle), 0, sin(angle))
		var query = PhysicsRayQueryParameters3D.create(
			position + Vector3(0, 1.5, 0),
			position + Vector3(0, 1.5, 0) + direction * tree_detection_distance
		)
		query.collision_mask = 1
		
		var result = world_space.intersect_ray(query)
		if result:
			var collider = result.get("collider")
			if collider and ("Tree" in collider.name or "Pine" in collider.name):
				return true
	
	return false

# Public method to respawn monster if needed
func respawn_monster():
	print("🔄 Monster Spawner: Attempting to respawn monster...")
	print("📊 Current monster count: ", spawned_monsters.size(), "/", spawn_count)
	
	if spawned_monsters.size() < spawn_count:
		print("✅ Respawning monster...")
		spawn_monsters()
	else:
		print("❌ No respawn needed - monster count at maximum")

# Public method to get current monster count
func get_monster_count() -> int:
	return spawned_monsters.size()

# Public method to get all spawned monsters
func get_spawned_monsters() -> Array[Node3D]:
	return spawned_monsters

# Handle monster death and respawning
func _on_monster_died(monster: Node3D):
	print("💀 Monster Spawner: Monster died, will respawn after delay")
	print("📍 Dead monster position was: ", monster.global_position)
	
	# Remove from spawned monsters list
	if monster in spawned_monsters:
		spawned_monsters.erase(monster)
		print("📊 Remaining monsters: ", spawned_monsters.size())
	
	# Respawn after a delay
	await get_tree().create_timer(10.0).timeout  # 10 second delay
	print("🔄 Monster Spawner: Respawn timer expired, spawning new monster...")
	respawn_monster()

# Connect to monster death events
func _connect_to_monster_events(monster: Node3D):
	if monster.has_signal("monster_died"):
		monster.monster_died.connect(_on_monster_died)
	elif monster.has_method("connect_death_signal"):
		monster.connect_death_signal(_on_monster_died)
