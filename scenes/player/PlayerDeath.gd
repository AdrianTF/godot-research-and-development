extends KinematicBody2D

var isFacingADirection = true

func _ready():
	$DeathSoundPlayer.play()

func _process(_delta):
	var movementVector = get_movement_vector()
	
	if (movementVector.x != 0):
		if(isFacingADirection):
			$AnimatedSprite.flip_h = true if movementVector.x < 0 else false
			isFacingADirection = false
		
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	queue_free()

func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return moveVector
