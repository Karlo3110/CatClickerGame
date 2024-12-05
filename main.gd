extends Node2D

var score = 0
var click_value = 1
var click_upgrade_cost = 25
var auto_clickers = 0
var auto_clicker_cost = 50
var auto_clicker_rate = 1

func _ready():
	load_game()
	update_ui()
	update_timer_interval()  # Ensure the timer starts with the correct interval

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not is_mouse_over_ui():
				add_click()

func add_click():
	score += click_value
	update_ui()

func update_ui():
	$UI/Control/Label.text = "Score: %d" % score
	$UI/Control/UpgradeClickButton.text = "Upgrade Click (Cost: %d)" % click_upgrade_cost
	$UI/Control/AutoClickerButton.text = "Buy Auto Clicker (Cost: %d)" % auto_clicker_cost
	$UI/Control/AutoClickersLabel.text = "AutoClickers: %d" % auto_clickers
	
	if auto_clickers > 0:
		$UI/AutoClickerBar.visible = true
	else:
		$UI/AutoClickerBar.visible = false


func is_mouse_over_ui() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	var ui_elements = $UI/Control.get_children()
	for element in ui_elements:
		if element is Control:
			var rect = Rect2(element.global_position, element.size)
			if rect.has_point(mouse_pos):
				return true
	return false

func _on_upgrade_click_button_pressed():
	if score >= click_upgrade_cost:
		score -= click_upgrade_cost
		click_value += 1
		click_upgrade_cost = int(click_upgrade_cost * 1.5)
		update_ui()

func _on_auto_clicker_button_pressed():
	if score >= auto_clicker_cost:
		score -= auto_clicker_cost
		auto_clickers += 1
		auto_clicker_cost = int(auto_clicker_cost * 1.3)
		update_timer_interval()
		update_ui()

func update_timer_interval():
	var base_time = 5.0  # Base interval in seconds
	if auto_clickers >= 10:
		$Timer.wait_time = base_time / 2  # Halve the time after 10 auto-clickers
	else:
		$Timer.wait_time = base_time
	$Timer.start()  # Restart the timer with the new interval

func _on_timer_timeout():
	if auto_clickers > 0:
		score += auto_clickers * click_value
		update_ui()
	$UI/AutoClickerBar.value = 0  # Reset the progress bar when the timer triggers

func _process(delta):
	# Update the progress bar to show the timer countdown
	if $Timer.time_left > 0:
		$UI/AutoClickerBar.value = 1.0 - ($Timer.time_left / $Timer.wait_time)

func save_game():
	var save_data = {
		"score": score,
		"click_value": click_value,
		"click_upgrade_cost": click_upgrade_cost,
		"auto_clickers": auto_clickers,
		"auto_clicker_cost": auto_clicker_cost
	}
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game():
	if FileAccess.file_exists("user://save_data.json"):
		var file = FileAccess.open("user://save_data.json", FileAccess.READ)
		var save_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var result = json.parse(save_text)
		if result == OK:
			var save_data = json.data
			score = save_data.get("score", 0)
			click_value = save_data.get("click_value", 1)
			click_upgrade_cost = save_data.get("click_upgrade_cost", 25)
			auto_clickers = save_data.get("auto_clickers", 0)
			auto_clicker_cost = save_data.get("auto_clicker_cost", 50)
		update_ui()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()



func reset_game():
	score = 0
	click_value = 1
	click_upgrade_cost = 25
	auto_clickers = 0
	auto_clicker_cost = 50
	auto_clicker_rate = 1
	
	if FileAccess.file_exists("user://save_data.json"):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("save_data.json")
				
	update_ui()
	update_timer_interval()


func _on_reset_game_pressed() -> void:
	reset_game()
