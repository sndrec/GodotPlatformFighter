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

## Whether this interrupt can be triggered any time, 
## or only when the fighter is grounded/airborne.
@export var requiredState: groundRequire = groundRequire.Any
