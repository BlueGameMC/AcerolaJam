extends RigidBody3D

var Car

var Mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Car = $"../VehicleBody3D"
	max_contacts_reported = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	look_at(Car.global_position)
	rotation.x = 0.0
	rotation.z = 0.0
	$Cube_001.rotation = Vector3(randf_range(0,360),randf_range(0,360),randf_range(0,360))	
	
	if position.distance_to(Car.position) <= 12:
		Mode = 1
	else:
		Mode = 0
	
	print(position.distance_to(Car.position))
	
	if Mode == 0:
		apply_impulse(global_transform.basis.z * -2)
		if randi_range(0,1000) <= 2 && get_contact_count() >= 1:
			apply_impulse(global_transform.basis.y * 500)
	if Mode == 1:
		apply_impulse(global_transform.basis.z * 4)
		if randi_range(0,1000) <= 4 && get_contact_count() >= 1:
			apply_impulse(global_transform.basis.y * 500)
