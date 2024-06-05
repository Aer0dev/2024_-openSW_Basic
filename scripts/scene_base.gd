extends Spatial

enum {
	NOTHING = -1,
	GRASS = 0,
	ROAD = 1,
	LINE = 2
}



func _ready():
	redraw_board()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		redraw_board()


func redraw_board()->void:
	$GridMap.clear()
	for z in range(-5, 40):
		var i: int
		
		if z <= 5:
			i = GRASS
		else : 
			var previous = $GridMap.get_cell_item(0, 0, z-1)
			i = check_next(previous)
			
		for x in range(-10, 10):
			$GridMap.set_cell_item(x, 0, z, i)#Grass 가지고옴

func check_next(previous:int)->int:
	var i:int
	
	match previous:
		GRASS:
			i = rand_array([GRASS, LINE, ROAD])
		ROAD:
			i = GRASS
		LINE:
			i = rand_array([LINE, ROAD])
		NOTHING:
			i = GRASS
	return i

func rand_array(list:Array)->int:
	randomize()
	return list[randi()%list.size()]
