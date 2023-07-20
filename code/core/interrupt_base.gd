class_name Interrupt extends Resource

## Time in frames to blend into the new state's animation if this interrupt triggers.
@export var blendTime: int = 0

## Time in frames before the new state can be interrupted by anything.
@export var lagTime: int = 0

enum groundRequire {
	Any,
	OnlyGrounded,
	OnlyAirborne
}

## If this interrupt is enabled when the state is entered.
@export var startActive: bool = true

## Frame of the state that the interrupt should become active, if it was inactive.
@export var enableTime: int = 0

## Frame of the state that the interrupt should become inactive, if it was active.
@export var disableTime: int = 0

## Whether this interrupt can be triggered any time, 
## or only when the fighter is grounded/airborne.
@export var requiredState: groundRequire = groundRequire.Any
