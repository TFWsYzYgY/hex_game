extends "Card.gd"

func _init():
	fast = 0

func entering(player):
	.entering(player)
	get_parent().increase("land", 1)
