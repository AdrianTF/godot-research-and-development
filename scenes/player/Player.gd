extends KinematicBody2D

signal died

var playerDeathScene = preload("res://scenes/player/PlayerDeath.tscn")
var footseptParticles = preload("res://scenes/player/FootstepParticles.tscn")

enum State { NORMAL, DASHING, ATTACKING}

var gravity = 1000
var velocity = Vector2.ZERO
var maxHorizontalSpeed = 140
var maxDashSpeed = 500
var minDashSpeed = 200
var horizontalAcceleration = 2000
var jumpSpeed = 300
var jumpTerminationMultiplier = 4
var hasDoubleJump = false
var hasDash = false
var currentState = State.NORMAL
var isStateNew = true
var isAttacking = false
var isDying = false


func _ready():
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")
	$AnimatedSprite.connect("animation_finished", self, "on_attack_animation_finished")
	$AnimatedSprite.connect("frame_changed", self, "on_animated_sprite_frame_changed")

func _process(delta):
	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
		State.ATTACKING:
			process_attack(delta)
	isStateNew = false

func change_state(newState):
	currentState = newState
	isStateNew = true

func process_normal(delta):
	if(isStateNew):
		$DashParticles.emitting = false
	
	var moveVector = get_movement_vector()
	
	velocity.x +=moveVector.x * horizontalAcceleration * delta
	if (moveVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
	
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	
	if(moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || hasDoubleJump)):
		velocity.y = moveVector.y * jumpSpeed
		if(!is_on_floor() && $CoyoteTimer.is_stopped()):
			$"/root/Helper".apply_camera_shake(.75)
			hasDoubleJump = false
		$CoyoteTimer.stop()
	
	if(velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jumpTerminationMultiplier * delta
	else:
		velocity.y += gravity * delta
		
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if (wasOnFloor && !is_on_floor()):
		$CoyoteTimer.start()
	
	if(!wasOnFloor && is_on_floor() && !isStateNew):
		create_footsteps(1.5)
	
	if (is_on_floor()):
		hasDoubleJump = true
		hasDash = true
	
	if (hasDash && Input.is_action_just_pressed("dash")):
		call_deferred("change_state", State.DASHING)
		hasDash = false
		
	if (Input.is_action_just_pressed("attack")):
		call_deferred("change_state", State.ATTACKING)
	
	update_animation()

func process_dash(delta):
	if (isStateNew):
		$DashParticles.emitting = true
		$"/root/Helper".apply_camera_shake(.75)
		$AnimatedSprite.play("jump")
		var moveVector = get_movement_vector()
		var velocityMod = 1
		
		if (moveVector.x != 0):
			velocityMod = sign(moveVector.x)
		else:
			velocityMod = -1 if $AnimatedSprite.flip_h else 1
		velocity = Vector2(maxDashSpeed * velocityMod, 0)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.x = lerp(0, velocity.x, pow(2, -8 * delta))
	
	if (abs(velocity.x) < minDashSpeed):
		call_deferred("change_state", State.NORMAL)

func process_attack(delta):
	if(isStateNew):
		$DashParticles.emitting = false
		$AnimatedSprite.play("slash")
		isAttacking = true
		$AttackArea/CollisionShape2D.disabled = false
	
	if(!isStateNew && !isAttacking):
		call_deferred("change_state", State.NORMAL)
	velocity.y += gravity * delta
	
	var moveVector = get_movement_vector()
	#var wasOnFloor = is_on_floor() add && !wasOnFloor to the if statement to keep moving while atk
	if (isAttacking && is_on_floor() ):
		moveVector *= 0
	velocity.x += moveVector.x * horizontalAcceleration * delta
	if (moveVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
	
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	isStateNew = false

func on_attack_animation_finished():
	if ($AnimatedSprite.animation == "slash"):
		$AttackArea/CollisionShape2D.disabled = true
		isAttacking = false

func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return moveVector

func update_animation():
	var movementVector = get_movement_vector()
	
	if (!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif (movementVector.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
	
	if (movementVector.x != 0):
		$AnimatedSprite.flip_h = true if movementVector.x < 0 else false
		get_node("AttackArea").set_scale(Vector2(-1,1) if movementVector.x < 0 else Vector2(1,1))

func kill():
	if (isDying):
		return
	isDying = true
	var playerDeathInstance = playerDeathScene.instance()
	get_parent().add_child_below_node(self, playerDeathInstance)
	playerDeathInstance.global_position = global_position
	emit_signal("died")

func create_footsteps(scale = 1):
	var footstep = footseptParticles.instance()
	get_parent().add_child(footstep)
	footstep.scale = Vector2.ONE * scale
	var position = global_position
	position.y += 8
	footstep.global_position = position
	$FootstepAudioPlayer.play()

func on_hazard_area_entered(_area2d):
	$"/root/Helper".apply_camera_shake(1)
	call_deferred("kill")

func on_animated_sprite_frame_changed():
	if($AnimatedSprite.animation == "run" && $AnimatedSprite.frame % 2 == 1):
		create_footsteps()
