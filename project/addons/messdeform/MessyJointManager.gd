tool
extends Node

export(bool) var enabled = true setget set_enabled

var updater = Updater.new(self)

func _enter_tree():
	set_meta("MessyJointManager", true)

func get_joints():
	var joints = []
	for child in get_children():
		if child.has_meta("MessyJoint"):
			joints.push_back(child)
	return joints

func reset_joints():
	for joint in get_joints():
		joint.reset()

func update_joints():
	var update_data = {}

	for joint in get_joints():
		joint.process_joint(update_data)

	for node in update_data:
		var new_verts = node.get_uv()

		var node_update_data = update_data[node]
		for idx in node_update_data:
			new_verts[idx] = node_update_data[idx]

		node.set_messy_polygon(new_verts)

func set_enabled(new_enabled):
	if new_enabled:
		add_child(updater)
		updater.set_draw_behind_parent(true)
	else:
		if updater:
			remove_child(updater)
		reset_joints()
	enabled = new_enabled

class Updater extends Node2D:
	var joint_man

	func _init(joint_man):
		self.joint_man = joint_man

	func _ready():
		set_process(true)

	func _process(delta):
		update()

	func _draw():
		joint_man.update_joints()
