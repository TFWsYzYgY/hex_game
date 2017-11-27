extends "Card.gd"

func entering(player):
	.entering(player)
	get_parent().add_units_to_half_neighbours(3, get_ind())
