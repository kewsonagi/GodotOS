extends Node

var default_offset = 8.0
var default_speed = 0.3



func get_node_center(node):
	return (get_viewport().get_visible_rect().size.x / 2) - (node.size.x / 2)


func animate_slide_from_left(node, offset = default_offset, speed = default_speed):
	node.position.x = -node.size.x
	
	var t = create_tween()
	t.tween_property(node, 'position:x', default_offset, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished


func animate_slide_to_left(node, offset = default_offset, speed = default_speed):
	var t = create_tween()
	t.tween_property(node, 'position:x', -node.size.x, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return t.finished


func animate_slide_from_right(node, offset = default_offset, speed = default_speed):
	node.position.x = get_viewport().size.x
	
	var vp_size = get_viewport().get_visible_rect().size.x
	
	var t = create_tween()
	t.tween_property(node, 'position:x', (vp_size - node.size.x) - default_offset, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished


func animate_slide_to_right(node, offset = default_offset, speed = default_speed):
	var t = create_tween()
	t.tween_property(node, 'position:x', get_viewport().size.x, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return t.finished


func animate_pop(node):
	node.pivot_offset.x = node.size.x / 2
	node.pivot_offset.y = node.size.y / 2
	node.scale = Vector2.ZERO
	
	var t = create_tween()
	t.tween_property(node, 'scale', Vector2.ONE, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished


func animate_shrink(node):
	var t = create_tween()
	t.tween_property(node, 'scale', Vector2.ZERO, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return t.finished


func animate_from_left_to_center(node):
	node.position.x = -node.size.x
	
	var t = create_tween()
	t.tween_property(node, 'position:x', get_node_center(node), default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished


func animate_from_center_to_left(node):
	var t = create_tween()
	t.tween_property(node, 'position:x', -node.size.x, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return t.finished


func animate_from_right_to_center(node):
	node.position.x = get_viewport().get_visible_rect().size.x
	
	var t = create_tween()
	t.tween_property(node, 'position:x', get_node_center(node), default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished


func animate_from_center_to_right(node):
	var t = create_tween()
	t.tween_property(node, 'position:x', node.size.x, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return t.finished
