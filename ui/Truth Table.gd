extends VBoxContainer

var header = preload("res://ui/TrutTableHeader.tscn")
var socket =  preload("res://ui/TrutTableInstance.tscn")
onready var tabs := get_node("/root/main/TabContainer")

var displayed_objects:=[]

func show_ui() -> void:
	self.visible=true
	get_node("TabName").text=tabs.get_child(tabs.current_tab).name
	get_node("Type/Value").text = tabs.get_child(tabs.current_tab).type
	
	var output :=""
	
	var displayed_objects:={"VAR":[],"PREFAB_INPUT":[],"OUTPUT":[],"PREFAB_OUTPUT":[]}
	
	for iter in tabs.get_child(tabs.current_tab).get_children():
		if iter.get_class()== "GraphNode" and ["VAR","PREFAB_INPUT","PREFAB_OUTPUT","OUTPUT"].has \
		(iter.gate_type.to_upper()):
			displayed_objects[iter.gate_type.to_upper()].append(iter)
	var column:=0
	for i in displayed_objects:
		for j in range (displayed_objects[i].size()):
			column+=1
			output+=displayed_objects[i][j].name+"\t"
	output+="\n"
	var input_count : int = displayed_objects.VAR.size()+displayed_objects.PREFAB_INPUT.size()
	for i in range(pow(2,input_count)):
		var binary := to_binary(i,input_count)
		
		for j in range(column):
			output+= str(binary[j])+"\t" if j<input_count else "0\t"
		output+="\n"
	
#	for i in range(pow(2,displayed_objects.VAR.size()+displayed_objects.PREFAB_INPUT.size())):
#			var counter=0
#			for key  in array.Variables.keys():
#				array.Variables[key].Node.get_node("Outputs/Output").SetValue(int(get_node("ScrollContainer/GridContainer/"+str(i)+","+str(counter)).text))
#				counter+=1
#			yield(get_tree().create_timer(0.03), "timeout")
#			for key  in array.Outputs.keys():
#				get_node("ScrollContainer/GridContainer/"+str(i)+","+str(counter)).text=str(array.Outputs[key].get_node("Sockets/Input").value)
#				counter+=1
	output+=" [/table]"
	get_node("ContentBox/Content").text=output

# Returns the given input in binary
func to_binary(number:int, bit:int) -> Array:
	var i :=0
	var array:=[]
	for _j in range(bit):array.append(0)
	while number>0:
		array[i]=number%2
		number/=2
		i+=1
	array.invert()
	return array

	
