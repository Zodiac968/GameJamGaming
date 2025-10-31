extends Node3D

@export var finalPos: Array[Vector3]
@export var object: Node3D
@export var isMoving = false
@export var speed = 1
var isFinished = true
var count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isMoving && finalPos && isFinished:
		var tween = create_tween()
		tween.tween_property(object, "position", finalPos[count], speed)
		isFinished = false
		tween.finished.connect(enableFinished)
		
func enableFinished():
	isFinished = true
	if count < len(finalPos) - 1:
		count += 1

func enableMovement():
	isMoving = true
