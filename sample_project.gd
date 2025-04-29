extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Button.pressed.connect(_on_button_pressed)
	
func _on_button_pressed() -> void:
	get_tree().get_current_scene().get_node("CanvasLayer_CreditsList").open_credits_list.emit()
