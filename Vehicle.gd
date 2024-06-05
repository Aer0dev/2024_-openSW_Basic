extends KinematicBody

var velocity := Vector3.ZERO

func start(speed:float) -> void:
	velocity = Vector3(speed, 0, 0)
	
func _physics_process(delta:float)-> void:
	velocity = move_and_slide(velocity, Vector3.UP)
	
