extends CharacterBody3D

@export var controls:Resource = preload("res://resources/p1_controls.tres")
@export var weapons:Array[Resource] = Array[Resource]
var curr_weapon:Resource = null

@onready var cam_pivot := $camera_pivot
@onready var local_mesh_pivot := $LocalMeshPivot
@onready var bullet_spawn := $LocalMeshPivot/bullet_spawn

const SPEED := 10.0 # max speed the engine can get us to
const JUMP_VELOCITY := 4.5
const WATER_DRAG := 1.0
const PLAYER_ACC := 3.0
const MAX_SPEED := 1000 # max speed with boosts
const TURN_SPEED := 1
const CAM_SPEED := 3.0
const AIR_SNAP := 15.0

const LOG10 = log(10)

var look_dir: Vector3 = Vector3(1, 1, 1);
var turn_dir:float = 0;



	
func _physics_process(delta: float) -> void:
	
	var turn_desired:float = 0
	var curr_speed :=  Vector2(velocity.x, velocity.z).length()
			
			
	var look_input := Input.get_vector(controls.look_right, controls.look_left,  controls.look_down, controls.look_up)
	# var look_yaw:float = Input.get_axis(controls.look_right, controls.look_left)
	cam_pivot.rotate(Vector3(0, 1, 0), look_input.x * delta * CAM_SPEED)
	# var look_pitch:float = Input.get_axis(controls.look_up, controls.look_down)
	cam_pivot.rotate_object_local(Vector3(1, 0, 0), look_input.y * delta * CAM_SPEED)
	
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		var desired_pivot: Vector3 = cam_pivot.rotation
		rotation.y = rotate_toward(rotation.y, desired_pivot.y, delta * AIR_SNAP)
		local_mesh_pivot.rotation.x = rotate_toward(local_mesh_pivot.rotation.x, desired_pivot.x, delta * AIR_SNAP)
		
	
	else: 
		
		local_mesh_pivot.rotation.x = 0
		
		
		# Handle jump.
		if Input.is_action_just_pressed(controls.jump) and is_on_floor():
			velocity.y = JUMP_VELOCITY

		turn_desired = Input.get_axis(controls.turn_right, controls.turn_left)
		
		if curr_speed > 0:
			turn_dir = move_toward(turn_dir, turn_desired, delta)
		
		
		var drive_dir := Input.get_axis(controls.move_forward, controls.move_backward)
		var local_z := (transform.basis * velocity).z
		var movement_power = 0
		if Input.is_action_pressed(controls.move_forward):
			local_z = 1
		if local_z >= 0:
			movement_power = 1
		if local_z > 1:
			movement_power = 0.3 * log(local_z)/LOG10
		
		if curr_speed < SPEED:
			velocity.z = move_toward(velocity.z, MAX_SPEED, cos(rotation.y) * drive_dir * PLAYER_ACC * delta * movement_power)
			velocity.x = move_toward(velocity.x, MAX_SPEED, sin(rotation.y) * drive_dir * PLAYER_ACC * delta * movement_power)
		
		
		velocity.x = move_toward(velocity.x, 0, WATER_DRAG * delta)
		velocity.z = move_toward(velocity.z, 0, WATER_DRAG * delta)
		
	
	var turn_power := 0.0
	if curr_speed > 1 or curr_speed < -1:
		#turn_power = 1 - log((abs(curr_speed)+.3)/4)/LOG10 + .5
		turn_power = 1 - .4 * log(abs(curr_speed))/LOG10
	else:
		# turn_power = 1 + log((abs(curr_speed)+.3)/4)/LOG10 + .5
		turn_power = 1.5 + log(abs(curr_speed))/LOG10
	if turn_power < 0:
		turn_power = 0
		
	
	rotate_object_local(Vector3(0, 1, 0), delta * turn_dir * turn_power * TURN_SPEED)
	velocity = velocity.rotated(Vector3(0, 1, 0),  delta * turn_dir * turn_power * TURN_SPEED)
	
	
	
	
	
	

	move_and_slide()
