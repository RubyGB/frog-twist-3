extends Node2D

signal daytime_modulate_finished
signal final_daytime

export var minBugRadius : float
export var bugBorderExclusion : int
export var numFireflies : int # TODO: replace this parameter when I add more bugs / change the bug generation
export var numDragonflies : int # TODO: same as above
export var daytimeModulateSpeed : float

var fadeinComplete : bool = false
func _fadein(animName : String) -> void:
	if animName == "fade_in":
		fadeinComplete = true

var timer : float = 20
var clickedOnce : bool = false
var countdowns : int = 0

var daytime : bool = false
var daytimeLerpProgress : float = 0

var final_daytime : bool = false

var daytime_modulate_finished : bool = false
func _dmf() -> void:
	daytime_modulate_finished = true
	checkDaytimeFinished()
var daytime_bugs_unregistered : bool = false
func _dbu() -> void:
	daytime_bugs_unregistered = true
	checkDaytimeFinished()
var daytime_tongue_retracted : bool = false
func _dtr() -> void:
	daytime_tongue_retracted = true
	checkDaytimeFinished()
func checkDaytimeFinished() -> void:
	if !final_daytime and daytime_modulate_finished and daytime_bugs_unregistered and daytime_tongue_retracted:
		Globals.recordNewScore(BugNet.score)
		GlobalMusicPlayer.fadein(GlobalMusicPlayer.RESULTS)
		final_daytime = true
		emit_signal("final_daytime")

onready var validBugBounds := Rect2(bugBorderExclusion, bugBorderExclusion, Globals.SWIDTH - 2*bugBorderExclusion, Globals.SHEIGHT - 2*bugBorderExclusion)
onready var modulateColor1 : Color = $night_modulate.modulate
onready var modulateColor2 : Color = $frog_modulate.modulate
const fireflyPrefab = preload("res://bugs/firefly/firefly.tscn")
const dragonflyPrefab = preload("res://bugs/dragonfly/dragonfly.tscn")
func _ready():
	connect("daytime_modulate_finished", self, "_dmf")
	BugNet.connect("all_bugs_unregistered", self, "_dbu")
	get_node("%tongue").connect("final_tongue_retracted", self, "_dtr")
	
	spawnBugs()
	$transition/animator.play("fade_in")

func spawnBugs() -> void:
	for _n in range(numFireflies):
		var firefly = fireflyPrefab.instance()
		firefly.position = validBugSpawnPoint()
		$frog_modulate.add_child(firefly)
		BugNet.registerBug(BugNet.Type.FIREFLY)
	for _n in range(numDragonflies):
		var dragonfly = dragonflyPrefab.instance()
		dragonfly.position = validBugSpawnPoint()
		$frog_modulate.add_child(dragonfly)
		BugNet.registerBug(BugNet.Type.DRAGONFLY)

func _process(delta : float) -> void:
	if !fadeinComplete:
		return
	
	if !clickedOnce and Input.is_action_just_pressed("click"):
		clickedOnce = true
		playLevelMusic()
	if daytime:
		day_p(delta)
		return
	if (timer <= 3 and countdowns == 0) or (timer <= 2 and countdowns == 1) or (timer <= 1 and countdowns == 2):
		countdowns += 1
		$countdown.play()
	if timer <= 0:
		# game is "over", initiate day sequence
		$timeup.play()
		get_tree().call_group("daytime", "_begin_day")
	elif clickedOnce:
		timer -= delta
	var seconds := ceil(timer) as int
	$UI/TimeLabel.text = timerString(seconds)

func playLevelMusic() -> void:
	if Globals.musicChoice == Globals.MUSIC_CHOICE.RANDOM:
		GlobalMusicPlayer.playID(GlobalMusicPlayer.LEVEL_A + ( randi() % 3 ))
		return
	GlobalMusicPlayer.playID(GlobalMusicPlayer.LEVEL_A + Globals.musicChoice-1)

func day_p(delta : float) -> void:
	daytimeLerpProgress = min(1, daytimeLerpProgress + daytimeModulateSpeed * delta)
	$night_modulate.modulate = modulateColor1.linear_interpolate(Color.white, daytimeLerpProgress)
	$frog_modulate.modulate = modulateColor2.linear_interpolate(Color.white, daytimeLerpProgress)

	if daytimeLerpProgress == 1:
		emit_signal("daytime_modulate_finished")
		pass

func _input(event : InputEvent) -> void:
	if !fadeinComplete:
		return
	if event.is_action_pressed("reset"):
		$transition/animator.play("fade_out")
		GlobalMusicPlayer.fadeout()

func _restart_level(animName : String) -> void:
	if animName != "fade_out":
		return
	BugNet.hardReset()
	GlobalMusicPlayer.fadein(GlobalMusicPlayer.TITLE) # ambience
	get_tree().change_scene_to(Globals.gameScene)

func validBugSpawnPoint() -> Vector2:
	return Globals.randomUnobstructedPointInRect(validBugBounds, Globals.PhysicsLayer.OBSTACLE)

func timerString(time : int) -> String:
	var s : String = str(time)
	if time < 10:
		s = "0" + s
	return "Time " + s

func _begin_day() -> void:
	daytime = true
	GlobalMusicPlayer.hardStop()
