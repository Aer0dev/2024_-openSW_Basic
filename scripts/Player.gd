extends Area

var is_moving := false
var is_rotating := false
var changeScale := false

var point := 0
var prev_z := 0

var dir := Vector3.ZERO
var following_woodplate := false
var woodplate_reference: Node = null
var is_on_woodplate := false
onready var move_sound = $move_sound
onready var menu_node = $CanvasLayer/menu

func _ready():
	Global.score = 0
	prev_z = self.translation.z
	connect("body_entered", self, "_on_Area_body_entered")
	connect("body_exited", self, "_on_Area_body_exited")
	
func _round_z(value: float) -> float:
	return round((value - 0.9) / 2.0) * 2.0 + 0.9

func _round_2(value: float) -> float:
	return round((value-1.0) / 2.0) * 2.0 +1.0

func _physics_process(delta: float)->void:
	var r0 :float= $MeshInstance.rotation_degrees.y
	var r1 :float= $MeshInstance.rotation_degrees.y
	
	dir = Vector3.ZERO
	if Input.is_action_just_pressed("ui_up"):
			$move_sound.play()
			if r0 != 0.0: r1 = 0.0
			if not $ray_up.is_colliding():
				 dir = Vector3.BACK
				 following_woodplate = false
	
	if Input.is_action_just_pressed("ui_down"):
			$move_sound.play()
			if r0 != 180.0: r1 = -180.0
			if not $ray_down.is_colliding():
				 dir = Vector3.FORWARD
				 following_woodplate = false
	
	if not following_woodplate:
		if Input.is_action_just_pressed("ui_right"):
			$move_sound.play()
			if r0 != -90: r1 = -90
			if $ray_left.is_colliding() == false:
				dir = Vector3.LEFT
		elif Input.is_action_just_pressed("ui_left"):
			$move_sound.play()
			if r0 != 90: r1 = 90
			if $ray_right.is_colliding() == false:
				dir = Vector3.RIGHT
	else:
		self.translation.x = woodplate_reference.translation.x
		
	if dir == Vector3.BACK:
		get_parent().z_player = int(self.translation.z)
		
	if r0 != r1 and not is_rotating:
		$tw_r.interpolate_property($MeshInstance, "rotation_degrees:y", r0, r1, 0.1,Tween.TRANS_EXPO, Tween.EASE_OUT)
		$tw_r.start()
		yield($tw_r, "tween_all_completed")
		is_rotating = false

	
	if dir != Vector3.ZERO and not is_moving:
		is_moving = true
		following_woodplate = false
		woodplate_reference = null

		self.translation.x = _round_2(self.translation.x)
		self.translation.z = _round_z(self.translation.z)
		
		var a = self.translation
		var b = a + (dir*2)
		var c = Vector3(b.x ,get_parent().player_height(b.z), b.z)
		var t = 0.1
		$tw.interpolate_property(self, "translation", a, b, 0.1, Tween.TRANS_BOUNCE,Tween.EASE_OUT)	
		$tw.interpolate_property($MeshInstance, "translation:y", 0.0, 0.4, t/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$tw.interpolate_property($MeshInstance, "translation:y", 0.4, 0.0, t/2, Tween.TRANS_LINEAR, Tween.EASE_IN, t/2)
		$tw.start()
		yield($tw, "tween_all_completed")
		is_moving = false
		
		# 플레이어 위치 출력
		print("Player Position: ", self.translation)

		
		if int(self.translation.z) > prev_z:
			Global.score += 1
			print("point: %d" % Global.score)
			prev_z = self.translation.z
		
	
	if not changeScale:
		changeScale = true
		var scale1 = Vector3.ONE
		var scale2 = Vector3(1.1, 0.9, 1.1)
		$tw_b.interpolate_property($MeshInstance, "scale", scale1, scale2, 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
		$tw_b.interpolate_property($MeshInstance, "scale", scale2, scale1, 0.2, Tween.TRANS_SINE, Tween.EASE_IN)
		$tw_b.start()
		yield($tw_b, "tween_all_completed")
		changeScale = false

func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("woodplates"):
		print("enter")
		is_on_woodplate = true
		following_woodplate = true
		woodplate_reference = body
	elif body.is_in_group("vehicle"):
		#get_tree().reload_current_scene()
		menu_node.pause()
		
func _on_Area_body_exited(body: Node) -> void:
	if body.is_in_group("woodplates"):
		print("exit")
		is_on_woodplate = false
		following_woodplate = false
		woodplate_reference = null


