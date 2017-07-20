from visual.text import *
import time

#importing pygame to play the background music :)
#import pygame
#Uncomment it if you have the redblue gogles
scene.stereo='redblue'

scene.title = "Renaissance"
#scene.fullscreen = 1
scene.fov = 0.001
scene.range = 0
rate(100)

# Uncomment this if you need to play the background music 
#pygame.mixer.init()
#intromusic=pygame.mixer.Sound("/usr/share/sounds/KDE_Startup.wav")
#pygame.mixer.Sound.play(intromusic)



def intro():
	Title= text(pos=(0,3,0), string='MCA PROUDLY PRESENTS', color=color.red, depth=0.3, justify='center')
	for i in range(20):
		rate(10)
		scene.range = i
	Title.makeinvisible()
	scene.range = 0
	Header= text(pos=(0,3,0), string='RENAISSANCE 2005', color=color.yellow, 		depth=0.3, justify='center')
	for i in range(20):
		rate(10)
		scene.fov = 3
		scene.range = i
	# Now play with colors
	Header.reshape(color= color.cyan)
	time.sleep(1)
	Header.reshape(color= color.blue)
	time.sleep(1)
	Header.reshape(color= color.green)
	time.sleep(1)
	Header.reshape(color=color.orange)
	time.sleep(1)
	Header.reshape(color= color.red)
	# Now let's delete the Header
	Header.makeinvisible()
	scene.range = 10
	scene.fov = 0.2
	Body= text(pos=(0,3,0), string='A CELEBRATION OF LINUX ', color=color.red, depth=0.3, justify='center')
	Body.reshape(color=color.orange)

# Invoking intro()
if __name__ == '__main__':
	intro()
	
   

