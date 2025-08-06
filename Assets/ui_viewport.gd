extends SubViewportContainer
			
var viewport: SubViewport
var camera: Camera3D

func _ready():
	camera = $SubViewport/ViewportCamera

func _process(delta: float) -> void:
	if Global.player.camera and camera:
		camera.global_transform = Global.player.camera.global_transform
