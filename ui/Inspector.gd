extends VBoxContainer
var port = preload("res://ui/Port.tscn")

var node : GraphNode = null

func _ready() -> void:
	reset_node()

func show_ui() -> void:
	self.visible=true

func set_node(obj) -> void:
	var is_same:bool = obj==node
	self.node=obj
	get_node("ObjectName").placeholder_text=node.tag if node.tag!="" else node.name
	get_node("Position_x/Value").placeholder_text = str(node.offset.x)
	get_node("Position_y/Value").placeholder_text = str(node.offset.y)

	if node.gate_type.to_lower()=="var":
		get_node("Value/Value").pressed = node.get_node("CheckButton").pressed
		get_node("Value/Value").text=str(node.get_node("CheckButton").pressed).to_lower()	

	if is_same:
		get_node("Type/Value").text = node.gate_type.to_upper()
	else:			
		get_node("ObjectName").editable=true
		get_node("Interval/Value").editable=true
		get_node("Position_x/Value").editable=true
		get_node("Position_y/Value").editable=true
		get_node("Value/Value").visible=node.gate_type.to_lower()=="var"
		get_node("Source/Value").disabled=node.gate_type.to_lower()!="prefab"
		get_node("Interval").visible=node.gate_type.to_lower()=="clock"
		get_node("IO").visible=true
		get_node("Legs").visible= !["var","clock","output","prefab"].has(node.gate_type.to_lower())
		get_node("Legs/Value").placeholder_text= str(node.legs) if get_node("Legs").visible else ""
		get_node("Id/Value").text = str(node.id)			
		get_node("IO/List/InputList").visible=node.gate_type.to_lower()!="var"
		get_node("IO/List/Input").visible=node.gate_type.to_lower()!="var"
		get_node("Source/Value").text = node.source if node.gate_type.to_lower()=="prefab" else "local://"

		for iter in get_node("IO/List/InputList/VBoxContainer").get_children():
			iter.queue_free()
		for iter in get_node("IO/List/OutputList/VBoxContainer").get_children():
			iter.queue_free()
		var left:=0
		var right:=0
		for i in range (node.get_child_count()):
			if node.is_slot_enabled_left(i):
				var iter = port.instance()
				iter.name=str(i)
				iter.get_node("Port").text=str(left)
				iter.get_node("ArrowBackward").visible=true
				iter.get_node("ArrowForward").visible=false
				get_node("IO/List/InputList/VBoxContainer").add_child(iter)
				left+=1
			if node.is_slot_enabled_right(i):
				var iter = port.instance()
				iter.name=str(i)
				iter.get_node("Port").text=str(right)
				iter.get_node("ArrowBackward").visible=false
				iter.get_node("ArrowForward").visible=true
				get_node("IO/List/OutputList/VBoxContainer").add_child(iter)
				right+=1
	
	var connections:=[]
	for connection in node.get_parent().get_connection_list():
		if connection["from"]==node.name or connection["to"]==node.name:
			connections.append(connection)
	for iter in connections:
		pass
	get_node("Timer").start()	

func reset_node() -> void:
	node=null
	get_node("ObjectName").placeholder_text=""
	get_node("Id/Value").text = ""
	get_node("Type/Value").text = ""
	get_node("Value/Value").pressed = false 
	get_node("Interval/Value").text = ""
	get_node("Interval/Value").placeholder_text = ""
	get_node("Position_x/Value").text = ""
	get_node("Position_y/Value").text = ""
	get_node("Position_x/Value").placeholder_text = ""
	get_node("Position_y/Value").placeholder_text = ""
	get_node("Source/Value").text="local://"
	get_node("Value/Value").text=""
	get_node("Legs/Value").text=""
	
	
	get_node("ObjectName").editable=false
	get_node("Interval/Value").editable=false
	get_node("Position_x/Value").editable=false
	get_node("Position_y/Value").editable=false
	get_node("Value/Value").disabled=true
	get_node("Source/Value").disabled=true
	get_node("Interval").visible=false
	get_node("Legs").visible=false
	get_node("Value").visible=false
	get_node("IO").visible=false

func _on_refresh() -> void:
	if node!=null:
		set_node(node)
	else:
		get_node("Timer").stop()
		reset_node()

func _on_ObjectName_text_entered(new_text) -> void:
	if node!=null and new_text.dedent()!="":
		node.tag=new_text.dedent()
	get_node("ObjectName").text=""
		

func _on_Value_toggled(button_pressed) -> void:
	if node!=null:
		get_node("Value/Value").text=str(button_pressed).to_lower()
		if node.gate_type.to_lower()=="var":
			node.set_value(button_pressed)
	else:
		get_node("Value/Value").text=""

func _on_Position_text_entered(new_text) -> void:
	if node!=null and new_text.is_valid_integer():
		var point=Vector2.ZERO
		point.x = float(get_node("Position_x/Value").text) if get_node("Position_x/Value").text!="" else float(get_node("Position_x/Value").placeholder_text)
		point.y = float(get_node("Position_y/Value").text) if get_node("Position_y/Value").text!="" else float(get_node("Position_y/Value").placeholder_text)
		node.offset=Vector2(point.x,point.y)
		get_node("Position_x/Value").text =""
		get_node("Position_y/Value").text =""	
	else:
		get_node("Position_x/Value").text =""
		get_node("Position_y/Value").text =""

func _on_Legs_text_entered(new_text : String) -> void:
	if new_text.is_valid_integer():
		var legs : int = int(new_text)
		print(legs)
		var updated_node := node 
		node.resize_legs(legs)
		reset_node()
		set_node(updated_node)		
	get_node("Legs/Value").text=""
