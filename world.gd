extends Node2D

enum MOONBOMB {CHANGE_MUSIC, CONFUSE, FREEZE, INVINCIBILITY, HPUP, ATKUP, BMBUP}

enum KIND {HP, ATK, SPL, BMB, HEALTH}

@export var camera_limit_left = -10000000
@export var camera_limit_top = -10000000
@export var camera_limit_right = 10000000
@export var camera_limit_bottom = 10000000

@export var initial_dialog : TalkBox  = null
@export var state = 0
@export var peace = false

@export var music : String = 'res://planet_something_something.ogg'

@onready var camera = $hecCamera

@onready var hellBomb = preload("res://bomb_effect_hell.tscn")
@onready var earthBomb = preload("res://bomb_effect_earth.tscn")
@onready var moonBomb = preload("res://bomb_effect_moon.tscn")

@onready var chatbox_class = preload("res://talk_box.tscn")

@onready var floating_label_scene: PackedScene = preload("res://floating_label.tscn")

enum HEC {EARTH, HELL, MOON}

var worldID : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$hecCamera.limit_left = camera_limit_left
	$hecCamera.limit_right = camera_limit_right
	$hecCamera.limit_top = camera_limit_top
	$hecCamera.limit_bottom = camera_limit_bottom
	
	if peace:
		$hecCamera/hecatia1.peace = true
		$hecCamera/hecatia2.peace = true
		$hecCamera/hecatia3.peace = true
		
	
	worldID = scene_file_path.split('res://')[1].split('.tscn')[0]
	var world_state = global.get_world_state(worldID)
	global.set_world_state(worldID, world_state)
	set_instance_state(world_state)
	connect_persistent_nodes()
	
	# dead characters get revived with 1 hp
	if global.hp[HEC.HELL] <= 0:
		global.set_hp(HEC.HELL, 1)
	if global.hp[HEC.EARTH] <= 0:
		global.set_hp(HEC.EARTH, 1)
	if global.hp[HEC.MOON] <= 0:
		global.set_hp(HEC.MOON, 1)
		
	#camera.update_camera_position()
	# initial dialog if applicable
	if initial_dialog != null:
		global.dialogBox.activate(initial_dialog)

func unglow_moongates():
	var moongates = get_tree().get_nodes_in_group('moongate')
	for gate in moongates:
		gate.material = null
	
func glow_moongates():
	var moongates = get_tree().get_nodes_in_group('moongate')
	for gate in moongates:
		# TODO: for some reason,
		# this has the same color as progress bar?
		# might be fine?
		gate.material = preload('res://moongate_material.tres')

func set_idle():
	for child in $hecCamera.get_children():
		if child is Hecatia:
			if not child.dead:
				child.animationState.travel('idle')
				

func bomb(actives, level):
	global.play_bomb()
	if actives["hell"]:
		hell_bomb(level)
	if actives["earth"]:
		earth_bomb(level)
	if actives["moon"]:
		moon_bomb(level)
	await get_tree().create_timer(global.bomb_duration).timeout
	global.canbomb = true
	

func hell_bomb(level):
	var obj = hellBomb.instantiate()
	obj.damage = (1.0 + (global.spl[HEC.HELL]-1)**2 * 0.1) *  (global.baseBombDMG +  0.5* global.baseBombDMG * (level-1))
	obj.position = $hecCamera.cam_position()
	print(obj.damage)
	if level == 3:
		obj.instakill = true
	global.world_node().add_child(obj)
	
func earth_bomb(level):
	var obj = earthBomb.instantiate()
	obj.position = $hecCamera.cam_position()
	global.world_node().add_child(obj)
	var plushp = round((1.0 + (global.spl[HEC.EARTH]-1) * 0.2) * (10 + (level - 1) * 5))
	for child in $hecCamera.get_children():
		if child is Hecatia:
			if not child.dead:
				child.healing_animation()
				show_hp_gain_label(child, plushp)
	
	if level < 3:
		var newhp = clamp(global.hp[HEC.HELL] + plushp,0,global.maxhp[HEC.HELL])
		if newhp > global.hp[HEC.HELL]:
			global.set_hp(HEC.HELL, newhp)
		newhp = clamp(global.hp[HEC.EARTH] + plushp,0,global.maxhp[HEC.EARTH])
		if newhp > global.hp[HEC.EARTH]:
			global.set_hp(HEC.EARTH, newhp)
		newhp = clamp(global.hp[HEC.MOON] + plushp,0,global.maxhp[HEC.MOON])
		if newhp > global.hp[HEC.MOON]:
			global.set_hp(HEC.MOON, newhp)
	else:
		# can overheal
		# overheal max determined by hearth spell level
		var newhp = clamp(global.hp[HEC.HELL] + plushp,0,global.maxhp[HEC.HELL] + 10*global.spl[HEC.EARTH])
		global.set_hp(HEC.HELL, newhp)
		newhp = clamp(global.hp[HEC.EARTH] + plushp,0,global.maxhp[HEC.EARTH] + 10*global.spl[HEC.EARTH])
		global.set_hp(HEC.EARTH, newhp)
		newhp = clamp(global.hp[HEC.MOON] + plushp,0,global.maxhp[HEC.MOON] + 10*global.spl[HEC.EARTH])
		global.set_hp(HEC.MOON, newhp)
	
func moon_bomb(level):
	var obj = moonBomb.instantiate()
	# 0: change music
	# 1: confuse enemies
	# 2: freeze enemy
	# 3: invincibility
	# 4: stat gain hp
	# 5: stat gain atk
	# 6: gain bomb
	# var neffects = 7
	var nmaxoutcomes = 3
	
	var happening = range(0,nmaxoutcomes)
	happening.shuffle()
	var bonus = randi_range(0, global.spl[HEC.MOON])
	for i in range(level):
		var outcome = happening[i] + bonus
		match outcome:
			MOONBOMB.CHANGE_MUSIC:
				global.funny_music()
			MOONBOMB.CONFUSE:
				obj.confuse = true
			MOONBOMB.FREEZE:
				obj.freeze = true
			MOONBOMB.INVINCIBILITY:
				for child in $hecCamera.get_children():
					if child is Hecatia:
						if not child.dead:
							child.set_invincibility(5+2.5*global.spl[HEC.MOON], true)
			MOONBOMB.HPUP:
				for child in $hecCamera.get_children():
					if child is Hecatia:
						increase_maxhp_and_show_label(child)
			MOONBOMB.ATKUP:
				for child in $hecCamera.get_children():
					if child is Hecatia:
						increase_atk_and_show_label(child)
			MOONBOMB.BMBUP:
				global.set_bombs(global.bombs + 1)
				
				show_stat_increase_label($hecCamera/hecatia3, KIND.BMB, 1)
			_:
				# if we have a large bonus
				# we could get higher values
				# give ATKUP effect
				# thus, we can get more atkup per bomb
				for child in $hecCamera.get_children():
					if child is Hecatia:
						increase_atk_and_show_label(child)
				
	obj.position = $hecCamera.cam_position()
	global.world_node().add_child(obj)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	camera.update_camera_position()

func set_hecatias_position(pos : Vector2, rot : Vector2):
	$hecCamera/hecatia1.position = pos - Vector2(16,0)
	$hecCamera/hecatia2.position = pos
	$hecCamera/hecatia3.position = pos + Vector2(16,0)
	$hecCamera/hecatia1.init_direction(rot)
	$hecCamera/hecatia2.init_direction(rot)
	$hecCamera/hecatia3.init_direction(rot)
	$hecCamera.set_cam_position(pos)
	
func get_alive_hec_positions():
	var hecposlist = []
	for child in $hecCamera.get_children():
		if child is Hecatia:
			if not child.dead:
			#print(child)
				hecposlist.append(child.position)
	return hecposlist
	
func is_any_active():
	var ret = false
	var i = 1
	for k in global.actives:
		if global.actives[k] and !$hecCamera.get_node('hecatia' + str(i+1)).dead:
			ret = true
			i = i + 1
			break
	return ret
	
func connect_persistent_nodes():
	for node in get_tree().get_nodes_in_group('fairySpawner'):
		node.connect('obj_state_update', _update_world_state)
	for node in get_tree().get_nodes_in_group('moongate'):
		node.connect('obj_state_update', _update_world_state)
	for node in get_tree().get_nodes_in_group('powerup'):
		node.connect('obj_state_update', _update_world_state)
	for node in get_tree().get_nodes_in_group('trigger'):
		node.connect('obj_state_update', _update_world_state)


func get_default_world_state():
	var world_state = {'state' : 0}
	for node in get_tree().get_nodes_in_group('fairySpawner'):
		world_state[node.name] =node.STATE.ALIVE
	for node in get_tree().get_nodes_in_group('moongate'):
		world_state[node.name] =node.STATE.ALIVE
	for node in get_tree().get_nodes_in_group('powerup'):
		world_state[node.name] =node.STATE.ALIVE
	for node in get_tree().get_nodes_in_group('trigger'):
		world_state[node.name] =node.STATE.DEFAULT
	return world_state
	
func set_instance_state(world_state):
	state = world_state['state']
	for node in get_tree().get_nodes_in_group('fairySpawner'):
		node.set_initial_state(world_state[node.name])
	for node in get_tree().get_nodes_in_group('moongate'):
		node.set_initial_state(world_state[node.name])
	for node in get_tree().get_nodes_in_group('powerup'):
		node.set_initial_state(world_state[node.name])
	for node in get_tree().get_nodes_in_group('trigger'):
		node.set_initial_state(world_state[node.name])


func get_camera_pos():
	return camera.cam_position()
	
func show_oob(hectype):
	match hectype:
		HEC.EARTH:
			$OOBindicator1.visible = true
		HEC.HELL:
			$OOBindicator2.visible = true
		HEC.MOON:
			$OOBindicator3.visible = true
			
func hide_oob(hectype):
	match hectype:
		HEC.EARTH:
			$OOBindicator1.visible = false
		HEC.HELL:
			$OOBindicator2.visible = false
		HEC.MOON:
			$OOBindicator3.visible = false
			
func set_state(s):
	state = s
	global.allWorldState[worldID]['state'] = s

func _update_world_state(spawnerID, spawnerState):
	global.allWorldState[worldID][spawnerID] = spawnerState


func show_hp_gain_label(hecatia: Hecatia, value: int = 1) -> void:
	# Taking advantage of the fact that the value of hectype
	# corresponds to the position in the maxhp array
	show_stat_increase_label(hecatia, KIND.HEALTH, value)

func increase_maxhp_and_show_label(hecatia: Hecatia, value: int = 1) -> void:
	# Taking advantage of the fact that the value of hectype
	# corresponds to the position in the maxhp array
	global.set_maxhp(hecatia.hectype, global.maxhp[hecatia.hectype] + value)
	
	show_stat_increase_label(hecatia, KIND.HP, value)


func increase_atk_and_show_label(hecatia: Hecatia, value: int = 1) -> void:
	global.set_atk(hecatia.hectype, global.atk[hecatia.hectype] + value)
	
	show_stat_increase_label(hecatia, KIND.ATK, value)


func show_stat_increase_label(hecatia: Hecatia, kind: KIND, value: int) -> void:
	if hecatia.dead:
		return
	
	var floating_label: Node2D = floating_label_scene.instantiate()
	
	floating_label.set_text(hecatia.hectype, kind, value)
	floating_label.global_position = hecatia.global_position
	
	add_child(floating_label)
