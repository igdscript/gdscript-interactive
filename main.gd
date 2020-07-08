extends VSplitContainer

onready var expression = Expression.new()
var last_ctrl_pressed:int=0
var history=[""]
var history_pos:int=-1

func _ready():
	pass # Replace with function body.
	
func append_log(s):
	var colh=$log.cursor_get_line()
	var colw=$log.cursor_get_column()
	var linenum=$log.get_line_count()
	$log.deselect()
	$log.cursor_set_line($log.get_line_count(),false)
	#$log.cursor_set_column($log.get_line(linenum).length(),false)
	$log.insert_text_at_cursor(s+"\n")
	$log.cursor_set_line(colh,false)
	$log.cursor_set_column(colw,false)

func _unhandled_key_input(event):
	match event.scancode:
		KEY_CONTROL:
			last_ctrl_pressed=-1 if event.pressed else OS.get_ticks_msec()
			#print("Control pressed at %d" % last_ctrl_pressed)
		KEY_PAGEUP:
			if -history_pos<history.size():
				history[history_pos]=$input.text
				history_pos-=1
				$input.text=history[history_pos]
		KEY_PAGEDOWN:
			if history_pos<-1:
				history[history_pos]=$input.text
				history_pos+=1
				$input.text=history[history_pos]
		_:
			#print("Enter pressed at %d, delta=%d" % [OS.get_ticks_msec(),OS.get_ticks_msec()-last_ctrl_pressed])
			if last_ctrl_pressed==-1 || OS.get_ticks_msec()-last_ctrl_pressed<100:
				if last_ctrl_pressed!=-1: last_ctrl_pressed=0
				match event.scancode:
					KEY_DELETE:
						$log.text=""
					KEY_ENTER:
						var error = expression.parse($input.text, [])
						if error != OK:
							append_log(expression.get_error_text())
						else:
							var result = expression.execute([], null, true)
							if not expression.has_execute_failed():
								append_log(str(result))
								history[-1]=$input.text
								history_pos=-1
								history.append("")
								$input.text=""
							else:
								append_log(expression.get_error_text())
								pass
