extends Area3D
class_name ExitDoor

# Exit door that appears after collecting all keys

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@export var door_height: float = 3.0
@export var door_width: float = 2.0
@export var glow_intensity: float = 1.5

signal player_near_exit_door(is_near: bool)

var is_active: bool = true
var game_completed_scene: PackedScene = preload("res://scenes/ui/game_completed.tscn")
var player_near: bool = false

func _ready():
	# Set up the door appearance
	_setup_door_mesh()
	_setup_collision()
	# No interaction prompt setup needed

	# Set collision layer/mask to detect player
	collision_layer = 1
	collision_mask = 2

	# Ensure collision shape is enabled
	collision_shape.disabled = false

	# Connect to player interaction
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _setup_door_mesh():
	# Create a simple door mesh
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(door_width, door_height, 0.2)
	mesh_instance.mesh = box_mesh
	
	# Create glowing green material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.9, 0.5, 0.5)  # Softer green, more transparent
	material.emission_enabled = true
	material.emission = Color(0.2, 0.5, 0.2)  # Less bright emission
	material.emission_energy = glow_intensity * 0.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	mesh_instance.material_override = material

func _setup_collision():
	var box_shape = BoxShape3D.new()
	# Make the collision shape slightly thicker for reliable blocking
	box_shape.size = Vector3(door_width, door_height, 1.0)
	collision_shape.shape = box_shape
	collision_shape.disabled = false
	collision_shape.set_deferred("disabled", false)
	print("[ExitDoor] CollisionShape3D enabled:", not collision_shape.disabled)

func _on_body_entered(body):
	if body.has_method("get_name") and body.name == "Player":
		player_near = true
		emit_signal("player_near_exit_door", true)
		print("Player near exit door - can escape!")

func _on_body_exited(body):
	if body.has_method("get_name") and body.name == "Player":
		player_near = false
		emit_signal("player_near_exit_door", false)

func _process(_delta):
	# Debug: print every frame
	if player_near:
		if Input.is_action_just_pressed("interact"):
			print("[ExitDoor] Interact key pressed while near door!")
		if Input.is_action_just_pressed("interact") and is_active:
			print("[ExitDoor] Escape triggered! Changing to game_completed_scene.")
			_escape_game()

func _escape_game():
	print("Player escaped! Game completed! (Scene transition)")
	# Emit escape event
	Events.player_escaped.emit()
	
	# Get the completion time before switching scenes
	var completion_time = 0.0
	var objective_manager = get_node("../ObjectiveManager")
	
	# If the relative path doesn't work, try to find it in the scene tree
	if not objective_manager:
		var scene_tree = get_tree()
		if scene_tree:
			# Search through all nodes in the scene tree
			var all_nodes = scene_tree.get_nodes_in_group("")
			for node in all_nodes:
				if node.get_class() == "ObjectiveManager":
					objective_manager = node
					break
	
	if objective_manager:
		var completion_stats = objective_manager.get_completion_stats()
		completion_time = completion_stats.get("survival_time", 0.0)
		print("Game completed in: ", completion_time, " seconds")
	else:
		print("WARNING: Could not find ObjectiveManager to get completion time")
	
	# Store the completion time in a global variable or pass it somehow
	# For now, we'll use a simple approach by storing it in the Events autoload
	Events.game_completion_time = completion_time
	
	# Instantly switch to preloaded scene
	get_tree().change_scene_to_packed(game_completed_scene)
