extends RichTextLabel

# set before adding to the scene.
var scoreToDisplay : int

func _ready():
	var innerString := "$" + str(abs(scoreToDisplay) * 100)
	if scoreToDisplay < 0:
		innerString = "-" + innerString
	bbcode_text = "[center][wave amp=10][rainbow freq=1.5]" + innerString + "[/rainbow][/wave][/center]"

func finished():
	queue_free()
