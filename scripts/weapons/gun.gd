extends Resource

@export var mesh_scene:PackedScene = null
@export var bullet:PackedScene = null
@export var icon:CompressedTexture2D = null

enum FTYPE {
	STANDARD,
	MACHINEGUN,
	SHOTGUN
}
@export var fire_type:FTYPE = FTYPE.STANDARD

@export var fire_rate:float = .01

# passed to bullet
@export var damage:float = 10
@export var travel_distance:float = 20
@export var bullet_drop:float = -10
@export var bullet_speed:float = 3.0




func fire_held(delta:float, duck_velocity:Vector3, start_position:Node3D, world:Node3D, up_dir:Vector3, source:Node, last_fire:Resource, audio_player:AudioStreamPlayer) -> void:
	
	if last_fire.time > fire_rate:
		last_fire.time = 0
	
		
		var spawned_bullet = bullet.instantiate()
		spawned_bullet.creator = source
		spawned_bullet.position = start_position.global_position
		spawned_bullet.direction = start_position.get_child(0).global_position - start_position.global_position		
		audio_player.play()
		
		if fire_type == FTYPE.MACHINEGUN:
			var perp_vector = spawned_bullet.direction.cross(up_dir).normalized()
			
			var small_offset:Vector3 = perp_vector * (randf() * .1 -.05)
			#small_offset = small_offset.rotated(spawned_bullet.direction, randf() * 2*PI )
			spawned_bullet.direction += small_offset
				
			perp_vector = spawned_bullet.direction.cross(perp_vector).normalized()
			
			small_offset = perp_vector * (randf() * .1 -.05)
			#small_offset = small_offset.rotated(spawned_bullet.direction, randf() * 2*PI )
			spawned_bullet.direction += small_offset
		
		if fire_type == FTYPE.SHOTGUN:
			for i in range(20) :
				var sub_bullet = bullet.instantiate()
				
				sub_bullet.creator = source
		
				sub_bullet.position = start_position.global_position
				sub_bullet.direction = start_position.get_child(0).global_position - start_position.global_position		
				
				
				var perp_vector = sub_bullet.direction.cross(up_dir).normalized()
				
				var small_offset:Vector3 = perp_vector * (randf() * .1 -.05)
				#small_offset = small_offset.rotated(spawned_bullet.direction, randf() * 2*PI )
				sub_bullet.direction += small_offset
				
				perp_vector = sub_bullet.direction.cross(perp_vector).normalized()
				
				small_offset = perp_vector * (randf() * .1 -.05)
				#small_offset = small_offset.rotated(spawned_bullet.direction, randf() * 2*PI )
				sub_bullet.direction += small_offset
				
				
				sub_bullet.starting_velocity = duck_velocity
				sub_bullet.damage = damage
				sub_bullet.travel_distance = travel_distance
				sub_bullet.bullet_drop = bullet_drop
				sub_bullet.bullet_speed = bullet_speed
				
				world.add_child(sub_bullet)
		
		
		spawned_bullet.starting_velocity = duck_velocity
		spawned_bullet.damage = damage
		spawned_bullet.travel_distance = travel_distance
		spawned_bullet.bullet_drop = bullet_drop
		spawned_bullet.bullet_speed = bullet_speed
		
		
		
		world.add_child(spawned_bullet)
		
	last_fire.time += delta
