#!/usr/bin/env perl
use warnings;
use CGI qw/:standard/;

print header, start_html( "Requester info" ),
    p( "Here is what you look like from this end:" ), hr,
    pre("\n", map({ sprintf("%-25s=>\t%s\n", $_, $ENV{$_}) } sort keys %ENV)),
    hr, end_html;
