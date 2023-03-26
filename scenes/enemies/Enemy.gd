extends KinematicBody2D

var enemyDeathScene = preload("res://scenes/enemies/EnemyDeath.tscn")

export var isSpawning = true

var maxSpeed = 25
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var gravity = 500
var startDirection = Vector2.RIGHT

func _ready():
	direction = startDirection
	$GoalDetector.connect("area_entered", self, "on_goal_entered")
	$HitboxArea.connect("area_entered", self, "on_hitbox_entered")

func _process(delta):
	if(isSpawning):
		return
	
	velocity.x = (direction * maxSpeed).x
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	$Visuals/AnimatedSprite.flip_h = true if direction.x > 0 else false

func on_goal_entered(_area2d):
	direction *= -1


func kill():
	var enemyDeathInstance = enemyDeathScene.instance()
	get_parent().add_child_below_node(self, enemyDeathInstance)
	enemyDeathInstance.global_position = global_position
	enemyDeathInstance.direction = direction


func on_hitbox_entered(_area2d):
	$"/root/Helper".apply_camera_shake(1)
	call_deferred("kill")
	queue_free()
