#!/usr/bin/perl -w

# very quick hack to convert an opera bookmark file into an xbel
# bookmark file (as the one used by konqueror, I don't know what
# xbel is about, I used my konqueror file as an example)

use strict;

sub write_xbel_hdr {
	print "<!DOCTYPE xbel>\n";
	print "<xbel folded=\"yes\">\n";
}

sub write_xbel_tail {
	print "</xbel>\n";
}

# parser as a simple state machine: if 0 it tries to read an URL,
# a FOLDER or a FOLDER end (a dash).
# state 1: reading an URL
# state 2: reading a folder
#
# it ignores the order of the bookmarks -- hopefully I can
# convince konqueror to sort them (it's only interested in the
# name and href of the bookmark)
sub parse_input {
	my($state);
	my($title, $url);
	my($indent);
	$state = 0;
	$indent = "";
	while(<STDIN>) {
		s/^\s+//;
		s/\s+$//;
		if ($state == 0) {
			if ($_ eq "#URL") {	$state = 1; next; }
			if ($_ eq "#FOLDER") { $state = 2; next; }
			if ($_ eq "-") {
				$indent = substr($indent, 0, -2);
				print "$indent</folder>\n";
				next;
			} # finish writing the folder
		} elsif ($state == 1) {
			if (/NAME=(.*)$/) {
				$title = $1;
			} elsif (/URL=(.*)$/) {
				$url = $1;
			}
			if ($_ eq "") {
				print "$indent<bookmark icon=\"html\" href=\"$url\">\n";
				print "$indent<title>$title</title></bookmark>\n";
				$state = 0;
			}
		} elsif ($state == 2) {
			if (/NAME=(.*)$/) {
				$title = $1;
			}
			if ($_ eq "") {
				print "$indent<folder folded=\"yes\">\n";
				$indent .= "  ";
				print "$indent<title>$title</title>\n";
				$state = 0;
			}
		}
	}
}

write_xbel_hdr;
parse_input;
write_xbel_tail;
