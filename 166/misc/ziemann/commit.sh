#!/bin/sh

uci set radio.@radio[0].state=0
uci commit radio

echo 'Channel selection made permanent on Router'

