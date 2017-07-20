import appuifw
from graphics import *
import e32
from key_codes import *
from socket import *

class Keyboard(object):
  def __init__(self,onevent=lambda:None):
    self._keyboard_state={}
    self._downs={}
    self._onevent=onevent
  def handle_event(self,event):
    if event['type'] == appuifw.EEventKeyDown:
      code=event['scancode']
      if not self.is_down(code):
        self._downs[code]=self._downs.get(code,0)+1
      self._keyboard_state[code]=1
    elif event['type'] == appuifw.EEventKeyUp:
      self._keyboard_state[event['scancode']]=0
    self._onevent()
  def is_down(self,scancode):
    return self._keyboard_state.get(scancode,0)
  def pressed(self,scancode):
    if self._downs.get(scancode,0):
      self._downs[scancode]-=1
      return True
    return False

keyboard=Keyboard()

PCBTADDR = '00:10:DC:71:75:82'
port = 4

btsock = socket(AF_BT, SOCK_STREAM, BTPROTO_RFCOMM)
target = (PCBTADDR, port)
btsock.connect(target)

appuifw.app.screen='normal'
appuifw.app.title=u'Linux Desktop Control'

img=None
def handle_redraw(rect):
  if img:
    canvas.blit(img)

appuifw.app.body=canvas=appuifw.Canvas(
  event_callback=keyboard.handle_event,
  redraw_callback=handle_redraw)
img=Image.new(canvas.size)

running=1
def quit():
  global running
  global btsock
  running=0
  btsock.close()

appuifw.app.exit_key_handler=quit

while running:
  e32.ao_sleep(0.1)
  handle_redraw(())
  e32.ao_yield()
  if keyboard.is_down(EScancodeLeftArrow):
    canvas.text((0,48),u"Left key pressed",fill=0xff0000)
    btsock.send('Left')
  if keyboard.is_down(EScancodeRightArrow):
    canvas.text((0,48),u"Right key pressed",fill=0xff0000)
    btsock.send('Right')
  if keyboard.is_down(EScancodeDownArrow):
    canvas.text((0,48),u"Down key pressed",fill=0xff0000)
    btsock.send('Down')
  if keyboard.is_down(EScancodeUpArrow):
    canvas.text((0,48),u"Up key pressed",fill=0xff0000)
    btsock.send('Up')
  if keyboard.is_down(EScancodeSelect):
    canvas.text((0,48),u"Select key pressed",fill=0xff0000)
    btsock.send('Select')
  if keyboard.is_down(EScancodeBackspace):
    canvas.text((0,48),u"Backspace key pressed",fill=0xff0000)
    btsock.send('Backspace')
  if keyboard.is_down(EScancode0):
    canvas.text((0,48),u"0 key pressed",fill=0xff0000)
    btsock.send('0')
  if keyboard.is_down(EScancode1):
    canvas.text((0,48),u"1 key pressed",fill=0xff0000)
    btsock.send('1')
  if keyboard.is_down(EScancode2):
    canvas.text((0,48),u"2 key pressed",fill=0xff0000)
    btsock.send('2')
  if keyboard.is_down(EScancode3):
    canvas.text((0,48),u"3 key pressed",fill=0xff0000)
    btsock.send('3')
  if keyboard.is_down(EScancode4):
    canvas.text((0,48),u"4 key pressed",fill=0xff0000)
    btsock.send('4')
  if keyboard.is_down(EScancode5):
    canvas.text((0,48),u"5 key pressed",fill=0xff0000)
    btsock.send('5')
  if keyboard.is_down(EScancode6):
    canvas.text((0,48),u"6 key pressed",fill=0xff0000)
    btsock.send('6')
  if keyboard.is_down(EScancode7):
    canvas.text((0,48),u"7 key pressed",fill=0xff0000)
    btsock.send('7')
  if keyboard.is_down(EScancode8):
    canvas.text((0,48),u"8 key pressed",fill=0xff0000)
    btsock.send('8')
  if keyboard.is_down(EScancode9):
    canvas.text((0,48),u"9 key pressed",fill=0xff0000)
    btsock.send('9')
  if keyboard.is_down(EScancodeStar):
    canvas.text((0,48),u"Star key pressed",fill=0xff0000)
    btsock.send('Star')
  if keyboard.is_down(EScancodeHash):
    canvas.text((0,48),u"Hash key pressed",fill=0xff0000)
    btsock.send('Hash')
    running=0

btsock.close()
