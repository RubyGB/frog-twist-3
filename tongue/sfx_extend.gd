extends AudioStreamPlayer

export var extendPitchSpeed : float
export var minExtendPitch : float
export var maxExtendPitch : float

var extending : bool = false

func _process(delta : float) -> void:
	if not extending:
		return
	pitch_scale = min(pitch_scale + extendPitchSpeed * delta, maxExtendPitch)

func _start_extend(_dir) -> void:
	pitch_scale = minExtendPitch
	play()
	extending = true

func _stop_extend() -> void:
	stop()
	extending = false
