tool
extends EditorPlugin

var btn_reset

var joint_man

func _enter_tree():
	add_custom_type("MessyJoint", "Node", preload("MessyJoint.gd"), preload("MessyJoint.png"))
	add_custom_type("MessyJointManager", "Node", preload("MessyJointManager.gd"), preload("MessyJointManager.png"))
	add_custom_type("MessyPolygon", "Polygon2D", preload("MessyPolygon.gd"), preload("MessyPolygon.png"))

	btn_reset = Button.new()
	btn_reset.set_text("Reset")
	btn_reset.set_h_size_flags(Control.SIZE_EXPAND)
	btn_reset.hide()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, btn_reset)
	btn_reset.connect("pressed", self, "on_reset_pressed", []);

func _exit_tree():
	remove_custom_type("MessyJointManager")
	remove_custom_type("MessyJoint")

func handles(object):
	return object.has_meta("MessyJointManager")

func make_visible(visible):
	if visible:
		btn_reset.show()
	else:
		btn_reset.hide()

func edit(object):
	joint_man = object

func clear():
	joint_man = null

func on_reset_pressed():
	joint_man.reset_joints()
