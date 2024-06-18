extends Node2D

@export var camera_limit_left = -10000000
@export var camera_limit_top = -10000000
@export var camera_limit_right = 10000000
@export var camera_limit_bottom = 10000000

@export var initial_dialog : Array[String] = []
@export var state = 0

@onready var camera = $hecCamera

@onready var hellBomb = preload("res://bomb_effect_hell.tscn")
@onready var earthBomb = preload("res://bomb_effect_earth.tscn")
@onready var moonBomb = preload("res://bomb_effect_moon.tscn")

@onready var chatbox_class = preload("res://talk_box.tscn")

enum HEC {HELL, EARTH, MOON}

var worldID : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$hecCamera.limit_left = camera_limit_left
	$hecCamera.limit_right = camera_limit_right
	$hecCamera.limit_top = camera_limit_top
	$hecCamera.limit_bottom = camera_limit_bottom
	
	worldID = scene_file_path.split('res://')[1].split('.tscn')[0]
	print(worldID)
	var world_state = global.get_world_state(worldID)
	global.set_world_state(worldID, world_state)
	print(global.allWorldState)
	set_instance_state(world_state)
	connect_fairy_spawners()
	
	# dead characters get revived with 1 hp
	if global.hp[HEC.HELL] <= 0:
		global.set_hp(HEC.HELL, 1)
	if global.hp[HEC.EARTH] <= 0:
		global.set_hp(HEC.EARTH, 1)
	if global.hp[HEC.MOON] <= 0:
		global.set_hp(HEC.MOON, 1)
		
	#camera.update_camera_position()
	# initial dialog if applicable
	if len(initial_dialog) > 0:
		var chat = chatbox_class.instantiate()
		chat.messages = initial_dialog
		chat.loopmode = 3
		chat.n_message_list = 1
		global.dialogBox.activate(chat)

func bomb(actives, level):
	print("booom")
	print(actives)
	if actives["moon"]:
		moon_bomb(level)
	if actives["hell"]:
		hell_bomb(level)
	if actives["earth"]:
		earth_bomb(level)
	await get_tree().create_timer(global.bomb_duration).timeout
	global.canbomb = true
	

func hell_bomb(level):
	var obj = hellBomb.instantiate()
	obj.damage = global.baseBombDMG * level * global.spl[0]
	obj.position = $hecCamera.cam_position()
	if level == 3:
		obj.instakill = true
	global.world_node().add_child(obj)
	
func earth_bomb(level):
	var obj = earthBomb.instantiate()
	obj.position = $hecCamera.cam_position()
	global.world_node().add_child(obj)
	for child in $hecCamera.get_children():
		if child is Hecatia:
			if not child.dead:
				child.healing_animation()
	var plushp = 10 + (global.spl[HEC.EARTH] - 1) * 5
	if level < 3:
		var newhp = clamp(global.hp[HEC.HELL] + plushp,0,global.maxhp[HEC.HELL])
		newhp = max(global.hp[HEC.HELL], newhp)
		global.set_hp(HEC.HELL, newhp)
		newhp = clamp(global.hp[HEC.EARTH] + plushp,0,global.maxhp[HEC.EARTH])
		newhp = max(global.hp[HEC.EARTH], newhp)
		global.set_hp(HEC.EARTH, newhp)
		newhp = clamp(global.hp[HEC.MOON] + plushp,0,global.maxhp[HEC.MOON])
		newhp = max(global.hp[HEC.MOON], newhp)
		global.set_hp(HEC.MOON, newhp)
	else:
		# can overheal
		# TODO: maybe cap at 99? Not sure.
		global.set_hp(HEC.HELL, global.hp[HEC.HELL] + plushp)
		global.set_hp(HEC.EARTH, global.hp[HEC.EARTH] + plushp)
		global.set_hp(HEC.MOON, global.hp[HEC.MOON] + plushp)
	
func moon_bomb(level):
	var obj = moonBomb.instantiate()
	obj.position = $hecCamera.cam_position()
	global.world_node().add_child(obj)
	# TODO random effects
	# invincibility
	# change music
	# turn enemy into weaklings / oure spirits
	# confuse enemies

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	camera.update_camera_position()

func set_hecatias_position(pos : Vector2):
	$hecCamera/hecatia1.position = pos - Vector2(16,0)
	$hecCamera/hecatia2.position = pos
	$hecCamera/hecatia3.position = pos + Vector2(16,0)
	$hecCamera.set_cam_position(pos)
	
func get_alive_hec_positions():
	var hecposlist = []
	for child in $hecCamera.get_children():
		if child is Hecatia:
			if not child.dead:
			#print(child)
				hecposlist.append(child.position)
	return hecposlist
	
func connect_fairy_spawners():
	for child in get_children():
		if child is FairySpawner:
			child.connect('spawner_state_update', _update_world_state)

func get_default_world_state():
	var world_state = {'state' : 0}
	for child in get_children():
		if child is FairySpawner:
			world_state[child.name] = child.STATE.ALIVE
	return world_state
	
func set_instance_state(world_state):
	state = world_state['state']
	for child in get_children():
		if child is FairySpawner:
			child.set_initial_state(world_state[child.name])

func get_camera_pos():
	return camera.cam_position()
	
func show_oob(hectype):
	match hectype:
		HEC.HELL:
			$OOBindicator1.visible = true
		HEC.EARTH:
			$OOBindicator2.visible = true
		HEC.MOON:
			$OOBindicator3.visible = true
			
func hide_oob(hectype):
	match hectype:
		HEC.HELL:
			$OOBindicator1.visible = false
		HEC.EARTH:
			$OOBindicator2.visible = false
		HEC.MOON:
			$OOBindicator3.visible = false
			
func set_state(s):
	state = s
	global.allWorldState[worldID]['state'] = s

func _update_world_state(spawnerID, spawnerState):
	global.allWorldState[worldID][spawnerID] = spawnerState