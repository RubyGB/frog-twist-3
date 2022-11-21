extends Area2D

enum DragonflyColor {BLUE, GREEN, RED, ORANGE}
export (DragonflyColor) var color
export var instantFlyingSpeed : float
export var minWaitTime : float
export var maxWaitTime : float

var subFrame : int

var waited : float = 0
var nextWaitTime : float

var flying : bool = false
var flyingSpeed : float
var flyingStart : Vector2
var flyingDelta : Vector2
var flyingProgress : float = 0

var daytime : bool = false

func _ready():
	color = randi() % 4
	nextWaitTime = randomWaitTime()

func getFrame() -> int:
	return subFrame + 3 * color

func _process(delta : float) -> void:
	$sprite.frame = getFrame()
	
	if daytime and not flying:
		day_p(delta)
		return
	
	if flying:
		flyingProgress = min(flyingProgress + flyingSpeed * delta, 1)
		position = flyingStart + flyingDelta * dragonInterp(flyingProgress)
		if flyingProgress == 1:
			nextWaitTime = randomWaitTime()
			flying = false
	else:
		waited += delta
		if waited > nextWaitTime:
			waited -= nextWaitTime
			var target : Vector2 = newTarget()
			flyingStart = position
			flyingDelta = target - position
			flyingSpeed = instantFlyingSpeed / 2
			flyingProgress = 0
			flying = true
			
			# visual update to sprite rotation
			$sprite.look_at(position + flyingDelta.rotated(-PI/2))

func _on_dragonfly_body_entered(body:Node):
	if body.collision_layer | Globals.PhysicsLayer.TONGUE_END:
		BugNet.catchBug(BugNet.Type.DRAGONFLY)
		queue_free() # TODO: make cute animation for collecting dragonfly

func randomWaitTime() -> float:
	return (maxWaitTime - minWaitTime) * randf() + minWaitTime

func newTarget() -> Vector2:
	# will not move to a tile with an obstacle on it
	var x : int = randi() % Globals.TWIDTH
	var y : int = (randi() % (Globals.THEIGHT - 2)) + 1
	var tile_center := Vector2(x + 0.5, y + 0.5) * Globals.TSIZE
	if get_world_2d().direct_space_state.intersect_point(tile_center, 32, [], Globals.PhysicsLayer.OBSTACLE):
		return newTarget()
	return tile_center + Globals.TSIZE * Vector2(randf() - 0.5, randf() - 0.5)

func dragonInterp(t : float) -> float:
	return 0.5 * (1 - cos(PI * t))

func day_p(delta : float) -> void:
	pass

func _begin_day() -> void:
	daytime = true
