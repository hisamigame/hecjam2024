extends Area2D
class_name TalkBox

enum LOOPMODE {LOOP, NOLOOP, LASTONLY, REMOVESELF}

enum PORTRAITS {HELLNEUTRAL, HELLHAPPY, HELLANGRY,
	EARTHNEUTRAL, EARTHHAPPY, EARTHANGRY,
	MOONNEUTRAL, MOONHAPPY, MOONANGRY,
	JUNKONEUTRAL, JUNKOHAPPY, JUNKOANGRY,
	HISAMINEUTRAL, HISAMIHAPPY, HISAMIANGRY}

enum PORTRAITSTATUS {HIDDEN, INACTIVE, ACTIVE}

# THIS IS THE WORST PROGRAMMIGN SIN
# YOU'LL SEE IN THIS JAM, PROBABLY
# I'm using list of strings because @export  can't support array of arrays.
@export var message_list_list : Array[String]
@export var portrait1_list_list : Array[String]
@export var status1_list_list : Array[String]
@export var portrait2_list_list : Array[String]
@export var status2_list_list : Array[String]


# we do a lot of hacky things here since our dialog/portait/status
# are lists of strings, so we need to convert strings to expressions
# use dictionaries for this
var expression_dict = {
	'jun' : PORTRAITS.JUNKONEUTRAL, 'juh' : PORTRAITS.JUNKOHAPPY, 'jua' : PORTRAITS.JUNKOANGRY,
	'hin' : PORTRAITS.HISAMINEUTRAL, 'hih' : PORTRAITS.HISAMIHAPPY, 'hia' : PORTRAITS.HISAMIANGRY,
	'hn' : PORTRAITS.HELLNEUTRAL, 'hh' : PORTRAITS.HELLHAPPY, 'ha' : PORTRAITS.HELLANGRY,
	'en' : PORTRAITS.EARTHNEUTRAL, 'eh' : PORTRAITS.EARTHHAPPY, 'ea' : PORTRAITS.EARTHANGRY,
	'mn' : PORTRAITS.MOONNEUTRAL, 'mh' : PORTRAITS.MOONHAPPY, 'ma' : PORTRAITS.MOONANGRY,
	'hen' : PORTRAITS.HELLNEUTRAL, 'heh' : PORTRAITS.HELLHAPPY, 'hea' : PORTRAITS.HELLANGRY,
	}
# hen/heh/hea keys updated to point to hec that initiated conversation.

var status_dict = {
	'0' : PORTRAITSTATUS.HIDDEN,
	'1' : PORTRAITSTATUS.INACTIVE,
	'2' : PORTRAITSTATUS.ACTIVE,
}

var portraits1 : Array[String]
var status1 : Array[String]
var portraits2 : Array[String]
var status2 : Array[String]
var messages : Array[String]

var n_message_list : int
var this_message_i = 0

@export var loopmode = LOOPMODE.LOOP

enum HEC {EARTH, HELL, MOON}
@export var initiator = HEC.HELL

func update_dict():
	# updated dictionary based on who triggered the talkbox
	match initiator:
		HEC.EARTH:
			expression_dict['hen'] = PORTRAITS.EARTHNEUTRAL
			expression_dict['heh'] = PORTRAITS.EARTHHAPPY
			expression_dict['hea'] = PORTRAITS.EARTHANGRY
		HEC.HELL:
			expression_dict['hen'] = PORTRAITS.HELLNEUTRAL
			expression_dict['heh'] = PORTRAITS.HELLHAPPY
			expression_dict['hea'] = PORTRAITS.HELLANGRY
		HEC.MOON:
			expression_dict['hen'] = PORTRAITS.MOONNEUTRAL
			expression_dict['heh'] = PORTRAITS.MOONHAPPY
			expression_dict['hea'] = PORTRAITS.MOONANGRY

func _ready():
	n_message_list = len(message_list_list)
	if n_message_list > 0:
		this_message_i = 0
		messages.assign(message_list_list[this_message_i].split('|'))
		portraits1.assign(portrait1_list_list[this_message_i].split('|'))
		portraits2.assign(portrait2_list_list[this_message_i].split('|'))
		status1.assign(status1_list_list[this_message_i].split('|'))
		status2.assign(status2_list_list[this_message_i].split('|'))
	else:
		# this chat box has no dialog.
		# pointless. Should probably never happen?
		monitorable = false

func next_message():
	match loopmode:
		LOOPMODE.LOOP:
			this_message_i = (this_message_i + 1)%n_message_list
			messages.assign(message_list_list[this_message_i].split('|'))
			portraits1.assign(portrait1_list_list[this_message_i].split('|'))
			portraits2.assign(portrait2_list_list[this_message_i].split('|'))
			status1.assign(status1_list_list[this_message_i].split('|'))
			status2.assign(status2_list_list[this_message_i].split('|'))
		LOOPMODE.NOLOOP:
			this_message_i = clampi(this_message_i+1,0,n_message_list-1)
			messages.assign(message_list_list[this_message_i].split('|'))
			portraits1.assign(portrait1_list_list[this_message_i].split('|'))
			portraits2.assign(portrait2_list_list[this_message_i].split('|'))
			status1.assign(status1_list_list[this_message_i].split('|'))
			status2.assign(status2_list_list[this_message_i].split('|'))
		LOOPMODE.LASTONLY:
			this_message_i = this_message_i + 1
			if this_message_i == n_message_list:
				this_message_i = n_message_list - 1
				messages.assign([message_list_list[this_message_i].split('|')[-1]])
				portraits1.assign([portrait1_list_list[this_message_i].split('|')[-1]])
				portraits2.assign([portrait2_list_list[this_message_i].split('|')[-1]])
				status1.assign([status1_list_list[this_message_i].split('|')[-1]])
				status2.assign([status2_list_list[this_message_i].split('|')[-1]])
			else:
				messages.assign(message_list_list[this_message_i].split('|'))
				portraits1.assign(portrait1_list_list[this_message_i].split('|'))
				portraits2.assign(portrait2_list_list[this_message_i].split('|'))
				status1.assign(status1_list_list[this_message_i].split('|'))
				status2.assign(status2_list_list[this_message_i].split('|'))
		LOOPMODE.REMOVESELF:
			this_message_i = this_message_i + 1
			if this_message_i == n_message_list:
				# safe to do since
				# next_message() is called
				# after the previous message just closed
				# and not while the next message is about
				# to be displayed.
				queue_free()
			else:
				messages.assign(message_list_list[this_message_i].split('|'))
				portraits1.assign(portrait1_list_list[this_message_i].split('|'))
				portraits2.assign(portrait2_list_list[this_message_i].split('|'))
				status1.assign(status1_list_list[this_message_i].split('|'))
				status2.assign(status2_list_list[this_message_i].split('|'))
