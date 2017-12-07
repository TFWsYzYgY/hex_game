extends Panel



func _on_cardlist_item_activated( index ):
	var cardname = get_node("cardlist").get_item_text(index)

	var box = get_node("Panel_Deck/Box_Deck")
	
	#TODO: multiple cards allowed in deck?
	if box.has_node(cardname):
		var n = box.get_node(cardname)
		box.remove_child(n)
		n.queue_free()
	else:
		var l = Label.new()
		l.set_text(cardname)
		l.set_name(cardname)
		box.add_child(l)
		