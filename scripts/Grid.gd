extends Node2D

export (PackedScene) var card

var player_name = null
var players = {}
var player_spawns = {}

var all_cards = {}
var curr_card = null
var active_player = 0
var is_active_player = false

var drag_pressed = false
var drag_start = null

var gather = 0
var gather_start = null

var starting_player = 0
var turn = 1
var scoring_rules = [true, true, true]
var points = [0,0]
#var deck = [Card_Blank, Card_Forest]
var max_land_plays = [100, 1]
var max_moves = [1, 1]
var max_actions = [100, 2]

#TODO reduce land_plays to normal value
var land_plays = [100, 1]
var moves = [1, 1]
var actions = [100, 2]
var dist = 1

var v1 = Vector2(110, 0)
var v2 = Vector2(55, 96)

var random_unified_deck = ["Beach", "Lava", "Village", "Stones",
"Forest", "Grass", "Haunted", "Water", "Road"]#"Waste" , TODO: make sure card underneath is really deleted not remaining underneath

var hand_size = 0
var max_hand_size = 5

var directions = { "east" : Vector2(1,0),
					"southeast" : Vector2(0,1),
					"southwest" : Vector2(-1,1),
					"west" : Vector2(-1,0),
					"northwest" : Vector2(0,-1),
					"northeast" : Vector2(1,-1)}

var vec_dir = { 0 : Vector2(0, -64), #north
				1 : Vector2(55, -32), #northeast
				2 : Vector2(55, 32),	#southeast
				3 : Vector2(0, 64),	#south
				4 : Vector2(-55, 32),	#southwest
				5 : Vector2(-55, -32)}	#northwest

func _ready():
	randomize()
	#var gs = get_node("/root/gamestate")
	
	
	#initializing gamestate
	set_active_player(starting_player)
	
	print("Turn: ", turn)
	print("Current player is: ", int(active_player))
	
	#lower UI
	update_label()
	
	#creating center
	var path = str("res://scenes/Card_Center.tscn")
	curr_card = load(path)	#maybe preload
	#rpc("add_card", Vector2(0,0), false)
	add_card(Vector2(0,0), false)
	
	#creating upper UI/hand
	#draw_card_from_deck()
	#draw_card_from_deck()
	
	for button in get_tree().get_nodes_in_group("butt"):
		print(button)
		button.connect("pressed", self, "_ui_button_pressed", [button])
	
	set_process(true)
	
func _get_active_player():
	return active_player
	
#redraw constantly
func _process(delta):
	get_node("CanvasLayer/gather").set_text(str(gather))
	update()
	
#draw red hex for each neighbor/empty tiles
func _draw():
	var c = Color(1.0, 0.0, 0.0)
	#for key in neighbors:
	#	draw_Hex(ind_to_coord(key), c)
	
	
#only 2 players-> switch between 0 and 1, take care of turnover
sync func swap_active_player():
	set_active_player(int(!active_player))
	
	if active_player == starting_player:
		update_points()
		turn += 1
		print("Turn: ", turn)
		print("Current player is: ", active_player)
	
func get_random_card_from_deck():
	var i = randi()%random_unified_deck.size()
	return str(random_unified_deck[i])
	
func has_neighbour(ind):
	for d in directions:
		if ind + directions[d] in all_cards:
			return true
	return false
	
func draw_card_from_deck():
	if is_active_player:
		if hand_size < max_hand_size:
			var s = get_random_card_from_deck()
			add_bttn_to_hand(s)
			hand_size += 1
	
func add_bttn_to_hand(card_name):
	# Load new scene
	print("Adding card to hand: " + card_name)
	var s = ResourceLoader.load("res://scenes/Texturebutton.tscn")
	var button = s.instance()
	button.name = "Card_" + card_name
	button.texture_normal = load("res://assets/images/Hexagon_Tiles/" + card_name+ ".png")
	get_node("CanvasLayer/ScrollContainer/HBoxContainer").add_child(button)
	button.connect("pressed", self, "_ui_button_pressed", [button])
	

#tested for all combinations, TODO: maybe put into its own scene as score
sync func update_label():
	var s = "CanvasLayer/Panel_score/HBoxContainer/"
	get_node(s + "vbox2/Label_lands1").set_text( str( land_plays[0])+"/"+str( max_land_plays[0]))
	get_node(s + "vbox4/Label_lands2").set_text( str( land_plays[1])+"/"+str( max_land_plays[1]))
	
	get_node(s + "vbox2/Label_moves1").set_text(str( moves[0])+"/"+str(max_moves[0]))
	get_node(s + "vbox4/Label_moves2").set_text(str( moves[1])+"/"+str(max_moves[1]))
	
	get_node(s + "vbox2/Label_actions1").set_text(str( actions[0])+"/"+str(max_actions[0]))
	get_node(s + "vbox4/Label_actions2").set_text(str( actions[1])+"/"+str(max_actions[1]))
	
#swap the coordinatesystem
func coord_to_ind(pos):
	var j = int(pos.y/v2.y)
	pos -= j*v2
	var i = int(pos.x/v1.x)
	return Vector2(i, j)
	
#swap the coordinatesystem
func ind_to_coord(pos):
	return pos.x*v1 + pos.y*v2
	
func can_place(ind, card):
	if card.get_name() == "Center":
		return true
	if land_plays[active_player] <= 0:
		return false
	if actions[active_player] <= 0:
		return false
	if not is_active_player:
		return false
	if card.get_overwrite():
		if not ind in all_cards:
			return false
		if all_cards[ind].get_name() == "Center":
			return false
	else:
		if ind in all_cards:
			return false
		return has_neighbour(ind)
		
	return true
#adding card to map
#flag -> player added card not init
sync func add_card(ind, flag):
	print("adding card at: ", str(ind))
	print(flag)
	
	if curr_card == null:
		return
		
	var e = curr_card.instance()
	print(can_place(ind, e))
	if can_place(ind, e):
		
			
		if e.get_overwrite():
			all_cards[ind].queue_free()
			all_cards.erase(ind)
			
		e.add_to_group("Karten")
		add_child(e)
		e.set_ind(ind)
		all_cards[ind] = e
		curr_card = null
		all_cards[ind].connect("input_event", self, "_get_tooltip", [all_cards[ind]])
		
		e.entering(active_player)
		
		if flag:
			actions[active_player] -= 1
			land_plays[active_player] -= 1
			rpc("update_label")
	else:
		print("unable to place the card!")



func add_units_to_card(n, ind):
	if ind in all_cards:
		var k = all_cards[ind]
		k.add_units(n, active_player)
		
func add_units_half_circle(n, ind):
	add_units_to_card(n, ind + directions["southwest"])	#links unten
	add_units_to_card(n, ind + directions["southeast"])	#unten rechts
	add_units_to_card(n, ind + directions["west"])	#links
		
func add_units_circle(n, ind):
	for d in directions:
		add_units_to_card(n, ind + directions[d])

	

func _get_tooltip(viewport, event, shape_idx, card):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and curr_card == null:
		var m = get_tree().get_root().get_node("main")
		#m.drag(event.pressed, card.get_ind())
		if curr_card == null and event.pressed and actions[active_player] > 0 and moves[active_player] > 0:
			print("clicky")
			if (gather_start == card.get_ind() or gather_start == null) and active_player == card.get_owner():
				print("Clicked Card has units: "+ str(card.get_units()))
				gather(card)
			else:
				("trying to place")
				place(card)
			
			#gather(ind, card)
	
func gather(card):
	print("Trying to gather units from tile...")
	var ind = card.get_ind()
	if all_cards[ind].get_units() > 0 and all_cards[ind].get_owner() == active_player:
		gather_start = ind
		all_cards[ind].add_units(-1, active_player)
		gather += 1
		print(str(active_player) + " gathered: ", str(gather))
		
		
# gathering should not be permanent until placed
# chosing card should cancel gathering
func place(card):
	var ind = card.get_ind()
	
	#path(gather_start, ind)
	
	#path/distance
	if gather > 0 and path(gather_start, ind) <= dist:
		print("placing gathered units at: " + str(ind))
		all_cards[ind].add_units(gather, active_player)
		gather = 0
		gather_start = null
		moves[active_player] -= 1
		actions[active_player] -= 1
	else:
		print("unable to place")
		all_cards[gather_start].add_units(gather, active_player)
		gather = 0
		gather_start = null
	
	
func distance(ind1, ind2):
	return (abs(ind1.x-ind2.x) + abs(ind1.x + ind1.y - ind2.x - ind2.y) + abs(ind1.y - ind2.y))/2
	
#A* algorithm from ind1 to ind2
#TODO: update pathing with max possible distance to decrease checks+remove prints 
func path(ind1, ind2):
	var frontier = {} # PriorityQueue()
	frontier[0] = ind1 #at ind 0
	var came_from = {}
	var cost_so_far = {}
	came_from[ind1] = null
	cost_so_far[ind1] = 0
	
	print(".")
	print("starting to path at: " + str(frontier[0]))
	
	while not frontier.empty():
		var current = null
		
		
		for f in frontier:
			print("frontier")
			print(frontier[f])
			print(f)
			
		var val = null
		for f in frontier:
			print(f)
			print(val)
			
			if val == null or f < val:
				val = f
				print("pathing value at: " + str(f))
				print(frontier[f])
				
		print("deleting")
		current = frontier[val]
		frontier.erase(val)
			
		print("continuing")
	
		if current == ind2:
			print("pathlength is: " + str(cost_so_far[current]))
			return cost_so_far[current]
		
		for d in directions:
			print(d)
			var next = current + directions[d]
			if next in all_cards:
				print("found next tile in this direction")
				var new_cost = cost_so_far[current] + all_cards[next].get_fast()
				print("updating the cost to: " + str(new_cost))
				
				if (not next in cost_so_far) or (new_cost < cost_so_far[next]):
					print("inserting")
					cost_so_far[next] = new_cost
					var priority = new_cost + distance(ind2, next)
					
					while priority in frontier:
						print(priority)
						priority *= 1.1
					
					frontier[priority] = next
					came_from[next] = current
	
	
	
func drag(pressed, ind):
	if not drag_pressed and pressed and active_player == all_cards[ind].get_owner():
		drag_pressed = true
		drag_start = ind 
	if drag_pressed and not pressed:
		drag_pressed = false
		
		if moves[active_player] > 0 and actions[active_player] > 0:
			if drag_start != ind:
				print("the distance of the drag is: " + str(distance(drag_start, ind)))
				var u = all_cards[drag_start].get_units()
				add_units_to_card(-u, drag_start)
				add_units_to_card(u, ind)
				
				moves[active_player] -= 1
				actions[active_player] -= 1
				update_label()
				
			else:
				print("Can't move to the same tile")
		else:
			print("No move actions left")
			
		drag_start = null
	
func _ui_button_pressed(button):
	print(button.name)
	print(button.get_name())
	var path = str("res://scenes/", button.name, ".tscn")
	curr_card = load(path)#maybe preload
	
func update_points():
	print("scoring...")
	if scoring_rules[0]:
		for k in all_cards:
			var i = all_cards[k].get_owner()
			if i != -1:
				points[i] += 2
				
	if scoring_rules[1]:
		var i = get_node("Card_Center").get_owner()
		
		if i != -1:
			points[i] += turn
		
	get_node("CanvasLayer/Panel_score/HBoxContainer/vbox2/Label_points1").set_text(str(points[0]))
	get_node("CanvasLayer/Panel_score/HBoxContainer/vbox4/Label_points2").set_text(str(points[1]))
	
#minus 1 bc unique id starts at 1
func _on_bttn_pass_pressed():
	
	draw_card_from_deck()
	print("buttontotnotnot")
	
	land_plays[active_player] = max_land_plays[active_player]
	moves[active_player] = max_moves[active_player]
	actions[active_player] = max_actions[active_player]

	update_label()
	
	rpc("swap_active_player")
	
	
#method for moving cards not swapping
func move_card(ind, dir):
	print("move card")
	
	var c = all_cards[ind]
	all_cards.erase(ind)
	c.set_ind(ind+dir)
	all_cards[ind+dir] = c


#method for entering cards
#TODO: direction as input
func move_cards_circle(ind):

	var c = null
	
	#need a starting direction which is saved 
	var v = ind+directions["east"]
	#if v is a card move it to storage
	if v in all_cards:
		c = all_cards[v]
		all_cards.erase(v)
		
	#rechts oben
	v = ind + directions["northeast"]
	if v in all_cards:
		move_card(v, directions["southeast"])

		
	#links oben
	v = ind + directions["northwest"]
	if v in all_cards:
		move_card(v, directions["east"])
		
	#links
	v = ind + directions["west"]
	if v in all_cards:
		move_card(v, directions["northeast"])
		
	#links unten
	v = ind + directions["southwest"]
	if v in all_cards:
		move_card(v, directions["northwest"])
		
	#rechts unten
	v = ind + directions["southeast"]
	if v in all_cards:
		move_card(v, directions["west"])
		
	#rechts
	if c != null:
		v = ind + directions["southeast"]
		c.set_ind(v)
		all_cards[v] = c
		
	
#method for entering cards
#TODO: direction as input
func move_cards_line(ind):
	print("moving in line: " + str(ind+directions["east"]))
	if ind in all_cards:
		move_cards_line(ind + directions["east"])
		move_card(ind, directions["east"])


#method for entering cards
#TODO: direction as input
func push_last_tile_line(ind1):
	var ind2 = ind1 + directions["west"]
	if ind2 in all_cards:
		push_last_tile_line(ind2)
	else:
		move_card(ind1, directions["west"])





#change the value of the actions
func increase(action, number):
	if action == "move":
		max_moves[active_player] += number
	if action == "action":
		max_actions[active_player] += number
	if action == "land":
		max_land_plays[active_player] += number
	
func addPlayers(name, name_list, spawns):
	player_name = name
	players = name_list
	player_spawns = spawns
	
	print(player_spawns)
	
	for p_id in player_spawns:
		if p_id == 1:
			if p_id == get_tree().get_network_unique_id():
				get_node("CanvasLayer/Panel_score/HBoxContainer/vbox1/Label_player1").text = player_name
			else:
				get_node("CanvasLayer/Panel_score/HBoxContainer/vbox1/Label_player1").text = players[p_id]
		
		if p_id != 1:
			if p_id == get_tree().get_network_unique_id():
				get_node("CanvasLayer/Panel_score/HBoxContainer/vbox3/Label_player2").text = player_name
			else:
				get_node("CanvasLayer/Panel_score/HBoxContainer/vbox3/Label_player2").text = players[p_id]
	
	
	


#drawing a red hex
func draw_Hex(coord, color):
	var points_hex = PoolVector2Array()
	#var points_hex = Vector2Array()
	var c = PoolColorArray()
		
	for vec in vec_dir:
		points_hex.push_back(coord + vec_dir[vec])
		c.push_back(color)

	draw_polygon(points_hex, c)
	
	
	#TODO: fix unique id/active_player
func set_active_player(player):
	active_player = player
	is_active_player = (active_player+1 == get_tree().get_network_unique_id())
	print("is this the active player: " + str(is_active_player))