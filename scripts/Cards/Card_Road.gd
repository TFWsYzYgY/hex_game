extends "Card.gd"

func entering(player):
	get_parent().move_cards_line(get_ind()) #direction+steps
	.entering(player)
