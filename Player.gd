extends KinematicBody2D

export var speed = 800;
var accel = 30000;
var maxspd = 1200;
var direction = 0;
var velocity = Vector2.ZERO;
var screen_size #this feels like it belongs somewhere else
onready var fog = get_node("Camera2D/Fog")
onready var sprite = get_node("AnimatedSprite")
onready var healthBar = get_node("HealthBar")
export var PlayerBullet = preload("res://PlayerBullet.tscn")
export var Ray = preload("res://Ray.tscn")
var reload = 0;
var firing = .25; #how many seconds it takes you to shoot a bullet
var maxHealth = 4;
var health = maxHealth

func _ready():
	screen_size = get_viewport_rect().size
	#$RayCast2D.add_exception(self)

func _process(delta):
	#Get inputs
	var right = int(Input.is_action_pressed("ui_right"));
	var left = int(Input.is_action_pressed("ui_left"));
	var down = int(Input.is_action_pressed("ui_down"));
	var up = int(Input.is_action_pressed("ui_up"));
	var dir = Vector2(right-left,down-up);
	#Do movement
	if dir != Vector2.ZERO:
		velocity += dir * accel * delta;
		if velocity.length() > maxspd:
			velocity = velocity.normalized()*maxspd;
	elif velocity.length() > accel*delta*10:
		velocity -= velocity.normalized() * delta * accel;
	else:
		velocity = velocity * 0;
	position += velocity * delta;
	#Change Sprite
	if velocity.length() > 0:
		direction = fposmod(floor(rad2deg(-velocity.angle())/45),8);
		if(0 < velocity.angle() && velocity.angle() <= PI): # ||velocity.y>0 || (velocity.y==0 && velocity.x<0)):
			direction += 1
		#print(direction);
		sprite.animation = "walk"+str(direction)
	else:
		sprite.animation = "idle"+str(direction)
	
	#Other things
	healthBar.animation = str(health);
	
	if(reload < firing):
		reload += delta;
	z_index = 99+position[1]*0.1


func _on_Bullet_hit(damage):
	health -= 1;
	if(health==0):
		# Remove the current level
		
		var root = get_tree().get_root()
		# Add the next level
		var next_level_resource = load("res://dead.tscn")
		var next_level = next_level_resource.instance()
		next_level.direction = direction;
		root.add_child(next_level)
		
		var level = root.get_node("ingame")
		root.remove_child(level)
		level.call_deferred("free")
	else:
		$"Camera2D".shakeAmount = 16;
		$"PlayerHitFreeze".time = 0.1;
	
func _input(event):
	if event is InputEventMouseButton && reload > firing:
		var angle = get_global_position().angle_to_point(get_global_mouse_position())
		#shoot_angle(1000, angle, 500,1)
		#shoot_raycast(angle)
		reload = 0
		var ray = Ray.instance()
		ray.rotation = angle+PI
		add_child(ray)

		
func shoot(v, reach, damage):
	var bullet = PlayerBullet.instance()
	$"..".add_child(bullet)
	bullet.position = position + v.normalized()*128;
	bullet.velocity = v
	bullet.reach = reach
	bullet.damage = damage
	return bullet

func shoot_angle(speed, angle, reach, damage):
	var v = Vector2(-speed, 0)
	v = v.rotated(angle)
	return shoot(v, reach, damage)
