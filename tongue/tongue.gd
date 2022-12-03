extends Node2D

signal start_extend(direction)
signal stop_extend
signal end_retract
signal final_tongue_retracted

# export vars
export var topSpeed : float
export var acceleration : float
export var maxTurnAngle : float # in radians/second. 
export var selfCollideTolerance : int # Number of past frames of movement that will not count towards self-intersections
export var retractRate : float # Exponential base for retraction rate, must be larger than 1
export var maxRetractsPerFrame : int # bounds the top speed at which the tongue can retract at all

# distance at which the tongue will "catch" the mouse
const MOUSE_CATCH_DIST : float = 1.41

# member vars
var fadeinComplete : bool = false
func _fadein(animName : String) -> void:
	if animName == "fade_in":
		fadeinComplete = true

enum {STATE_HELD, JUST_PRESSED, JUST_RELEASED}
var clickStatus : int = STATE_HELD
enum {AIM, EXTEND, RETRACT}
var mode : int = AIM
var cSpeed : float
var retract_progress : float = 1 # accumulates exponentially fast
var daytime : float = false
var finalRetract : bool = false

# Returns the vector that goes from tongue end position to mouse position
func tongueToMouse() -> Vector2:
	return get_viewport().get_mouse_position() - $end.global_position

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			clickStatus = JUST_PRESSED
		else:
			clickStatus = JUST_RELEASED

func _process(delta) -> void:
	if !fadeinComplete:
		clickStatus = STATE_HELD
		return
	
	match mode:
		AIM:
			aim_p(delta)
		EXTEND:
			extend_p(delta)
		RETRACT:
			retract_p(delta)
	
	clickStatus = STATE_HELD # by this point, clicks will have been processed

func aim_p(_delta : float) -> void:
	if daytime and !finalRetract:
		emit_signal("final_tongue_retracted")
		finalRetract = true
	if !daytime and clickStatus == JUST_PRESSED:
		cSpeed = topSpeed / 2 # start at half speed and accelerate from there
		emit_signal("start_extend", tongueToMouse().normalized())
		$end/collider.disabled = false
		mode = EXTEND

# where all the magic happens
func extend_p(delta : float) -> void:
	if clickStatus == JUST_RELEASED:
		start_retract()
		return
	
	var dir = tongueToMouse()
	var distToMouse = dir.length()
	if distToMouse < MOUSE_CATCH_DIST:
		start_retract()
		return
	dir = dir.normalized()
	
	# angle correction
	if len($tail.points) > 1:
		var maxAngleDiff = maxTurnAngle * delta
		var lastMove : Vector2 = $tail.points[-1] - $tail.points[-2]
		var angleDiff : float = dir.angle_to(lastMove)
		if angleDiff > maxAngleDiff:
			dir = dir.rotated(angleDiff - maxAngleDiff)
		elif angleDiff < -maxAngleDiff:
			dir = dir.rotated(angleDiff + maxAngleDiff)
	
	# do move
	var spd : float = delta * cSpeed * close_decay_factor(distToMouse)
	var col = $end.move_and_collide(dir * spd)
	if col and col.collider.collision_layer | Globals.PhysicsLayer.OBSTACLE:
		$sfx_stuck.play()
		start_retract()
		return
	
	$tail.add_point($end.position)
	
	# After movement, check if out of screen bounds.
	if Globals.isOffScreen($end.global_position):
		$sfx_stuck.play()
		start_retract()
		return
	
	# After movement, check for self-intersection with sufficiently old tail segments
	var pts = $tail.points
	for n in range(1, len(pts)-1 - selfCollideTolerance):
		if Geometry.segment_intersects_segment_2d(pts[-2], pts[-1], pts[n-1], pts[n]):
			$sfx_stuck.play()
			start_retract()
			return
	
	# accelerate to top speed
	cSpeed = min(cSpeed + delta * acceleration, topSpeed)

func start_retract() -> void:
	emit_signal("stop_extend")
	mode = RETRACT
	$sfx_retract.play()

func retract_p(delta : float) -> void:
	if daytime and len($tail.points) == 0:
		finish_retract()
		return
	
	var prev_prog = retract_progress
	retract_progress *= pow(retractRate, delta)
	var numRetracts : int = 0
	for _i in range(floor(prev_prog), ceil(retract_progress)):
		numRetracts += 1
		var L = len($tail.points)
		if numRetracts > maxRetractsPerFrame or L == 0: break
		$end.position = $tail.points[L-1]
		$tail.remove_point(L-1)
	if len($tail.points) == 0:
		$end.position = Vector2.ZERO
		retract_progress = 1
		BugNet.tallyScore()
		emit_signal("end_retract")
		if not daytime:
			finish_retract()

func finish_retract() -> void:
	$end/collider.disabled = true
	mode = AIM
	$sfx_retract.stop()
	$sfx_close.play()

# returns a value in the range [1/2, 1) based on how close to 0 the input is
func close_decay_factor(x : float) -> float:
	var s = x * x / 32
	return (1 + s) / (2 + s)

func _begin_day() -> void:
	daytime = true
	if mode == EXTEND:
		start_retract()
