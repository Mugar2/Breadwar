extends Area2D



func _on_area_entered(area: Area2D) -> void:
	var grandpa=area.get_parent().get_parent()
	
	if area is Hitbox and area.owner!=owner and grandpa!=owner:
		var hitbox:Area2D=area
		var damage:int=hitbox.damage
		owner.life -=damage
		owner.velocity.y-=hitbox.knockback_y 
		owner.velocity.x+=hitbox.knockback_x * area.owner.last_direction
		
		owner.is_damaged=true
		$Damage_cooldown.start()
		
