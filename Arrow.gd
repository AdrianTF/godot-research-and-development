extends Node2D

export(Texture) var sprite
export(bool) var isReversed

func _ready():
	if (isReversed):
		$Sprite.texture = sprite
