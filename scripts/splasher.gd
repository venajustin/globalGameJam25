extends Area3D

@export var splash_sound:PackedScene = null


func _on_body_entered(body: Node3D) -> void:
	var splash = splash_sound.instantiate()
	splash.finished.connect(splash.queue_free.bind())
	add_child(splash)
	splash.play()
