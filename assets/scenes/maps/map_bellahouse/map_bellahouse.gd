extends Node2D

var is_player_interactable: bool = false
var last_npc: Node

func _ready() -> void:
  RenderingServer.set_default_clear_color(Color.BLACK)
  print($prop_bed/area_dialog)

func _process(_delta) -> void:
  if is_player_interactable and Input.is_action_just_pressed('cg_accept'):
    if last_npc == $prop_bed:
      print("Es tu cama.")
      
    elif last_npc == $prop_pc:
      print("Inserte escena de PC aquí.")
  

func _on_area_dialog_body_entered(body: Node2D) -> void:
  if body.is_in_group('player'):
    is_player_interactable = true
    last_npc = $prop_bed

func _on_area_pc_body_entered(body: Node2D) -> void:
  if body.is_in_group('player'):
    is_player_interactable = true
    last_npc = $prop_pc
