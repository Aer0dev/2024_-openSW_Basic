extends Control


func _ready():
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		print("pause")
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		print("unpause")
		resume()



func _process(delta):
	testEsc()

func _on_options_pressed():
	resume()
	get_tree().change_scene_to_file("res://scene/menu_ui.tscn")


func _on_Quit_button_down():
	get_tree().quit()


func _on_Retry_button_down():
	get_tree().reload_current_scene()
	resume()
