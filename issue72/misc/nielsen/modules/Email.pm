#!/usr/bin/perl

package SAMPLE::Email;

use strict;
use Apache;
use DBI;
use CGI;
use SAMPLE::Misc;
use SAMPLE::Constants;
use Mail::Mailer;

sub new
{
my $Class = shift;
my %Args = @_;
my $self = {};

$self->{'mail'} = new Mail::Mailer 'sendmail';

bless $self,$Class;

return ($self);
}

#--------------------------------------------------------------------------

sub Send_Mail {
my $self = shift;
my %Args = @_;

my $Header = {};
if (exists $Args{'header'}) { $Header = $Args{'header'};}
else {return (-1)};
my $Body = $Args{'body'};

my $Mail = $self->{'mail'};
$Mail->open($Header);
print $Mail $Body;

$Mail->close;

return (1);
}

1;


1;
