@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("RandomSprite2D", "Sprite2D", preload("RandomSprite2D.gd"), preload("icon.png"))
	pass

func _exit_tree():
	remove_custom_type("RandomSprite2D")
