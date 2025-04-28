@tool
class_name CreditsList_TSV_Import extends CanvasLayer

signal open_message_box
signal close_message_box

@onready var credits_container: MarginContainer = %MarginContainer_Messages

@onready var button_next: Button = %Button_Next

var current_credit_number: int = 0


var message_array: Array[String] = []

func _ready() -> void:		
	button_next.pressed.connect(_on_next_pressed)
	open_message_box.connect(_on_open_message_box)
	close_message_box.connect(_on_close_message_box)
	
	if credits_container.get_children():
		credits_container.get_child(0).visible = true
	
func _on_next_pressed() -> void:
	if current_credit_number + 1 >= credits_container.get_children().size():
		close_message_box.emit()
	else:
		credits_container.get_child(current_credit_number).visible = false
		current_credit_number += 1
		credits_container.get_child(current_credit_number).visible = true
	
func _on_open_message_box() -> void:
	self.visible = true
	
func _on_close_message_box() -> void:
	self.visible = false
	credits_container.get_child(current_credit_number).visible = false
	current_credit_number = 0
	credits_container.get_child(0).visible = true
	
