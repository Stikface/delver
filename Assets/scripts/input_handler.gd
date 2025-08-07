extends Node

var mouse_capture = false

func _input(event: InputEvent):
	#toggle mouse capture
	if Input.is_action_just_pressed("Pause"):
		mouse_capture = !mouse_capture #flips the boolean to the opposite of what it already was. ! = "NOT"
		if mouse_capture:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("Inventory"):
		print(Global.game_state)
		match Global.game_state:
			Global.GameState.PLAYING:
				Global.ui_overlay.visible = false
				Global.ui_tabmenu.visible = true
				Global.game_state = Global.GameState.MENUING
			Global.GameState.MENUING:
				Global.ui_overlay.visible = true
				Global.ui_tabmenu.visible = false
				Global.game_state = Global.GameState.PLAYING
