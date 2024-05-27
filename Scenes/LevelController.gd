extends Node2D
class_name LevelController

# Groups
const G_CONTROLLABLE = "controllable"
const G_WORD = "word"

var width : int = 33
var height : int = 18
var grid_block_size : float = 26.0
var tick_time : float = 0.2

var rules : Array = []
var movables : Array = []
var refresh_timer : float = 0.00001
var refresh_words : bool = false

# Singleton instance
static var instance : LevelController

# Enums
enum WordType { OBJECT, PROPERTY, RELATION }
enum WordProperty { NONE }
enum WordObject { NONE }
enum WordRelation { IS }

# Classes
class Movable:
	var position: Vector2
	var is_stop: bool
	var is_pushable: bool

	func move(movement: Vector2, tick_time: float) -> bool:
		# 이동 로직 구현
		return true

class Thing extends Movable:
	var object: int

	func is_property(property, apply):
		# 속성 적용 로직 구현
		pass

	func is_thing(target: String):
		# 타겟 적용 로직 구현
		pass

class Rule:
	var objects: Array = []
	var properties: Array = []
	var target_objects: Array = []

# LevelController methods
func _enter_tree():
	instance = self

func _process(delta: float) -> void:
	# Refresh words timer
	if refresh_timer > 0:
		refresh_timer -= delta

		if refresh_timer <= 0:
			_refresh_words()
			refresh_words = false
			refresh_timer = 0

	# Controls
	var horizontal : int = 0
	var vertical : int = 0
	horizontal += 1 if Input.is_action_pressed("right") else 0
	horizontal -= 1 if Input.is_action_pressed("left") else 0
	vertical -= 1 if Input.is_action_pressed("up") else 0
	vertical += 1 if Input.is_action_pressed("down") else 0

	var movement : Vector2 = Vector2(horizontal if vertical == 0 else 0, vertical) * grid_block_size
	var is_moving : bool = false

	if movement != Vector2.ZERO:
		var list = get_tree().get_nodes_in_group(G_CONTROLLABLE)
		for m in list:
			is_moving = m.move(movement, tick_time)

		if is_moving:
			_tick()
	elif Input.is_action_just_released("wait"):
		_tick()

func _tick() -> void:
	refresh_timer = tick_time

func _refresh_words() -> void:
	var group = get_tree().get_nodes_in_group(G_WORD)

	_set_rules_applied(false)
	rules.clear()
	if group.size() == 0:
		return

	# Populate sorted list
	var word_list : Array = []
	for word in group:
		word_list.append(word)

	# Sort for reading in up -> down direction
	word_list.sort_custom(Callable(self, "_compare_up_down"))

	var pending_rule : Array = []
	for word in word_list:
		if pending_rule.size() != 0 and pending_rule[pending_rule.size() - 1].position != word.position + Vector2.UP * grid_block_size:
			_make_all_rule_subsets(pending_rule)
			pending_rule.clear()

		pending_rule.append(word)
	_make_all_rule_subsets(pending_rule)

	# Sort for reading in left -> right direction
	word_list.sort_custom(Callable(self, "_compare_left_right"))

	pending_rule.clear()
	for word in word_list:
		if pending_rule.size() != 0 and pending_rule[pending_rule.size() - 1].position != word.position - Vector2.RIGHT * grid_block_size:
			_make_all_rule_subsets(pending_rule)
			pending_rule.clear()

		pending_rule.append(word)
	_make_all_rule_subsets(pending_rule)

	_set_rules_applied(true)
	refresh_words = false

func _compare_up_down(w1, w2) -> int:
	return -1 if w1.position.x < w2.position.x else ( -1 if w1.position.x == w2.position.x and w1.position.y < w2.position.y else 1)

func _compare_left_right(w1, w2) -> int:
	return -1 if w1.position.y < w2.position.y else ( -1 if w1.position.y == w2.position.y and w1.position.x < w2.position.x else 1)

func _set_rules_applied(apply: bool) -> void:
	for r in rules:
		for o in r.objects:
			for m in movables:
				if m is Thing and m.object == o:
					var t : Thing = m
					for p in r.properties:
						t.is_property(p, apply)

					for to in r.target_objects:
						t.is_thing(to.lower())

func _make_all_rule_subsets(words: Array) -> void:
	for i in range(words.size(), 2, -1):
		if _make_rule(words.slice(0, i)):
			pass

	for i in range(1, words.size()):
		if _make_rule(words.slice(i, words.size() - i)):
			pass

func _make_rule(words: Array) -> bool:
	# TODO aggregation
	var objects : Array = []
	var properties : Array = []
	var target_objects : Array = []

	var waiting_for_relation : bool = false
	var found_is : bool = false
	for word in words:
		if not waiting_for_relation and word.type == WordType.OBJECT:
			if not found_is:
				objects.append(word.object)
				waiting_for_relation = true
			else:
				if word.property != WordProperty.NONE:
					properties.append(word.property)
				elif word.object != WordObject.NONE:
					target_objects.append(word.object)
				var rule = Rule.new()
				rule.objects = objects
				rule.properties = properties
				rule.target_objects = target_objects
				rules.append(rule)
				return true
		elif not waiting_for_relation and word.type == WordType.PROPERTY:
			if found_is:
				properties.append(word.property)
				var rule = Rule.new()
				rule.objects = objects
				rule.properties = properties
				rule.target_objects = target_objects
				rules.append(rule)
				return true
		elif waiting_for_relation and word.type == WordType.RELATION:
			if word.relation == WordRelation.IS:
				waiting_for_relation = false
				found_is = true
		else:
			return false  # broken rule

	return false

func register_movable(movable: Movable) -> void:
	movables.append(movable)

func unregister_movable(movable: Movable) -> void:
	movables.erase(movable)

func can_reach_position(position: Vector2) -> bool:
	var matched : Movable = null

	var adjusted_position : Vector2 = position - Vector2(grid_block_size / 2, grid_block_size / 2)

	if adjusted_position.x < 0 or adjusted_position.x >= grid_block_size * width or adjusted_position.y < 0 or adjusted_position.y >= grid_block_size * height:
		return false

	for m in movables:
		if m.position == position:
			if m.is_stop and not m.is_pushable:
				matched = null
				return false
			elif matched == null:
				matched = m if m.is_pushable else null

	return true
