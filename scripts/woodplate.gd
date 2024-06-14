extends KinematicBody

var velocity := Vector3.ZERO
var is_woodplate := true

func start(speed:float) -> void:
	add_to_group("woodplates")
	velocity = Vector3(speed, 0, 0)
	$MeshInstance.rotation_degrees.y = 0.0 if sign(speed) == 1 else 180.0


func _physics_process(delta:float)-> void:
	velocity = move_and_slide(velocity, Vector3.UP)

func _on_Timer_timeout():
	call_deferred("queue_free")
