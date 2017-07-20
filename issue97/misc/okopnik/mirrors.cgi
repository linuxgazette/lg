#!/usr/bin/perl
## Created by Ben Okopnik on Mon Nov  2 19:59:08 EST 2003
use warnings;
use strict;
use CGI::Carp qw/fatalsToBrowser/;
use CGI qw/:standard/;
use HTML::Template;
$|++;

my ( $lang,  $tld,  $update, @anchors, @csv,     @langs, @mirr, 
     @mirrs, @tlds, @tran,   @trans,   %country, %langs, %tlds );

my $t = HTML::Template -> new( filename => "mirrors.tmpl", 
	die_on_bad_params => 1 );

open CSV, "mirrors.csv" or die "mirrors.csv: $!\n";
# Snarf content of mirrors DB
# @fields = qw/tld language http ftp maintainer email comments/;
chomp( @csv = <CSV> );
close CSV;

open TLD, "countries.csv" or die "countries.csv: $!\n";
# Read in and parse content of countries DB
# @fields = qw/tld fullname/;
while ( <TLD> ){ chomp; /^(.*?),(.*)$/; $country{ $1 } = $2 }
close TLD;

# Convert all characters in a string to HTML entities
sub mung { join "", map{ sprintf"&#%s;", ord } split //, shift }


# Separate out the translators
@tran = grep /^..,\w/, @csv;
# Identify the unique languages
$langs{ $_ }++ for map { /^..,([^,]+)/ } @tran;
@langs = sort keys %langs;

# Pull out the mirror maintainers
@mirr = grep /^..,,/, @csv;
# Identify the unique countries
$tlds{ $_ }++ for map { /^(..)/ } @mirr;
@tlds = sort { $country{ $a } cmp $country{ $b } } keys %tlds;

for $lang ( @langs ){
	my @groups;
	my %row;
	
	for ( grep /^..,$lang,/, @tran ){
		my @rec;
		my %group;
		# Parse CSV - convert escaped commas, split, then reconvert
		s/\\,/&comma;/g;
		@rec = split /,/;
		s/&comma;/,/g for @rec;

		# Create the hash to hold all the "inner loop" variables
		@group{ qw/http ftp trans email country/ } = 
			( @rec[2..4], mung( $rec[5] ), $country{ $rec[0] } );
		# Add it's ref to the list
		push @groups, \%group;
	}

	# Set an "outer loop" variable and attach the "inner loop" ref
	$row{ lng } = $lang;
	$row{ group } = \@groups;

	# Push the constructed row onto an array
	push @trans, \%row;
}

for $tld ( @tlds ){
	# Set some temporary (per-loop) variables
	my @sites;
	my %row;
	my %line;

	# Create a simple "flat" loop with two variables
	$line{ anchor } = $tld;
	$line{ fqdn   } = $country{ $tld };
	# Push the hashref onto the array
	push @anchors, \%line;
	
	# Here's the inner loop!
	for ( grep /^$tld/, @mirr ){
		my @rec;
		my %site;
		s/\\,/&comma;/g;
		@rec = split /,/;
		s/&comma;/,/g for @rec;

		# Mirror listings don't require much
		@site{ qw/http ftp maint/ } = @rec[2..4];
		# Load it up!
		push @sites, \%site;
	}
	
	# Outer loop vars
	$row{ tld } = $tld;
	$row{ country } = $country{ $tld };
	# Ref to the inner loop, attached
	$row{ sites } = \@sites;
	
	# ...and load up the total into the array to be passed to param()
	push @mirrs, \%row;
}

# Format the date as "wkday mon day year"
$update = join " ", ( split ' ', localtime )[ 0..2, 4 ];

# Submit parameters
$t -> param( UPDATE => $update, LANG => \@trans, 
	     MIRR   => \@mirrs, ANCH => \@anchors );

# Output the header if invoked as CGI
print header if ( $0 =~ /cgi$/ );

print start_html( "Linux Gazette - Mirrors and translations page" );
print $t -> output;
print end_html;
