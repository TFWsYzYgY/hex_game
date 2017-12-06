extends Area2D

export (String) var name
export (int) var start_units
export (String) var text

var owner = null
var needs_direction = false
var overwrite = false
var fast = 1
var units = Vector2(0,0)

var v1 = Vector2(110, 0)
var v2 = Vector2(55, 96)


func _ready():
	if text != null:
		get_node("Node2D/Panel2/Text").set_text(text)

func text():
	if get_node("Node2D/Panel2").is_visible():
		get_node("Node2D/Panel2").hide()
	else:
		get_node("Node2D/Panel2").show()

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
		units[owner] += n
	else:
		units[owner] -= n
		var numb = units[owner]
		if numb < 0:
			units[owner] = 0
			owner = player
			units[player] = abs(numb)
		if numb == 0:
			owner = -1
	
	update_units()
	
	
func get_owner():
	return owner
	
func get_units(player):
	return units[player]
	
func get_overwrite():
	return overwrite
	
func get_name():
	return name
	
func update_units():
	get_node("panel_units_p1/units_p1").set_text(str(units[0]))
	get_node("panel_units_p2/units_p2").set_text(str(units[1]))

func entering(player):
	owner = player
	get_node("panel_units_p1/units_p1").set("custom_colors/font_color", Color(1,0,1))
	get_node("panel_units_p2/units_p2").set("custom_colors/font_color", Color(0,1,1))
	
	
	if start_units == 0:
		owner = -1
	else:
		units[owner] = start_units
	
	update_units()
	
func get_fast():
	return fast
	
	