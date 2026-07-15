extends Control


var conf = ConfigFile.new()
var save_path = "user://save01.sav"
var is_loading: bool = false

@onready var _load = $"/root/auto_load"
@onready var _loading = $'/root/n_animLoading'


func _enter_tree() -> void:	
	#save_settings()
	load_settings()
	
	#print(DisplayServer.window_get_size())
	#$Label.text = str(DisplayServer.window_get_size())
	#$Label.text = "alpha v0.04"
	
	#save_game()
	#load_game()
	
func _ready() -> void:
	#save_game()
	pass
	
func _process(delta) -> void:
	# Quick save and load
	if Input.is_action_just_pressed("cg_quick_save"):
		save_game()
	
	if Input.is_action_just_pressed("cg_quick_load"):
		load_game()
	
	# Debug
	$Label.position.x += 100 * delta
	
	if $Label.position.x > size.x:
		$Label.position.x = -100
	
func save_settings():
	conf.set_value("display", "title", "ChamberGlit")
	conf.set_value("display", "width", 1280)
	conf.set_value("display", "height", 720)
	
	conf.set_value("audio", "volume", 0.0)
	conf.set_value("audio", "bgm", -0.4)
	conf.set_value("audio", "sfx", -0.6)
	
	conf.save("user://settings.ini")
	
func load_settings():
	var settings = conf.load("user://settings.ini")
	if settings != OK:
		return
		
	# Audio
	for audio in conf.get_sections():
		var audio_vol = conf.get_value("audio", "volume")
		var audio_bgm = conf.get_value("audio", "bgm")
		var audio_sfx = conf.get_value("audio", "sfx")

		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), audio_vol)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"), audio_bgm)
		# -SFX
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx_delay"), audio_sfx)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx_walk"), audio_sfx)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx_battles"), audio_sfx)
	
	# Display
	for display in conf.get_sections():
		var display_title = conf.get_value("display", "title")
		var display_width = conf.get_value("display", "width")
		var display_height = conf.get_value("display", "height")
		
		var window = get_window()
		var window_size = Vector2(display_width, display_height)
		var screen_size = DisplayServer.screen_get_size()
		print(screen_size)
		
		DisplayServer.window_set_title(display_title)
		
		ProjectSettings.set_setting("display/window/size/viewport_width", window_size.x)
		ProjectSettings.set_setting("display/window/size/viewport_height", window_size.y)
		
		window.size = window_size
		
		@warning_ignore("integer_division")
		window.position = screen_size / 2 - window.size / 2
		

func save_game():
	_loading._in.emit()
	
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	
	for node in save_nodes:
		# Check if the node is instanced, so it can be instanced again while loading
		if node.scene_file_path.is_empty():
			print("Persistent node '%s' is not an instanced scene, skipped." % node.name)
			continue
		
		# Check if the node has a save function
		if not node.has_method("save"):
			print("Persistent node '%s' is missing a save() function, skipped." % node.name)
			continue
			
		# Call the node's save function
		var node_data = node.call("save")
		
		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)
		
		# Store the save dict as a new line
		save_file.store_line(json_string)
	
	await _loading.tween.finished	
	_loading._out.emit()
		
func load_game():
	_loading._in.emit()
	is_loading = true
	
	if not FileAccess.file_exists(save_path):
		return
		
	# Revert the game state for not clone objects during loading
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for i in save_nodes:
		i.queue_free()
		
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), "in",
				json_string, "at line", json.get_error_line())
			continue
			
		var node_data = json.data
		
		# Go to saved scene
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		new_object.name = node_data["name"]
		# TODO: Figure how to change node name without numbers (eg.: $Node2, $Node3, etc...)
		
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])	
		
	is_loading = false
	
	await _loading.tween.finished	
	_loading._out.emit()
		
func test():
	#"XCVZPL;,WOPCNE[0JWEK]P21]0H0821HNC3IPB7HJXO[M12PON]"
	var title = "P̷͉̳̹͚̖̼̏͂̽̈́͛̀͐̀̍͆͝R̴̡͇͍͉͎͕̫͒̈́̀Ō̷̲̥̖̘̬̩̰̟̥̱̫ͅȚ̸͇̔͠Ê̶̯̜̪̥͖͓̭͎̿̍͗͜͜C̷̡̧͓̦̗͈̙͇͍̝̳̭̯͙͔͑̌͌̑̀̈́̿̅̀̓͑̂̾́Ç̸̡̧̙͎̺͍̬͙͙͙̗̣͈̣̳̩̏̃̓̂̒̕͠Ḯ̸̡̙͔͕̗͂̈́̉Ǫ̴̗̻̩͇͕͓̘̺̖͈́͜͠Ņ̸̝̣̻͗͊͆̔"
	OS.alert("(Zzz... ¿Por qué me habrán tenido que despertar...?)", title)
	OS.alert("(Bien, crí@. Parece que has encontrado un error no especificado.)", title)
	OS.alert("(Contacta con <4LG0RYTHM> y dile cómo lo has encontrado.\n"
		+ "El enlace está en <README.TXT>, junto con instrucciones más detalladas..)", title)
	OS.alert("(El bucle se suspenderá ahora. Intenta entrar otra vez.)", title)
	OS.alert("⁽ʸ ᵐᵉ ᵈᵉʲᵃˢ ᵈᵒʳᵐⁱʳ ᵈᵉ ᵘⁿᵃ ᵛᵉᶻ.⁾", title)
	get_tree().quit()
