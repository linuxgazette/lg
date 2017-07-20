#!/usr/bin/perl
# Created by Ben Okopnik on Sun Dec 14 00:00:10 EST 2003
use warnings;
use strict;
use CGI::Carp qw/fatalsToBrowser/;
use CGI qw/:standard/;

chdir '../../linuxgazette.net/';
chomp(my $latest = (sort { $b <=> $a } <[0-9]*[0-9]>)[0]);

print redirect("http://linuxgazette.net/$latest/");
# print $latest;

