extends KinematicBody2D

var gravity = 300
var velocity = Vector2.ZERO
var maxHorizontalSpeed = 100
var jumpSpeed = 100

func _ready():
	pass 

func _process(delta):
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	velocity.x = moveVector.x * maxHorizontalSpeed
	
	if(moveVector.y < 0 && is_on_floor()):
		velocity.y = moveVector.y * jumpSpeed
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
