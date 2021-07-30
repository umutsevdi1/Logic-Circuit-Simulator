extends Panel

var active_tab

func _ready() -> void:
	get_node("Tabs").visible=false
	for iter in get_node("VBoxContainer").get_children():
		var _s = iter.connect("pressed",self,"switch_tabs")

func switch_tabs() -> void:
	if active_tab!=null:
		active_tab.pressed=false
		active_tab=null
	for i in range(get_node("VBoxContainer").get_child_count()):
		if get_node("VBoxContainer").get_child(i).pressed:
			active_tab=get_node("VBoxContainer").get_child(i)
			break
	show_ui()	

func show_ui() -> void:
	if active_tab!=null:
		get_node("../../TabContainer").margin_right=-390
		get_node("Tabs").visible=true
		get_node("Tabs/Header").text=active_tab.name
		for iter in get_node("Tabs").get_children():
			iter.visible= iter.name =="Header"
		get_node("Tabs/"+active_tab.name).show_ui()
	else:
		get_node("Tabs").visible=false
		get_node("../../TabContainer").margin_right=-60
