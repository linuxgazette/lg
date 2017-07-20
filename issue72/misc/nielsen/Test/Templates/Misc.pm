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


package PACKAGE::Misc;

use strict;
use Apache;
use DBI;
use CGI;
use Crypt::Blowfish;
use PACKAGE::Constants;

my $Blowfish_Key = "BLOWFISH_KEY";
my $Blowfish_Cipher = new Crypt::Blowfish $Blowfish_Key;

#-----------------------------------
sub Encrypt
{
    my $self = shift;
    my $String = shift;

    my $Temp = $String;
    my $Encrypted = "";

while (length $Temp > 0)  
{
    while (length $Temp < 8) {$Temp .= "\t";}
    my $Temp2 = $Blowfish_Cipher->encrypt(substr($Temp,0,8));
    $Encrypted .= $Temp2; 
    if (length $Temp > 8) {$Temp = substr($Temp,8);} else {$Temp = "";}
}

my $Unpacked = unpack("H*",$Encrypted);

return ($Unpacked);
}

#-------------------------------------------------------------------------
sub Decrypt
{
    my $self = shift;
    my $String = shift;

    my $Packed = pack("H*",$String);

    my $Temp = $Packed;
    my $Decrypted = "";
while (length $Temp > 0)  
{
    my $Temp2 = substr($Temp,0,8);
  if (length $Temp2 == 8) 
  {
      my $Temp3 = $Blowfish_Cipher->decrypt($Temp2);
      $Decrypted .= $Temp3;
  } 
    if (length $Temp > 8) {$Temp = substr($Temp,8);} else {$Temp = "";}
}
$Decrypted =~ s/\t+$//g;

return ($Decrypted);
}

#-------------------------------------------
sub Convert_Html
{
    my $self = shift;
    my $String = shift;

    if (ref $String) {$String = "";}
else 
{
    $String =~ s/\&/\&amp\;/g;
    $String =~ s/\"/\&quot\;/g;
    $String =~ s/\>/\&gt\;/g;
    $String =~ s/\</\&lt\;/g;
    $String =~ s/\|/\&\#124\;/g;

}

return ($String);
}

#-------------------------------------------
sub Clean_String
{
    my $self = shift;
    my $String = shift;
    my $No = shift;
    if ($No > 0) {$String = substr($String,0,$No);}

    if (ref $String) {$String = "";}
else 
{
 $String =~ s/[^a-zA-Z0-9 \~\!\@\#\$\%\^\&\*\(\)\_\+\-\=\\\[\]\;\'\,\.\/\{\}\:\"\<\>\?\n\|]//g;
  }
return ($String);
}

#--------------------------------------------------------------------

sub File_Query
{
my $self = shift;
my %Args = @_;
if (!(exists $Args{'file'}))  {return (-1);}

my $File = $Args{'file'};
my (@Temp) = split(/\./, $File);
my $Ext = pop @Temp;
if (!($Ext =~ /[a-z]/i)) {$Ext = "ext";}

my $Global = MAIL::Constants->Get_Constants;
my $TempDir = $Global->{'tempdir'};

my $New = "$TempDir/1.$Ext";
my $No = 1;
while (-e $File) {$No++; $File = "$TempDir/$No.$Ext";} 
 
my $buffer;
open (OUTFILE,">$New");
while (my $bytesread=read($File,$buffer,1024)) {print OUTFILE $buffer;}
close OUTFILE;

#if ($Ext eq ".wav")
#  {
#  my $Command = "cd $Data_Dir; /usr/local/realproducer-8.5/realproducer -i intro$Ext";
#  system ($Command);
#  }

return ($File);
}


