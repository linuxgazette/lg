#!/bin/sh
echo 'HTTP/1.0 200 OK'
echo 'Server: Netscape-Communications/3.0'
echo 'Content-type: text/html'
echo

ch1=$(uci get radio.@radio[0].ch1)
ch2=$(uci get radio.@radio[0].ch2)
ch3=$(uci get radio.@radio[0].ch3)
ch4=$(uci get radio.@radio[0].ch4)
ch5=$(uci get radio.@radio[0].ch5)

header='<HTML><HEAD><TITLE>Radio Channels</TITLE></HEAD><BODY>
<H1 ALIGN=CENTER>Radio channel selection</H1>'

echo $header 

echo '<FORM action="setchannel.sh" method="get">'
echo -n 'Channel 1: <input type="text" name="ch1" size="80" value="'
echo -n $ch1; echo '"> '
echo '<input type="submit" value="Submit">'
echo '</FORM>'

echo '<FORM action="setchannel.sh" method="get">'
echo -n 'Channel 2 <input type="text" name="ch2" size="80" value="'
echo -n $ch2; echo '"> '
echo '<input type="submit" value="Submit">'
echo '</FORM>'

echo '<FORM action="setchannel.sh" method="get">'
echo -n 'Channel 3: <input type="text" name="ch3" size="80" value="'
echo -n $ch3; echo '"> '
echo '<input type="submit" value="Submit">'
echo '</FORM>'

echo '<FORM action="setchannel.sh" method="get">'
echo -n 'Channel 4: <input type="text" name="ch4" size="80" value="'
echo -n $ch4; echo '"> '
echo '<input type="submit" value="Submit">'
echo '</FORM>'

echo '<FORM action="setchannel.sh" method="get">'
echo -n 'Channel 5: <input type="text" name="ch5" size="80" value="'
echo -n $ch5; echo '"> '
echo '<input type="submit" value="Submit">'
echo '</FORM>'

echo '<FORM action="commit.sh" method="get">'
echo '<input type="submit" value="Make persisient on Router">'
echo '</FORM>'

echo '</BODY></HTML>' 
