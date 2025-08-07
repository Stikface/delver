extends Node

var player: Node3D
var input_handler: Node
var ui_overlay: Control
var ui_tabmenu: Control

enum GameState {
	PLAYING,
	MENUING
}

var game_state: GameState = GameState.PLAYING

var mouse_capture = false

func _input(event: InputEvent):
	#toggle mouse capture
	if Input.is_action_just_pressed("game_pause"):
		mouse_capture = !mouse_capture #flips the boolean to the opposite of what it already was. ! = "NOT"
		if mouse_capture:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("game_inventory"):
		match game_state:
			GameState.PLAYING:
				ui_overlay.visible = false
				ui_tabmenu.visible = true
				game_state = GameState.MENUING
			GameState.MENUING:
				ui_overlay.visible = true
				ui_tabmenu.visible = false
				game_state = GameState.PLAYING
