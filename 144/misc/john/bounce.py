from visual import *

#A floor is an instance of box object with attributes like length, height, width etc.
floor = box(length=4, height=0.5, width=4, color=color.blue)

# A ball is a spherical object with attributes like position,radius, color etc..
ball = sphere(pos=(0,4,0),radius=1, color=color.red)

#Ball moves in the y axis 
ball.velocity = vector(0,-1,0)

# small change in time 
dt = 0.01

while 1:
    #setting the rate of animation speed
    rate(100)
    # Change the position of ball based on the velocity on the y axis 
    ball.pos = ball.pos + ball.velocity*dt
    if ball.y < 1:
        ball.velocity.y = -ball.velocity.y
    else:
        ball.velocity.y = ball.velocity.y - 9.8*dt
