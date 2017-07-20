#!/bin/bash
# Created by Ben Okopnik on Sun Oct 17 22:46:14 EDT 2010

cd /home/okopnik
echo -ne "Content-Type: application/gzip\nContent-disposition: attachment; filename=retr-list.txt.gz\n\n"
# echo -ne "Content-Type: text/plain\nContent-disposition: attachment; filename=retr-list.txt\n\n"
/usr/bin/find linuxgazette.net -type f|/bin/sed 's#^#http://#'|sort -n|/bin/gzip
