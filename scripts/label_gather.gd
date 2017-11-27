extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process(true)
	
func _process(delta):
	set_global_position(get_global_mouse_position()+Vector2(0,20))
	#set("position", get_local_mouse_pos()+Vector2(0,20))
