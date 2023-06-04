@tool
extends EditorScript

@export var recursive = false

var editor : EditorInterface
var selection : EditorSelection

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	editor = get_editor_interface()
	selection = editor.get_selection()
	
	if selection != null:
		toggle_visibility(selection)


func toggle_visibility(selection):
	var selected_nodes : Array[Node] = selection.get_selected_nodes()
	
	for node in selected_nodes:
		var children = node.find_children("*", "", recursive)
		for child in children:
			if child.is_visible():
				child.set_visible(false)
			else:
				child.set_visible(true)
