extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(Vector2(inputX, inputY))


var inputX = 0
var inputY = 0
var inputF = false
var eTipVisible = false
var inputE = false

var startingPositions = {}
var startingPosition = Vector2(0, 0)
var dragging = false
var dragIndex = -99

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
			elif event:
				dragging = true
				dragIndex = event.index
				startingPosition = event.position
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
					eTipVisible = false
		elif event.position.x > get_viewport_rect().size.x / 2:
			if event.pressed:
				inputF = true
			else:
				inputF = false

func _input(event):
	handleTouch(event)
