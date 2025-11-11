extends Node

var accounts: Dictionary = {}
const SAVE_PATH := "user://accounts.json"
var current_user: String = ""


func _ready() -> void:
	load_accounts()


# --- Cargar datos del archivo ---
func load_accounts() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		accounts = JSON.parse_string(content)
		if accounts == null:
			accounts = {}
		file.close()
	else:
		accounts = {}


# --- Guardar datos ---
func save_accounts() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(accounts))
	file.close()


# --- Registrar usuario ---
func register_user(username: String, password: String) -> bool:
	if accounts.has(username):
		return false # Ya existe

	# Guarda en formato nuevo (diccionario)
	accounts[username] = {
		"password": password,
		"Progreso": 1 #Editar después
	}
	save_accounts()
	return true


# --- Iniciar sesión ---
func login_user(username: String, password: String) -> bool:
	if not accounts.has(username):
		return false

	var user_data = accounts[username]

	# --- Soporte para formatos antiguos y nuevos ---
	if typeof(user_data) == TYPE_STRING:
		# Versión vieja (solo contraseña)
		if user_data == password:
			current_user = username
			return true
	elif typeof(user_data) == TYPE_DICTIONARY:
		# Versión nueva con campo "password"
		if user_data.has("password") and user_data["password"] == password:
			current_user = username
			return true

	return false


func get_current_user_data() -> Dictionary:
	if current_user != "" and accounts.has(current_user):
		var user_data = accounts[current_user]
		if typeof(user_data) == TYPE_DICTIONARY:
			return user_data
	return {}


func update_current_user_data(new_data: Dictionary) -> void:
	if current_user != "" and accounts.has(current_user):
		for key in new_data.keys():
			accounts[current_user][key] = new_data[key]
		save_accounts()
