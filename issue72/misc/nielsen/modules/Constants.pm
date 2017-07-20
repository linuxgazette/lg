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


package SAMPLE::Constants;

use strict;
use Apache;
use DBI;

sub Get_Constants
{
my (@Temp) = @_;
### Have all the subroutines execute here and stuff the results
### into an array.

my $Global = {};

my $dbh;
use DBI;
use DBI;

$dbh ||= DBI->connect('dbi:Pg:dbname=sample',"","");
$Global->{'dbh'} = $dbh;
$Global->{'tempdir'} = '/tmp';
$Global->{'web_root'} = '/usr/local/apache/htdocs';

return ($Global);
}

1;
