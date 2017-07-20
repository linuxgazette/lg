#!/usr/bin/perl -w
# Created by Ben Okopnik on Sun May  1 15:14:49 EDT 2005
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI qw/:standard/;
$|++;

$dir = "/var/www/linuxgazette.net";
$issue = param( 'issue' );
$issue ||= readlink "$dir/current";

# Let's clean this thing up, shall we?
$issue =~ s/^.*?((?:issue)*\d+).*?/$1/;

if ( -f "$dir/$issue/TWDT.html" ){
	$out = header( { Content_type => 'chemical/x-pdb' } );
	# print `HOME=/tmp /usr/bin/lynx -dump -nolist $dir/$issue/TWDT.html|/home/ben/bin/bibelot -f -t TWDT$issue`;
 	# $out .= `HOME=/tmp /usr/bin/links -dump $dir/$issue/TWDT.html|/home/ben/bin/bibelot -f -t TWDT$issue`;
 	$out .= `HOME=/tmp /usr/bin/links -dump $dir/$issue/TWDT.html`;
	print $out;
}	
else {
	print header, start_html( 'Our Toxic Waste Dump (all the chemical/x-pdb files are here!)' ), h3( 'The Chemical Factory' );
	print "This is the list of all the LG issues that contain a
		TWDT.html (required for generating a 'TWDT.pdb'):", p;
	chdir $dir;
	for ( sort { $b <=> $a } <[0-9][0-9]*> ){
		chomp;
		next unless -f "$_/TWDT.html";
		print a( { href => "http://linuxgazette.net/cgi-bin/TWDT.pdb?issue=$_" }, $_ ), "<br>";
	}
}

