extends Node2D

export (PackedScene) var MainMenu = preload("res://mainmenu.tscn")

var timer = 0;
var direction = 0;
var menud = false;

func _ready():
	$"AnimatedSprite".frame = direction;

func _process(delta):
	timer += delta;
	if(timer>2 && !menud):
		var menu = MainMenu.instance()
		add_child(menu)
		menud = true;
	$"AnimatedSprite".modulate = Color(1,1,1,1.3-timer*0.3)

func set_direction(directionIn):
	self.direction = int(floor(directionIn))
