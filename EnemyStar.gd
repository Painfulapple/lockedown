extends "res://EnemyGeneric.gd"
var count = 0;

func shoot_pattern():
	if count > 0:
		shoot(Vector2(300,0), 1200, 37)
		shoot(Vector2(300,300), 1200, 37)
		shoot(Vector2(0,300), 1200, 37)
		shoot(Vector2(-300,300), 1200, 37)
		shoot(Vector2(-300,0), 1200, 37)
		shoot(Vector2(-300,-300), 1200, 37)
		shoot(Vector2(0,-300), 1200, 37)
		shoot(Vector2(300,-300), 1200, 37)
		count = 0;
	else:
		count+=1;
