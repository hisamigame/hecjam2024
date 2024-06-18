extends Control

const TARGET_FPS=60
const x_width = 256
const y_width = 176

var current_world = 'world0'
var old_world = ''
var old_world_scene = null

var hell_active = false
var earth_active = false
var moon_active = false

enum HECTYPE {HELL, EARTH, MOON}

var inputstring = {'hell' : HECTYPE.HELL, 'earth' : HECTYPE.EARTH, 'moon' : HECTYPE.MOON}

var actives = {'hell' : false, 'earth' : false, 'moon' : false}

const defaultHP = 20
const defaultMaxHP = 20
const defaultAtk = 10
const defaultSpl = 1

const baseBombDMG = 50
const bomb_duration = 0.5

var spl = [1.0, 1.0, 1.0]
var atk = [1.0, 1.0, 1.0]
var maxhp = [20, 20, 20]
var hp = [20, 20, 20]
var bombs = 0
var canbomb = false
var canchat = true

@onready var hplabels = [$VBoxContainer/UI/hp0, $VBoxContainer/UI/hp1, $VBoxContainer/UI/hp2]
@onready var spllabels = [$VBoxContainer/UI/spl0, $VBoxContainer/UI/spl1, $VBoxContainer/UI/spl2]
@onready var atklabels = [$VBoxContainer/UI/atk0, $VBoxContainer/UI/atk1, $VBoxContainer/UI/atk2]
@onready var prompts = [$VBoxContainer/UI/Z, $VBoxContainer/UI/X, $VBoxContainer/UI/C]

@onready var viewport = $VBoxContainer/SubViewportContainer/SubViewport

@onready var dialogBox = $dialogBox
const saveFile = 'file://save.json'

var allWorldState = {} # we build the world-state dictionary as we traverse game

func set_hp(t, newhp):
	if newhp < 0:
		newhp = 0
	hp[t] = newhp
	hplabels[t].text = str(newhp) +"/" + str(maxhp[t])
	
func set_maxhp(t, newmaxhp):
	maxhp[t] = newmaxhp
	hplabels[t].text = str(hp[t]) +"/" + str(newmaxhp)
	
func set_spl(t, newSPL):
	spl[t] = newSPL
	spllabels[t].text = str(newSPL)
	
func set_atk(t, newATK):
	atk[t] = newATK
	atklabels[t].text = str(newATK)

func load_state_from_disc():
	pass
	
func save_state_to_disc():
	pass
	
func get_world_state(world):
	var world_state
	if world in allWorldState:
		world_state = allWorldState[world]
	else:
		world_state = world_node().get_default_world_state()
	return world_state
	
func set_world_state(world, state):
	allWorldState[world] = state

func _ready():
	hide_ui()

func start_game():
	var world = load("res://" + global.current_world + ".tscn")
	var worldscene = world.instantiate()
	worldscene.name = global.current_world
	global.get_subviewport().add_child(worldscene)
	worldscene.process_mode = Node.PROCESS_MODE_PAUSABLE
	set_hp(HECTYPE.HELL, defaultHP)
	set_hp(HECTYPE.EARTH, defaultHP)
	set_hp(HECTYPE.MOON, defaultHP)
	set_maxhp(HECTYPE.HELL, defaultMaxHP)
	set_maxhp(HECTYPE.EARTH, defaultMaxHP)
	set_maxhp(HECTYPE.MOON, defaultMaxHP)
	set_atk(HECTYPE.HELL, defaultAtk)
	set_atk(HECTYPE.EARTH, defaultAtk)
	set_atk(HECTYPE.MOON, defaultAtk)
	set_spl(HECTYPE.HELL, defaultSpl)
	set_spl(HECTYPE.EARTH, defaultSpl)
	set_spl(HECTYPE.MOON, defaultSpl)
	global.show_ui()
	get_tree().current_scene.call_deferred('free')
	canbomb = true

func hide_ui():
	$VBoxContainer/UI.visible = false
	
func show_ui():
	$VBoxContainer/UI.visible = true

func transition():
	$transition.generate_offsets()
	$transition.transition()
	
func stoptransition():
	$transition.reset()

func _unhandled_input(event):
	for s in actives:
		if event.is_action_pressed(s):
			actives[s] = true
			prompts[inputstring[s]].set_pressed()
			
		elif event.is_action_released(s):
			actives[s] = false
			prompts[inputstring[s]].set_unpressed()
	
	#if event.is_action_pressed("bomb") and canchat:
	#	if !$dialogBox.active:
	#		#pause()
	#		$dialogBox.activate(['message 1 long long long long log', 'message 2', 'junko is good'])
	
	if event.is_action_pressed("bomb") and canbomb:
		pause()
		print("boom incoming...")
		global.canbomb = false
		$bombScreen.activate()

# Called when the node enters the scene tree for the first time.

func get_subviewport():
	return get_node("/root/global/VBoxContainer/SubViewportContainer/SubViewport")

func world_node():
	return get_node_or_null("/root/global/VBoxContainer/SubViewportContainer/SubViewport/" + current_world)

func old_world_node():
	return get_node_or_null("/root/global/VBoxContainer/SubViewportContainer/SubViewport/" + old_world)

func get_camera_pos():
	var world = world_node()
	if world:
		return world.get_camera_pos()
	else:
		return null

func pause():
	get_tree().paused = true
	
func unpause():
	get_tree().paused = false

func change_level(scene_name, spawnID):
	call_deferred('_change_level', scene_name, spawnID)
	
func _change_level(scene_name, spawnID):
	var scene = load('res://' + scene_name + '.tscn')
	pause()
	canbomb = false
	transition()
	var newWorld = scene.instantiate()
	old_world = current_world
	current_world = scene_name
	
	old_world_scene = old_world_node()
	old_world_scene.free()
	#viewport().call_deferred('remove_child', old_world_scene)
	newWorld.process_mode = Node.PROCESS_MODE_PAUSABLE
	newWorld.name = scene_name
	set_hecatia_to_spawn(newWorld, spawnID)
	get_subviewport().add_child(newWorld)
	
func set_hecatia_to_spawn(newWorld, spawnID):
	var pos = Vector2.ZERO
	var spawnPoint = newWorld.get_node_or_null('spawnPoint' + str(spawnID))
	if spawnPoint:
		pos = spawnPoint.position
	newWorld.set_hecatias_position(pos)
	
func transition_done():
	if not dialogBox.active:
		unpause()
	stoptransition()
	canbomb = true
