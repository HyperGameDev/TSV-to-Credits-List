@tool
class_name CreditsList_TSV_Import extends CanvasLayer

signal open_credits_list
signal close_credits_list

@onready var credits_container: ScrollContainer = %ScrollContainer_Credits
@onready var labels_vbox: VBoxContainer = %VBox_Labels
@onready var credits_list: VBoxContainer = %Credits_List

@onready var credits_tween_control: Control = %Credits_Tween_Control

@onready var button_close: Button = %Button_Close

const SCROLL_SPEED_DIVISOR: float = 200.

var credits_array: Array[String] = []

func _ready() -> void:		
	button_close.pressed.connect(_on_close_pressed)
	open_credits_list.connect(_on_open_credits_list)
	close_credits_list.connect(_on_close_credits_list)
	
	if not Engine.is_editor_hint():
		start_scroll()

func start_scroll() -> void:
	var scroll_size: float = credits_list.size.y
	var scroll_speed: float = scroll_size / SCROLL_SPEED_DIVISOR
	
	if scroll_size > 0:
		var tween = credits_tween_control.create_tween()
		tween.tween_property(credits_container, "scroll_vertical", scroll_size, scroll_speed)
		tween.finished.connect(_on_scroll_finished)

func _on_scroll_finished() -> void:
	close_credits_list.emit()
	
func _on_close_pressed() -> void:
	close_credits_list.emit()
	
func _on_open_credits_list() -> void:
	self.visible = true
	start_scroll()
	
func _on_close_credits_list() -> void:
	self.visible = false
	
