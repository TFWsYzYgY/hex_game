extends "Card.gd"

func entering(player):
	.entering(player)
	get_parent().add_units_circle(2, get_ind())
