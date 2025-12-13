extends CharacterBody2D


const obj_bullet = preload("res://assets/nodes/chr_bullet/chr_bullet.tscn")


func shoot(direction: float, speed: float):
  var new_bullet = obj_bullet.instantiate()
  new_bullet.velocity = Vector2(speed, 0).rotated(deg_to_rad(direction))
  new_bullet.position = position
  
  get_parent().add_child(new_bullet)
