extends StaticBody3D

@onready var m := $"MeshInstance3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vertices := PackedVector3Array()
	vertices.push_back(Vector3(20, 0, 0))
	vertices.push_back(Vector3(0, 0, 20))
	vertices.push_back(Vector3(-20, 0, 0))
	vertices.push_back(Vector3(0, 0, -20))
	
	var arr_mesh := ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	m.mesh = arr_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
