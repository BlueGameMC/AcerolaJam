# For any unfortunate soul that may happen to read this code, I just want to say I am sorry
# I am so so sorry
extends VehicleBody3D

var max_rpm = 1000
var max_tourqe = 200

var timeGrounded = 0

var CanJump = false

func _init():
	max_contacts_reported = 1
	

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
	apply_torque(global_transform.basis.x * Input.get_axis("Back","Forward") * 200)
	apply_torque(global_transform.basis.y * Input.get_axis("Right","Left") * 200)
	
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
		if timeGrounded > 50:
			if get_contact_count() >= 1 && timeGrounded > 100:
				# Car is turtled
				var rotation_vec = global_transform.basis.y * Input.get_axis("Right","Left") * 700
				apply_torque(rotation_vec)
				rotation_vec = global_transform.basis.x * Input.get_axis("Back","Forward") * 700
				apply_torque(rotation_vec)
				
			# Air control
			var rotation_vec = global_transform.basis.y * Input.get_axis("Right","Left") * 500
			apply_torque(rotation_vec)
			rotation_vec = global_transform.basis.x * Input.get_axis("Back","Forward") * 500
			apply_torque(rotation_vec)
		timeGrounded+=1

	if $FL.is_in_contact() || $FR.is_in_contact() || $BL.is_in_contact() || $BR.is_in_contact() || get_contact_count() == 0:
		timeGrounded=0
	# I have decided to add jumping because why not (I have no plan)
	if $FL.is_in_contact() && $FR.is_in_contact() && $BL.is_in_contact() && $BR.is_in_contact():
		CanJump = true
	
	if Input.is_action_just_pressed("Jump") && CanJump:
		apply_central_impulse(global_transform.basis.y*500)
	
	# Camera stuff (I'll be honest most of these comments really are not helping things)
	var camera = $"../SubViewportContainer/SubViewport/Camera3D"
	camera.position = lerp(camera.position, Vector3($CameraTarget.global_position.x,global_position.y+10,$CameraTarget.global_position.z), 4*delta)
	camera.look_at(global_position)
