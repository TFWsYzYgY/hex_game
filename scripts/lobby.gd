extends Control

func _ready():
	# Called every time the node is added to the scene.
	#linking the signals from gamestate to functions here
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	
	

func _on_host_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return
	
	get_node("connect").hide()
	get_node("players").show()
	get_node("connect/error_label").text=""

	var name = get_node("connect/name").text
	
	gamestate.set_deck(load_deck())
	gamestate.host_game(name)
	refresh_lobby()

func _on_join_pressed():
	#check that name is not empty
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	#check that ip is valid
	var ip = get_node("connect/ip").text
	if (not ip.is_valid_ip_address()):
		get_node("connect/error_label").text="Invalid IPv4 address!"
		return

	#disable buttons -> safety while loading
	get_node("connect/error_label").text=""
	get_node("connect/host").disabled=true
	get_node("connect/join").disabled=true

	var name = get_node("connect/name").text
	gamestate.set_deck(load_deck())
	gamestate.join_game(ip, name)
	# refresh_lobby() gets called by the player_list_changed signal

func _on_connection_success():
	get_node("connect").hide()
	get_node("players").show()

func _on_connection_failed():
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false
	get_node("connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("players").hide()
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled

func _on_game_error(errtxt):
	get_node("error").text=errtxt
	get_node("error").popup_centered_minsize()

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	get_node("players/list").clear()
	get_node("players/list").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("players/list").add_item(p)

	get_node("players/start").disabled=not get_tree().is_network_server()

func _on_start_pressed():
	gamestate.begin_game()


func _on_deckeditor_pressed():
	var deck = load_deck()

	for card in deck:
		var l = Label.new()
		l.set_text(card)
		l.set_name(card)
		get_node("editor/Panel_Deck/Box_Deck").add_child(l)
		
	get_node("connect").hide()
	get_node("editor").show()
	get_node("connect/error_label").text=""


func _on_back_to_menu_pressed():
	save_deck()
	get_node("editor").hide()
	get_node("connect").show()
	

func save_deck():
	var savegame = File.new()
	savegame.open("user://savedeck.save", File.WRITE)
	
	var box = get_node("editor/Panel_Deck/Box_Deck")

	for l in box.get_children():
		savegame.store_line(to_json(l.get_name()))
		box.remove_child(l)
		l.queue_free()
		
	savegame.close()
	
	
# Note: This can be called from anywhere inside the tree.  This function is path independent.
func load_deck():
	var savegame = File.new()
	var deck = []
	
	if !savegame.file_exists("user://savedeck.save"):
		return deck

	savegame.open("user://savedeck.save", File.READ)
	#30 bc arbitrary max deck
	while !savegame.eof_reached():
		var line = parse_json(savegame.get_line())
		if line != null:
			deck.append(line)
	
	savegame.close()
	
	return deck