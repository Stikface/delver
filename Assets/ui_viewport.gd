extends SubViewportContainer
# https://www.reddit.com/r/godot/comments/15ikgr4/is_it_possible_for_a_subviewport_to_use_a/
# get the camera we want to copy values from
@onready var target_camera: Camera3D = Global.player_camera:
	get: return _target_camera
	set(value):
		_target_camera = value
		if _target_camera and camera:
			camera.projection = _target_camera.projection
			
@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewPort/Camera3D

var _target_camera: Camera3D

func _process(delta: float) -> void:
	
	if target_camera and camera:
		camera.global_transform = target_camera.global_transform
		print(camera.global_transform)
		print (target_camera.global_transform)
