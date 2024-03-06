# For any unfortunate soul that may happen to read this code, I just want to say I am sorry
# I am so so sorry
extends VehicleBody3D

var max_rpm = 1000
var max_tourqe = 200

# So this says timeGrounded but really it should be timeSinceGrounded but if i try to fix it and it doesn't work i will actually pass away
var timeGrounded = 0

var CanJump = false

func _ready():
	max_contacts_reported = 5
	

func _physics_process(delta):
	steering = lerp(steering, Input.get_axis("Right","Left") * 0.6,2*delta)
	var acceleration = Input.get_axis("Back","Forward")*2
	var rpm = abs($BL.get_rpm())
	$BL.engine_force = acceleration * max_tourqe * (1 - rpm / max_rpm)
	rpm = abs($BR.get_rpm())
	$BR.engine_force = acceleration * max_tourqe * (1 - rpm / max_rpm)
	
	# This entire block is just for the car to stop getting stuck (I'll be honest I still don't think it quite works)
	rpm = abs($FR.get_rpm())
	$FR.engine_force = (acceleration * max_tourqe * (1 - rpm / max_rpm))/5
	rpm = abs($FL.get_rpm())
	$FL.engine_force = (acceleration * max_tourqe * (1 - rpm / max_rpm))/5
	apply_torque(global_transform.basis.x * Input.get_axis("Back","Forward") * 300)
	apply_torque(global_transform.basis.y * Input.get_axis("Right","Left") * 300)
	
	if Input.get_action_strength("Drift")>0.5:
		# The godot vehicle body was a really bad choice for this
		# I had to hack in drifting and air control but :/
		$BR.wheel_friction_slip = lerp($BR.wheel_friction_slip, 4.5, 8*delta)
		$BL.wheel_friction_slip = lerp($BL.wheel_friction_slip, 4.5, 8*delta)
		$FR.wheel_friction_slip = lerp($FR.wheel_friction_slip, 4.8, 8*delta)
		$FL.wheel_friction_slip = lerp($FL.wheel_friction_slip, 4.8, 8*delta)
	else:
		
		$BR.wheel_friction_slip = lerp($BR.wheel_friction_slip, 15.5, 8*delta)
		$BL.wheel_friction_slip = lerp($BL.wheel_friction_slip, 15.5, 8*delta)
		$FR.wheel_friction_slip = lerp($FR.wheel_friction_slip, 12.5, 8*delta)
		$FL.wheel_friction_slip = lerp($FL.wheel_friction_slip, 12.5, 8*delta)
	
	if !$FL.is_in_contact() && !$FR.is_in_contact() && !$BL.is_in_contact() && !$BR.is_in_contact():
		CanJump = false
		if timeGrounded > 20:
			# Pre-block me here, i'm gonna try to stop the car from rolling sideways in air, if there isn't any code below this just know that i failed
			# I'm actually not sure if this is working but it hasn't broke anything yet so it's staying, and i'm crossing this off the trello board
			# It didn't work
			if get_contact_count() >= 1 && timeGrounded > 50: 
				# Car is turtled
				var rotation_vec = global_transform.basis.y * Input.get_axis("Right","Left") * 400
				apply_torque(rotation_vec)
				rotation_vec = global_transform.basis.x * Input.get_axis("Back","Forward") * 800
				apply_torque(rotation_vec)
				
			# Air control
			var rotation_vec = global_transform.basis.y * Input.get_axis("Right","Left") * 200
			apply_torque(rotation_vec)
			rotation_vec = global_transform.basis.x * Input.get_axis("Back","Forward") * 200
			apply_torque(rotation_vec)
			apply_central_impulse(global_transform.basis.z * Input.get_axis("Back","Forward") * 2)
			# At least you know this isn't AI because no AI could possibly generate code this bad
		timeGrounded+=1
	if $FL.is_in_contact() || $FR.is_in_contact() || $BL.is_in_contact() || $BR.is_in_contact():
		timeGrounded=0
	# I have decided to add jumping because why not (I have no plan)
	if $FL.is_in_contact() && $FR.is_in_contact() && $BL.is_in_contact() && $BR.is_in_contact():
		CanJump = true
	
	if Input.is_action_just_pressed("Jump") && CanJump:
		apply_central_impulse(global_transform.basis.y*650)
	
	# Camera stuff (I'll be honest most of these comments really are not helping things)
	var camera = $"../SubViewportContainer/SubViewport/Camera3D"
	var cameraFollow = $"../CameraFollow"
	
	# So the camera can't go in walls (a little buggy but whatevs)
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = global_position
	var end = cameraFollow.global_position + camera.global_transform.basis.z * 0.3
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	cameraFollow.position = lerp(cameraFollow.position, Vector3($CameraTarget.global_position.x,global_position.y+10,$CameraTarget.global_position.z), 2*delta)
	camera.position = cameraFollow.position
	
	camera.look_at(global_position)
	
	if result:
		camera.position = result.position - camera.global_transform.basis.z * 0.3
