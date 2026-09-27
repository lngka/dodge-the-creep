extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

func _ready() -> void:
	_setup_mobile_dpad()


func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()
	

func _on_message_timer_timeout() -> void:
	$Message.hide()


func _setup_mobile_dpad() -> void:
	var root: Control = $MobileControls
	root.visible = (
		DisplayServer.is_touchscreen_available()
		or OS.has_feature("mobile")
		or OS.has_feature("web_android")
		or OS.has_feature("web_ios")
	)
	if not root.visible:
		return

	var keys := {
		"Up": "move_up",
		"Left": "move_left",
		"Down": "move_down",
		"Right": "move_right",
	}
	for name in keys:
		var button: Button = root.get_node(name)
		_style_keycap(button)
		_bind_key(button, keys[name])


func _style_keycap(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_key_style(false))
	button.add_theme_stylebox_override("hover", _make_key_style(false))
	button.add_theme_stylebox_override("pressed", _make_key_style(true))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 0.7))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.85))
	button.add_theme_font_size_override("font_size", 22)
	button.focus_mode = Control.FOCUS_NONE


func _make_key_style(pressed: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.22 if pressed else 0.12)
	style.border_color = Color(1, 1, 1, 0.32 if pressed else 0.22)
	style.set_border_width_all(1)
	# Thicker bottom edge reads like a physical keycap.
	style.border_width_bottom = 1 if pressed else 3
	style.set_corner_radius_all(8)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


func _bind_key(button: Button, action: String) -> void:
	button.button_down.connect(func() -> void:
		Input.action_press(action)
	)
	button.button_up.connect(func() -> void:
		Input.action_release(action)
	)
	button.tree_exiting.connect(func() -> void:
		if Input.is_action_pressed(action):
			Input.action_release(action)
	)
