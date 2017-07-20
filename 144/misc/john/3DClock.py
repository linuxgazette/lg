from visual.text import *
import time

scene.title = "3D Clock"
while 1:
	rate(100)
	cur_time = time.localtime()
	time_string = str(cur_time[3]) +": "+ str(cur_time[4]) + ": "+ str(cur_time[5])
	timer = text(pos=(-3,0,-2), string=time_string, color= color.red, depth=0.5 )
	time.sleep(1)
        timer.makeinvisible()
	
	
        
