extends KinematicBody

var velocity := Vector3.ZERO

func start(speed:float) -> void:
	velocity = Vector3(speed, 0, 0)
	$MeshInstance.rotation_degrees.y = 0.0 if sign(speed) == 1 else 180.0
func _physics_process(delta:float)-> void:
	velocity = move_and_slide(velocity, Vector3.UP)
	
