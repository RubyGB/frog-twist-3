extends Label

func _ready() -> void:
	BugNet.connect("score_update", self, "_score_update")

func _score_update() -> void:
	text = BugNet.scoreString(BugNet.score)
