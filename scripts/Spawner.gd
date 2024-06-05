extends Spatial

onready var _vehicle = preload("res://prefabs/Vehicle.tscn")
var speed := 0.0

func start(_speed:float, time:float) -> void:
	speed = _speed
	$Timer.wait_time = time
	

func _on_Timer_timeout():
	if get_parent().z_cam - 6 > self.translation.z:
		queue_free()
	else:
		var vehicle = _vehicle.instance()
		get_parent().add_child(vehicle)
		vehicle.global_transform.origin = self.global_transform.origin
		vehicle.start(10)


