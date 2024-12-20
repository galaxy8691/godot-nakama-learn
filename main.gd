extends Node

var ip = "113.107.139.70"
var port = 7350
var server_key = "defaultkey"
var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var multiplayer_bridge : NakamaMultiplayerBridge
var start_game_count : int = 0
var match_id : String = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	client = Nakama.create_client(server_key, ip, port, "http", 3, NakamaLogger.LOG_LEVEL.ERROR)
	socket = Nakama.create_socket_from(client)
	socket.connected.connect(self._on_socket_connected)
	socket.closed.connect(self._on_socket_closed)
	socket.received_error.connect(self._on_socket_error)
	if "--server" in OS.get_cmdline_args():
		for arg in OS.get_cmdline_args():
			if arg.begins_with("--matchid="):
				match_id = arg.split("=")[1]
				set_host()
				


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_login_button_pressed() -> void:
	var  email = $CanvasLayer/Panel/EmailLineEdit.text
	var password = $CanvasLayer/Panel/PasswordLineEdit.text
	session = await client.authenticate_email_async(email, password)
	await socket.connect_async(session)
	$CanvasLayer/Panel/LoginButton.disabled = true
	$CanvasLayer/Panel/EmailLineEdit.editable = false
	$CanvasLayer/Panel/PasswordLineEdit.editable = false
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_joined)
	multiplayer.set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)
	multiplayer.peer_connected.connect(self._on_peer_connected)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)


func _on_socket_connected() -> void:
	print("Socket connected.")


func _on_socket_closed() -> void:
	print("Socket closed.")

func _on_socket_error(error) -> void:
	print("Socket error: ", error)

func _on_match_join_error(error) -> void:
	print("Match join error: ", error)

func _on_match_joined() -> void:
	PlayerManager.add_player(multiplayer.get_unique_id())
	PlayerManager.set_my_peer_id(multiplayer.get_unique_id())
	print(multiplayer_bridge.match_id)
	print("Match joined.")
	await get_tree().create_timer(2.0).timeout
	if match_id != "":
		set_host_peer_id.rpc(multiplayer.get_unique_id())
		start_game.rpc()

func _on_peer_connected(peer_id) -> void:
	PlayerManager.add_player(peer_id)
	sync_player_list.rpc(PlayerManager.players)
	print("Peer connected: ", peer_id)

func _on_peer_disconnected(peer_id) -> void:
	print("Peer disconnected: ", peer_id)


func _on_cj_match_button_pressed() -> void:
	multiplayer_bridge.join_named_match($CanvasLayer/Panel2/MatchNameLineEdit.text)
	

@rpc("any_peer")
func sync_player_list(players : Array[int]) -> void:
	for player in players:
		if player not in PlayerManager.players:
			PlayerManager.add_player(player)
	for player in PlayerManager.players:
		print("player: ", player)


func _on_start_button_pressed() -> void:
	start_game.rpc()


@rpc("any_peer", "call_local")
func start_game() -> void:
	#print("player count: ", PlayerManager.get_player_count())
	start_game_count += 1
	if start_game_count == PlayerManager.get_player_count():
		if PlayerManager.get_host_peer_id() == -1:
			print("no host")
			var i : int = 0
			for player in PlayerManager.players:
				$Game.get_node("Player" + str(i+1)).peer_id = player
				$Game.get_node("Player" + str(i+1)).set_multiplayer_authority(player)
				i += 1
		else:
			print("host: ", PlayerManager.get_host_peer_id())
			$Game/Player1.set_multiplayer_authority(PlayerManager.get_host_peer_id())
			$Game/Player1.peer_id = PlayerManager.players[0]
			$Game/Player2.set_multiplayer_authority(PlayerManager.get_host_peer_id())
			$Game/Player2.peer_id = PlayerManager.players[1]
		$Game.visible = true
		$CanvasLayer.visible = false

func _on_host_button_pressed() -> void:
	set_host_peer_id.rpc(multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func set_host_peer_id(peer_id : int) -> void:
	PlayerManager.set_host_peer_id(peer_id)
	print("set host peer id: ", peer_id)

func _on_login_test_1_button_pressed() -> void:
	var  email = "test1@test.com"
	var password = "password"
	session = await client.authenticate_email_async(email, password)
	await socket.connect_async(session)
	$CanvasLayer/Panel/LoginButton.disabled = true
	$CanvasLayer/Panel/EmailLineEdit.editable = false
	$CanvasLayer/Panel/PasswordLineEdit.editable = false
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_joined)
	multiplayer.set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)
	multiplayer.peer_connected.connect(self._on_peer_connected)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)

func _on_login_test_2_button_pressed() -> void:
	var  email = "test2@test.com"
	var password = "password"
	session = await client.authenticate_email_async(email, password)
	await socket.connect_async(session)
	$CanvasLayer/Panel/LoginButton.disabled = true
	$CanvasLayer/Panel/EmailLineEdit.editable = false
	$CanvasLayer/Panel/PasswordLineEdit.editable = false
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_joined)
	multiplayer.set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)
	multiplayer.peer_connected.connect(self._on_peer_connected)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)

func _on_login_test_3_button_pressed() -> void:
	set_host()

func set_host():
	var  email = "test3@test.com"
	var password = "password"
	session = await client.authenticate_email_async(email, password)
	await socket.connect_async(session)
	$CanvasLayer/Panel/LoginButton.disabled = true
	$CanvasLayer/Panel/EmailLineEdit.editable = false
	$CanvasLayer/Panel/PasswordLineEdit.editable = false
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_joined)
	multiplayer.set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)
	multiplayer.peer_connected.connect(self._on_peer_connected)
	multiplayer.peer_disconnected.connect(self._on_peer_disconnected)
	await get_tree().create_timer(2.0).timeout
	if match_id != "":
		multiplayer_bridge.join_match(match_id)
		
