extends Area2D

export var timeToNewTarget : float
export var moveSpeed : float
export var dayTimeWiggleRange : float # radians/sec

const HOME_WIDTH : int = 40
const MAX_TIME_OFFSCREEN : float = 0.25

var target : Vector2
var total_time : float = 0
var daytime : bool = false
var timeOffScreen : float = 0

onready var home : Vector2 = position
onready var targetRect := Rect2(position.x - HOME_WIDTH, position.y - HOME_WIDTH, 2*HOME_WIDTH, 2*HOME_WIDTH)
func _ready() -> void:
	target = newTarget()

func _process(delta : float) -> void:
	if daytime:
		day_p(delta)
		return
	
	total_time += delta
	if total_time > timeToNewTarget:
		total_time -= timeToNewTarget
		target = newTarget()
	# move towards target
	position += delta * moveSpeed * (target - position).normalized()

func newTarget() -> Vector2:
	return Globals.randomUnobstructedPathInRect(global_position, targetRect, Globals.PhysicsLayer.OBSTACLE)

func _on_firefly_body_entered(body : Node):
	if body.collision_layer | Globals.PhysicsLayer.TONGUE_END:
		BugNet.catchBug(BugNet.Type.FIREFLY)
		queue_free() # TODO: make a cute animation for collecting a firefly

func centerToFirefly() -> Vector2:
	return global_position - Vector2(Globals.SWIDTH/2, Globals.SHEIGHT/2)

func day_p(delta : float) -> void:
	var dir := centerToFirefly()
	var wiggle : float = delta * dayTimeWiggleRange * (2 * randf() - 1)
	dir = dir.rotated(wiggle)
	position += delta * 2 * moveSpeed * dir.normalized()
	if Globals.isOffScreen(position):
		timeOffScreen += delta
	if timeOffScreen >= MAX_TIME_OFFSCREEN:
		BugNet.unregisterBug(BugNet.Type.FIREFLY)
		queue_free()

func _begin_day() -> void:
	daytime = true
