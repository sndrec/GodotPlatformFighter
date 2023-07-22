class_name FighterPropertyTable extends Resource

## Character fall acceleration per frame.
@export var Gravity: float = 0.13

## Maximum downward speed without fast falling.
@export var TerminalVelocity: float = 2

## Maximum downward speed when fast falling.
@export var FastFallTerminalVelocity: float = 2.7

## Affects knockback received from attacks. Higher is less knockback.
@export var Weight: float = 109.0

## Amount of jumps. More than 2 allows for more than a single mid-air jump.
## 1 disabled mid-air jumps, and 0 disables jumping.
@export var MaxJumps: int = 2

## Amount of frames the fighter is in jumpsquat before jumping.
@export var JumpStartupLag: int = 5

## Slowest possible walk speed.
@export var InitialWalkSpeed: float = 0.08

## Slowest possible dash speed. Dashing is the state you immediately enter
## when smashing the stick left or right on the ground.
@export var InitialDashSpeed: float = 1.45

## Slowest possible run speed. Run is the state you enter
## after you have been dashing for a while.
@export var InitialRunSpeed: float = 1.6

## How much the fighter accelerates toward the desired walk speed per frame.
@export var WalkAcceleration: float = 0.08

## The speed where the fighter transitions from the slow walk animation to the mid walk animation.
@export var MidWalkPoint: float = 0.6

## The speed where the fighter transitions from the mid walk animation to the fast walk animation.
@export var FastWalkSpeed: float = 1.1

## Fastest possible walk speed.
@export var MaxWalkSpeed: float = 1.2

## Walk animation speed multiplier.
@export var WalkAnimationSpeed: float = 1.0

## Traction applied to a grounded fighter when input isn't or can't be applied.
## This includes going neutral on the stick, or being in hitstun.
@export var Friction: float = 0.16

## Run animation speed multiplier.
@export var RunAnimationScale: float = 1.0

## How much the fighter accelerates toward the desired airspeed per frame.
@export var AerialAcceleration: float = 0.075

## Drag applied to an airborne fighter when input isn't or can't be applied.
## This includes going neutral on the stick, or being in hitstun.
@export var AerialFriction: float = 0.15

## Maximum speed the fighter can accelerate to when airborne.
@export var MaxAerialHorizontalSpeed: float = 1.4

## Maximum horizontal speed the fighter can jump with from a standstill.
@export var InitialHorizontalJumpVelocity: float = 0.9

## Upward velocity of a full-hop.
@export var InitialVerticalJumpVelocity: float = 3.15

## Upward velocity of a short-hop.
@export var MaximumShorthopVerticalVelocity: float = 2.0

## Upward velocity of a mid-air jump.
@export var VerticalAirJumpMultiplier: float = 1.0

## Multiplier for horizontal velocity when jumping from the ground to the air.
@export var GroundToAirJumpMomentumMultiplier: float = 0.92

## Maximum horizontal velocity the fighter can have when jumping from the ground.
@export var MaximumGroundToAirJumpHorizontalVelocity: float = 1.8

## Horizontal velocity multiplier of a mid-air jump.
@export var HorizontalAirJumpMultiplier: float = 1.0
