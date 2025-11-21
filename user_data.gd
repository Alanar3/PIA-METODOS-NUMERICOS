extends Node

var accounts: Dictionary = {}
const SAVE_PATH := "user://accounts.json"
var current_user: String = ""

# --- Estructura de niveles de cada usuario ---
const LEVEL_STRUCTURE := {
	"Ecuaciones lineales": {
		"Montante": 0,
		"Gauss-Jordan": 0,
		"Eliminación Gaussiana": 0,
		"Gauss-Seidel": 0,
		"Jacobi": 0
	},
	"Ecuaciones no lineales": {
		"Gráfico": 0,
		"Bisectriz": 0,
		"Punto fijo": 0,
		"Newton Raphson": 0,
		"Falsa posición": 0,
		"Secante": 0
	},
	"Interpolación": {
		"Lineal": 0,
		"Newton hacia adelante": 0,
		"Newton hacia atrás": 0,
		"Diferencias divididas": 0,
		"Lagrange": 0
	},
	"Integración": {
		"Trapezoidal": 0,
		"Simpson 1/3": 0,
		"Simpson 3/8": 0,
		"Newton-Cotes cerradas": 0,
		"Newton-Cotes abiertas": 0
	},
	"Mínimos cuadrados": {
		"Línea recta": 0,
		"Cuadrática": 0,
		"Cúbica": 0,
		"Lineal con función": 0,
		"Cuadrática con función": 0
	},
	"Ecuaciones Diferenciales Ordinarias": {
		"Euler modificado": 0,
		"Runge-Kutta": 0,
		"Runge-Kutta orden superior": 0,
		"Runge-Kutta 2do orden": 0,
		"Runge-Kutta 3er orden": 0,
		"Runge-Kutta 4to orden (Simpson 1/3)": 0,
		"Runge-Kutta 4to orden (Simpson 3/8)": 0
	}
}


func _ready() -> void:
	load_accounts()


# --- Cargar datos desde archivo ---
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
		return false  # Ya existe

	# Se crea un usuario con la estructura completa
	accounts[username] = {
		"password": password,
		"Niveles": LEVEL_STRUCTURE.duplicate(true)
	}

	save_accounts()
	return true


# --- Iniciar sesión ---
func login_user(username: String, password: String) -> bool:
	if not accounts.has(username):
		return false

	var user_data = accounts[username]

	if typeof(user_data) == TYPE_STRING:
		# Formato viejo (solo contraseña)
		if user_data == password:
			current_user = username
			return true

	elif typeof(user_data) == TYPE_DICTIONARY:
		# Formato nuevo
		if user_data.has("password") and user_data["password"] == password:
			current_user = username
			return true

	return false


# --- Obtener datos del usuario actual ---
func get_current_user_data() -> Dictionary:
	if current_user != "" and accounts.has(current_user):
		var user_data = accounts[current_user]
		if typeof(user_data) == TYPE_DICTIONARY:
			return user_data
	return {}


# --- Actualizar datos del usuario actual ---
func update_current_user_data(new_data: Dictionary) -> void:
	if current_user != "" and accounts.has(current_user):
		for key in new_data.keys():
			accounts[current_user][key] = new_data[key]
		save_accounts()
