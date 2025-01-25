extends Node

@onready var players := {
	"1": {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera3D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/World/Player1/camera_pivot/camera_point
	},
	"2": {
		viewport = $HBoxContainer/SubViewportContainer2/SubViewport,
		camera = $HBoxContainer/SubViewportContainer2/SubViewport/Camera3D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/World/Player2/camera_pivot/camera_point
	}
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players["2"].viewport.world_3d = players["1"].viewport.world_3d
	for node in players.values():
		var remote_transform := RemoteTransform3D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
