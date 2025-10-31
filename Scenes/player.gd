extends CharacterBody3D

@export var SPEED = 5.0
@export var walkSpeed = 5.0
@export var runSpeed = 10.0
@export var move_lerp = 1
@export var rot_lerp = 2
@onready var graphics = $Graphics
@onready var animTree = $Graphics/Character_Model/AnimationTree
@onready var camera_pivot: Node3D = $SpringArmPivot
@onready var animPlayer = $Graphics/Character_Model/AnimationPlayer
#@onready var wall_detect = $WallDetect
@onready var wall_detect_right = $Graphics/WallDetect2
@export var hologram_material: ShaderMaterial
@export var glidingMaterial: StandardMaterial3D
@export var hands : Array[MeshInstance3D]
@export var Particle: PackedScene = preload("res://Scenes/pickup_particle.tscn")

@export var jumpHeight := 2.0
@export var jumpDistance := 3.0
@export var smJumpHeight := 1.0
@export var smJumpDistance := 1.5

var prevHeight
var prevDistance

@onready var gravity = 2 * jumpHeight / (jumpDistance/SPEED/2)**2
@onready var jumpVelocity = 2 * jumpHeight / (jumpDistance/SPEED/2)

var tween

var targetRotation := 0.0
var isMoving := false

### Jumping
var groundControl := 0.0
var midaircontrol := 1.0
var isOnFloor = true
var jumpDelay = 0.1
var jumpDelayTimer = 0.0
var landDelay = 0.1
var landDelayTimer = 0.0
var jumpStartFlag = false
var landStartFlag = false
var justJumped = false
var timer = 0.0
var coyoteTime = 0.2
var cTimer = coyoteTime
var jumpBuffer = 0.1
var jbTimer = 0.0
@export var glidingRate = -1.0
var glidingAnim := 0.0

### Abilities
@onready var ability1 = $"../Ability1"
@onready var ability2 = $"../Ability2"
@onready var ability3 = $"../Ability3"
var hasA1 = true
var hasA2 = true
var hasA3 = true
@onready var hotbar = $Hotbar
var prevAbility = -1
var currAbility = -1
var abilityChange = false
var isRefractive = false
var isSmall = false
var isGlidable = false
var isGliding = false

### Sound
@onready var jump_sfx : AudioStreamPlayer3D = $Jump
@onready var land_sfx : AudioStreamPlayer3D = $Land
@onready var ability_sfx : AudioStreamPlayer3D = $PowerUp
@onready var glide_sfx : AudioStreamPlayer3D = $GlideSpawn
@onready var pickup_sfx : AudioStreamPlayer3D = $AbilityPickup

func _ready() -> void:
	pass
	hotbar.select(0, false)

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_text_backspace"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("one"):
		if hasA1:
			prevAbility = currAbility
			currAbility = 0
	elif Input.is_action_just_pressed("two"):
		if hasA2:
			prevAbility = currAbility
			currAbility = 1
	elif Input.is_action_just_pressed("three"):
		if hasA3:
			prevAbility = currAbility
			currAbility = 2
	elif Input.is_action_just_pressed("four"):
		prevAbility = currAbility
		currAbility = 3
	if currAbility != -1:
		hotbar.select(currAbility, false)
	
	if Input.is_action_just_pressed("ability_activate"):
		abilityChange = true
		animTree.set("parameters/AbilityTransition/transition_request", "ability")
		deactivate(prevAbility)
		abilityChange = true
		match currAbility:
			0: 
				refractionActivate()
			1:
				smallActivate()
			2:
				glidingActivate()
			_: 
				print("No ability found")
				abilityChange = false
		ability_sfx.play()
		hotbar.select(currAbility, false)
		
	if Input.is_action_just_pressed("ability_deactivate"):
		abilityChange = true
		animTree.set("parameters/AbilityTransition/transition_request", "ability")
		match currAbility:
			0: refractionDeactivate()
			1: smallDeactivate()
			2: glidingDeactivate()
			_: 
				print("No ability found")
				abilityChange = false
		ability_sfx.play()
		if currAbility != -1:
			hotbar.deselect(currAbility)
	
	for i in range(3):
		if !isActivated(i) && i != currAbility:
			hotbar.deselect(i)

func _physics_process(delta: float) -> void:
	
	var yVel = velocity.y
	velocity.y = 0.0
	
	if !is_on_floor():
		velocity.y = yVel - gravity * delta
		if justJumped:
			timer += delta
		cTimer -= delta
		jbTimer -= delta
		isOnFloor = false
		groundControl = lerp(groundControl, 1.0, 5*delta)
		animTree.set("parameters/GroundControl/blend_amount", groundControl)
		if(velocity.y < 0):
			midaircontrol = lerp(midaircontrol, 0.0, 5*delta)
		else: midaircontrol = lerp(midaircontrol, 1.0, 5*delta)
		animTree.set("parameters/MidAirControl/blend_amount", midaircontrol)
		if isGlidable && velocity.y < 0 && Input.is_action_pressed("ui_accept"):
			velocity.y = glidingRate
			glidingAnim = lerp(glidingAnim, 1.0, 5*delta)
			if !isGliding: 
				glide_sfx.play()
				isGliding = true
		else:
			glidingAnim = lerp(glidingAnim, 0.0, 5*delta)
			isGliding = false
		animTree.set("parameters/Gliding/blend_amount", glidingAnim)
	if is_on_floor():
		if Input.is_action_pressed("run"):
			animTree.set("parameters/WalkRun/scale", 2.0)
			SPEED = runSpeed
		else:
			animTree.set("parameters/WalkRun/scale", 1.0)
			SPEED = walkSpeed
		
		isGliding = false
		glidingAnim = lerp(glidingAnim, 0.0, 7*delta)
		animTree.set("parameters/Gliding/blend_amount", glidingAnim)
		cTimer = coyoteTime
		if justJumped:
			justJumped = false
			timer = 0.0
			landStart()
		elif !isOnFloor:
			isOnFloor = true
			landStart()
		
		if jbTimer > 0:
			jumpStart()
		
	if Input.is_action_just_pressed("ui_accept"):
		if (!is_on_floor()):
			jbTimer = jumpBuffer
			
		if (is_on_floor() or (!is_on_floor() and cTimer > 0)) and !justJumped:
			jumpStart()
	
	var input_dir := Vector2.ZERO
	if jumpStartFlag:
		jumpDelayTimer -= delta
		if jumpDelayTimer < 0:
			jumpDelayTimer = 0.0
			jump()
			jumpStartFlag = false
	elif landStartFlag:
		landDelayTimer -= delta
		if landDelayTimer < 0:
			landDelayTimer = 0.0
			landStartFlag = false
			groundControl = 0.0
			animTree.set("parameters/GroundControl/blend_amount", 0)
	else:
		# Get the input direction and handle the movement/deceleration.
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	if abilityChange:
		input_dir = Vector2.ZERO
	
	# Get only the Y rotation (yaw) of the pivot
	var yaw = camera_pivot.rotation.y
	# Build forward/right directions from yaw only
	var forward := Vector3(sin(yaw), 0, cos(yaw))
	var right := Vector3(cos(yaw), 0, -sin(yaw))
	var direction := (input_dir.y * forward + input_dir.x * right)
	direction.normalized()

	if Input.is_action_just_pressed("face_forward"):
		var camDir = -(forward).normalized()
		targetRotation = atan2(-camDir.x, -camDir.z)
	
	if direction:
		isMoving = true
		velocity.x = lerp(velocity.x, direction.x * SPEED, move_lerp*delta)
		velocity.z = lerp(velocity.z, direction.z * SPEED, move_lerp*delta)
		$Wall_detects.rotation.y = atan2(-direction.x, -direction.z)
		graphics.rotation.y = lerp_angle(graphics.rotation.y, atan2(-direction.x, -direction.z), delta*rot_lerp)
		targetRotation = graphics.rotation.y
	else:
		isMoving = false
		velocity.x = lerp(velocity.x, 0.0, move_lerp*delta)
		velocity.z = lerp(velocity.z, 0.0, move_lerp*delta)
		
		graphics.rotation.y = lerp_angle(graphics.rotation.y, targetRotation, delta*rot_lerp)
		
	
	animTree.set("parameters/Movement/blend_position", velocity.length() / SPEED)
	
	for wall_detect in $Wall_detects.get_children():
		wall_detect.force_raycast_update()
		if(wall_detect.is_colliding() && !wall_detect.get_collider().is_in_group("pushable")):
			var playerForward = $Wall_detects.global_basis.z
			velocity -= playerForward * playerForward.dot(velocity)
			break

	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody3D:
			var collider = collision.get_collider()
			var push_direction = -collision.get_normal()
			var push_force = 300# Adjust this value
			var push_position = collision.get_position()- collider.global_position
			collider.apply_central_impulse(push_direction * push_force * delta)

func landStart():
	animTree.set("parameters/JumpLand/blend_amount", 1)
	animTree.set("parameters/JumpTransition/transition_request", "Jump")
	landStartFlag = true
	landDelayTimer = landDelay
	land_sfx.play()

func jumpStart():
	if jumpStartFlag: return
	jumpDelayTimer = jumpDelay
	jumpStartFlag = true
	landStartFlag = false
	groundControl = 0.0
	animTree.set("parameters/GroundControl/blend_amount", 0)
	animTree.set("parameters/JumpLand/blend_amount", 0)
	animTree.set("parameters/JumpTransition/transition_request", "Jump")

func jump():
	jump_sfx.play()
	velocity.y = jumpVelocity
	justJumped = true
	midaircontrol = 1.0
	animTree.set("parameters/GroundControl/blend_amount", 1)

func isActivated(val):
	match val:
		0: return isRefractive
		1: return isSmall
		2: return isGlidable
		_: return false

func refractionActivate():
	tween = create_tween()
	tween.tween_method(set_material_blend, 0.0, 1.0, 2.0)
	tween.finished.connect(disableAbilityChange)
	isRefractive = true

func smallActivate():
	tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.5, 0.5, 0.5), 2.0)
	tween.finished.connect(disableAbilityChange)
	gravity = 2 * smJumpHeight / (smJumpDistance/SPEED/2)**2
	jumpVelocity = 2 * smJumpHeight / (smJumpDistance/SPEED/2)
	isSmall = true

func glidingActivate():
	for i in hands:
		i.material_override = glidingMaterial
	tween = create_tween()
	tween.tween_method(set_material_emission, 1, 3, 2.0)
	tween.finished.connect(disableAbilityChange)
	isGlidable = true

func set_material_emission(val):
	glidingMaterial.emission_energy_multiplier = val

func deactivate(val):
	match val:
		0: refractionDeactivate()
		1: smallDeactivate()
		2: glidingDeactivate()

func refractionDeactivate():
	tween = create_tween()
	tween.tween_method(set_material_blend, hologram_material.get_shader_parameter("blend"), 0.0, 2.0)
	tween.finished.connect(disableAbilityChange)
	isRefractive = false

func smallDeactivate():
	tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1, 1, 1), 2.0)
	tween.finished.connect(disableAbilityChange)
	gravity = 2 * jumpHeight / (jumpDistance/SPEED/2)**2
	jumpVelocity = 2 * jumpHeight / (jumpDistance/SPEED/2)
	isSmall = false

func glidingDeactivate():
	tween = create_tween()
	tween.tween_method(set_material_emission, glidingMaterial.emission_energy_multiplier, 1, 2)
	tween.finished.connect(disableAbilityChange)
	tween.finished.connect(changeMaterial)
	isGlidable = false

func changeMaterial():
	for i in hands:
		i.material_override = hologram_material

func set_material_blend(val):
	hologram_material.set_shader_parameter("blend", val)

func disableAbilityChange():
	abilityChange = false

func enableAb1(body):
	hasA1 = true
	hotbar.set_item_disabled(0, false)
	var particleEffect = Particle.instantiate()
	add_child(particleEffect)
	particleEffect.global_position = ability2.global_position
	particleEffect.get_node("GPUParticles3D").emitting = true
	pickup_sfx.play()
	ability1.queue_free()

func enableAb2(body):
	hasA2 = true
	hotbar.set_item_disabled(1, false)
	var particleEffect = Particle.instantiate()
	add_child(particleEffect)
	particleEffect.global_position = ability2.global_position
	particleEffect.get_node("GPUParticles3D").emitting = true
	pickup_sfx.play()
	ability2.queue_free()

func enableAb3(body):
	hasA3 = true
	hotbar.set_item_disabled(2, false)
	var particleEffect = Particle.instantiate()
	add_child(particleEffect)
	particleEffect.global_position = ability2.global_position
	particleEffect.get_node("GPUParticles3D").emitting = true
	pickup_sfx.play()
	ability3.queue_free()
