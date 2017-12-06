extends Area2D

var v1 = Vector2(110, 0)
var v2 = Vector2(55, 96)

#swap the coordinatesystem
func coord_to_ind(pos):
	var j = round(pos.y/v2.y)
	pos -= j*v2
	var i = round(pos.x/v1.x)
	
	return Vector2(i, j)
	
	
func _on_Area2D_input_event(viewport, event, shape_idx ):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var m = get_tree().get_root().get_node("main")
		if m.is_active():
			
			var ind = coord_to_ind(get_global_mouse_position())
			print("Board Click index: "+ str(ind))
			m.rpc("add_card", ind, true, m.get_card_path())