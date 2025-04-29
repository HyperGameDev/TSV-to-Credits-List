@tool
class_name CreditsList_TSV_Import extends CanvasLayer

signal open_credits_list
signal close_credits_list

@onready var credits_container: ScrollContainer = %ScrollContainer_Credits
@onready var vbox_labels: VBoxContainer = %VBox_Labels

@onready var button_close: Button = %Button_Close

var credits_array: Array[String] = []

func _ready() -> void:		
	button_close.pressed.connect(_on_close_pressed)
	open_credits_list.connect(_on_open_credits_list)
	close_credits_list.connect(_on_close_credits_list)
	
	if credits_container.get_children():
		credits_container.get_child(0).visible = true
	
func _on_close_pressed() -> void:
	close_credits_list.emit()
	
func _on_open_credits_list() -> void:
	self.visible = true
	
func _on_close_credits_list() -> void:
	self.visible = false
	
