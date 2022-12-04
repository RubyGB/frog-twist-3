extends PathFollow2D

enum StinkbugColor {RED, BLUE, GREEN, ORANGE}
export (StinkbugColor) var color
export var scuttleSpeed : float
export var subFrame : int

enum STATE { GROW, MOVE, SHRINK }
var state : int = STATE.GROW

func _ready():
	color = randi() % 4
	scuttleSpeed /= get_parent().curve.get_baked_length()

func getFrame() -> int:
	return subFrame + 4 * color

func _process(delta : float) -> void:
	$sprite.frame = getFrame()
	match state:
		STATE.GROW:
			grow_p(delta)
		STATE.MOVE:
			move_p(delta)
		STATE.SHRINK:
			shrink_p(delta)

func grow_p(delta : float) -> void:
	state = STATE.MOVE

func move_p(delta : float) -> void:
	unit_offset = min(1.0, unit_offset + scuttleSpeed * delta)
	if unit_offset == 1.0:
		state = STATE.SHRINK

func shrink_p(delta : float) -> void:
	queue_free()

func die() -> void:
	BugNet.catchBug(BugNet.Type.STINKBUG)
	queue_free()
