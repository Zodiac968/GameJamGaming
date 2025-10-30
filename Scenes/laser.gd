extends RayCast3D


@onready var beamMesh = $Mesh
@onready var playerLaser = $"../PlayerLaser"
var plaser_starting = false
var plaser_ending = false
var laserSpawn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cast_point 
	force_raycast_update()
	if is_colliding():
		cast_point = to_local(get_collision_point())
		beamMesh.scale.y = cast_point.y
		beamMesh.position.y = cast_point.y/2
		if get_collider().is_in_group("player") && get_collider().isRefractive:
			var graphics = get_collider().get_node("Graphics")
			if graphics:
				playerLaser.enabled = true
				playerLaser.graphics = graphics
				plaserStart()
				if !laserSpawn:
					get_collider().get_node("LaserShoot").play()
					laserSpawn = true
		else:
			print("LaserEnd")
			plaserEnd()
		checkLaserTrigger()
	else:
		beamMesh.scale.y = 200
		beamMesh.position.y = -100
		# Reset Player Laser Transforms
		plaserStart()
	
	if plaser_starting:
		var mesh = playerLaser.get_node("Mesh")
		mesh.scale.x = lerp(mesh.scale.x, 1.0, 5*delta)
		mesh.scale.z = lerp(mesh.scale.z, 1.0, 5*delta)
		if mesh.scale.x > 0.99 && mesh.scale.z > 0.99:
			plaser_starting = false
	elif plaser_ending && playerLaser.enabled:
		var mesh = playerLaser.get_node("Mesh")
		mesh.scale.x = lerp(mesh.scale.x, 0.0, 9*delta)
		mesh.scale.z = lerp(mesh.scale.z, 0.0, 9*delta)
		if mesh.scale.x < 0.2 && mesh.scale.z < 0.2:
			plaser_ending = false
			disablePlayerLaser()

func plaserStart():
	plaser_starting = true
	plaser_ending = false
func plaserEnd():
	plaser_ending = true
	plaser_starting = false

func disablePlayerLaser():
	playerLaser.enabled = false
	playerLaser.get_node("Mesh").scale.y = 0.01
	playerLaser.get_node("Mesh").position.y = 0
	playerLaser.position = position
	laserSpawn = false
	

func checkLaserTrigger():
	if get_collider().is_in_group("laser_trigger"):
		get_collider().on_trigger()
