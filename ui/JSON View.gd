extends TextEdit

func _ready():
	self.add_keyword_color("header",Color("#afaa63"))
	self.add_keyword_color("import",Color("#afaa63"))
	self.add_keyword_color("table",Color("afaa63"))
	self.add_keyword_color("connect",Color("#afaa63"))
	self.add_color_region("\"","\"",Color("#70d56d"))
	
	var elements := [
		"name","type","input","output","source","path"
	]
	for i in elements:
		self.add_keyword_color(i,Color("#af0ac8"))
