extends Node

# Distant Footsteps Manager
# Controls the random playback of distant footsteps to create atmosphere

@export var min_interval: float = 20.0
@export var max_interval: float = 60.0
@export var volume_variation: float = 5.0
@export var pitch_variation: float = 0.3

var timer: float = 0.0
var footsteps_player: AudioStreamPlayer3D

func _ready():
	# Find the distant footsteps player - try multiple paths
	var horror_ambience = null
	
	# Try to find HorrorAmbience node
	horror_ambience = get_node_or_null("../HorrorAmbience")
	if not horror_ambience:
		horror_ambience = get_node_or_null("../../HorrorAmbience")
	if not horror_ambience:
		horror_ambience = get_node_or_null("../../../HorrorAmbience")
	if not horror_ambience:
		# Search the entire scene tree
		horror_ambience = _find_horror_ambience_in_scene()
	
	if horror_ambience:
		footsteps_player = horror_ambience.get_node_or_null("DistantFootsteps")
		print("Distant Footsteps Manager: Found player at: ", footsteps_player != null)
	else:
		print("ERROR: Distant Footsteps Manager could not find HorrorAmbience node!")
	
	# Set initial random timer
	timer = randf_range(min_interval, max_interval)

func _find_horror_ambience_in_scene() -> Node3D:
	# Search the entire scene tree for HorrorAmbience
	var scene_root = get_tree().current_scene
	if scene_root:
		return _search_for_horror_ambience(scene_root)
	return null

func _search_for_horror_ambience(node: Node) -> Node3D:
	if node.name == "HorrorAmbience":
		return node as Node3D
	
	for child in node.get_children():
		var result = _search_for_horror_ambience(child)
		if result:
			return result
	
	return null

func _process(delta):
	timer -= delta
	
	if timer <= 0.0 and footsteps_player:
		# Play distant footsteps with random variations
		footsteps_player.volume_db = -35.0 + randf_range(-volume_variation, volume_variation)
		footsteps_player.pitch_scale = 0.7 + randf_range(-pitch_variation, pitch_variation)
		footsteps_player.play()
		
		# Set next random timer
		timer = randf_range(min_interval, max_interval)
		
		print("Distant Footsteps Manager: Playing distant footsteps")
