extends Node

# members
onready var player = $Player


func _ready():
	# build the debug overlay
	var overlay = load('res://debug_overlay.tscn').instance()
	overlay.add_stat('pos',player, 'position', false)
	#overlay.add_stat('vel',player, 'velocity', false)
	#overlay.add_stat('look',player, 'look_vector', false)
	overlay.add_stat('move',player,'move_dir', false)
	overlay.add_stat('aim',player,'aim_dir', false)
	overlay.add_stat('torso',player, 'torso_dir', false)
	#overlay.add_stat('action',player, 'player_action', false)
	overlay.add_stat('diff',player, 'vec_dif', false)
	overlay.add_stat('look',player,'look_angle',false)
	overlay.add_stat('arms',player,'arm_angle',false)
	
	
	add_child(overlay)
	
	# connect player signals
	#player.connect('player_fired_bullet', projectile_manager, 'handle_bullet_spawned')
