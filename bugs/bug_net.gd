extends Node

# This singleton handles tracking of different bug types and also holds the current score

signal score_update
signal all_bugs_unregistered

enum Type {FIREFLY, DRAGONFLY}

var registered : Dictionary
var typesRegistered : int = 0
var caught : Dictionary

var score : int = 0
func resetScore() -> void:
	score = 0

func scoreString(sc : int) -> String:
	var s : String = str(sc * 100)
	while len(s) < 8:
		s = "0" + s
	return "Score " + s

func hardReset() -> void:
	resetScore()
	registered = {}
	typesRegistered = 0
	caught = {}

func registerBug(type : int) -> void:
	if !registered.has(type):
		typesRegistered += 1
		registered[type] = 1
		caught[type] = 0
	else:
		registered[type] += 1

func unregisterBug(type : int) -> void:
	if !registered.has(type):
		return
	
	registered[type] -= 1
	if registered[type] == 0:
		registered.erase(type)
		typesRegistered -= 1
	# emit signal when all bugs have been unregistered
	if typesRegistered == 0:
		emit_signal("all_bugs_unregistered")

func catchBug(type : int) -> void:
	caught[type] += 1
	unregisterBug(type)

# This function will zero the dictionary of caught bugs
func tallyScore() -> void:
	score += numCaught() * (tryCaught(Type.FIREFLY) + 5*tryCaught(Type.DRAGONFLY))
	for type in caught:
		caught[type] = 0
	emit_signal("score_update")

func numCaught() -> int:
	return tryCaught(Type.FIREFLY) + tryCaught(Type.DRAGONFLY)

func tryCaught(type : int) -> int:
	if !caught.has(type):
		return 0
	return caught[type]
