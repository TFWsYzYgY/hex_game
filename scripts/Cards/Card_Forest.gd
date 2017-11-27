extends "Card.gd"

func _init():
	needs_direction = true

func entering(player):
	get_parent().move_cards_circle(get_ind())
	.entering(player)
