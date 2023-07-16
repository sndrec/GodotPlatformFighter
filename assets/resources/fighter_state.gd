class_name FighterState extends Resource
## A state for a fighter.
##
## This resource represents a unique state that a fighter can exist in.
## A FighterState handles functions calls for what to do when a fighter
## enters this state, for each frame the fighter is in the state,
## when the fighter leaves the state, as well as additional
## special behaviour, such as actions and subactions.


## Name of your state. Used to identify your state.
@export var stateName: String

## Name of the animation to start playing when this state is entered,
## if you use the default ft_enteredNewState function.
@export var stateAnim: String

## Convert motion on the TransN bone into character velocity.
## Enable for states where the animation should move the character.
@export var useAnimPhysics: bool

## State to go to when the animation for this state finishes playing without being interrupted.
## Leave blank to stay in this state when the animation is finished.
@export var onAnimFinishedState: String

## Frames to blend between the current state animation and incoming state animation.
@export var onAnimFinishedStateBlendTime: int

## Functions to run when the state is entered.
@export var onEnterState: Array[FighterFunction]

## Functions that will run on every frame the fighter is in this state.
@export var onFrame: Array[FighterFunction]

## Functions that will run just before changing to a new state.
@export var onExitState: Array[FighterFunction]

## Functions that handle when this state can/will change to a new state.
## Execution stops when an interrupt is successfully executed, so
## the order is important when determining what interrupts take precedence
## if the requirements for two different interrupts are met on the same frame.
@export var interrupts: Array[Interrupt]

## The state action is special:
## Each function in this array will run once,
## but you can add timers to delay when each function is ran.
## This is integral for timing events with your animation (i.e. hitboxes and gfx)
## in a simple and easily configurable manner.
@export var action: Array[Subaction]

func _init(p_stateName = "Whatever", p_stateAnim = "Wait", p_useAnimPhysics = false, p_onAnimFinishedState = "", p_onAnimFinishedStateBlendTime = 0, p_onEnterState: Array[FighterFunction] = [], p_onFrame: Array[FighterFunction] = [], p_interrupts: Array[Interrupt] = [], p_onExitState: Array[FighterFunction] = [], p_action: Array[Subaction] = []):
	stateName = p_stateName
	stateAnim = p_stateAnim
	useAnimPhysics = p_useAnimPhysics
	onAnimFinishedState = p_onAnimFinishedState
	onAnimFinishedStateBlendTime = p_onAnimFinishedStateBlendTime
	onEnterState = p_onEnterState
	onFrame = p_onFrame
	interrupts = p_interrupts
	onExitState = p_onExitState
	action = p_action
