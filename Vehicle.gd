extends KinematicBody

var velocity := Vector3.ZERO
var car_list:Array = []

func add_list():
	var dir = Directory.new()
	dir.open("res://Assets/cars/")
	dir.list_dir_begin()
	
	while true:
		var file : String = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".vox"):
			car_list.append(file)
	
	dir.list_dir_end()
	print(car_list)

func start(speed:float) -> void:
	add_list()
	velocity = Vector3(speed, 0, 0)
	$MeshInstance.rotation_degrees.y = 0.0 if sign(speed) == 1 else 180.0
	$MeshInstance.mesh = load("res://Assets/cars/" + car_list[randi()%car_list.size()])

func _physics_process(delta:float)-> void:
	velocity = move_and_slide(velocity, Vector3.UP)
	
