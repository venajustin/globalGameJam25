extends Control


@onready var healthbar := $Control/TextureProgressBar
@onready var weapon_select := $Control/VBoxContainer/WeaponSelection

@export var weapon_option_s: PackedScene

@export var deselect_color:Color
@export var select_color:Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func player_damage(new_health:int) -> void: 
	healthbar.value = new_health
func swap_weapon(index:int) -> void:
	var selected = weapon_select.get_child(index)
	if selected:
		for wep in weapon_select.get_children():
			wep.color = deselect_color
		selected.color = select_color
func register_weapon(weapon:Resource) -> void:
	var new_icon = weapon_option_s.instantiate()
	var trect:TextureRect = new_icon.get_child(0)
	trect.texture = weapon.icon
	new_icon.color = deselect_color
	weapon_select.add_child(new_icon)
	
