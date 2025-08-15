extends Node

# Ambient Audio Manager
# Controls the timing and random playback of ambient horror sounds

@export var owl_hoot_min_interval: float = 15.0
@export var owl_hoot_max_interval: float = 45.0
@export var wolf_howl_min_interval: float = 30.0
@export var wolf_howl_max_interval: float = 90.0
@export var monster_growl_min_interval: float = 20.0
@export var monster_growl_max_interval: float = 60.0

var owl_timer: float = 0.0
var wolf_timer: float = 0.0
var monster_timer: float = 0.0

var owl_player: AudioStreamPlayer3D
var wolf_player: AudioStreamPlayer3D
var monster_player: AudioStreamPlayer3D

func _ready():
	# Wait a frame to ensure scene is fully loaded
	await get_tree().process_frame
	
	# Find the ambient audio players - try multiple paths
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
		owl_player = horror_ambience.get_node_or_null("OwlHoots")
		wolf_player = horror_ambience.get_node_or_null("WolfHowl")
		# Use RustlingLeaves for horror ambient instead of monster growl
		monster_player = horror_ambience.get_node_or_null("RustlingLeaves")
		
		print("Ambient Audio Manager: Found horror ambience at: ", horror_ambience.get_path())
		print("Owl player: ", owl_player != null)
		print("Wolf player: ", wolf_player != null)
		print("Horror ambient player: ", monster_player != null)
		
		# Test audio players
		if owl_player:
			print("Owl player stream: ", owl_player.stream != null)
		if wolf_player:
			print("Wolf player stream: ", wolf_player.stream != null)
		if monster_player:
			print("Horror ambient player stream: ", monster_player.stream != null)
	else:
		print("ERROR: Ambient Audio Manager could not find HorrorAmbience node!")
	
	# Set initial random timers
	owl_timer = randf_range(owl_hoot_min_interval, owl_hoot_max_interval)
	wolf_timer = randf_range(wolf_howl_min_interval, wolf_howl_max_interval)
	monster_timer = randf_range(monster_growl_min_interval, monster_growl_max_interval)

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
	# Update timers
	owl_timer -= delta
	wolf_timer -= delta
	monster_timer -= delta
	
	# Play owl hoot
	if owl_timer <= 0.0 and owl_player and owl_player.stream:
		owl_player.play()
		owl_timer = randf_range(owl_hoot_min_interval, owl_hoot_max_interval)
		print("Ambient Audio Manager: Playing owl hoot")
	
	# Play wolf howl
	if wolf_timer <= 0.0 and wolf_player and wolf_player.stream:
		wolf_player.play()
		wolf_timer = randf_range(wolf_howl_min_interval, wolf_howl_max_interval)
		print("Ambient Audio Manager: Playing wolf howl")
	
	# Play horror ambient
	if monster_timer <= 0.0 and monster_player and monster_player.stream:
		monster_player.play()
		monster_timer = randf_range(monster_growl_min_interval, monster_growl_max_interval)
		print("Ambient Audio Manager: Playing horror ambient")
