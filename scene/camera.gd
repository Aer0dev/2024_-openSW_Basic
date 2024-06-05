extends KinematicBody

export(float) var speed := 1.0
var vel := Vector3.ZERO

var new_line := 0
var old_line := 0

func _ready():
	pass # Replace with function body.


func _physics_process(_delta:float) -> void:
	vel = speed * Vector3.BACK
	vel = move_and_slide(vel)
	new_line = int(translation.z)
	if new_line == old_line+2:
		old_line = new_line
		get_parent().add_line()
		get_parent().del_line()
		print(new_line)
