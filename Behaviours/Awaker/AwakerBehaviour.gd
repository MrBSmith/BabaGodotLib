extends Behaviour
class_name AwakerBehaviour

# This Behaviour awake bodies that has the Awakable Behaviour and are 
# inside the AwakeArea when awake_nearby_bodies

# Most of the time you don't have to write any line of code, just define
# awake_nearby_bodies as an answer for a signal and connect the signal 
# from the editor and voilà!

onready var awake_area = $AwakeArea

#### ACCESSORS ####

func is_class(value: String): return value == "AwakerBehaviour" or .is_class(value)
func get_class() -> String: return "AwakerBehaviour"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

# Awake bodies in the area, so they can fall, if needed
func awake_nearby_bodies():
	if awake_area == null : return
	
	var bodies_nearby = awake_area.get_overlapping_bodies()
	for body in bodies_nearby:
		if body is PhysicsBody2D && body != owner:
			if body.is_in_group("Awakable"):
				var awake_behaviour = Utils.find_behaviour(body, "Awakable")
				awake_behaviour.call_deferred("awake")




#### INPUTS ####



#### SIGNAL RESPONSES ####
