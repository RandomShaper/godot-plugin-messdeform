tool
extends Node

export(NodePath) var parent_path setget set_parent_path
export(NodePath) var child_path setget set_child_path
export(float, 0, 1, 0.1) var parent_weight = 0.5
export(bool) var inverse = false setget set_inverse

const PARENT_INDS = [ [ 3, 2 ], [ 0, 1 ] ]
const CHILD_INDS = [ [ 0, 1 ], [ 3, 2 ] ]

var parent
var child
var parent_sgmt = []
var child_sgmt = []

var ready = false

func _enter_tree():
	set_meta("MessyJoint", true)

func _exit_tree():
	ready = false

func _ready():
	ready = true
	reset()

func set_parent_path(path):
	parent_path = path
	reset()

func set_child_path(path):
	child_path = path
	reset()

func set_inverse(new_inverse):
	inverse = new_inverse
	reset()

func reset():
	if !ready:
		return

	ready = false

	if parent_path:
		parent = get_node(parent_path)
		parent.set_polygon(parent.get_uv())
	else:
		parent = null

	if child_path:
		child = get_node(child_path)
		child.set_polygon(child.get_uv())
	else:
		child = null

	# Sanity check
	for node in [ parent, child ]:
		if !node || !node.is_type("Polygon2D"):
			print(get_name(), " is not correctly set up")
			return

	parent_sgmt.clear()
	child_sgmt.clear()

	var mode_ind = 0
	if inverse: mode_ind = 1
	for i in range(2):
		parent_sgmt.push_back(parent.get_uv()[PARENT_INDS[mode_ind][i]])
		child_sgmt.push_back(child.get_uv()[CHILD_INDS[mode_ind][i]])

	ready = true

func process_joint(out_update_data):
	if !ready:
		return

	var child_mat = child.get_relative_transform_to_parent(parent)

	for node in [child, parent]:
		if !out_update_data.has(node):
			out_update_data[node] = {}

	var mode_ind = 0
	if inverse: mode_ind = 1

	for i in range(2):
		# In parent space
		var parent_vert = parent_sgmt[i] + parent.get_offset()
		var child_vert = child_sgmt[i] + child.get_offset()

		# Now much does the offset at this side differ from the rest one?
		var rest_offs = child_sgmt[i] - parent_sgmt[i]
		var current_offs = child_mat * child_vert - parent_vert
		var excess = current_offs - rest_offs

		# Compute new vertices positions
		out_update_data[parent][PARENT_INDS[mode_ind][i]] = \
			parent_sgmt[i] + parent_weight * excess
		out_update_data[child][CHILD_INDS[mode_ind][i]] = \
			child_sgmt[i] - (1.0 - parent_weight) * excess.rotated(-child.get_rot())
