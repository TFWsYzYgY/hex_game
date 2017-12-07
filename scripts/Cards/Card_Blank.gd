extends "Card.gd"

	
#func _on_Card_Blank_input_event( viewport, event, shape_idx ):
#
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
#		var m = get_tree().get_root().get_node("main")
#		print("Blank Click index: "+ str(get_ind()))
#		#m.add_card(get_ind(), true)
#		m.rpc("add_card", get_ind(), true)