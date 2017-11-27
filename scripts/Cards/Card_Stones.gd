extends "Card.gd"

func entering(player):
	.entering(player)
	get_parent().increase("move", 1)
	