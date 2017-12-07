extends Node

# Default game port
const DEFAULT_PORT = 10567

# Max number of players
#TODO: check if total players = 2 or server + 2players
const MAX_PEERS = 2

var player_count = 0

# Name for my player
var player_name = "The Warrior"

# Names for remote players in id:name format
var players = {}

var deck = []

var current_scene = null


# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)


# Callback from SceneTree
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/world")): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions
remote func register_player(id, name):
	print("registering player: " + name)
	if (get_tree().is_network_server()):
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name) # Send myself to new dude
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
			rpc_id(p_id, "register_player", id, name) # Send new dude to player

	players[id] = name
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func goto_scene(path, player_spawns):
	
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:

	call_deferred("_deferred_goto_scene",path, player_spawns)

func _deferred_goto_scene(path, player_spawns):
    # Immediately free the current scene,
    # there is no risk here.
	current_scene.free()

    # Load new scene
	var s = ResourceLoader.load(path)

    # Instance the new scene
	current_scene = s.instance()

    # Add it to the active scene, as child of root
	get_tree().get_root().add_child(current_scene)

    # optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene( current_scene )
	
	current_scene.set_network_master(get_tree().get_network_unique_id())
	current_scene.addPlayers(player_name, players, player_spawns)
	current_scene.addDeck(deck)
	current_scene.initialize()
	
	print("size: " + str(players.size()))
	print("Scene change finished")


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if (not id in players_ready):
		players_ready.append(id)

	if (players_ready.size() == players.size()):
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(name):
	player_name = name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

#this gamestate belongs to a client now
func join_game(ip, name):
	player_name = name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())
	
	if players.size() > 1:
		print("too many players on the server")
		return
	
	#TODO: maybe reverse player_spawns to player number: id
	var player_spawns = {}
	player_spawns[1] = 0
	
	var player_count = 1

	for p in players:
		player_spawns[p] = player_count
		player_count += 1
		
	print("player count: " + str(player_count))
	print("spawns: " + str(player_spawns))
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "goto_scene", "res://scenes/main/game.tscn", player_spawns)
	
	goto_scene("res://scenes/main/game.tscn", player_spawns)
	

func end_game():
	if (has_node("/root/world")): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() - 1 )
	
func set_deck(array):
	deck  = array
	
	
	
	
	