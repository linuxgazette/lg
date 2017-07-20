#!/bin/sh

# logger button handler: $BUTTON $ACTION $SEEN

STATE=$(uci get radio.@radio[0].state)

CH1=$(uci get radio.@radio[0].ch1)
CH2=$(uci get radio.@radio[0].ch2)
CH3=$(uci get radio.@radio[0].ch3)
CH4=$(uci get radio.@radio[0].ch4)
CH5=$(uci get radio.@radio[0].ch5)

if [ $BUTTON = "ses" ] ; then

if [ $ACTION = "released" ] ; then
# logger state=$STATE
  killall wget
  if [ $SEEN -gt "0" ] ; then
    STATE=-1
  fi
  case $STATE in
  0 )
     madplay /root/radio/ch1.mp3
     wget -q -O - $CH1 | madplay - &
     uci set radio.@radio[0].state=1
     ;;
  1 )
     madplay /root/radio/ch2.mp3
     wget -q -O - $CH2 | madplay - &
     uci set radio.@radio[0].state=2
     ;;
  2 )
     madplay /root/radio/ch3.mp3
     wget -q -O - $CH3 | madplay - &
     uci set radio.@radio[0].state=3
     ;;
  3 )
     madplay /root/radio/ch4.mp3
     wget -q -O - $CH4 | madplay - & 
     uci set radio.@radio[0].state=4
     ;;
  4 )
     madplay /root/radio/ch5.mp3
     wget -q -O - $CH5 | madplay - &
     uci set radio.@radio[0].state=5
     ;;
  * )
     uci set radio.@radio[0].state=0
     madplay /root/radio/off.mp3
     ;;
  esac
fi

fi

if [ $BUTTON = "reset" ] ; then
  if [ $ACTION = "pressed" ] ; then
    killall wget
    uci set radio.@radio[0].state=0
    madplay /root/radio/off.mp3
  fi
fi

