extends Line2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var point
var time = 0;
var removal = 0
var oldpoint;
signal end;
export(NodePath) var targetpath
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	global_position = Vector2(0,0);
	global_rotation = 0;
	point = get_parent().global_position;
	if Input.is_action_pressed("ui_page_down"): #Placeholder for when you should actually check for whether or not to draw line
		if(time < .05):
			time += delta;
		elif get_parent().velocity.length() > 1:
			#Add a point, reset the point timer, and check for intersections
			add_point(point);
			time -= .05;
			if len(points) > 5:
				find_intersections(points);
		oldpoint = point;
	elif len(points) > 0:
		remove_point(0);
	
	pass;
	
func find_intersections(points):
    var intersections = []

    # Iterate all segments to see if they intersect another.
    # (Start at 1 because it's easier to iterate pairs of points)
    for i in range(1, len(points)-2):

        # Note: the +1 makes sure we don't get two results per segment pairs
        # (intersection of A into B and intersection of B into A, which are the same anyways)
        if true:
            var j = len(points)-1;
            if abs(j - i) < 2:
                # Ignore self and neighbors
                continue

            var begin0 = points[i - 1]
            var end0 = points[i]

            var begin1 = points[j - 1]
            var end1 = points[j]

            # Calculate intersection of the two segments
            var intersection = get_segment_intersection(begin0, end0, begin1, end1)
            if intersection != null:
                for _p in range(0, i-1):
                     remove_point(0);
                emit_signal("end");
               

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
