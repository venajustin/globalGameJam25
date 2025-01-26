extends Resource

@export var mesh_scene:PackedScene = null
@export var bullet:PackedScene = null

@export var fire_rate:float = .01

# passed to bullet
@export var damage:float = 10
@export var travel_distance:float = 20
@export var bullet_drop:float = -10
@export var bullet_speed:float = 3.0


var last_fire:float = 0

func fire_held(delta:float, duck_velocity:Vector3, start_position:Node3D, world:Node3D) -> void:
	
	if last_fire > fire_rate:
		last_fire = 0
		
		var spawned_bullet = bullet.instantiate()
		
		spawned_bullet.position = start_position.global_position
		spawned_bullet.direction = start_position.get_child(0).global_position - start_position.global_position		
		
		spawned_bullet.starting_velocity = duck_velocity
		spawned_bullet.damage = damage
		spawned_bullet.travel_distance = travel_distance
		spawned_bullet.bullet_drop = bullet_drop
		spawned_bullet.bullet_speed = bullet_speed
				
		world.add_child(spawned_bullet)
		
	last_fire += delta
