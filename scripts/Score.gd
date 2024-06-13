extends Label

func _process(delta):
	self.text = str("%dm" % Global.score)
