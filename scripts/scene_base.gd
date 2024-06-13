extends Spatial

enum {
	NOTHING = -1,
	GRASS = 0,
	ROAD = 1,
	LINE = 2
	WATER = 3
}

var new_line := 30
var old_line := -5
var z_player := 0 
var z_cam := 0
var gamestart := false
var car_list:Array = []

onready var _spawner = preload("res://prefabs/Spawner.tscn")

func _ready():
	add_list()
	redraw_board()
	Engine.time_scale = 0 
	
func _startGame():
	Engine.time_scale = 1
	gamestart = true
func _stopGame():
	Engine.time_scale = 0
func _restartGame():
	get_tree().reload_current_scene()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey && gamestart == false:	#맨처음에 아무키나 입력이 들어와야 게임이 시작되도록 변경함
		_startGame()
	if event.is_action_pressed("Restart"):		#R키 눌러서 게임 재시작
		_restartGame()
	if event.is_action_pressed("ui_cancel"):	#ESC누르면 일시정지
		_stopGame()
func add_line():
	var previous = $GridMap.get_cell_item(0, 0, new_line)
	var i = check_next(previous)
	new_line += 1
	
	if i in [ROAD, LINE, WATER]:
		add_spawner(new_line)
		
	if i == GRASS:
		add_extra(new_line)
	
	for x in range(-1, 1):
		$GridMap.set_cell_item(x, 0, new_line, i)
		
func del_line():
	for x in range(-1, 1):
		$GridMap.set_cell_item(x, 0, old_line, -1)		
		yield(get_tree(), "idle_frame" )
	
	for x in range(-8, 8):
		if $Tree.get_cell_item(x, 0, old_line) != -1:
			$Tree.set_cell_item(x, 0, old_line, -1)
			yield(get_tree(), "idle_frame" )
	old_line+=1
	
func redraw_board()->void:
	$GridMap.clear()
	for z in range(old_line, new_line):
		var i: int
		
		if z <= 5:
			i = GRASS
		else : 
			var previous = $GridMap.get_cell_item(0, 0, z-1)
			i = check_next(previous)
		
		if i in [ROAD, LINE]:
			add_spawner(z)
			var spawner = _spawner.instance()
			add_child(spawner)
			spawner.translation = Vector3(40, 2, (z*2)+1)
		
		if z>4 and i == GRASS:
			add_extra(z)
		
		for x in range(-1, 1):
			$GridMap.set_cell_item(x, 0, z, i)

func add_spawner(line)->void:
	var line_type = $GridMap.get_cell_item(0, 0, line)
	
	# 라인이 WATER 타입인 경우, 함수 실행을 중지합니다
	if line_type == WATER:
		return
	
	var side = rand_array([-1, 1])
	var time = rand_range(2.0, 5.0)
	var speed = rand_range(10.0, 15.0) * - side
	
	var spawner = _spawner.instance()
	add_child(spawner)
	spawner.translation = Vector3(30 * side, 1.8, (line*2) + 1)
	spawner.start(speed, time)

func add_extra(line)->void:
	$Tree.set_cell_item(-8, 0, line ,randi()%4 )
	$Tree.set_cell_item(7, 0, line ,randi()%4 )

	for x in range(-7, 7):
		if randi()%10 < 2:
			$Tree.set_cell_item(x, 0, line ,randi()%4 )
		
		
func check_next(previous:int)->int:
	var i:int
	
	match previous:
		GRASS:
			i = rand_array([GRASS, LINE, ROAD, WATER])
		ROAD:
			i = GRASS
		LINE:
			i = rand_array([LINE, ROAD])
		NOTHING:
			i = GRASS
	return i
	
func player_height(pos_z)->float:
	var p = Vector3(0, 0, pos_z)
	var m = $GridMap.world_to_map(p)
	var i = $GridMap.get_cell_item(m.x, m.y, m.z)
	return  0.2 if i == GRASS else 0.2

func rand_array(list:Array)->int:
	randomize()
	return list[randi()%list.size()]

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
	
func rand_car()->String:
	return "res://Assets/cars/" +car_list[randi()%car_list.size()]
