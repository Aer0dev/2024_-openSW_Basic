extends KinematicBody

var velocity := Vector3.ZERO


func start(speed:float, path_name:String) -> void:

	velocity = Vector3(speed, 0, 0)
	$MeshInstance.rotation_degrees.y = 0.0 if sign(speed) == 1 else 180.0
	$MeshInstance.mesh = load(path_name)
	
	var collisionBox:BoxShape = BoxShape.new()
	collisionBox.extents = $MeshInstance.get_aabb().size / 2
	$CollisionShape.shape = collisionBox

func _physics_process(delta:float)-> void:
	velocity = move_and_slide(velocity, Vector3.UP)
	


func _on_Timer_timeout():
	call_deferred("queue_free")
