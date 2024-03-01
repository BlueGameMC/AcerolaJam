extends VehicleBody3D

var max_rpm = 1000
var max_tourqe = 200

func _physics_process(delta):
	steering = lerp(steering, Input.get_axis("Right","Left") * 0.6,2*delta)
	var acceleration = Input.get_axis("Back","Forward")*2
	var rpm = abs($BL.get_rpm())
	$BL.engine_force = acceleration * max_tourqe * (1 - rpm / max_rpm)
	rpm = abs($BR.get_rpm())
	$BR.engine_force = acceleration * max_tourqe * (1 - rpm / max_rpm)
	if Input.get_action_strength("Drift")>0.5:
		#$BL.use_as_traction = false
		#$BR.use_as_traction = false
		$BR.wheel_friction_slip = lerp($BR.wheel_friction_slip, 2.5, 8*delta)
		$BL.wheel_friction_slip = lerp($BL.wheel_friction_slip, 2.5, 8*delta)
		$FR.wheel_friction_slip = lerp($FR.wheel_friction_slip, 8.8, 8*delta)
		$FL.wheel_friction_slip = lerp($FL.wheel_friction_slip, 8.8, 8*delta)
	else:
		#$BL.use_as_traction = true
		#$BR.use_as_traction = true
		
		$BR.wheel_friction_slip = lerp($BR.wheel_friction_slip, 10.5, 8*delta)
		$BL.wheel_friction_slip = lerp($BL.wheel_friction_slip, 10.5, 8*delta)
		$FR.wheel_friction_slip = lerp($FR.wheel_friction_slip, 10.5, 8*delta)
		$FL.wheel_friction_slip = lerp($FL.wheel_friction_slip, 10.5, 8*delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera = $"../Camera3D"
	
	$"../Camera3D".position = lerp($"../Camera3D".position, $Body/CameraTarget.global_position, 4*delta)
	
	camera.look_at(global_position)
