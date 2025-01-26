extends StaticBody3D


@onready var  water_model := $Water
@onready var collision_shape = $CollisionShape3D

var shape:HeightMapShape3D

func _ready() -> void:
	shape = collision_shape.shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	water_model.get_active_material().shader
	var points = shape.map_data
	
	
	
	var xmax := shape.map_width
	var ymax := shape.map_depth
