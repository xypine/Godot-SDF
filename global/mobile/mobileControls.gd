extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var touchEnabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(Vector2(inputX, inputY))
	if inputX != 0:
		touchEnabled = true
	if inputY != 0:
		touchEnabled = true


var inputX = 0
var inputY = 0
var inputF = false
var eTipVisible = false
var inputE = false

var startingPosition = Vector2(0, 0)
var dragging = false
var dragIndex = -99

#

var inputX2 = 0
var inputY2 = 0

var startingPosition2 = Vector2(0, 0)
var dragging2 = false
var dragIndex2 = -99

func handleTouch(event):
	inputE = false
	if event is InputEventScreenDrag:
		if event.position.x <= get_viewport_rect().size.x / 2:
			if dragging:
				var pos = event.position
				var dist = pos.x - startingPosition.x
				var dist2 = pos.y - startingPosition.y
				inputX = dist
				inputY = dist2
			elif true: #event
				dragging = true
				dragIndex = event.index
				startingPosition = event.position
		else:
			if dragging2:
				inputF = false
				var pos = event.position
				var dist = pos.x - startingPosition2.x
				var dist2 = pos.y - startingPosition2.y
				inputX2 = dist
				inputY2 = dist2
			elif true: #event
				dragging2 = true
				dragIndex2 = event.index
				startingPosition2 = event.position
	if event is InputEventScreenTouch:
		if event.position.x <= get_viewport_rect().size.x / 2:
			if event.index == dragIndex and not event.pressed:
				dragging = false
				inputX = 0
				inputY = 0
				dragIndex = -99
			elif event.position.y < 21:
				if eTipVisible and event.pressed:
					inputE = true
#					eTipVisible = false
		elif event.position.x > get_viewport_rect().size.x / 2:
			if event.index == dragIndex2 and not event.pressed:
				dragging2 = false
				inputX2 = 0
				inputY2 = 0
				dragIndex2 = -99
			if event.pressed and dragging2 == false:
				inputF = true #true
			else:
				inputF = false

func _input(event):
	handleTouch(event)
