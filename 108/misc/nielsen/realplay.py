#!/usr/bin/python

### This is a python script to create a smil file for RealPlayer.
### Its purpose is to just make a list of all the mps files I have
### in a directory and write it to a smil file. 
### Very simple, nothing spectacular. This script is important
### to me since I like to listen to music while studying or applying
### for jobs. 

import os, sys, re, random

Home = "/var/www/html/audio"
Xml = "/tmp/temp1.smil"

  ### Create the regular rexpression for filtering files with mp3 extension.
Re_Mp3 = re.compile('mp3')
  ### Get the list of files.
List = os.listdir(Home)
  ### Filter out the non-mp3 files.
List = [i for i in List if Re_Mp3.search(i)]

  ## Open the smil file with some smil tags.
Write = open(Xml,"w")
Write.write("<smil>\n<body>\n")

  ## Get the no of files we have. 
Max = len(List)
  ## From 1 to the number of files,
  ## Print out a random file, and reduce the total list number by one
  ## Repeat until the list is 0. 
for i in range(0,Max):
    ## Get the current length of the list
  Length = len(List)
    ## Get a random number from it.
  Position = random.randint(0,Length-1)

    ### Get the filename
  File = List[Position]
    ### Create a link to my local webserver where you can see the file.
    ### The webserver must be properly setup for this to work. 
  Line = "<audio src='http://127.0.0.1/audio/"+File+"' title='"+File+"'/>\n"

    ### Write the line to the smil file. 
  Write.write(Line)
    ### Delete the item from the list so that we don't resue it. 
  del List[Position]

  ### Write the end tags for the smil file and close the file.
Write.write("</body>\n</smil>\n")
Write.close()
