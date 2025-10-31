extends RayCast3D

@export var laserParticle : Node3D
@onready var beamMesh = $Mesh
@onready var playerLaser
var player
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
		$LaserParticle_End.position = cast_point
		$LaserParticle_End.visible = true
		beamMesh.scale.y = cast_point.y
		beamMesh.position.y = cast_point.y/2
		if get_collider().is_in_group("player") && get_collider().isRefractive:
			player = get_collider()
			player.currLaser = self
			var graphics = get_collider().get_node("Graphics")
			playerLaser = graphics.get_node("LaserGenPos/PlayerLaser")
			if graphics:
				playerLaser.visible = true
				playerLaser.enabled = true
				playerLaser.get_node("LaserParticle_Start").visible = true
				plaserStart()
				if !laserSpawn:
					print("Something", plaser_starting)
					get_collider().get_node("LaserShoot").play()
					laserSpawn = true
		else:
			plaserEnd()
			if playerLaser:
				playerLaser.get_node("LaserParticle_Start").visible = false
		checkLaserTrigger()
	else:
		beamMesh.scale.y = 200
		beamMesh.position.y = -100
		# Reset Player Laser Transforms
		$LaserParticle_End.visible = false
		plaserEnd()
	
	if plaser_starting && playerLaser && player.currLaser == self:
		var mesh = playerLaser.get_node("Mesh")
		mesh.scale.x = lerp(mesh.scale.x, 1.0, 5*delta)
		mesh.scale.z = lerp(mesh.scale.z, 1.0, 5*delta)
		if mesh.scale.x > 0.9 && mesh.scale.z > 0.9:
			plaser_starting = false
	elif plaser_ending && playerLaser && playerLaser.enabled && player.currLaser == self:
		var mesh = playerLaser.get_node("Mesh")
		mesh.scale.x = lerp(mesh.scale.x, 0.0, 9*delta)
		mesh.scale.z = lerp(mesh.scale.z, 0.0, 9*delta)
		if mesh.scale.x < 0.1 && mesh.scale.z < 0.1:
			plaser_ending = false
			disablePlayerLaser()

func plaserStart():
	plaser_starting = true
	plaser_ending = false
func plaserEnd():
	plaser_ending = true
	plaser_starting = false

func disablePlayerLaser():
	playerLaser.visible = false
	playerLaser.enabled = false
	playerLaser.get_node("Mesh").scale.y = 0.01
	playerLaser.get_node("Mesh").position.y = 0
	laserSpawn = false
	

func checkLaserTrigger():
	if get_collider().is_in_group("laser_trigger"):
		get_collider().on_trigger()
