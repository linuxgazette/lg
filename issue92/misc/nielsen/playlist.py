#!/usr/bin/python
# Make sure this line above is the first line of this file.

### Copyright under GPL 

  ## import the python modules we need. 
import os, re, time, random

  ## Setup some variables. You can change these varaibles for your needs. 
Home = "/var/www/html/audio"
Url_Base = "http://127.0.0.1/audio"
Song_Max = 200
List_Type = "mpegurl"

## DO NOT CHANGE ANYTHING BELOW HERE UNLESS YOU ARE A PYTHON GEEK.
File_Match = re.compile('[{mp3}{rm}{wav}{ogg}{mpeg}]$')
Home_Re = re.compile('^' + Home)
List_Types = {'smil':'application/smil', 'mpegurl':'audio/x-mpegurl'}

#---------------------------------------
  ## This function will go through and get the absolute path of all files
  ## that match. It is a recursive method. 
def Dir_Contents(Item=""):
  Final_List = []  
  if Item == '': return ('')
  elif os.path.isdir(Item):
    List = os.listdir(Item)
    for Item2 in List:
      Item3 = Item + "/" + Item2
      Temp_List = Dir_Contents(Item=Item3)
      for Item4 in Temp_List: Final_List.append(Item4)
  elif os.path.isfile(Item):
    if File_Match.search(Item):   return([Item])
    else:   return([])
  return (Final_List)
      
#--------------------------

List =  Dir_Contents(Home)
List_Copy = List
  ## Randomize how many times we call random. 
Secs = int(time.strftime('%S')) * int(time.strftime('%H')) * int(time.strftime('%M'))
for i in range(0,Secs): random.random()

  ## Randomly get one file at a time until there is none left. 
New_List = []
while (len(List_Copy) > 0):
  Position = random.randint(0,len(List_Copy) - 1)
  New_List.append(List_Copy[Position])
  del List_Copy[Position]

  ## Redo the urls in the list.
Urls = []
for Item in New_List:
    ## For each item, strip the Home directory prefix and preappend the url.
  Url = Url_Base + Home_Re.sub('', Item)
  Urls.append(Url)    

  ## If we are greater than the number of songs we want to listen to,
  ## cap it off. Bonus points if you can figure out how many songs
  ## are in this array when Song_Max = 200.
if len(New_List) > Song_Max:  New_List = New_List[0:Song_Max]

  ## If the idiot who edited this file has an invalid list type.... 
if not List_Types.has_key(List_Type): List_Type = 'mpegurl'
Content_Type = List_Types[List_Type]

  ### Now print out the content. 
print "Content-Type: " + Content_Type + "\n\n"

if List_Type == 'mpegurl':  
  for Url in Urls: print Url
elif List_Type == 'smil':
  print "\n<smil>\n   <body>\n"
  for Item in Urls:  print "      <audio src='" + Url+ "'/>"
  print "   </body>\n</smil>\n"
else:  
  for Url in Urls: print Url
    

#------------------------------------------------------------------------
#                          Open Radio version 1.0

#                       Copyright 2003, Mark Nielsen
#                            All rights reserved.
#    This Copyright notice was copied and modified from the Perl
#    Copyright notice.
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of either:

#        a) the GNU General Public License as published by the Free
#        Software Foundation; either version 1, or (at your option) any
#        later version, or

#        b) the "Artistic License" which comes with this Kit.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
#    the GNU General Public License or the Artistic License for more details.

#    You should have received a copy of the Artistic License with this
#    Kit, in the file named "Artistic".  If not, I'll be glad to provide one.
#    You can look at http://www.perl.com for the Artistic License.

#    You should also have received a copy of the GNU General Public License
#   along with this program in the file named "Copying". If not, write to the
#   Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
#    02111-1307, USA or visit their web page on the internet at
#    http://www.gnu.org/copyleft/gpl.html.

