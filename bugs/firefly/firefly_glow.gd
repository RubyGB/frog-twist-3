extends Light2D

# The rate of firefly glow pulses. Increase for more frequent glowing
export var glow_rate : float
export var min_glow_wait : float

# member variables
var total_time : float = 0
var pulse_width : float

onready var glow_mean : float = 1 / glow_rate
func _ready():
	pulse_width = nextPulseWidth()
	total_time = randf() * pulse_width
	energy = basePulse(total_time / pulse_width)

func _process(delta : float) -> void:
	total_time += delta
	if total_time > pulse_width:
		total_time -= pulse_width
		pulse_width = nextPulseWidth()
	# change energy based on position in current pulse
	energy = basePulse(total_time / pulse_width)


# generate a new pulse width by exponential random variable (e.g., this is a Poisson process)
func nextPulseWidth() -> float:
	var w : float = -glow_mean * log(1 - randf())
	return max(w, min_glow_wait)

# returns a pulse function for x in the range [0, 1]. Not exactly zero at endpoints but very close.
# basePulse(x / w) gives a pulse of length w
func basePulse(x : float) -> float:
	var s : float = (x - 0.5) * (x - 0.5)
	return exp(-50 * s)
