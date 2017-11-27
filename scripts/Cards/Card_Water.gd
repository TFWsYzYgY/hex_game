extends "Card.gd"

func entering(player):
	.entering(player)
	get_parent().add_units_to_all_neighbours(2, get_ind())
