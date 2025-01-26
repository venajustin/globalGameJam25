extends Node3D

var damage:float = 10
var travel_distance:float = 40
var bullet_speed:float = 5
var bullet_drop:float = -10

var direction: Vector3 = Vector3(0, 0, 0)
var starting_velocity:Vector3 = Vector3(0, 0, 0)

var velocity := Vector3(0, 0, 0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = starting_velocity
	velocity += direction * bullet_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity *= 1 - 1/travel_distance
	
	position = position + velocity * delta
