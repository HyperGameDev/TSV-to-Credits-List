@tool
extends EditorPlugin

var main_plugin := preload("res://addons/tsv_to_credits_list/main_plugin.tscn").instantiate()

var _file_dialog: FileDialog = FileDialog.new()

var maximum_credit_length: int = 100
var lines_to_generate: int

var names_array: Array[String] = []
var credits_dictionary

func _enter_tree() -> void:
	add_control_to_bottom_panel(main_plugin,"TSV to Credits List")
	
	create_file_dialog()
	
	scene_changed.connect(_on_scene_changed)
	
	main_plugin.button_upload.pressed.connect(_on_upload_pressed)
	main_plugin.button_generate.pressed.connect(_on_generate_pressed)
	main_plugin.button_reset.pressed.connect(_on_reset_pressed)

func create_file_dialog() -> void:
	var base_control : Panel = EditorInterface.get_base_control()
	
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.filters = PackedStringArray(["*.tsv"])
	_file_dialog.connect("file_selected",_on_file_selected)
	
	base_control.add_child(_file_dialog)
	
func _on_upload_pressed() -> void:
	_file_dialog.show()
	_file_dialog.popup_centered_ratio(.5)
	
func _on_reset_pressed() -> void:
	show_preview_elements(false)
	main_plugin.file_name.text = "Upload a file..."
	reset_buttons(false)
	
func reset_buttons(do_reset:bool) -> void:
	main_plugin.button_reset.visible = do_reset
	main_plugin.button_upload.disabled = do_reset

func _on_file_selected(path) -> void:
	_file_dialog.hide()
	reset_buttons(true)
	
	clear_previous_tsv_data()
	
	var tsv_file_path: String = path
	main_plugin.file_name.text = tsv_file_path
	
	load_tsv(tsv_file_path)
	
func clear_previous_tsv_data() -> void:
	var tsv_table_rows: Array[Node] = main_plugin.vbox_tsv_table.get_children()
	names_array.clear()
	for row in tsv_table_rows:
		if row.name == "Row0":
			continue
		row.queue_free()
		

func load_tsv(path) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var tsv_data: String = file.get_as_text()
	
	parse_tsv(tsv_data)
	
func parse_tsv(data) -> void:
	var lines: PackedStringArray = data.split("\n")
	
	for line in lines:
		var line_data: PackedStringArray = line.split("\t")
		var credits_string: String = line_data[0] # [column number]
		
		if int(line_data[1]) > 0: # Check column 2 (totals) for anything not 0
			names_array.append(credits_string.substr(0,maximum_credit_length))
		
	lines_to_generate = names_array.size()
	if lines_to_generate > 0:
		generate_preview()

func generate_preview() -> void:
	generate_table_preview()
	show_tsv_to_generate()
	
func generate_table_preview() -> void:
	var tsv_table: VBoxContainer = main_plugin.vbox_tsv_table
	
	for i in lines_to_generate:
		var tsv_row := preload("res://addons/tsv_to_credits_list/row.tscn").instantiate()
		tsv_table.add_child(tsv_row)
		tsv_row.get_node("%Label_Credit").text = names_array[i]
		print(names_array[i])
		
func _on_scene_changed(scene):
	var generate_button: Button = main_plugin.button_generate
	
	if scene == null:
		generate_button.disabled = true
		generate_button.text = "[SCENE IS EMPTY]"
	else:
		generate_button.disabled = false
		generate_button.text = "Generate (in " + str(scene.name) + ")"
	
func show_preview_elements(do_show: bool) -> void:
	var tsv_preview: PanelContainer = main_plugin.tsv_preview
	var tsv_instructions: Label = main_plugin.tsv_instructions
	var generate_button: Button = main_plugin.button_generate 
	
	tsv_preview.visible = do_show
	tsv_instructions.visible = do_show
	generate_button.visible = do_show

func show_tsv_to_generate() -> void:
	var scene_being_edited := get_editor_interface().get_edited_scene_root()
	
	show_preview_elements(true)
	
	_on_scene_changed(scene_being_edited)
	
func _on_generate_pressed() -> void:
	var scene_being_edited := get_editor_interface().get_edited_scene_root()
	var add_a_list: bool = true
	
	var hbox_error: HBoxContainer = main_plugin.hbox_error
	var label_error_msg: Label = main_plugin.label_error_msg
	
	for node in scene_being_edited.get_children():
		if node is CreditsList_TSV_Import:
			add_a_list = false
			
			hbox_error.visible = true
			label_error_msg.text = "A credits lists already exists!"
			
			break
			
	if add_a_list:
		hbox_error.visible = false
		var credits_list := preload("res://addons/tsv_to_credits_list/tsv_credits_list.tscn").instantiate()

		if scene_being_edited:
			scene_being_edited.add_child(credits_list)
			generate_credits(scene_being_edited,credits_list)
			
	
func generate_credits(scene_being_edited,list_to_add_credits_to) -> void:
	var credits_container: MarginContainer = list_to_add_credits_to.credits_container
	
	for i in range(names_array.size()):
		var credit = names_array[i]
		var credit_label := preload("res://addons/tsv_to_credits_list/label_credit_1.tscn").instantiate()
		credits_container.add_child(credit_label)
		credit_label.owner = scene_being_edited
		credit_label.text = credit

		
	credits_container.get_child(0).visible = true
	add_list_to_edited_scene(scene_being_edited,list_to_add_credits_to)
	
func add_list_to_edited_scene(scene_with_credits,credits_list_to_add):
				
	credits_list_to_add.owner = scene_with_credits
	
	
	
	if not get_parent().is_editable_instance(credits_list_to_add):
		get_parent().set_editable_instance(credits_list_to_add,true)
	
	

func _exit_tree() -> void:
	remove_control_from_bottom_panel(main_plugin)
	main_plugin.queue_free()
