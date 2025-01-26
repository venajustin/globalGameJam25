extends Node

@onready var players := {
	"1": {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera3D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/World/Player1,
		player_cam = $HBoxContainer/SubViewportContainer/SubViewport/World/Player1/camera_pivot/camera_point,
		hud = $Player1Hud
	},
	"2": {
		viewport = $HBoxContainer/SubViewportContainer2/SubViewport,
		camera = $HBoxContainer/SubViewportContainer2/SubViewport/Camera3D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/World/Player2,
		player_cam = $HBoxContainer/SubViewportContainer/SubViewport/World/Player2/camera_pivot/camera_point,
		hud = $Player2Hud
	}
}
@onready var game_over := $GameOver


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_over.visible = false
	players["2"].viewport.world_3d = players["1"].viewport.world_3d
	for i in len(players.values()):
		var node = players.values()[i]
		var remote_transform := RemoteTransform3D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player_cam.add_child(remote_transform)
		node.player.damage_taken.connect(node.hud.player_damage.bind())
		node.player.swap_weapon.connect(node.hud.swap_weapon.bind())
		node.player.register_weapon.connect(node.hud.register_weapon.bind())
		node.player.died.connect(end_game.bind(i))
		node.player.register_hud()

func _process(_delta:float) -> void:
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func end_game(player:int) ->void:
	var player_text:String = "Tie game"
	for node in players.values():
		if node.hud.find_child("TextureProgressBar").value > 0:
			player_text = node.hud.find_child("Label").text
	game_over.get_child(1).text = player_text + " wins" 
	game_over.visible = true
	$HBoxContainer.process_mode = Node.PROCESS_MODE_DISABLED
