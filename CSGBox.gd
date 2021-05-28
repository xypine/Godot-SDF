tool
extends CSGBox


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const slots = 10
var debugN = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(slots):
		var ind = i + 1
		material.set_shader_param("s"+str(ind)+"s", 0.0);
		material.set_shader_param("b"+str(ind)+"s", 0.0);

func recursiveFlattenChildren(o: Node, target: Array):
	for i in o.get_children():
		target.append(i)
		recursiveFlattenChildren(i, target)
	return target
func modv(v: Vector3, l: Vector3):
	return Vector3(fmod(v.x, l.x), fmod(v.y, l.y), fmod(v.z, l.z))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if false and Input.is_action_just_pressed("debug_normals"):
		debugN = not debugN
	var ind = 0
	var indb = 0
	var limits = Vector3(width, height, depth)/2.0
	for i in recursiveFlattenChildren(self, []):
		if i is CSGSphere:
			ind += 1
			ind = ind % slots
			var pos = i.global_transform.origin
#			pos = modv(pos, limits/2.0)
			material.set_shader_param("s"+str(ind), pos);
			material.set_shader_param("s"+str(ind)+"s", i.radius);
			material.set_shader_param("s"+str(ind)+"b", not i.invert_faces);
		elif i is CSGBox:
			indb += 1
			indb = indb % slots
			var pos = i.global_transform.origin
			material.set_shader_param("b"+str(indb), pos);
			material.set_shader_param("b"+str(indb)+"s", i.scale.x);
			material.set_shader_param("b"+str(indb)+"b", not i.invert_faces);
	material.set_shader_param("domainScale", limits);
	material.set_shader_param("debugNormal", debugN);
