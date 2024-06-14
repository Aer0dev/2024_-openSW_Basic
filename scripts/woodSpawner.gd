extends Spatial

onready var _wood = preload("res://prefabs/woodplate.tscn")
var speed := 0.0

func start(_speed:float, time:float) -> void:
	speed = _speed
	$Timer.wait_time = time
	

func _on_Timer_timeout():
	if get_parent().z_cam - 6 > self.translation.z:
		queue_free()
	else:
		var wood = _wood.instance()
		get_parent().add_child(wood)
		wood.global_transform.origin = self.global_transform.origin
		wood.start(speed )


