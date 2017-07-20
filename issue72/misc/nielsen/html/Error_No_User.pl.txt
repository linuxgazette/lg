#!/usr/bin/perl

print "Content-type: text/html\n\n\n";

print "<h1> Nore mote user defined. Please enable user authentication.</h1>\n";

foreach my $Env (sort keys %ENV) {print "<br>$Env = $ENV{$Env}\n";}
