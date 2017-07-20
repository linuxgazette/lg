#******************************************************************#
# File Name      :      sine.py                                    #
# Date           :      07/11/2007                                 #
# Author         : Maxin B. John <maxinbjohn at gmail.com>         #
# Project Name   : PyX sample programs                             #
# Version        :1.0                                              #
# Discription    :This will plot the sine function                 #
# History        : 07.11.2007 - Created this file.                 #
#******************************************************************#

from pyx import *

g = graph.graphxy(width=8)
g.plot(graph.data.function("y(x)=sin(x)", min=0, max=10))
g.writePSfile("sine")
