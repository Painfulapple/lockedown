extends KinematicBody2D
var time = 0
export (PackedScene) var Bullet = preload("res://BaseBullet.tscn")
export (float) var seconds_per_shot = 1
var pitch;
var pitchVariation = 0.3
var sightRange = 800;
var z_offset = 99;
var velocity : Vector2
var direction;
var shooting = false
var health = 2 setget set_health
onready var sprite = get_node("AnimatedSprite")

func _ready():
	var trail = $"../Player/Trail";
	trail.connect("end",self,"_on_Trail_end");
	pitch = get_node("ShootSound").pitch_scale;
	direction = floor(rand_range(0,8))
	#$Area2D.connect("area_entered", self, "_on_Area2D_area_entered")
	
func _process(delta):
	z_index = z_offset+position[1]*0.1
	time += delta
	if(time > seconds_per_shot):
		time = fmod(time, seconds_per_shot)
		shoot_pattern()
	direction = floor(rad2deg(angle_to_player())/45+3.5)
	if(direction==-1):
		direction = 0;
	if velocity.length() > 0:
		sprite.animation = "walk"+str(direction)
	else:
		if(shooting):
			sprite.animation = "shoot"+str(direction)
			if(sprite.frame==1):
				shooting = false
		else:
			#warning-ignore:warning_id 
			sprite.animation = "idle"+str(direction)
		
		
func shoot_pattern():
	var distance = $"../Player".global_position.distance_to(global_position);
	if(distance<sightRange):
		shoot_angle(800, angle_8_to_player(), 3000, 37)
		get_node("ShootSound").pitch_scale = pitch-pitchVariation/2+pitchVariation*randf();
		get_node("ShootSound").play();

func shoot(v, reach, damage):
	var bullet = Bullet.instance()
	$"..".add_child(bullet)
	bullet.position = position + v.normalized()*128;
	bullet.velocity = v
	bullet.reach = reach
	bullet.damage = damage
	shooting = true
	return bullet

func shoot_angle(speed, angle, reach, damage):
	var v = Vector2(-speed, 0)
	v = v.rotated(angle)
	return shoot(v, reach, damage)
	
func angle_to_player():
	return position.angle_to_point($"../Player".position)
	
func angle_8_to_player():
	return deg2rad(floor(rad2deg(angle_to_player())/45+0.5)*45)

func _on_Area2D_area_entered(area):
	print("AAAAAa")

func set_health(h):
	health = h
	if h <= 0:
		queue_free()

func _on_Trail_end():
	#if Input.is_action_pressed("ui_accept"):
	var points = $"../Player/Trail".points;
	find_intersections(points);


func find_intersections(points):
    var intersections = 0;

    # Iterate all segments to see if they intersect another.
    # (Start at 1 because it's easier to iterate pairs of points)
    for i in range(1, len(points)):

        # Note: the +1 makes sure we don't get two results per segment pairs
        # (intersection of A into B and intersection of B into A, which are the same anyways)

            var begin0 = points[i - 1]
            var end0 = points[i]

            var begin1 = global_position;
            var end1 = global_position + Vector2(0,5000);

            # Calculate intersection of the two segments
            var intersection = get_segment_intersection(begin0, end0, begin1, end1)
            if intersection != null:
                intersections += 1;
    if intersections == 1:
        queue_free();

    return intersections


static func get_segment_intersection(a, b, c, d):
    # http://paulbourke.net/geometry/pointlineplane/ <-- Good stuff
    var cd = d - c
    var ab = b - a
    var div = cd.y * ab.x - cd.x * ab.y

    if abs(div) > 0.001:
        var ua = (cd.x * (a.y - c.y) - cd.y * (a.x - c.x)) / div
        var ub = (ab.x * (a.y - c.y) - ab.y * (a.x - c.x)) / div
        var intersection = a + ua * ab
        if ua >= 0.0 and ua <= 1.0 and ub >= 0.0 and ub <= 1.0:
            return intersection
        return null

    # Segments are parallel!
    return null
