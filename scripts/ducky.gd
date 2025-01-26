extends CharacterBody3D

@export var controls:Resource = preload("res://resources/p1_controls.tres")
@export var weapons:Array[Resource]
var curr_weapon:Resource = null
var curr_weapon_i:int = 0

@onready var cam_pivot := $camera_pivot
@onready var local_mesh_pivot := $LocalMeshPivot
@onready var bullet_spawn := $LocalMeshPivot/bullet_spawn
@onready var world_ref := $"../"

@export var gun_local_last_fire:Resource

signal damage_taken
signal swap_weapon
signal register_weapon
signal died

const SPEED := 7.0 # max speed the engine can get us to
const RUN_SPEED := 20.0
const BOOST := 1.5
const JUMP_VELOCITY := 4.5
const WATER_DRAG := 5.0
const PLAYER_ACC := 35.0
const MAX_SPEED := 1000 # max speed with boosts
const TURN_SPEED := 5.0
const CAM_SPEED := 3.0
const AIR_SNAP := 15.0

var last_fire:float = 0

const LOG10 = log(10)

var look_dir: Vector3 = Vector3(1, 1, 1);

var health:int = 100

var tilt_ammount:float = 0
var input_direction:Vector2
const TILT_SNAP := 5.0

func _ready() -> void:
	if weapons:
		if curr_weapon_i < weapons.size():
			curr_weapon = weapons[curr_weapon_i]
			swap_mesh_to_weapon()
	

func register_hud() -> void:
	for wep in weapons:
		register_weapon.emit(wep)
	damage_taken.emit(health)
	swap_weapon.emit(curr_weapon_i)

func swap_mesh_to_weapon() -> void:
	local_mesh_pivot.get_child(0).queue_free()
	var new_mesh = curr_weapon.mesh_scene.instantiate()
	local_mesh_pivot.add_child(new_mesh)
	local_mesh_pivot.move_child(new_mesh, 0)
	swap_weapon.emit(curr_weapon_i)




func _physics_process(delta: float) -> void:
	
	var turn_desired:float = 0
	var curr_speed :=  Vector2(velocity.x, velocity.z).length()
			
	
	if Input.is_action_just_pressed(controls.weapon_next):
		if curr_weapon_i + 1 < weapons.size():
			curr_weapon_i += 1
		else:
			curr_weapon_i = 0
		curr_weapon = weapons[curr_weapon_i]
		swap_mesh_to_weapon()
	if Input.is_action_just_pressed(controls.weapon_prev):
		if  curr_weapon_i - 1 >= 0:
			curr_weapon_i -= 1
		else:
			curr_weapon_i = weapons.size() - 1
		curr_weapon = weapons[curr_weapon_i]
		swap_mesh_to_weapon()
	
	last_fire += delta
	if Input.is_action_pressed(controls.fire):
		var downwards_start := global_transform.basis.y * -1.0
		curr_weapon.fire_held(last_fire, velocity + downwards_start, bullet_spawn, world_ref, global_transform.basis.y, self, gun_local_last_fire)
		last_fire = 0
	
	var look_input := Input.get_vector(controls.look_right, controls.look_left,  controls.look_down, controls.look_up)
	# var look_yaw:float = Input.get_axis(controls.look_right, controls.look_left)
	cam_pivot.rotate(Vector3(0, 1, 0), look_input.x * delta * CAM_SPEED)
	# var look_pitch:float = Input.get_axis(controls.look_up, controls.look_down)
	
	cam_pivot.rotate_object_local(Vector3(1, 0, 0), look_input.y * delta * CAM_SPEED)
	if cam_pivot.transform.basis.y.y < 0:
		cam_pivot.rotate_object_local(Vector3(1, 0, 0), -look_input.y * delta * CAM_SPEED)

	
	var desired_direction := Input.get_vector(controls.turn_left, controls.turn_right, controls.move_forward, controls.move_backward)
	if not is_on_floor():
		velocity += get_gravity() * delta
		desired_direction = Vector2(0, 0)
	else:
		if Input.is_action_just_pressed(controls.jump) and is_on_floor():
			velocity.y = JUMP_VELOCITY
		velocity.x = move_toward(velocity.x, 0, WATER_DRAG * delta)
		velocity.z = move_toward(velocity.z, 0, WATER_DRAG * delta)
	
	input_direction = input_direction.move_toward (desired_direction,delta * TILT_SNAP)

	
	

	if Input.is_action_pressed(controls.scope):
		var desired_pivot: Vector3 = cam_pivot.rotation
		rotation.y = rotate_toward(rotation.y, desired_pivot.y, delta * AIR_SNAP)
		local_mesh_pivot.rotation.x = rotate_toward(local_mesh_pivot.rotation.x, -desired_pivot.x, delta * AIR_SNAP)
		tilt_ammount = PI / 12

		
		# Scoped in we can strafe in any direction
		var vel_2d = Vector3(velocity.x, 0, velocity.z)
		var global_input_dir := transform.basis * Vector3(input_direction.x, 0, input_direction.y)
		var dir_change_coefficient = 1 - (vel_2d.dot(global_input_dir.normalized()) / SPEED ) 
		if dir_change_coefficient < 0:
			dir_change_coefficient = 0
		if dir_change_coefficient > SPEED:
			dir_change_coefficient = SPEED
		if (vel_2d.length() == 0 || global_input_dir.length() == 0) :
			dir_change_coefficient = 1
		velocity += global_input_dir * delta * PLAYER_ACC * dir_change_coefficient
	else:
		# not scoped we move like a boat
		var real_run_speed := RUN_SPEED
		if Input.is_action_pressed("p1_boost"):
			real_run_speed *= BOOST
		
		var vel_2d = Vector3(velocity.x, 0, velocity.z)
		var global_input_dir := transform.basis * Vector3(0, 0, input_direction.y)
		var dir_change_coefficient = 1 - (vel_2d.dot(global_input_dir.normalized()) / real_run_speed ) 
		if dir_change_coefficient < 0:
			dir_change_coefficient = 0
		if dir_change_coefficient > real_run_speed:
			dir_change_coefficient = real_run_speed
		if (vel_2d.length() == 0 || global_input_dir.length() == 0) :
			dir_change_coefficient = 1
		velocity += global_input_dir * delta * PLAYER_ACC * dir_change_coefficient
		
		var proportion_of_speed = 1 - ( vel_2d.length() / real_run_speed )
		if proportion_of_speed < 0.2:
			proportion_of_speed = 0.2
		var final_turn_speed = TURN_SPEED * proportion_of_speed
		
		
		rotate_object_local(Vector3(0, 1, 0), delta * -input_direction.x  * final_turn_speed)
		velocity = velocity.rotated(Vector3(0, 1, 0),  delta * -input_direction.x * final_turn_speed)
		
		
		
		local_mesh_pivot.rotation.x = 0
		tilt_ammount = PI / 8

	
	#local_mesh_pivot.rotation = Vector3(0, 0, 0)
	local_mesh_pivot.rotation.z = input_direction.x * tilt_ammount
	#local_mesh_pivot.transform = local_mesh_pivot.transform.rotated(transform.basis.z, input_direction.x * tilt_ammount )
	#local_mesh_pivot.transform = local_mesh_pivot.transform.rotated(transform.basis.x, input_direction.y * tilt_ammount )

	move_and_slide()

func _on_hitbox_enter(area: Area3D) -> void:
	if area is Bullet:
		if area.creator != self:
			var dmg:int = area.damage * 100
			health -= dmg
			if health < 0:
				health = 0
				died.emit()
			area.queue_free()
			damage_taken.emit(health)
