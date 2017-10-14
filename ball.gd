extends RigidBody2D

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	if(get_linear_velocity().length() < 100): #if our speed is less than desirable
		set_linear_velocity(get_linear_velocity().normalized()*200) #then give ball more speed in the same direction it was going
		print("speed was too low")
	if(get_linear_velocity().length() > 800):
		set_linear_velocity(get_linear_velocity().normalized()*800)
	#Yes, you do need to learn linear algebra. You absolutely have to at least know the terms like normalized...
	#and what they mean to use the premade functions. Godot does lots of math for you.
	
	#print(str(get_linear_velocity().length())) #was just used to debug the speed, doesn't need to be in game build, so I commented it out.s