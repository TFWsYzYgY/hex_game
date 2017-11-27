extends "Card.gd"

func entering(player):
	.entering(player)
	get_parent().push_last_tile_line(get_ind())
