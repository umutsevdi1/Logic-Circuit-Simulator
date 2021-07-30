extends GraphEdit
var offset_data=scroll_offset
var selected_units:={}
var clipboard:={}

onready var inspector = get_node("/root/main/RightTab/TabSelection/Tabs/Inspector")

#Removing unnecessary icons
func _ready() -> void:
	for i in range(3):
		self.get_zoom_hbox().get_child(i).visible=false
	self.get_zoom_hbox().set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT)
	self.get_zoom_hbox().rect_position-=Vector2(30,-10)
	
# Change scroll effect to zoom
func _process(_delta):
	if get_global_mouse_position().x in range(self.rect_global_position.x,self.rect_global_position.x+self.rect_size.x) and \
	get_global_mouse_position().y in range(self.rect_global_position.y,self.rect_global_position.y+self.rect_size.y) and $CreateNew.visible==false:
		var vector = (get_local_mouse_position()+scroll_offset)/zoom
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/Cursor").text="("+str(float(int(vector.x*10000))/10000)+", "+str(float(int(vector.y*10000))/10000)+")"
		
		if Input.is_action_just_released("middle_click") and self.visible:
			offset_data=self.scroll_offset
		if Input.is_action_just_released("zoom_in") and zoom>=0.60:
			self.zoom-=0.1
		elif Input.is_action_just_released("zoom_out") and zoom<=1.7:
			self.zoom+=0.1
		if Input.is_action_just_released("zoom_in") or  Input.is_action_just_released("zoom_out") and self.visible:
			self.scroll_offset=offset_data
			get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/Zoom").text=str(int(self.zoom*100))+"%"

func _on_Tab_node_selected(node) -> void:
	inspector.set_node(node)
	if !selected_units.has(node.name):
		selected_units[node.name]=node
		node.modulate.a=0.5

		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/Selection").visible=true
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/IconSelection").visible=true
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/VSeparatorSelection").visible=true
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/Selection").text+=node.name
		var text=""
		var detailed_text=""
		var i = 0
		for key in selected_units.keys():
			if i<2:
				text+=key+", "
			i+=1
			detailed_text+=key+str(selected_units[key].offset)+"\n"
		if i>2:
			text+="+"+str(i-2)+"..."
			
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/Selection").text=text
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/IconSelection").hint_tooltip=detailed_text
		
func _on_Tab_node_unselected(node) -> void:
	node.modulate.a=1
	if selected_units.has(node.name):
		var _s1 = selected_units.erase(node.name)
	
	if selected_units.size()==0:
		inspector.reset_node()
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/Selection").text=""
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/IconSelection").hint_tooltip=""
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/Selection").visible=false
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/IconSelection").visible=false
		get_tree().get_root().get_node("main").get_node("BottomTab/HBoxContainer/VSeparatorSelection").visible=false

func _on_Tab_connection_request(from, from_port, to, to_port) -> void:
	var command = from
	if from_port!=0 :
		command+="["+str(from_port)+"]"
	command+=" -> "+to
	if to_port!=0:
		command+="["+str(to_port)+"]"
	print(command+";")
	
	for iter in self.get_connection_list():
		if iter.to == to and iter.to_port == to_port:
			return
	var _s1 = self.connect_node(from, from_port, to, to_port)
	push_value(from,from_port)
	
func _on_Tab_disconnection_request(from, from_port, to, to_port) -> void:
	var command = from
	if from_port!=0 :
		command+="["+str(from_port)+"]"
	command+=" -: "+to
	if to_port!=0:
		command+="["+str(to_port)+"]"
	print(command+";")
	
	var slot := port_to_slot(to,to_port,true)
	if slot==-1:
		return
	
	var object := self.get_node(to)
	object.set_slot(slot,object.is_slot_enabled_left(slot),0,Color.white,
	object.is_slot_enabled_right(slot),0,object.get_slot_color_right(slot))
	get_node(to).calculate()
	
	self.disconnect_node(from, from_port, to, to_port)
	
func _on_Tab_copy_nodes_request() -> void:
	if selected_units.size()==0:
		return
	var command = "new * ="
	if selected_units.size()>1:
		command+="["
		for iter in selected_units:
			command+=iter+", "
		command = command.rstrip(", ")
		command+="]"
	else:	command+= selected_units.keys()[0]
	command += ";"
	print(command)
	clipboard=selected_units.duplicate(true)
	print("copy ",selected_units,";")

func _on_Tab_paste_nodes_request() -> void :
	for iter in selected_units.keys():
		_on_Tab_node_unselected(selected_units[iter])
	print("*;")
	for iter in clipboard.keys():
		var node = GateConstructor.setup_gate(clipboard[iter].gate_type,clipboard[iter].offset+Vector2(40,40))
		self.add_child(node)
		selected_units[node.name]=node
		set_selected(node)
		emit_signal("node_selected",node)
	print("paste ",clipboard," as ",selected_units,";")

func _on_Tab_delete_nodes_request():
	$DeleteConfirm.dialog_text="Confirm delete request of "+str(selected_units.size())+" items."
	$DeleteConfirm.popup()

func _on_DeleteConfirm_confirmed():	
	print("del ",selected_units,";")
	get_node("../../../RightTab/TabSelection/Tabs/Inspector").reset_node()
	for unit in selected_units:
		for iter in get_connection_list():	
			if iter.from==unit or iter.to==unit:
				self._on_Tab_disconnection_request(iter.from, iter.from_port, iter.to, iter.to_port)
		get_node(unit).queue_free()
	selected_units.clear()
	
func push_value(from : String,port : int) -> void:
	for iter in get_connection_list():
		if iter["from"]==from and iter["from_port"]==port:
			var slot := port_to_slot(iter.to,iter.to_port,true)
			if slot ==-1:
				return
			get_node(iter.to).set_slot(slot,get_node(iter.to).is_slot_enabled_left(slot),0,get_node(from).get_connection_output_color(port),
			get_node(iter.to).is_slot_enabled_right(slot),0,get_node(iter.to).get_slot_color_right(slot))
			
			var command = from
			if port!=0 :
				command+="["+str(port)+"]"
			command+=" -> "+iter.to
			if iter.to_port!=0:
				command+="["+str(iter.to_port)+"]"
			print("\t└ ",command, ":= ",str(get_node(iter.to).calculate()).to_lower())

func port_to_slot(from : String, port : int, is_left : bool) -> int :
	var object :=  self.get_node(from)
	var index := 0
	
	if is_left:
		for i in range(object.get_child_count()): 
			if object.is_slot_enabled_left(i):
				if index==port:
					return i
				else:	index+=1
	else:
		for i in range(object.get_child_count()): 
			if object.is_slot_enabled_right(i):
				if index==port:
					return i
				else:	index+=1
	return -1


func _on_Tab_popup_request(position):
	$CreateNew.rect_position= position
	$CreateNew.popup()

func _on_ItemList_item_selected(index):
	var node = GateConstructor.setup_gate(get_node("CreateNew/ItemList").get_item_text(index).split(" ")[0],($CreateNew.rect_position+scroll_offset)/zoom)
	self.add_child(node)
	$CreateNew.visible=false
	$CreateNew/ItemList.unselect_all()
