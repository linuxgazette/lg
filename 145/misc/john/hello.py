#******************************************************************#
# File Name      :      hello.py                                   #
# Date           :      07/11/2007                                 #
# Author         : Maxin B. John <maxinbjohn at gmail.com>         #
# Project Name   : PyX sample programs                             #
# Version        :1.0                                              #
# Discription    :This will print Hello,World                      #
# History        : 07.11.2007 - Created this file.                 #
#******************************************************************#

from pyx import *

c = canvas.canvas()
c.text(10, 10, "Hello, world!")
c.writePSfile("hello")
