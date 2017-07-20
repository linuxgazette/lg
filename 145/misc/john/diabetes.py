#******************************************************************#
# File Name      :      diabetes.py                                #
# Date           :      07/11/2007                                 #
# Author         : Maxin B. John <maxinbjohn at gmail.com>         #
# Project Name   : PyX sample programs                             #
# Version        :1.0                                              #
# Discription    :This will generate the diabetes level graph      #
# History        : 07.11.2007 - Created this file.                 #
#******************************************************************#

from pyx import *

g = graph.graphxy(width=8, x=graph.axis.bar()) # graphxy instance
g.plot(graph.data.file("diabetes.dat", xname=0, y=2), [graph.style.changebar()])
g.writePSfile("diabetes")
