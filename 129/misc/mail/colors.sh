#! /bin/bash
#  Hey Emacs, this is a -*-bash-*- script

##  An easy graphical chart to help find out about the
##  various colors available in the console, using X,Y
##  coordinates.
##
##  The X axis denotes the background range, and the
##  Y axis the foreground range.  See bash(1) and
##  color_codes(4) man pages for details.
##
##  (C) Mahesh Aravind
##  Released under GPL.
## 
##  $Author: maravind $
##  $Date: 2006/05/13 04:58:31 $
##  $Revision: 1.6 $

# The line drawing stuff...
# X axis
echo -n "   |"
for i in $(seq 40 47)
do
    echo -n "   ${i}   "
done

# seq(1) makes everything faster and easier.
echo; echo -n "---+"
for i in $(seq 64); do echo -n "-"; done
echo

for i in $(seq 30 37)
do
    # The Y axis for each lines
    echo -n "${i} |"
    for j in $(seq 40 47)
    do
        # `\e' generates the ESC code.  To type that in the
	# console, do "Ctrl V Ctrl [".  `echo' requires that
	# you type these values in double quotes, I don't know
	# why!
        echo -en "\e[${i};${j}m Normal \e[0m"
    done
    echo

    echo -en "   |"
    for j in $(seq 40 47)
    do
        # If you want additional attributes, then substitute
	# `1' for Bold attribute,
	# `4' for Underline,
	# `5' for Blink,
	# `7' for Reverse video.
        echo -en "\e[${i};${j};1m  Bold  \e[0m"
	#                     ^^ this one...
    done
    echo
done
echo

## $Log: colors.sh,v $
## Revision 1.6  2006/05/13 04:58:31  maravind
## final finishing touches
##
## Revision 1.5  2006/05/13 04:50:58  maravind
## removed the help string outputs
##
## Revision 1.4  2006/05/13 04:43:37  maravind
## commented the script
##
## Revision 1.3  2006/05/13 04:41:10  maravind
## some minor changes.
##
## Revision 1.2  2006/05/11 04:54:22  maravind
## added graphical lines
##
## Revision 1.1  2006/05/03 09:44:12  maravind
## Initial revision
##