extends Label

func _ready() -> void:
	if BugNet.connect("score_update", self, "_score_update") != OK:
		return

func _score_update() -> void:
	text = BugNet.scoreString(BugNet.score)
