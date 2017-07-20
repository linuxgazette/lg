#!/bin/sh

decode(){
echo $QUERY_STRING |\
   sed 's/+/ /g'| sed 's/\%0[dD]//g' |\
   awk '/%/{while(match($0,/\%[0-9a-fA-F][0-9a-fA-F]/))\
     {$0=substr($0,1,RSTART-1)sprintf("%c",0+("0x"substr(\
      $0,RSTART+1,2)))substr($0,RSTART+3);}}{print}'
}
TMP=$( decode )
CHAN=${TMP%=http*}
URL=${TMP:4}
uci set radio.@radio[0].$CHAN=$URL
echo "Setting Channel $CHAN to station $URL"
