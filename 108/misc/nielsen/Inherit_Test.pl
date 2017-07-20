#!/usr/bin/perl

use Class::Inheritance;
my $Inherit = new Class::Inheritance;
use strict;

my $package = $ARGV[0];
my $function = $ARGV[1];

if ($package eq '') {
    print "ERROR: package not defined.\n";
    print "USAGE: perl Inherit_Test.pl <package> <function or method>\n";
    exit();
}
elsif ($function eq '') {
    print "ERROR: function (method) not defined.\n";
    print "USAGE: perl Inherit_Test.pl <package> <function or method>\n";
    exit();
}

#-------------------------------
print "We assume the filename for the package is in '$package\.pm'.\n";
print "Looking at function (method) '$function' in class '$package'.\n\n";

my $class = $Inherit->Methods_Parent($package, $function);
if ($class eq '') {print "Function '$function' not found.\n\n";}
else {print "Function '$function' comes from the class '$class'.\n\n";}

my $tree =  $Inherit->Inherit_Tree($package);
print "Parent Tree is: $tree\n\n";

my $temp = $Inherit->Inherit_Tree_Matches($package, $function);
print "Original sources (defined) for '$function' are: $temp\n\n";
