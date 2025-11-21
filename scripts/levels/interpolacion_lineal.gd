extends Node2D

var pause_open := false
var tiempo_restante := 900.0
var group_to_show: Node

var respuesta_correcta := "1.0395"
var categoria := "Ecuaciones lineales"
var metodo := "Montante"
var sistema_cuentas: Node

func _ready() -> void:
	$Panel.visible = false
	$TextureRect/CanvasLayer/LabelTimer.text = formato_tiempo(tiempo_restante)
	$TextureRect/CanvasLayer/LabelTimer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	group_to_show = $Group16
	group_to_show.visible = false

	$TextureRect/Area2D.input_event.connect(_on_area2d_input_event)
	$TextureRect/Area2D.mouse_exited.connect(_on_area2d_mouse_exited)

	$Group16/ComprobarRespuesta.pressed.connect(_on_comprobar_respuesta_pressed)

	get_tree().paused = false

	sistema_cuentas = get_node("/root/Sistema")

func _process(delta):
	tiempo_restante -= delta
	if tiempo_restante < 0:
		tiempo_restante = 0
		get_tree().change_scene_to_file("res://scenes/ui/MenuPrincipal.tscn")
	$TextureRect/CanvasLayer/LabelTimer.text = formato_tiempo(tiempo_restante)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()

func toggle_pause_menu():
	pause_open = !pause_open
	$Panel.visible = pause_open
	get_tree().paused = false

func formato_tiempo(t: float) -> String:
	var segundos := int(t)
	var minutos := segundos / 60
	var resto := segundos % 60
	return "%02d:%02d" % [minutos, resto]

func _on_area2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		group_to_show.visible = !group_to_show.visible
		print("¡Group16 toggled! Visible:", group_to_show.visible)

func _on_area2d_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MenuPrincipal.tscn")

func _on_comprobar_respuesta_pressed() -> void:
	var input_node = $Group16/Respuesta
	if not input_node:
		print("No se encontró el nodo Respuesta")
		return

	var respuesta_usuario = input_node.text.strip_edges()

	if respuesta_usuario == respuesta_correcta:
		print("¡Respuesta correcta! Nivel completado.")
		if sistema_cuentas:
			var user_data = sistema_cuentas.get_current_user_data()
			var niveles = user_data.get("Niveles", {})
			if niveles.has(categoria):
				niveles[categoria][metodo] = 1
				sistema_cuentas.update_current_user_data({"Niveles": niveles})
		get_tree().change_scene_to_file("res://scenes/ui/MenuPrincipal.tscn")
	else:
		print("Respuesta incorrecta. Intenta de nuevo.")
