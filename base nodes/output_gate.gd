extends Node2D
const TYPE = "Output"
var value=0
		
func CreateNode():
	UIHandler.CreateUI_variable(self)
	Move.MoveStart(true)

func _on_Gate_button_down():
	UIHandler.CreateUI_variable(self)
	Move.MoveStart(false)

func _on_Gate_button_up():
	Move.hold=false