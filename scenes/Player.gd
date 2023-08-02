extends Node3D

class_name BasePlayer

var focused = true
var curTick = 0
var plReady = false
var controlledFighter

var inputState: Dictionary

func reset_input_state() -> void:
	inputState = {
	"l_stick" = Vector2.ZERO,
	"c_stick" = Vector2.ZERO,
	"l_stick_lagged" = Vector2.ZERO,
	"l_stick_velocity" = Vector2.ZERO,
	"shield_analog" = 0.0,
	"jump_pressed" = false,
	"special_pressed" = false,
	"attack_pressed" = false,
	"shield_pressed" = false,
	"grab_pressed" = false,
	"pause_pressed" = false,
	"jump_down" = false,
	"special_down" = false,
	"attack_down" = false,
	"shield_down" = false,
	"grab_down" = false,
	"pause_down" = false,
	"jump_released" = false,
	"special_released" = false,
	"attack_released" = false,
	"shield_released" = false,
	"grab_released" = false,
	"pause_released" = false
	}

var inputBuffer = []
var inputBufferSize = 8

func grab_from_buffer(inKey: String) -> bool:
	for state in inputBuffer:
		if state[inKey]:
			return true
	return false

func clear_in_buffer(inKey: String) -> void:
	for state in inputBuffer:
		state[inKey] = false

func clear_vector_in_buffer(inKey: String) -> void:
	for state in inputBuffer:
		state[inKey] = Vector2.ZERO

func clear_vector_in_buffer_above_threshold(inKey: String, inVec: Vector2) -> void:
	for state in inputBuffer:
		if check_vector_above_threshold(state[inKey], inVec):
			state[inKey] = Vector2.ZERO

func clear_vector_axis_in_buffer_above_threshold(inKey: String, inAxis: String, inThreshold: float) -> void:
	for state in inputBuffer:
		var check = state[inKey].x
		if inAxis == "y":
			check = state[inKey].y
		if absf(check) >= inThreshold and sign(check) == sign(inThreshold):
			if inAxis == "x":
				state[inKey].x = 0
			else:
				state[inKey].y = 0

func grab_and_try_clear_from_buffer(inKey: String) -> bool:
	var p = false
	for state in inputBuffer:
		p = p or state[inKey]
		if p:
			print("-----")
			print(inKey)
			break
	if p:
		for state in inputBuffer:
			state[inKey] = false
	return p

func check_vector_above_threshold(inVec1: Vector2, inVec2: Vector2):
	# inVec1 is usually going to be the input in inputstate
	# inVec2 is the threshold we are comparing that input against
	return inVec2.normalized().dot(inVec1 - inVec2) > 0.0

func check_vector_in_buffer_above_threshold(inKey: String, inVec: Vector2) -> bool:
	for state in inputBuffer:
		if check_vector_above_threshold(state[inKey], inVec):
			return true
	return false

func grab_vector_axis_highest(axis: String, inKey: String) -> float:
	var highest = 0.0
	for i in range(inputBufferSize):
		var check = inputBuffer[i][inKey].x
		if axis == "y":
			check = inputBuffer[i][inKey].y
		if absf(check) > absf(highest):
			highest = check
	return highest

func get_movement_vector_recent_highest(axis: String) -> float:
	return grab_vector_axis_highest(axis, "l_stick")

func get_movement_vector_velocity_recent_highest(axis: String) -> float:
	return grab_vector_axis_highest(axis, "l_stick_velocity")

func get_cstick_vector_recent_highest(axis: String) -> float:
	return grab_vector_axis_highest(axis, "c_stick")

func check_movement_vector_above(inVec: Vector2) -> bool:
	return check_vector_in_buffer_above_threshold("l_stick", inVec)

func check_movement_vector_velocity_above(inVec: Vector2) -> bool:
	return check_vector_in_buffer_above_threshold("l_stick_velocity", inVec)

func check_cstick_vector_above(inVec: Vector2) -> bool:
	return check_vector_in_buffer_above_threshold("c_stick", inVec)

func clear_movement_vector() -> void:
	clear_vector_in_buffer("l_stick")

func clear_movement_vector_velocity() -> void:
	clear_vector_in_buffer("l_stick_velocity")

func clear_cstick_vector() -> void:
	clear_vector_in_buffer("c_stick")

func clear_movement_vector_above_threshold(inVec: Vector2) -> void:
	clear_vector_in_buffer_above_threshold("l_stick", inVec)

func clear_movement_vector_velocity_above_threshold(inVec: Vector2) -> void:
	clear_vector_in_buffer_above_threshold("l_stick_velocity", inVec)

func clear_cstick_vector_above_threshold(inVec: Vector2) -> void:
	clear_vector_in_buffer_above_threshold("c_stick", inVec)

func clear_movement_vector_axis_above_threshold(inAxis: String, inThreshold: float) -> void:
	clear_vector_axis_in_buffer_above_threshold("l_stick", inAxis, inThreshold)

func clear_movement_vector_velocity_axis_above_threshold(inAxis: String, inThreshold: float) -> void:
	clear_vector_axis_in_buffer_above_threshold("l_stick_velocity", inAxis, inThreshold)

func clear_cstick_vector_axis_above_threshold(inAxis: String, inThreshold: float) -> void:
	clear_vector_axis_in_buffer_above_threshold("c_stick", inAxis, inThreshold)

func get_movement_vector_unbuffered() -> Vector2:
	return inputBuffer[0]["l_stick"]
func get_cstick_vector_unbuffered() -> Vector2:
	return inputBuffer[0]["c_stick"]
func get_trigger_analog_unbuffered() -> float:
	return inputBuffer[0]["shield_analog"]
func get_movement_vector_velocity_unbuffered() -> Vector2:
	return inputBuffer[0]["l_stick_velocity"]

func jump_down() -> bool:
	return inputBuffer[0]["jump_down"]
func special_down() -> bool:
	return inputBuffer[0]["special_down"]
func attack_down() -> bool:
	return inputBuffer[0]["attack_down"]
func shield_down() -> bool:
	return inputBuffer[0]["shield_down"]
func grab_down() -> bool:
	return inputBuffer[0]["grab_down"]
func pause_down() -> bool:
	return inputBuffer[0]["pause_down"]

func jump_pressed() -> bool:
	return grab_from_buffer("jump_pressed")
func special_pressed() -> bool:
	return grab_from_buffer("special_pressed")
func attack_pressed() -> bool:
	return grab_from_buffer("attack_pressed")
func shield_pressed() -> bool:
	return grab_from_buffer("shield_pressed")
func grab_pressed() -> bool:
	return grab_from_buffer("grab_pressed")
func pause_pressed() -> bool:
	return grab_from_buffer("pause_pressed")

func jump_released() -> bool:
	return grab_from_buffer("jump_released")
func special_released() -> bool:
	return grab_from_buffer("special_released")
func attack_released() -> bool:
	return grab_from_buffer("attack_released")
func shield_released() -> bool:
	return grab_from_buffer("shield_released")
func grab_released() -> bool:
	return grab_from_buffer("grab_released")
func pause_released() -> bool:
	return grab_from_buffer("pause_released")

func jump_pressed_unbuffered() -> bool:
	return inputBuffer[0]["jump_pressed"]
func special_pressed_unbuffered() -> bool:
	return inputBuffer[0]["special_pressed"]
func attack_pressed_unbuffered() -> bool:
	return inputBuffer[0]["attack_pressed"]
func shield_pressed_unbuffered() -> bool:
	return inputBuffer[0]["shield_pressed"]
func grab_pressed_unbuffered() -> bool:
	return inputBuffer[0]["grab_pressed"]
func pause_pressed_unbuffered() -> bool:
	return inputBuffer[0]["pause_pressed"]

func jump_released_unbuffered() -> bool:
	return inputBuffer[0]["jump_released"]
func special_released_unbuffered() -> bool:
	return inputBuffer[0]["special_released"]
func attack_released_unbuffered() -> bool:
	return inputBuffer[0]["attack_released"]
func shield_released_unbuffered() -> bool:
	return inputBuffer[0]["shield_released"]
func grab_released_unbuffered() -> bool:
	return inputBuffer[0]["grab_released"]
func pause_released_unbuffered() -> bool:
	return inputBuffer[0]["pause_released"]

func clear_jump_pressed() -> void:
	clear_in_buffer("jump_pressed")
func clear_special_pressed() -> void:
	clear_in_buffer("special_pressed")
func clear_attack_pressed() -> void:
	clear_in_buffer("attack_pressed")
func clear_shield_pressed() -> void:
	clear_in_buffer("shield_pressed")
func clear_grab_pressed() -> void:
	clear_in_buffer("grab_pressed")
func clear_pause_pressed() -> void:
	clear_in_buffer("pause_pressed")

func clear_jump_released() -> void:
	clear_in_buffer("jump_released")
func clear_special_released() -> void:
	clear_in_buffer("special_released")
func clear_attack_released() -> void:
	clear_in_buffer("attack_released")
func clear_shield_released() -> void:
	clear_in_buffer("shield_released")
func clear_grab_released() -> void:
	clear_in_buffer("grab_released")
func clear_pause_released() -> void:
	clear_in_buffer("pause_released")

func set_jump_pressed() -> void:
	inputState["jump_pressed"] = true
func set_special_pressed() -> void:
	inputState["special_pressed"] = true
func set_attack_pressed() -> void:
	inputState["attack_pressed"] = true
func set_shield_pressed() -> void:
	inputState["shield_pressed"] = true
func set_grab_pressed() -> void:
	inputState["grab_pressed"] = true
func set_pause_pressed() -> void:
	inputState["pause_pressed"] = true

func set_jump_released() -> void:
	inputState["jump_released"] = true
func set_special_released() -> void:
	inputState["special_released"] = true
func set_attack_released() -> void:
	inputState["attack_released"] = true
func set_shield_released() -> void:
	inputState["shield_released"] = true
func set_grab_released() -> void:
	inputState["grab_released"] = true
func set_pause_released() -> void:
	inputState["pause_released"] = true

enum buttons {
	jump = 1,
	special = 2,
	attack = 4,
	shield = 8,
	grab = 16,
	pause = 32
}

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		focused = true
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		focused = false

func _ready() -> void:
	reset_input_state()
	for i in range(inputBufferSize):
		inputBuffer.append(inputState.duplicate())
	plReady = true

func _get_local_input() -> Dictionary:
	var movement_vector := Vector2.ZERO
	var strong_vector := Vector2.ZERO
	var shield_analog := 0.0
	var input_buttons = 0
	for pad in Input.get_connected_joypads():
		if !focused:
			break
		var leftright = Input.get_joy_axis(pad, 0)
		var updown = Input.get_joy_axis(pad, 1)
		
		var cstickleftright = Input.get_joy_axis(pad, 2)
		var cstickupdown = Input.get_joy_axis(pad, 3)
		
		var newShield = max(Input.get_joy_axis(pad, 4), Input.get_joy_axis(pad, 5))
		#newShield = move_toward(newShield, 0, 0.1)
		#newShield *= (1 / 0.9)
		
		if newShield > shield_analog:
			shield_analog = newShield
		
		var new_movement_vector = Vector2(leftright, updown)
		new_movement_vector = new_movement_vector.move_toward(Vector2.ZERO, 0.05)
		new_movement_vector *= (1 / 0.95)
		
		if new_movement_vector.length() > movement_vector.length():
			movement_vector = new_movement_vector
		
		var new_cstick_vector = Vector2(cstickleftright, cstickupdown)
		new_cstick_vector = new_cstick_vector.move_toward(Vector2.ZERO, 0.05)
		new_cstick_vector *= (1 / 0.95)
		
		if new_cstick_vector.length() > strong_vector.length():
			strong_vector = new_cstick_vector
		
		if !(input_buttons & buttons.jump):
			if Input.is_joy_button_pressed(pad, 1) or Input.is_joy_button_pressed(pad, 3):
				input_buttons += buttons.jump
		
		if !(input_buttons & buttons.special):
			if Input.is_joy_button_pressed(pad, 2):
				input_buttons += buttons.special
		
		if !(input_buttons & buttons.attack):
			if Input.is_joy_button_pressed(pad, 0):
				input_buttons += buttons.attack
		
		if !(input_buttons & buttons.grab):
			if Input.is_joy_button_pressed(pad, 4):
				input_buttons += buttons.grab
		
		if !(input_buttons & buttons.shield):
			if Input.is_joy_button_pressed(pad, 9) or Input.is_joy_button_pressed(pad, 10):
				input_buttons += buttons.shield
		
	
	var input := {}
	if movement_vector != Vector2.ZERO:
		input["movement_vector"] = movement_vector
	if strong_vector != Vector2.ZERO:
		input["strong_vector"] = strong_vector
	if shield_analog != 0.0:
		input["shield_analog"] = shield_analog
	if input_buttons != 0:
		input["buttons"] = input_buttons
	
	
	return input

func _network_process(input: Dictionary) -> void:
	if !plReady:
		return
	curTick += 1
	var inputVector = input.get("movement_vector", Vector2.ZERO)
	var cstickVector = input.get("strong_vector", Vector2.ZERO)
	var analog = input.get("shield_analog", 0.0)
	var ourButtons: int = input.get("buttons", 0)
	var jump = ourButtons & buttons.jump
	var attack = ourButtons & buttons.attack
	var special = ourButtons & buttons.special
	var grab = ourButtons & buttons.grab
	var shield = ourButtons & buttons.shield
	var pause = ourButtons & buttons.pause
	
	inputState["l_stick_lagged"] = lerp(inputBuffer[0]["l_stick_lagged"], inputBuffer[0]["l_stick"], 0.5)
	inputState["l_stick"] = inputVector
	inputState["c_stick"] = cstickVector
	inputState["shield_analog"] = analog
	inputState["l_stick_velocity"] = inputState["l_stick"] - inputState["l_stick_lagged"]
	
	if !jump_down() and jump:
		set_jump_pressed()
	if !attack_down() and attack:
		set_attack_pressed()
	if !special_down() and special:
		set_special_pressed()
	if !grab_down() and grab:
		set_grab_pressed()
	if !shield_down() and shield:
		set_shield_pressed()
	if !pause_down() and pause:
		set_pause_pressed()
	
	if jump_down() and !jump:
		set_jump_released()
	if attack_down() and !attack:
		set_attack_released()
	if special_down() and !special:
		set_special_released()
	if grab_down() and !grab:
		set_grab_released()
	if shield_down() and !shield:
		set_shield_released()
	if pause_down() and !pause:
		set_pause_released()
	
	inputState["jump_down"] = jump > 0
	inputState["attack_down"] = attack > 0
	inputState["special_down"] = special > 0
	inputState["grab_down"] = grab > 0
	inputState["shield_down"] = shield > 0
	inputState["pause_down"] = pause > 0
	
	inputBuffer.push_front(inputState.duplicate())
	inputBuffer.remove_at(inputBuffer.size() - 1)
	
	reset_input_state()
	
	if controlledFighter:
		controlledFighter.fighter_tick()

func _take_ownership_of_fighter(inFighter) -> void:
	inFighter.inputController = self

func _save_state() -> Dictionary:
	return {
		curTick = curTick,
		_inputState = inputState.duplicate(),
		_inputBuffer = inputBuffer.duplicate()
	}

func _load_state(state: Dictionary) -> void:
	curTick = state["curTick"]
	inputState = state["_inputState"].duplicate()
	inputBuffer = state["_inputBuffer"].duplicate()
