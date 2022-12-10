extends CharacterBody2D

func _physics_process(_delta: float):
	velocity = Vector2(128, -20)
	move_and_slide()
