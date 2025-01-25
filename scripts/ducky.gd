extends CharacterBody3D


const SPEED = 5.0 # max speed the engine can get us to
const JUMP_VELOCITY = 4.5
const WATER_DRAG = 1.0
const PLAYER_ACC = 3.0
const MAX_SPEED = 1000 # max speed with boosts
const TURN_SPEED = 1.5

const LOG10 = log(10)

var look_dir: Vector3 = Vector3(1, 1, 1);

func _physics_process(delta: float) -> void:
	
	
			
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if Input.is_action_pressed("rotate_left"):
			global_rotate(Vector3(0, 1, 0), delta * .5 )
				#look_dir = look_dir.rotated(Vector3(0, 1, 0), delta * .5 )
		if Input.is_action_pressed("rotate_right"):
			global_rotate(Vector3(0, 1, 0), delta * -.5 )
			#look_dir = look_dir.rotated(Vector3(0, 1, 0), delta * -.5 )
		if Input.is_action_pressed("rotate_back"):
			rotate_object_local(Vector3(1, 0, 0), delta * .5 )
			#look_dir = look_dir.rotated(Vector3(1, 0, 0), delta * .5 )
		if Input.is_action_pressed("rotate_forward"):
			rotate_object_local(Vector3(1, 0, 0), delta * -.5 )
			#look_dir = look_dir.rotated(Vector3(1, 0, 0), delta * -.5 )
		
	
	else: 
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var turn_dir := Input.get_axis("turn_right", "turn_left")
		var curr_speed :=  Vector2(velocity.x, velocity.z).length()
		var turn_power := 0.0
		if curr_speed > .56234 or curr_speed < -.56234:
			turn_power = 1 - log(abs(curr_speed))/LOG10
		else:
			turn_power = 1.5 + log(abs(curr_speed))/LOG10
		if turn_power < 0:
			turn_power = 0
		print("curr speed", curr_speed)
		print("turn power", turn_power)
		print("turn dir", turn_dir)
		print()
		
	
		if curr_speed > 0:
			rotate_object_local(Vector3(0, 1, 0), delta * turn_dir * turn_power * TURN_SPEED)
			velocity = velocity.rotated(Vector3(0, 1, 0),  delta * turn_dir * turn_power * TURN_SPEED)
		
		
		var drive_dir := Input.get_axis("move_forward", "move_back")
		if curr_speed < SPEED:
			velocity.z = move_toward(velocity.z, MAX_SPEED, cos(rotation.y) * drive_dir * PLAYER_ACC * delta)
			velocity.x = move_toward(velocity.x, MAX_SPEED, sin(rotation.y) * drive_dir * PLAYER_ACC * delta)
		
		
		velocity.x = move_toward(velocity.x, 0, WATER_DRAG * delta)
		velocity.z = move_toward(velocity.z, 0, WATER_DRAG * delta)
		
		## Get the input direction and handle the movement/deceleration.
		## As good practice, you should replace UI actions with custom gameplay actions.
		#var input_dir := Input.get_vector("turn_left", "turn_right", "move_forward", "move_back")
		#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		#if direction:
			#velocity.x = direction.x * SPEED
			#velocity.z = direction.z * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
			#velocity.z = move_toward(velocity.z, 0, SPEED)
			#
			
		## on floor, move like a boat
		#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		#if direction:
			#
	
	
	
	
	
	

	move_and_slide()
