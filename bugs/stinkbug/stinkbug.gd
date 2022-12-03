extends PathFollow2D

enum StinkbugColor {RED, BLUE, GREEN, ORANGE}
export (StinkbugColor) var color
export var scuttleSpeed : float

var subFrame : int



func _ready():
	color = randi() % 4

func getFrame() -> int:
	return subFrame + 4 * color

func _process(delta : float) -> void:
	$sprite.frame = getFrame()
	
