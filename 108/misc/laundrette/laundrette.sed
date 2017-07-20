s/&/\&amp;/g
s/</\&lt;/g
s/>/\&gt;/g
s/^-----$/<hr width="80%">/g
s/^----$/<hr width="60%">/g
s/^{{$/<pre>/g
s/^}}$/<\/pre>/g
# So I won't get paragraphs I don't want, comments become spaces.
s/^\#.*/ /g
s/^\[\(.*\)\]$/<strong>\[\1\]<\/strong>/g
s/^!S!\(.*\)|\(.*\)!!$/<a name="spam.\1"><\/a>\n<h3>Spam: \2<\/h3>/g
s/^!!\(.*\)|\(.*\)!!$/<a name="laundrette.\1"><\/a>\n<h3>\2<\/h3>/g
s/^!W!\(.*\)|\(.*\)!!$/<a name="wacko.\1"><\/a>\n<h3>Wacko Topic: \2<\/h3>/g
#
s/ \*\(.*\)\*\([ .,:;]\)/ <b>\1<\/b>\2/g
s/ _\(.*\)_\([ .,:;]\)/ <u>\1<\/u>\2/g
s/ \/\(.*\)\/\([ .,:;]\)/ <i>\1<\/i>\2/g
# There's a better way of doing this...
# Ben told me how to do this, but tracking down the mail... eek!
s/^\*\(.*\)\*\([ .,:;]\)/<b>\1<\/b>\2/g
s/^_\(.*\)_\([ .,:;]\)/<u>\1<\/u>\2/g
s/^\/\(.*\)\/\([ .,:;]\)/<i>\1<\/i>\2/g
s/ \*\(.*\)\*$/ <b>\1<\/b>/g
s/ _\(.*\)_$/ <u>\1<\/u>/g
s/ \/\(.*\)\/$/ <i>\1<\/i>/g
s/^\[\[/<blockquote><em>[\n/g
s/\]\]$/\n]<\/em><\/blockquote>/g
s/^$/\n<p>/g

s/^\(http:.*\)$/<a href="\1">\1<\/a>/g
s/^\(https:.*\)$/<a href="\1">\1<\/a>/g
s/ ¬¬$/<br>/g
