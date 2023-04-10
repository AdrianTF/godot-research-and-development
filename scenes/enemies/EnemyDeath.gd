extends KinematicBody2D

var isFacingADirection = true
var direction = Vector2.ZERO

func _ready():
	$DeathSoundPlayer.play()

func _process(delta):
	if(isFacingADirection):
		$AnimatedSprite.flip_h = true if direction.x > 0 else false
		isFacingADirection = false
		
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	queue_free()
