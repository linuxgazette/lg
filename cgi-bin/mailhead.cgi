#!/usr/bin/perl -w
# Created by Ben Okopnik on Wed Mar  4 22:57:13 EST 2009
use strict;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI qw/:standard/;
$|++;

################### User vars ####################
my $max_length = 2048;
################### User vars ####################

our $Mbox = $ENV{MAIL} || "/var/spool/mail/ben";
open Mbox or die "$Mbox: $!\n";
my ($num, $flag, %all);

sub htmlize {
	my %subst = ( '>' => '&gt;', '<' => '&lt;', '&' => '&amp;' );
	$_[0] =~ s/([&<>])/$subst{$1}||$1/egsm;
	$_[0];
}

while (<Mbox>){
	if (/^From /){
		$flag++;
		$num++;
	}
	if ($flag){
		$all{$num}{Subject} = htmlize($_) if /^Subject: /;
		$all{$num}{From} = htmlize($_) if /^From: /;
		$flag-- if /^$/;
		next;
	}
	else {
		next if defined $all{$num}{msg} && length($all{$num}{msg}) > $max_length;
		$all{$num}{msg} .= htmlize($_);
	}
}

binmode STDOUT, ':encoding(UTF-8)';		# Set up utf-8 output
print header(-charset => 'utf-8'), 
	start_html( -encoding => 'utf-8', -title => 'Untitled');

if (!param()){
	for (1..$num){
		print pre("$_. $all{$_}{From}", a({-href=>
				url()."?msg=$_"}, $all{$_}{Subject}));
	}
}
else {
	print pre($all{param('msg')}{msg});
}

print end_html;

