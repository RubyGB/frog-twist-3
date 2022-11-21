extends Sprite

# The frame index for each animation
enum Frame {DOWN_CLOSED, DOWN_OPEN, UP_CLOSED, UP_OPEN, RIGHT_CLOSED, RIGHT_OPEN, LEFT_CLOSED, LEFT_OPEN}

# look in direction with open mouth
func get_open_direction(dir : Vector2) -> int:
	var dDist := dir.distance_squared_to(Vector2.DOWN)
	var uDist := dir.distance_squared_to(Vector2.UP)
	var rDist := dir.distance_squared_to(Vector2.RIGHT)
	var lDist := dir.distance_squared_to(Vector2.LEFT)
	var minDist = min(min(min(dDist, uDist), rDist), lDist)
	match minDist:
		dDist: return Frame.DOWN_OPEN
		uDist: return Frame.UP_OPEN
		rDist: return Frame.RIGHT_OPEN
		lDist: return Frame.LEFT_OPEN
		_:
			assert(false, "Frog animation error, no distance was closest to dir: " + str(dir))
			return -1

func _open_in_direction(dir : Vector2) -> void:
	frame = get_open_direction(dir)
	if frame == Frame.DOWN_OPEN:
		z_index = -2
	else:
		z_index = 0

# close mouth without changing direction. does nothing if already in a closed state
func _set_closed() -> void:
	if frame % 2 == 0: return
	frame -= 1
	z_index = 0
