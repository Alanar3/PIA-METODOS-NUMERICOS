extends Control

func _ready() -> void:
	# Asegúrate de que todos los mensajes estén ocultos al inicio
	$TextureRect/UsuarioCreado.visible = false
	$TextureRect/UsuarioYaExiste.visible = false
	$TextureRect/CompletaCampos.visible = false


func _process(_delta: float) -> void:
	pass


# --- Ir a la escena de Login ---
func _on_btn_login_pressed() -> void:
	get_tree().change_scene_to_file("res://Login.tscn")


# --- Registrar nuevo usuario ---
func _on_btn_registrar_pressed() -> void:
	var username = $TextureRect/Panel/UsernameRegister.text.strip_edges()
	var password = $TextureRect/Panel/PasswordRegister.text.strip_edges()

	if username == "" or password == "":
		# ⚠️ Mostrar mensaje de "Completa los campos"
		await mostrar_completa_campos()
		return

	if UserData.register_user(username, password):
		# ✅ Mostrar mensaje visual de éxito
		await mostrar_usuario_creado()
	else:
		# ⚠️ Mostrar mensaje de que el usuario ya existe
		await mostrar_usuario_ya_existe()


# --- Funciones de mensajes visuales temporales ---

func mostrar_usuario_creado() -> void:
	$TextureRect/UsuarioCreado.visible = true
	await get_tree().create_timer(2.5).timeout
	$TextureRect/UsuarioCreado.visible = false


func mostrar_usuario_ya_existe() -> void:
	$TextureRect/UsuarioYaExiste.visible = true
	await get_tree().create_timer(2.5).timeout
	$TextureRect/UsuarioYaExiste.visible = false


func mostrar_completa_campos() -> void:
	$TextureRect/CompletaCampos.visible = true
	await get_tree().create_timer(2.5).timeout
	$TextureRect/CompletaCampos.visible = false
