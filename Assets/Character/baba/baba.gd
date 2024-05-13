extends CharacterBody2D

var curPos = [0,0]

func _input(event):
	if event.is_action_pressed("right"):
		curPos[0] += 32
	elif event.is_action_pressed("left"):
		curPos[0] -= 32
	elif event.is_action_pressed("up"):
		curPos[1] -= 32
	elif event.is_action_pressed("down"):
		curPos[1] += 32
			
	
	
	
	
	self.position = Vector2(curPos[0], curPos[1])	
	
