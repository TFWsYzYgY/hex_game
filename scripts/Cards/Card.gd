extends Area2D

export (String) var name
export (int) var units
var owner = null
var needs_direction = false
var overwrite = false
var fast = 1

var v1 = Vector2(110, 0)
var v2 = Vector2(55, 96)


func _ready():
	if name != "Blank":
		get_node("Panel/Label_units").set_text(str(units))

#swap the coordinatesystem
func coord_to_ind(pos):
	var j = int(pos.y/v2.y)
	pos -= j*v2
	var i = int(pos.x/v1.x)
	
	return Vector2(i, j)
	
#swap the coordinatesystem
func ind_to_coord(pos):
	return pos.x*v1 + pos.y*v2
	
func get_ind():
	return coord_to_ind(get_position())
	
func set_ind(ind):
	set("position", ind_to_coord(ind))
	
func add_units(n, player):
	print(name)
	print(owner)
	
	if player == owner:
		units += n
	else:
		units -= n
		if units < 0:
			units = abs(units)
			owner = player
			
	set_teamcolor()
	get_node("Panel/Label_units").set_text(str(units))
	
	
func get_owner():
	return owner
	
func get_units():
	return units
	
func get_overwrite():
	return overwrite
	
func get_name():
	return name
	
func set_teamcolor():
	if units == 0:
		owner = -1
	if owner == -1:
		get_node("Panel/Label_units").set("custom_colors/font_color", Color(1,1,1))
	if owner == 0:
		get_node("Panel/Label_units").set("custom_colors/font_color", Color(1,0,0))
	if owner == 1:
		get_node("Panel/Label_units").set("custom_colors/font_color", Color(0,1,1))

func entering(player):
	owner = player
	set_teamcolor()
	get_parent().add_all_neighbors(get_ind())
	
func get_fast():
	return fast
	
	