extends Control

func _ready() -> void:
	# Aseguramos que las alertas estén ocultas al inicio
	$TextureRect/CompletaCampos.visible = false
	$TextureRect/DatosIncorrectos.visible = false


func _process(_delta: float) -> void:
	pass


func _on_btn_registrarse_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/Register.tscn")


func _on_btn_login_pressed() -> void:
	var username = $TextureRect/Panel/UsernameLogin.text.strip_edges()
	var password = $TextureRect/Panel/PasswordLogin.text.strip_edges()

	if username == "" or password == "":
		# ⚠️ Mostrar alerta de campos vacíos
		await mostrar_completa_campos()
		return

	if UserData.login_user(username, password):
		# ✅ Si las credenciales son correctas, cambiar de escena directamente
		get_tree().change_scene_to_file("res://scenes/ui/MenuPrincipal.tscn")
	else:
		# ❌ Mostrar alerta de datos incorrectos
		await mostrar_datos_incorrectos()


# --- Funciones de mensajes visuales temporales ---

func mostrar_completa_campos() -> void:
	$TextureRect/CompletaCampos.visible = true
	await get_tree().create_timer(2.5).timeout
	$TextureRect/CompletaCampos.visible = false


func mostrar_datos_incorrectos() -> void:
	$TextureRect/DatosIncorrectos.visible = true
	await get_tree().create_timer(2.5).timeout
	$TextureRect/DatosIncorrectos.visible = false

func _on_btn_salir_pressed() -> void:
	get_tree().quit()
