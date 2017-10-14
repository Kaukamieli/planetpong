extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var screen_size
var buttonuptexture = preload("res://button.png")
var buttondowntexture = preload("res://button2.png")
var powerup
var seconds = 0
var emittime = 0
var poweruptime = 0
var powerupamount = 0
var powerupflag = 0
var time = 0

const PAD_SPEED = 250

var p1dir = "up" #direction of pads in the beginning
var p2dir = "up"
var p1points = 0
var p2points = 0
var button1flag = 0 #for making sure direction changes only once for even long button presses 
var button2flag = 0

var aiflag1 = 1 #AI should be on by default
var aiflag2 = 1

func _ready():
	screen_size = get_viewport_rect().size #find out the game area size
	set_fixed_process(true)
	randomize() #needed to make random actually random
	if (randi()%2 == 1): #randomizing the direction of ball in first round
		get_node("Ball").set_linear_velocity(Vector2(-200,0))
	else:
		get_node("Ball").set_linear_velocity(Vector2(200,0))
	get_node("powerup").set_pos(Vector2(randi()%700+150, randi()%400+100))
	get_tree().set_pause(true)
	
func _fixed_process(delta):
	
	time += delta
	seconds += delta
	emittime += delta
	var ball_pos = get_node("Ball").get_pos() #get position of ball every frame
		
	if (ball_pos.x < 0 or ball_pos.x > screen_size.x): #if ball goes to either end
		if (ball_pos.x < 0): #if ball in player1 goal, give player2 a point
			p2points += 1
			get_node("Score/p2score").set_text(str(p2points))
		if (ball_pos.x > screen_size.x):
			p1points += 1
			get_node("Score/p1score").set_text(str(p1points))
		ball_pos = screen_size*0.5 #set variable ball_pos in the center if it is in goal
		get_node("Ball").set_pos(ball_pos) #put the actuall ball node in the variable ball_pos we just got, could have done this in single line too
		if (randi()%2 == 1): #randomizing the direction of the ball after each goal
			get_node("Ball").set_linear_velocity(Vector2(-200,0))
		else:
			get_node("Ball").set_linear_velocity(Vector2(200,0))
		seconds = 0
		
	var p1_pos = get_node("Player1").get_pos() #get position of player1
	
	if(p1_pos.y > 0 and p1dir == "up"): #making the pad work with single button needs up/down flag. If you can move up and direction is up, move up
		p1_pos.y += -PAD_SPEED*delta #getting the new position, gotta know where you actually want to move before moving
	if(p1_pos.y < screen_size.y and p1dir == "down"):
		p1_pos.y += PAD_SPEED*delta
		
	get_node("Player1").set_pos(p1_pos) #set player1 position to the position we know we want to move to
	
	var p2_pos = get_node("Player2").get_pos()
	
	if(p2_pos.y > 0 and p2dir == "up"):
		p2_pos.y += -PAD_SPEED*delta
	if(p2_pos.y < screen_size.y and p2dir == "down"):
		p2_pos.y += PAD_SPEED*delta
		
	get_node("Player2").set_pos(p2_pos)
	
	if(seconds > 7): #if ball doesn't touch a player for few seconds, it's probably bouncing up and down in steep angle, so let's do something about it
		get_node("Ball").set_linear_velocity(Vector2((randf()*2-1)*2000,(randf()*2-1)*2000))
		seconds = 0
		emittime = 0
		get_node("Ball/Particles2D").set_emitting(true)
		
	if (emittime > 0.3): #emitter off after a while
		get_node("Ball/Particles2D").set_emitting(false)
		
	if (poweruptime < time): #making everything normal if powerups are off
		get_node("Ball/Sprite").set_scale(Vector2(0.5,0.5))
		
	if (time/15 > powerupamount):
		get_node("powerup").set_pos(Vector2(randi()%700+150, randi()%400+100))
		powerupamount += 1
		
	if (aiflag1 == 1):
		if(get_node("Ball").get_pos().y < get_node("Player1").get_pos().y):
			p1dir = "up"
		if(get_node("Ball").get_pos().y > get_node("Player1").get_pos().y):
			p1dir = "down"
			
	if (aiflag2 == 1):
		if(get_node("Ball").get_pos().y < get_node("Player2").get_pos().y):
			p2dir = "up"
		if(get_node("Ball").get_pos().y > get_node("Player2").get_pos().y):
			p2dir = "down"
		

		
	if (Input.is_action_pressed("p1_move")): #Making game work with keyboard Z and M too for web version.
		aiflag1 = 0
		if (button1flag == 0): #Buttons change pad directions
			button1flag = 1
			if (p1dir == "up"):
				p1dir = "down"
				get_node("TouchScreenButton").set_texture(buttondowntexture)
			elif (p1dir == "down"):
				p1dir = "up"
				get_node("TouchScreenButton").set_texture(buttonuptexture)
	if (Input.is_action_pressed("p2_move")):
		aiflag2 = 0
		if (button2flag == 0):
			button2flag = 1
			if (p2dir == "up"):
				p2dir = "down"
				get_node("TouchScreenButton1").set_texture(buttondowntexture)
			elif (p2dir == "down"):
				p2dir = "up"
				get_node("TouchScreenButton1").set_texture(buttonuptexture)
	if (!Input.is_action_pressed("p1_move")):
		button1flag = 0;
	if (!Input.is_action_pressed("p2_move")):
		button2flag = 0;

func _on_TouchScreenButton_pressed(): #Normal buttons couldn't handle 2 presses at the same time, but touchscreenbutton can
	aiflag1 = 0
	if (button1flag == 0): #Buttons change pad directions
		button1flag = 1
		if (p1dir == "up"):
			p1dir = "down"
			get_node("TouchScreenButton").set_texture(buttondowntexture)
		elif (p1dir == "down"):
			p1dir = "up"
			get_node("TouchScreenButton").set_texture(buttonuptexture)

func _on_TouchScreenButton_released(): #To reset the flag. Flag makes sure the action only happens once and not every frame you touch the button. 
	button1flag = 0

func _on_TouchScreenButton1_pressed(): 
	aiflag2 = 0
	if (button2flag == 0):
		button2flag = 1
		if (p2dir == "up"):
			p2dir = "down"
			get_node("TouchScreenButton1").set_texture(buttondowntexture)
		elif (p2dir == "down"):
			p2dir = "up"
			get_node("TouchScreenButton1").set_texture(buttonuptexture)

func _on_TouchScreenButton1_released():
	button2flag = 0

func _on_Ball_body_enter( body ):

	if (body == get_node("Player1") or body == get_node("Player2")):
		seconds = 0
		emittime = 0
		get_node("Ball/Particles2D").set_emitting(true)
	if (body == get_node("powerup")):
		get_node("Ball").set_angular_velocity(randi()%100-50)
		poweruptime = time + 7
		pass


func _on_Splashscreenbutton_pressed():
		get_tree().set_pause(false)
		get_node("Splashscreen").queue_free()
