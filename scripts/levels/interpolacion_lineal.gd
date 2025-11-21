extends Node2D

# Variables de juego
var pause_open := false
var tiempo_restante := 60.0
var group_to_show: Node  # Nodo que se mostrará al hacer clic

func _ready() -> void:
	# Panel de pausa oculto
	$Panel.visible = false

	# Inicializar temporizador
	$TextureRect/CanvasLayer/LabelTimer.text = formato_tiempo(tiempo_restante)
	$TextureRect/CanvasLayer/LabelTimer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Apuntar al nodo que se mostrará
	group_to_show = $TextureRect/Group16
	group_to_show.visible = false  # Inicialmente oculto

	# El juego nunca se pausa automáticamente
	get_tree().paused = false

	# Conectar señales del Area2D
	$TextureRect/Area2D.input_event.connect(_on_area2d_input_event)
	$TextureRect/Area2D.mouse_exited.connect(_on_area2d_mouse_exited)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()


func toggle_pause_menu():
	pause_open = !pause_open
	$Panel.visible = pause_open
	get_tree().paused = false  # Evitar pausa accidental


func _process(delta):
	# Actualizar temporizador
	tiempo_restante -= delta
	if tiempo_restante < 0:
		tiempo_restante = 0

	$TextureRect/CanvasLayer/LabelTimer.text = formato_tiempo(tiempo_restante)

	# Cambiar de escena si el tiempo se acaba
	if tiempo_restante == 0:
		get_tree().change_scene_to_file("res://scenes/ui/MenuPrincipal.tscn")


func formato_tiempo(t: float) -> String:
	var segundos := int(t)
	var minutos := segundos / 60
	var resto := segundos % 60
	return "%02d:%02d" % [minutos, resto]


# -------------------------
# Area2D: clic y cursor
# -------------------------

func _on_area2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		group_to_show.visible = !group_to_show.visible
		print("¡Group16 toggled! Visible:", group_to_show.visible)




func _on_area2d_mouse_exited():
	# Vuelve al cursor normal
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MenuPrincipal.tscn")
