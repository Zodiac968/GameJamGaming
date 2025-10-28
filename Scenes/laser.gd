extends RayCast3D


@onready var beamMesh = $Mesh
@onready var playerLaser = $"../PlayerLaser"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cast_point 
	force_raycast_update()
	if is_colliding():
		cast_point = to_local(get_collision_point())
		beamMesh.scale.y = cast_point.y - 0.2
		beamMesh.position.y = cast_point.y/2
		if get_collider().is_in_group("player"):
			var graphics = get_collider().get_node("Graphics")
			if graphics:
				playerLaser.enabled = true
				playerLaser.graphics = graphics
		else:
			playerLaser.enabled = false
			playerLaser.get_node("Mesh").scale.y = 1
			playerLaser.get_node("Mesh").position.y = 0
			playerLaser.position = position
			
