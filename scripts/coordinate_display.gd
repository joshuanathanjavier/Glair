extends Control
class_name CoordinateDisplay

# Simple coordinate display for debugging

@onready var coordinate_label: Label = $CoordinateLabel

var player: Node3D = null

func _ready():
	# Find the player
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("CoordinateDisplay: No player found")
		visible = false

func _process(_delta):
	if player and is_instance_valid(player):
		var pos = player.global_position
		coordinate_label.text = "Position: (%.2f, %.2f, %.2f)" % [pos.x, pos.y, pos.z]
