tool
extends Polygon2D

export(float, 0.1, 2, 0.1) var mass_0 = 1.0
export(float, 0.1, 2, 0.1) var mass_1 = 1.0
export(float, 0.1, 2, 0.1) var mass_2 = 1.0
export(float, 0.1, 2, 0.1) var mass_3 = 1.0

onready var in_editor = get_tree().is_editor_hint()

onready var enabled = true

var polygon
var scaled_uv # If called "uv", base would be assisgned
var uv_center

func _enter_tree():
	set_meta("MessyPolygon2D", true)

func _ready():
	reset()

func set_enabled(enabled):
	self.enabled = enabled
	print(get_name(), " ", enabled)
	update()

func reset():
	# Inhibit base Polygon2D draw (hidden would prevent custom drawing)
	set_polygon(Vector2Array())
	normalize_uv()
	if !get_texture():
		uv_center = Vector2()
	else:
		uv_center = compute_center(get_uv(), [ mass_0, mass_1, mass_2, mass_3 ])
		var inv_tex_size = Vector2(1 / get_texture().get_size().x, 1 / get_texture().get_size().y)
		uv_center *= inv_tex_size

func set_messy_polygon(polygon):
	self.polygon = polygon
	update()

func _draw():
	if !enabled:
		return
	if in_editor:
		reset()

	draw_set_transform(get_offset(), 0, Vector2(1, 1))

	var center = compute_center(polygon, [ mass_0, mass_1, mass_2, mass_3 ])
	draw_subpoly(0, 1, center)
	draw_subpoly(1, 2, center)
	draw_subpoly(2, 3, center)
	draw_subpoly(3, 0, center)

func draw_subpoly(idx0, idx1, center):
	var tri = Vector2Array([ polygon[idx0], polygon[idx1], center ])
	var uvs = Vector2Array([ scaled_uv[idx0], scaled_uv[idx1], uv_center ])
	if get_vertex_colors().size() > 0:
		draw_polygon(tri, get_vertex_colors(), uvs, get_texture())
	else:
		draw_colored_polygon(tri, get_color(), uvs, get_texture())

func compute_center(points, weights = null):
	var sum = Vector2()
	var weight_sum = 0
	for i in range(points.size()):
		var weight
		if weights != null:
			weight = weights[i]
		else:
			weight = 1

		sum += weight * points[i]
		weight_sum += weight
	return sum / weight_sum

func normalize_uv():
	if !get_texture():
		return

	scaled_uv = Vector2Array()
	var original_uv = get_uv()
	var inv_tex_size = Vector2(1 / get_texture().get_size().x, 1 / get_texture().get_size().y)
	for i in range(original_uv.size()):
		scaled_uv.push_back(original_uv[i] * inv_tex_size)
