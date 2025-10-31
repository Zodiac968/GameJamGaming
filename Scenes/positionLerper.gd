extends Node3D

@export var finalPos: Vector3
@export var object: Node3D
@export var isMoving = false
@export var speed = 1
var isFinished = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isMoving && finalPos && isFinished:
		var tween = create_tween()
		tween.tween_property(object, "position", finalPos, speed)
		isFinished = false
		tween.finished.connect(enableFinished)
		
func enableFinished():
	isFinished = true

func enableMovement():
	isMoving = true
