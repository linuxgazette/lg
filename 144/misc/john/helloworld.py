from visual.text import *

# At present VPython supports only numbers and uppercase characters.Other characters will be displayed as *
# Specifying the Title of the window
scene.title = "Hello World"
# Here goes the hello world text
text(pos=(0,3,0), string='HELLO WORLD', color=color.orange, depth=0.3, justify='center')
