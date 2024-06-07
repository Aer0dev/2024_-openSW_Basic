extends Area

var is_moving := false
var dir := Vector3.ZERO

func _physics_process(delta: float)->void:
	dir = Vector3.ZERO
	
	if Input.is_action_just_pressed("ui_up"):
		if not $ray_up.is_colliding():
			 dir = Vector3.BACK
	elif Input.is_action_just_pressed("ui_right"):
		if $ray_left.is_colliding() == false:
			dir = Vector3.LEFT
	elif Input.is_action_just_pressed("ui_left"):
		if $ray_right.is_colliding() == false:
			dir = Vector3.RIGHT
	
	if dir == Vector3.BACK:
		get_parent().z_player = int(self.global_translation.z)
		
	
	print(dir)
	
	if dir != Vector3.ZERO and not is_moving:
		is_moving = true
		var a = self.translation
		var b = a + (dir*2)
		var c = Vector3(b.x ,get_parent().player_height(b.z), b.z)
		var t = 0.1
		$tw.interpolate_property(self, "translation", a, b, 0.1, Tween.TRANS_BOUNCE,Tween.EASE_OUT)	
		$tw.interpolate_property($MeshInstance, "translation:y", 0.0, 0.4, t/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$tw.interpolate_property($MeshInstance, "translation:y", 0.0, 0.4, t/2, Tween.TRANS_LINEAR, Tween.EASE_IN, t/2)
		$tw.start()
		yield($tw, "tween_all_completed")
		is_moving = false
	
	
