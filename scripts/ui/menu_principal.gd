extends Control

var menu_abierto: bool = false

# Diccionario que controla qué botón está seleccionado
var seleccion := {
	"interpolacion_lineal": false,
	"newton_adelante": false,
	"newton_atras": false,
	"diferencias_divididas": false,
	"lagrange": false
}


func _ready() -> void:
	var usuario := UserData.current_user
	
	# Referencias
	var btn_logout := $TextureRect/PanelArriba/CanvasLayer/BtnLogout
	var btn_usuario := $TextureRect/PanelArriba/CanvasLayer/BtnUsuario
	var lbl_nombre := $TextureRect/PanelArriba/CanvasLayer/BtnUsuario/NombreUsuario
	var btn_salir := $TextureRect/PanelAbajo/BtnSalir
	
	# Estado inicial
	btn_logout.visible = false
	btn_logout.modulate.a = 0.0
	
	# Conecta señales
	if not btn_usuario.pressed.is_connected(_on_BtnUsuario_pressed):
		btn_usuario.pressed.connect(_on_BtnUsuario_pressed)
	if not btn_logout.pressed.is_connected(_on_BtnLogout_pressed):
		btn_logout.pressed.connect(_on_BtnLogout_pressed)
	if not btn_salir.pressed.is_connected(_on_BtnSalir_pressed):
		btn_salir.pressed.connect(_on_BtnSalir_pressed)
	
	lbl_nombre.text = usuario if usuario != "" else "⚠️ No hay sesión activa."




# ---------------------------------------------------------
#   MENÚ DE USUARIO
# ---------------------------------------------------------

func _on_BtnUsuario_pressed() -> void:
	var btn_logout := $TextureRect/PanelArriba/CanvasLayer/BtnLogout
	var tween := create_tween()
	
	if not menu_abierto:
		btn_logout.visible = true
		tween.tween_property(btn_logout, "modulate:a", 1.0, 0.25)
		menu_abierto = true
	else:
		tween.tween_property(btn_logout, "modulate:a", 0.0, 0.25)
		await tween.finished
		btn_logout.visible = false
		menu_abierto = false


func _on_BtnLogout_pressed() -> void:
	UserData.current_user = ""
	
	var btn_logout := $TextureRect/PanelArriba/CanvasLayer/BtnLogout
	var tween := create_tween()
	tween.tween_property(btn_logout, "modulate:a", 0.0, 0.25)
	await tween.finished
	btn_logout.visible = false
	menu_abierto = false
	
	get_tree().change_scene_to_file("res://scenes/ui/Register.tscn")


func _on_BtnSalir_pressed() -> void:
	get_tree().quit()




# ---------------------------------------------------------
#   RANKING (funciona con cualquier botón)
# ---------------------------------------------------------

func show_ranking(method_name: String) -> void:
	print("Cargando ranking de:", method_name)

	var item_list = $TextureRect/Panel/VBoxContainer/ItemList

	if item_list == null:
		push_error("ERROR: No se encontró ItemList en TextureRect/Panel/VBoxContainer")
		return

	item_list.focus_mode = Control.FOCUS_NONE
	item_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_list.custom_minimum_size = Vector2(0, 200)

	item_list.visible = true
	item_list.modulate.a = 1.0
	item_list.clear()

	var rankings: Array = []

	for username in UserData.accounts.keys():
		var data = UserData.accounts[username]
		if not data.has("Niveles"):
			continue

		for categoria in data["Niveles"].keys():
			var metodos = data["Niveles"][categoria]

			if metodos.has(method_name):
				var tiempo = metodos[method_name]
				if tiempo > 0:
					rankings.append({
						"username": username,
						"time": tiempo
					})

	rankings.sort_custom(func(a, b): return a["time"] < b["time"])

	for entry in rankings:
		item_list.add_item("%s — %s segundos" % [entry["username"], entry["time"]])




# ---------------------------------------------------------
#   BOTONES DE LOS NIVELES
# ---------------------------------------------------------

func reset_seleccion():
	for key in seleccion.keys():
		seleccion[key] = false


# --- Interpolación Lineal ---
func _on_interpolacion_lineal_pressed() -> void:
	reset_seleccion()
	seleccion["interpolacion_lineal"] = true
	show_ranking("Lineal")


# --- Newton hacia adelante ---
func _on_newton_hacia_adelante_pressed() -> void:
	reset_seleccion()
	seleccion["newton_adelante"] = true
	show_ranking("Newton hacia adelante")


# --- Newton hacia atrás ---
func _on_newton_hacia_atras_pressed() -> void:
	reset_seleccion()
	seleccion["newton_atras"] = true
	show_ranking("Newton hacia atrás")


# --- Diferencias divididas ---
func _on_newton_con_diferencias_divididas_pressed() -> void:
	reset_seleccion()
	seleccion["diferencias_divididas"] = true
	show_ranking("Diferencias divididas")


# --- Lagrange ---
func _on_lagrange_pressed() -> void:
	reset_seleccion()
	seleccion["lagrange"] = true
	show_ranking("Lagrange")




# ---------------------------------------------------------
#   BOTÓN JUGAR (Cambia según lo que seleccionaste)
# ---------------------------------------------------------

func _on_btn_jugar_pressed() -> void:
	if seleccion["interpolacion_lineal"]:
		get_tree().change_scene_to_file("res://assets/interpolacion-lineal.tscn")

	elif seleccion["newton_adelante"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Newton hacia adelante.tscn")

	elif seleccion["newton_atras"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Newton hacia atras.tscn")

	elif seleccion["diferencias_divididas"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Newton con diferencias divididas.tscn")

	elif seleccion["lagrange"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Lagrange.tscn")
