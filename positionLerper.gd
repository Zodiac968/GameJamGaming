extends Node3D

@export var pos1: Node3D
@export var pos2: Node3D
@export var object: Node3D
@export var isMoving = false
@export var speed = 1
var currPos: Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pos1:
		currPos = pos1.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isMoving && pos1 && pos2:
		currPos = lerp(currPos, pos2.global_position, speed * delta)
		object.global_position = currPos

func enableMovement():
	isMoving = true
