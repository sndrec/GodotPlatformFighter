extends Node3D

class_name BasePlayer

var focused = true
var curTick = 0

var controlledFighter

var inputState = [
	Vector2.ZERO,
	Vector2.ZERO,
	0.0,
	false,
	false,
	false,
	false,
	false,
	false,
	Vector2.ZERO
]

var buttonPressTime = [0, 0, 0, 0, 0, 0]
var buttonReleaseTime = [0, 0, 0, 0, 0, 0]

func get_movement_vector() -> Vector2:
	return inputState[0]
func get_cstick_vector() -> Vector2:
	return inputState[1]
func get_trigger_analog() -> float:
	return inputState[2]

func get_movement_vector_velocity() -> Vector2:
	return inputState[0] - inputState[9]

func jump_down() -> bool:
	return inputState[3]
func special_down() -> bool:
	return inputState[4]
func attack_down() -> bool:
	return inputState[5]
func shield_down() -> bool:
	return inputState[6]
func grab_down() -> bool:
	return inputState[7]
func pause_down() -> bool:
	return inputState[8]

func jump_pressed() -> bool:
	return buttonPressTime[0] == curTick
func special_pressed() -> bool:
	return buttonPressTime[1] == curTick
func attack_pressed() -> bool:
	return buttonPressTime[2] == curTick
func shield_pressed() -> bool:
	return buttonPressTime[3] == curTick
func grab_pressed() -> bool:
	return buttonPressTime[4] == curTick
func pause_pressed() -> bool:
	return buttonPressTime[5] == curTick

func jump_released() -> bool:
	return buttonReleaseTime[0] == curTick
func special_released() -> bool:
	return buttonReleaseTime[1] == curTick
func attack_released() -> bool:
	return buttonReleaseTime[2] == curTick
func shield_released() -> bool:
	return buttonReleaseTime[3] == curTick
func grab_released() -> bool:
	return buttonReleaseTime[4] == curTick
func pause_released() -> bool:
	return buttonReleaseTime[5] == curTick

func set_jump_pressed() -> void:
	buttonPressTime[0] = curTick
	inputState[3] = true
func set_special_pressed() -> void:
	buttonPressTime[1] = curTick
	inputState[4] = true
func set_attack_pressed() -> void:
	buttonPressTime[2] = curTick
	inputState[5] = true
func set_shield_pressed() -> void:
	buttonPressTime[3] = curTick
	inputState[6] = true
func set_grab_pressed() -> void:
	buttonPressTime[4] = curTick
	inputState[7] = true
func set_pause_pressed() -> void:
	buttonPressTime[5] = curTick
	inputState[8] = true

func set_jump_released() -> void:
	buttonReleaseTime[0] = curTick
	inputState[3] = false
func set_special_released() -> void:
	buttonReleaseTime[1] = curTick
	inputState[4] = false
func set_attack_released() -> void:
	buttonReleaseTime[2] = curTick
	inputState[5] = false
func set_shield_released() -> void:
	buttonReleaseTime[3] = curTick
	inputState[6] = false
func set_grab_released() -> void:
	buttonReleaseTime[4] = curTick
	inputState[7] = false
func set_pause_released() -> void:
	buttonReleaseTime[5] = curTick
	inputState[8] = false

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

func _get_local_input() -> Dictionary:
	var movement_vector = Vector2.ZERO
	var strong_vector = Vector2.ZERO
	var shield_analog = 0.0
	var input_buttons = 0
	for pad in Input.get_connected_joypads():
		if !focused:
			break
		var leftright = Input.get_joy_axis(pad, 0)
		var updown = Input.get_joy_axis(pad, 1)
		
		var cstickleftright = Input.get_joy_axis(pad, 2)
		var cstickupdown = Input.get_joy_axis(pad, 3)
		
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
			if Input.is_joy_button_pressed(pad, 5):
				input_buttons += buttons.grab
		
		if !(input_buttons & buttons.shield):
			if Input.is_joy_button_pressed(pad, 9) or Input.is_joy_button_pressed(pad, 10):
				input_buttons += buttons.shield
		
	
	var input := {}
	if movement_vector != Vector2.ZERO:
		input["movement_vector"] = movement_vector
	if strong_vector != Vector2.ZERO:
		input["strong_vector"] = strong_vector
	if shield_analog != 0:
		input["shield_analog"] = shield_analog
	if input_buttons != 0:
		input["buttons"] = input_buttons
	
	return input

func _network_process(input: Dictionary) -> void:
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
	
	inputState[9] = lerp(inputState[9], inputState[0], 0.5)
	inputState[0] = inputVector
	inputState[1] = cstickVector
	inputState[2] = analog
	
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
	
	if controlledFighter:
		controlledFighter.fighter_tick()

func _take_ownership_of_fighter(inFighter) -> void:
	inFighter.inputController = self

func _save_state() -> Dictionary:
	return {
		curTick = curTick,
		inputState = inputState.duplicate(),
		buttonPressTime = buttonPressTime.duplicate(),
		buttonReleaseTime = buttonReleaseTime.duplicate()
	}

func _load_state(state: Dictionary) -> void:
	curTick = state["curTick"]
	inputState = state["inputState"].duplicate()
	buttonPressTime = state["buttonPressTime"].duplicate()
	buttonReleaseTime = state["buttonReleaseTime"].duplicate()
