extends Node2D

const SWIDTH : int = 256
const SHEIGHT : int = 224
const SRECT : Rect2 = Rect2(0, 0, SWIDTH, SHEIGHT)

const TSIZE : int = 16
const TWIDTH : int = 16
const THEIGHT : int = 14

enum PhysicsLayer {BUGS = 1, TONGUE_END = 2, OBSTACLE = 4}

var levelMusicProgress : float = 0
var zoomLevel : int = 3 # multiplier for game window size
var topScore : int = 0
func recordNewScore(score : int) -> void:
	if score > topScore:
		topScore = score

onready var mouseCursorUp = load("res://ui/mouse_cursor.png")
onready var mouseCursorDown = load("res://ui/mouse_cursor_down.png")
onready var gameScene = load("res://main.tscn")
func _ready() -> void:
	OS.set_window_size(Vector2(zoomLevel * SWIDTH, zoomLevel * SHEIGHT))
	randomize()
	Input.set_custom_mouse_cursor(mouseCursorUp)

func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("click"):
		Input.set_custom_mouse_cursor(mouseCursorDown)
	if Input.is_action_just_released("click"):
		Input.set_custom_mouse_cursor(mouseCursorUp)

## Some helper functions

func isOffScreen(pos : Vector2) -> bool:
	return !SRECT.has_point(pos)

func randomPointInRect(rect : Rect2) -> Vector2:
	return Vector2(rect.position.x + rect.size.x * randf(), rect.position.y + rect.size.y * randf())

func randomUnobstructedPointInRect(rect : Rect2, collision_layer : int = 2147483647) -> Vector2:
	if !SRECT.intersects(rect):
		assert(false, "Globals: randomUnobstructedPointInRect passed off-screen Rect2")
	var proposed := randomPointInRect(rect)
	var obstacles : Array = get_world_2d().direct_space_state.intersect_point(proposed, 32, [], collision_layer)
	if obstacles or isOffScreen(proposed): # in normal gameplay circumstances, this will be average shallow recursion
		return randomUnobstructedPointInRect(rect, collision_layer)
	return proposed

# Returns a point which can be reached in the rect by travelling in a straight line from the initial position without colliding with something
func randomUnobstructedPathInRect(from : Vector2, rect : Rect2, collision_layer : int = 2147483647) -> Vector2:
	# if currently inside an obstacle, just return a random point outside
	if get_world_2d().direct_space_state.intersect_point(from, 32, [], PhysicsLayer.OBSTACLE):
		return randomUnobstructedPointInRect(rect, collision_layer)
	
	# does not check that a path is possible a priori, so if a path is extremely improbable / does not exist, a stack overflow is likely
	var proposed := randomPointInRect(rect)
	var raycastHit = get_world_2d().direct_space_state.intersect_ray(from, proposed, [], collision_layer)
	if raycastHit:
		return randomUnobstructedPathInRect(from, rect, collision_layer)
	return proposed
