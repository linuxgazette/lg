from visual import *

"""
This will print the sin curve 
"""
scene.title = "Sin Curve"
scene.center = vector(0,0,0)

# using a suitable 'box' as x- axis 
xaxis = box(length= 20, height=0.2, width= 0.5, color=color.blue)

#creating the sine curve object
sinecurve = curve( color = color.red, radius=0.2)
dt = 0.1

for t in arange(0,10,dt):
  dydt = vector( t,sin(t), 0 );
  sinecurve.append( pos=dydt, color=(1,0,0) )
  rate( 500 )
