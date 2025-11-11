extends Control

var menu_abierto: bool = false

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
	
	# Asigna nombre de usuario
	lbl_nombre.text = usuario if usuario != "" else "⚠️ No hay sesión activa."


func _on_BtnUsuario_pressed() -> void:
	var btn_logout := $TextureRect/PanelArriba/CanvasLayer/BtnLogout
	var tween := create_tween()
	
	if not menu_abierto:
		# Mostrar con animación suave
		btn_logout.visible = true
		tween.tween_property(btn_logout, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		menu_abierto = true
	else:
		# Ocultar con animación suave
		tween.tween_property(btn_logout, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished
		btn_logout.visible = false
		menu_abierto = false


func _on_BtnLogout_pressed() -> void:
	# Limpia el usuario actual (simula cerrar sesión)
	UserData.current_user = ""
	
	# Oculta el botón con animación
	var btn_logout := $TextureRect/PanelArriba/CanvasLayer/BtnLogout
	var tween := create_tween()
	tween.tween_property(btn_logout, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	btn_logout.visible = false
	menu_abierto = false
	
	# Cambia de escena al menú principal
	get_tree().change_scene_to_file("res://Register.tscn")


func _on_BtnSalir_pressed() -> void:
	# Sale completamente del juego o aplicación
	get_tree().quit()
