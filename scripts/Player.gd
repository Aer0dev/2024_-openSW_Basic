extends Area

var is_moving := false
var dir := Vector3.ZERO

func _physics_process(delta: float)->void:
	dir = Vector3.ZERO
	
	if Input.is_action_just_pressed("ui_up"):
		dir = Vector3.BACK
	elif Input.is_action_just_pressed("ui_right"):
		dir = Vector3.LEFT
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector3.RIGHT
	
	if dir == Vector3.BACK:
		get_parent().z_player = int(self.global_translation.z)
		
	
	print(dir)
	
	if dir != Vector3.ZERO and not is_moving:
		is_moving = true
		var a = self.translation
		var b = a + (dir*2)
		$tw.interpolate_property(self, "translation", a, b, 0.1, Tween.TRANS_BOUNCE,Tween.EASE_OUT)	
		$tw.start()
		yield($tw, "tween_all_completed")
		is_moving = false
	
	
