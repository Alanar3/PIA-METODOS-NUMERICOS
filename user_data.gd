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
		"Runge-Kutta 2do orden": 0,
		"Runge-Kutta 3er orden": 0,
		"Runge-Kutta 4to orden (Simpson 1/3)": 0,
		"Runge-Kutta 4to orden (Simpson 3/8)": 0,
		"Runge-Kutta orden superior": 0
	}
}


func _ready() -> void:
	load_accounts()


# ---------------------------------------------------------
#        CARGAR / GUARDAR
# ---------------------------------------------------------

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


func save_accounts() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(accounts))
	file.close()


# ---------------------------------------------------------
#          REGISTRO Y LOGIN
# ---------------------------------------------------------

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


func login_user(username: String, password: String) -> bool:
	if not accounts.has(username):
		return false

	var user_data = accounts[username]

	# Formato antiguo (solo contraseña)
	if typeof(user_data) == TYPE_STRING:
		if user_data == password:
			current_user = username
			return true

	# Formato nuevo
	if typeof(user_data) == TYPE_DICTIONARY:
		if user_data.has("password") and user_data["password"] == password:
			current_user = username
			return true

	return false


# ---------------------------------------------------------
#       ACCESO A DATOS DEL USUARIO
# ---------------------------------------------------------

func get_current_user_data() -> Dictionary:
	if current_user != "" and accounts.has(current_user):
		var user_data = accounts[current_user]
		if typeof(user_data) == TYPE_DICTIONARY:
			return user_data
	return {}


# ---------------------------------------------------------
#          ACTUALIZAR DATOS + DESBLOQUEAR NIVELES
# ---------------------------------------------------------

func update_current_user_data(new_data: Dictionary) -> void:
	if current_user != "" and accounts.has(current_user):
		for key in new_data.keys():
			accounts[current_user][key] = new_data[key]

		# Después de guardar → actualizar niveles desbloqueados
		update_level_unlocks()

		save_accounts()


# ---------------------------------------------------------
#       DESBLOQUEAR SIGUIENTES NIVELES AUTOMÁTICAMENTE
# ---------------------------------------------------------

func update_level_unlocks() -> void:
	if current_user == "" or not accounts.has(current_user):
		return

	var niveles = accounts[current_user]["Niveles"]

	for categoria in niveles.keys():
		var metodos_dict = niveles[categoria]
		var keys = metodos_dict.keys()  # Orden natural del JSON

		for i in range(keys.size()):
			if i == 0:
				continue  # El primer nivel siempre está desbloqueado

			var nivel_anterior = keys[i - 1]
			var nivel_actual = keys[i]

			var tiempo_anterior = metodos_dict[nivel_anterior]

			# Si el usuario NO ha completado el nivel anterior → bloquear actual
			if tiempo_anterior <= 0:
				metodos_dict[nivel_actual] = 0


# ---------------------------------------------------------
#       REVISAR SI UN NIVEL ESTÁ DESBLOQUEADO
# ---------------------------------------------------------

func is_level_unlocked(category: String, method: String) -> bool:
	if current_user == "":
		return false

	var niveles = accounts[current_user]["Niveles"]
	if not niveles.has(category):
		return false
	if not niveles[category].has(method):
		return false

	var metodos = niveles[category]
	var keys = metodos.keys()
	var index = keys.find(method)

	# El primer nivel SIEMPRE está desbloqueado
	if index == 0:
		return true

	# Si ya tiene tiempo registrado, también está desbloqueado
	if metodos[method] > 0:
		return true

	# Revisar nivel anterior
	var anterior = keys[index - 1]
	return metodos[anterior] > 0
