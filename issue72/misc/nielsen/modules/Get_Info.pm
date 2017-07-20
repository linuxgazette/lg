#!/usr/bin/perl

#              Create Functions for Perl/PostgreSQL version 1.0

#                       Copyright 2001, Mark Nielsen
#                            All rights reserved.
#    This Copyright notice was copied and modified from the Perl 
#    Copyright notice. 
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of either:

#        a) the GNU General Public License as published by the Free
#        Software Foundation; either version 1, or (at your option) any
#        later version, or

#        b) the "Artistic License" which comes with this Kit.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
#    the GNU General Public License or the Artistic License for more details.

#    You should have received a copy of the Artistic License with this
#    Kit, in the file named "Artistic".  If not, I'll be glad to provide one.

#    You should also have received a copy of the GNU General Public License
#   along with this program in the file named "Copying". If not, write to the 
#   Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 
#    02111-1307, USA or visit their web page on the internet at
#    http://www.gnu.org/copyleft/gpl.html.

package SAMPLE::Get_Info;

use strict;
use Apache;
use DBI;
use CGI;
use SAMPLE::Misc;
use SAMPLE::Constants;

sub new 
{
my $Class = shift;
my $self = {};

my $Global = SAMPLE::Constants::Get_Constants;
  ### Get the database connection.
$self->{'dbh'} = $Global->{'dbh'};

if (exists $ENV{'REMOTE_USER'}) 
  {
  my $Username = $ENV{'REMOTE_USER'};

  my $dbh = $self->{'dbh'};
  my $Command = "select * from users where username = ?";
  my $sth = $dbh->prepare($Command);
  $sth->execute($Username);
  $self->{'users'} =  $sth->fetchrow_hashref();
  }
else {$self->{'users'} = {};}

bless $self,$Class;

return ($self);
}
#--------------------------------------------------------------------------

sub Info
{
my $self = shift;
my $Table = shift;
my $Id = shift;

my $Info = {};

  ### We should have a way to error out here instead of returning nothing.
if (!($Table =~ /[a-z]/i)) {return ($Info);}
if ($Id < 1) {return($Info);}

my @Valid_Tables = ( 'class', 'contact', 'students', 'users');

if (!(grep($_ eq $Table, @Valid_Tables))) {return ($Info);}

my $dbh = $self->{'dbh'};
my $Command = "select * from $Table where $Table\_id = ?";
my $sth = $dbh->prepare($Command);
$sth->execute($Id);
my $ref = $sth->fetchrow_hashref();

return ($ref);
}

#----------------------------------------------------------------------
# This method is used to create a temporary table which we can use.
# For persistent database connections, this can be a problem. 
# We should create a method to destroy this table when it is done
# being used. 
sub Get_Temp_Table_Name
{
my $self = shift;

my $dbh = $self->{'dbh'};
my $Sql = "select sql_temp_table_insert() as name";
my $sth = $dbh->prepare($Sql);
$sth->execute();
my $ref = $sth->fetchrow_hashref;
my $Name = $ref->{'name'};

return ("temp_table_$Name");
}

#--------------------------------------------------------------------
sub List
{
my $self = shift;
my $Table = shift;
my $Type = shift;
my $Fields = shift;

my $Info = {};

  ### Return nothing if table is not specified. We should error out instead.
if (!($Table =~ /[a-z]/i)) {return ($Info);}
my @Valid_Tables = ( 'class', 'contact', 'students', 'users');
if (!(grep($_ eq $Table, @Valid_Tables))) {return ($Info);}

  ### This determines if we want active, inactive, or all rows. 
my $Clause = "active = 1";
if ($Type eq "inactive") {$Clause = "active = 0";}
elsif ($Type eq "all") {$Clause = "active = 1 or active = 0";}

  ### This determines if we want all information,or just the row id and status.
my $HowMuch = "$Table\_id, active";
if ($Fields eq "all") {$HowMuch = '*';}

my $dbh = $self->{'dbh'};
my $Command = "select $HowMuch 
   from $Table where $Clause";
my $sth = $dbh->prepare($Command);
$sth->execute();
  ### We put it all into an associative array by table_id primary key. 
  ### IF your data is huge, you will clog up your memory. 
  ### Remember, we are selecting a lot or all of the elements in the table. 
while (my $ref = $sth->fetchrow_hashref()) 
  {
  my $Key = $ref->{"$Table\_id"};
  $Info->{$Key} = $ref;
  }

  ### Sometime in the future, we should be able to select which fields
  ### we want returned, and not just the two choices above. 
  ### We will need to make this method use keys as arguments and not
  ### by using @_.

  ## We should add the option to restrict by users_id later. 

return ($Info);
}

#---------------------------------------------------------------------
sub Get_Items
{
my $self = shift;
my $Table = shift;

### This was going to be used to get rows of various tables. 
### Ignore it now. 

return (1);
}




1;
