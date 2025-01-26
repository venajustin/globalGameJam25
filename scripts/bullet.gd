class_name Bullet
extends Area3D

var damage:float = 10
var travel_distance:float = 10
var bullet_speed:float = 5
var bullet_drop:float = -10

var direction: Vector3 = Vector3(0, 0, 0)
var starting_velocity:Vector3 = Vector3(0, 0, 0)
var min_speed:float

var velocity := Vector3(0, 0, 0)

var creator:Node = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	starting_velocity += direction * bullet_speed
	velocity = starting_velocity
	min_speed = Vector2(starting_velocity.x, starting_velocity.z).length() / travel_distance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.x *= 1 - 1/travel_distance
	velocity.z *= 1 - 1/travel_distance
	if Vector2(velocity.x, velocity.z).length() < min_speed:
		queue_free()
	
	velocity.y += delta * bullet_drop
	
	position = position + velocity * delta
