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
var water_timer: Timer
var is_in_water

onready var menu_node = $Player/CanvasLayer/menu


onready var player = $Player 
onready var _spawner = preload("res://prefabs/Spawner.tscn")
onready var _wspawner = preload("res://prefabs/woodSpawner.tscn")

func _ready():
	add_list()
	redraw_board()
	Engine.time_scale = 0 
	water_timer = Timer.new()
	water_timer.set_wait_time(0.05)
	water_timer.set_one_shot(true)
	water_timer.connect("timeout", self, "_on_water_timer_timeout")
	add_child(water_timer)
	
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
	#if event.is_action_pressed("ui_cancel"):	#ESC누르면 일시정지
	#	_stopGame()
func add_line():
	var previous = $GridMap.get_cell_item(0, 0, new_line)
	var i = check_next(previous)
	new_line += 1
	
	if i in [ROAD, LINE]:
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
			
		if i == WATER:
			wood_spawner(z)	
			
		if z>4 and i == GRASS:
			add_extra(z)
		
		for x in range(-1, 1):
			$GridMap.set_cell_item(x, 0, z, i)

func add_spawner(line)->void:
	var side = rand_array([-1, 1])
	var time = rand_range(2.0, 5.0)
	var speed = rand_range(10.0, 15.0) * - side
	
	var spawner = _spawner.instance()
	add_child(spawner)
	spawner.translation = Vector3(30 * side, 1.8, (line*2) + 1)
	spawner.start(speed, time)
	
	
func wood_spawner(line)->void:
	var side = rand_array([-1, 1])
	var time = rand_range(2.0, 5.0)
	var speed = rand_range(10.0, 15.0) * - side
	
	var wspawner = _wspawner.instance()
	add_child(wspawner)
	wspawner.translation = Vector3(30 * side, 1.8, (line*2) + 1)
	wspawner.start(speed, time)	

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

func check_player_on_water():
	var player_pos = player.translation
	var map_pos = $GridMap.world_to_map(player_pos)
	var cell_value = $GridMap.get_cell_item(map_pos.x, 0, map_pos.z)
	
	if player.is_on_woodplate:
		is_in_water = false
		if water_timer.is_stopped():
			water_timer.stop()
		#print("wood")
	if cell_value == WATER :
		if not is_in_water:
			is_in_water = true
			water_timer.start()
		#print("water")
	else:
		is_in_water = false
		if not water_timer.is_stopped():
			water_timer.stop()

		
func _on_water_timer_timeout():
	if is_in_water:
		#_restartGame()
		menu_node.pause()


func _process(delta):
	if gamestart:
		check_player_on_water()
		
