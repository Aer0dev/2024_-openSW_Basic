extends KinematicBody

export(float) var speed := 1.0
var vel := Vector3.ZERO

var new_line := 0
var old_line := 0

func _ready():
	pass # Replace with function body.


func _physics_process(_delta:float) -> void:
	var ratio := 0
	var player = get_parent().z_player
	var diff = player - int(self.translation.z)
	
	if diff > 5:
		ratio = diff / 2		
	print(diff)
	
	vel = lerp(vel, (speed + ratio) * Vector3.BACK, 0.8)
	vel = move_and_slide(vel)
	new_line = int(translation.z)
	if new_line == old_line+2:
		old_line = new_line
		get_parent().add_line()
		get_parent().del_line()
		get_parent().z_cam = old_line
		print(new_line)
