extends Node2D
const TYPE = "Prefab"
var socket=preload("res://base nodes/input.tscn")
var output=preload("res://base nodes/output.tscn")
var value=-1
var legs=0

var path=null
var Item=null

func _physics_process(_delta):
	$Gate.Calculate()

func CreateNode():
	Database.CreatePrefab(path,Item["Items"],Item["PrefabItems"],get_node("Gate/Tab"))
	UIHandler.CreateUI(self)
	Move.MoveStart(true)
	ResizeLegs()
	
func ResizeLegs():
	for i in get_node("Gate/Tab/PrefabItems/Outputs").get_children():
		var s = socket.instance()
		s.name=i.name
		$Sockets.add_child(s)
	for i in get_node("Gate/Tab/PrefabItems/Inputs").get_children():
		var s = output.instance()
		s.name="O"+str(i.get_instance_id())
		$Outputs.add_child(s)
	$Sockets.rect_size.y=36*$Sockets.get_child_count()
	$Outputs.rect_size.y=25*$Outputs.get_child_count()
	$Gate.rect_size.y=36*$Sockets.get_child_count()
	$Gate/Label.rect_size.y=36*$Sockets.get_child_count()