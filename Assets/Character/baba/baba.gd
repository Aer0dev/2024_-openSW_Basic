extends CharacterBody2D

var curPos = Vector2(960, 540)
var posStack = []

func _ready():
	posStack.push_back(curPos)  # 초기 위치를 스택에 추가합니다.

func _input(event):
	if event.is_action_pressed("right"):
		curPos.x += 32
	elif event.is_action_pressed("left"):
		curPos.x -= 32
	elif event.is_action_pressed("up"):
		curPos.y -= 32
	elif event.is_action_pressed("down"):
		curPos.y += 32
	elif event.is_action_pressed("rewind") and posStack.size() > 1:  # z 키가 눌렸고, 스택에 이전 위치가 있을 때만 실행합니다.
		print("pressed rewind")
		posStack.pop_back()  # 최신 위치 제거
		curPos = posStack[posStack.size() - 1]  # 이전 위치를 현재 위치로 설정합니다.
	
	self.position = curPos

	if event.is_action_pressed("right") or event.is_action_pressed("left") or event.is_action_pressed("up") or event.is_action_pressed("down"):
		posStack.push_back(curPos)  # 새로운 위치를 스택에 추가합니다.

