extends Node

# Random Monster Growls Manager
# Controls the random playback of monster growls for atmosphere

@export var min_interval: float = 45.0
@export var max_interval: float = 120.0
@export var volume_variation: float = 3.0
@export var pitch_variation: float = 0.2

var timer: float = 0.0
var growl_player: AudioStreamPlayer3D

func _ready():
	# Find the monster growl player - try multiple paths
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
		growl_player = horror_ambience.get_node_or_null("CreakingBranches")
		print("Random Monster Growls Manager: Found player at: ", growl_player != null)
	else:
		print("ERROR: Random Monster Growls Manager could not find HorrorAmbience node!")
	
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
	
	if timer <= 0.0 and growl_player:
		# Play monster growl with random variations
		growl_player.volume_db = -25.0 + randf_range(-volume_variation, volume_variation)
		growl_player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
		growl_player.play()
		
		# Set next random timer
		timer = randf_range(min_interval, max_interval)
		
		print("Random Monster Growls Manager: Playing monster growl")
