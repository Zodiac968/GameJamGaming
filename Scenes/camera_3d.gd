extends Camera3D

@export var smoothness: float = 4
@onready var targetPos = $"../SpringArm3D/CamTargetPos"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = lerp(global_position, targetPos.global_position, delta*smoothness)
