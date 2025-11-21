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

# RUTAS (ajusta aquí si tus nodos están en otra ruta)
const PATH_TEXTURERECT := "TextureRect"
const PATH_PANEL_ABAJO := PATH_TEXTURERECT + "/PanelAbajo"
const PATH_BTN_JUGAR := PATH_PANEL_ABAJO + "/BtnJugar"

const PATH_BTN_LINEAL := PATH_TEXTURERECT + "/Interpolacion lineal"
const PATH_BTN_ADELANTE := PATH_TEXTURERECT + "/Newton hacia adelante"
const PATH_BTN_ATRAS := PATH_TEXTURERECT + "/Newton hacia atras"
const PATH_BTN_DIVIDIDAS := PATH_TEXTURERECT + "/Newton con diferencias divididas"
const PATH_BTN_LAGRANGE := PATH_TEXTURERECT + "/Lagrange"

func _ready() -> void:
	var usuario := UserData.current_user
	
	# Referencias UI básicas (si una ruta no existe no explota aquí)
	var btn_logout := get_node_or_null(PATH_TEXTURERECT + "/PanelArriba/CanvasLayer/BtnLogout")
	var btn_usuario := get_node_or_null(PATH_TEXTURERECT + "/PanelArriba/CanvasLayer/BtnUsuario")
	var lbl_nombre := get_node_or_null(PATH_TEXTURERECT + "/PanelArriba/CanvasLayer/BtnUsuario/NombreUsuario")
	var btn_salir := get_node_or_null(PATH_PANEL_ABAJO + "/BtnSalir")

	# Estado inicial del menú
	if btn_logout:
		btn_logout.visible = false
		btn_logout.modulate.a = 0.0

	# Conectar señales (comprobando null y conexiones previas)
	if btn_usuario and not btn_usuario.is_connected("pressed", Callable(self, "_on_BtnUsuario_pressed")):
		btn_usuario.pressed.connect(_on_BtnUsuario_pressed)
	if btn_logout and not btn_logout.is_connected("pressed", Callable(self, "_on_BtnLogout_pressed")):
		btn_logout.pressed.connect(_on_BtnLogout_pressed)
	if btn_salir and not btn_salir.is_connected("pressed", Callable(self, "_on_BtnSalir_pressed")):
		btn_salir.pressed.connect(_on_BtnSalir_pressed)

	if lbl_nombre:
		lbl_nombre.text = usuario if usuario != "" else "⚠️ No hay sesión activa."

	# Bloqueo inicial de los niveles (establece .disabled en los botones si existen)
	apply_level_locks()

	# Deshabilitar botón JUGAR al inicio (comprobando null)
	var btn_jugar = get_node_or_null(PATH_BTN_JUGAR)
	if btn_jugar:
		btn_jugar.disabled = true


# ---------------------------------------------------------------------
# BLOQUEAR NIVELES SEGÚN EL PROGRESO GUARDADO
# ---------------------------------------------------------------------
func apply_level_locks() -> void:
	if UserData.current_user == "":
		return

	var data = UserData.get_current_user_data()
	if not data.has("Niveles"):
		return

	# Intentamos leer la categoría "Interpolación" con seguridad
	if not data["Niveles"].has("Interpolación"):
		return

	var niveles = data["Niveles"]["Interpolación"]

	# Referencias a los botones (pueden ser null)
	var btn_lineal = get_node_or_null(PATH_BTN_LINEAL)
	var btn_adelante = get_node_or_null(PATH_BTN_ADELANTE)
	var btn_atras = get_node_or_null(PATH_BTN_ATRAS)
	var btn_divididas = get_node_or_null(PATH_BTN_DIVIDIDAS)
	var btn_lagrange = get_node_or_null(PATH_BTN_LAGRANGE)

	# --- Nivel 1 siempre disponible ---
	if btn_lineal:
		btn_lineal.disabled = false

	# --- Nivel 2 depende del 1 ---
	if btn_adelante:
		btn_adelante.disabled = niveles.get("Lineal", 0) <= 0

	# --- Nivel 3 depende del 2 ---
	if btn_atras:
		btn_atras.disabled = niveles.get("Newton hacia adelante", 0) <= 0

	# --- Nivel 4 depende del 3 ---
	if btn_divididas:
		btn_divididas.disabled = niveles.get("Newton hacia atrás", 0) <= 0

	# --- Nivel 5 depende del 4 ---
	if btn_lagrange:
		btn_lagrange.disabled = niveles.get("Diferencias divididas", 0) <= 0

	# Aseguramos estado del botón Jugar en caso de que ya hubiera una selección
	update_play_button_status()


# ---------------------------------------------------------------------
# MENÚ DE USUARIO
# ---------------------------------------------------------------------
func _on_BtnUsuario_pressed() -> void:
	var btn_logout := get_node_or_null(PATH_TEXTURERECT + "/PanelArriba/CanvasLayer/BtnLogout")
	var tween := create_tween()
	
	if not menu_abierto:
		if btn_logout:
			btn_logout.visible = true
		tween.tween_property(btn_logout, "modulate:a", 1.0, 0.25)
		menu_abierto = true
	else:
		tween.tween_property(btn_logout, "modulate:a", 0.0, 0.25)
		await tween.finished
		if btn_logout:
			btn_logout.visible = false
		menu_abierto = false


func _on_BtnLogout_pressed() -> void:
	UserData.current_user = ""
	
	var btn_logout := get_node_or_null(PATH_TEXTURERECT + "/PanelArriba/CanvasLayer/BtnLogout")
	var tween := create_tween()
	if btn_logout:
		tween.tween_property(btn_logout, "modulate:a", 0.0, 0.25)
		await tween.finished
		btn_logout.visible = false
	menu_abierto = false
	
	get_tree().change_scene_to_file("res://scenes/ui/Register.tscn")


func _on_BtnSalir_pressed() -> void:
	get_tree().quit()




# ---------------------------------------------------------------------
# RANKING
# ---------------------------------------------------------------------
func show_ranking(method_name: String) -> void:
	var item_list = get_node_or_null(PATH_TEXTURERECT + "/Panel/VBoxContainer/ItemList")
	if item_list == null:
		push_error("ERROR: No se encontró ItemList")
		return

	item_list.clear()
	item_list.focus_mode = Control.FOCUS_NONE
	item_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_list.visible = true
	item_list.modulate.a = 1.0

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




# ---------------------------------------------------------------------
# SELECCIÓN DE NIVELES + BLOQUEAR BOTÓN JUGAR
# ---------------------------------------------------------------------
func reset_seleccion():
	for key in seleccion.keys():
		seleccion[key] = false

	# Cuando se selecciona algo, el botón jugar se habilita o no
	update_play_button_status()


func update_play_button_status():
	var btn_jugar = get_node_or_null(PATH_BTN_JUGAR)

	# si no existe el btn_jugar, no hacemos nada
	if btn_jugar == null:
		return

	# Si ningún nivel está seleccionado → NO se puede jugar
	if not seleccion.values().has(true):
		btn_jugar.disabled = true
		return

	# Detectar qué nivel fue elegido
	var actual := ""
	for key in seleccion.keys():
		if seleccion[key]:
			actual = key
			break

	# Mapa entre key → ruta real del botón
	var botones = {
		"interpolacion_lineal": PATH_BTN_LINEAL,
		"newton_adelante": PATH_BTN_ADELANTE,
		"newton_atras": PATH_BTN_ATRAS,
		"diferencias_divididas": PATH_BTN_DIVIDIDAS,
		"lagrange": PATH_BTN_LAGRANGE
	}

	var ruta_boton = botones.get(actual, "")
	if ruta_boton == "":
		btn_jugar.disabled = true
		return

	var boton = get_node_or_null(ruta_boton)
	if boton == null:
		# si no existe el botón, deshabilitamos jugar por seguridad
		btn_jugar.disabled = true
		return

	# Si el botón del nivel está bloqueado → NO puedes jugar
	btn_jugar.disabled = boton.disabled




# ---------------------------------------------------------------------
# EVENTOS DE LOS BOTONES
# ---------------------------------------------------------------------
func _on_interpolacion_lineal_pressed() -> void:
	reset_seleccion()
	seleccion["interpolacion_lineal"] = true
	show_ranking("Lineal")
	update_play_button_status()

func _on_newton_hacia_adelante_pressed() -> void:
	reset_seleccion()
	seleccion["newton_adelante"] = true
	show_ranking("Newton hacia adelante")
	update_play_button_status()

func _on_newton_hacia_atras_pressed() -> void:
	reset_seleccion()
	seleccion["newton_atras"] = true
	show_ranking("Newton hacia atrás")
	update_play_button_status()

func _on_newton_con_diferencias_divididas_pressed() -> void:
	reset_seleccion()
	seleccion["diferencias_divididas"] = true
	show_ranking("Diferencias divididas")
	update_play_button_status()

func _on_lagrange_pressed() -> void:
	reset_seleccion()
	seleccion["lagrange"] = true
	show_ranking("Lagrange")
	update_play_button_status()




# ---------------------------------------------------------------------
# BOTÓN JUGAR
# ---------------------------------------------------------------------
func _on_btn_jugar_pressed() -> void:
	if seleccion["interpolacion_lineal"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/interpolacion lineal.tscn")

	elif seleccion["newton_adelante"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Newton hacia adelante.tscn")

	elif seleccion["newton_atras"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Newton hacia atras.tscn")

	elif seleccion["diferencias_divididas"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Newton con diferencias divididas.tscn")

	elif seleccion["lagrange"]:
		get_tree().change_scene_to_file("res://scenes/levels/interpolacion/Lagrange.tscn")
