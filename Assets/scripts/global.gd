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
