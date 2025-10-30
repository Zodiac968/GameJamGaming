extends "res://Scenes/laser.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cast_point 
	force_raycast_update()
	if is_colliding() && enabled:
		cast_point = to_local(get_collision_point())
		beamMesh.scale.y = cast_point.y
		beamMesh.position.y = cast_point.y/2
		checkLaserTrigger()
	elif enabled:
		beamMesh.scale.y = 200
		beamMesh.position.y = -100
	
