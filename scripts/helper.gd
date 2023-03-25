extends Node

func apply_camera_shake(percentage):
	var camera = get_tree().get_nodes_in_group("camera")
	if(camera.size() > 0):
		camera[0].apply_shake(percentage)
