#!/usr/bin/perl
use warnings;
use strict;

#******************************************
# Email2SMS Version 1
# Written by Suramya Tomar (suramya@suramya.com)
# http://www.suramya.com
# Released Under the GPL Ver 2.
#
# This program is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, or    
# (at your option) any later version.     
#         
# This program is distributed in the hope that it will be useful, but  
# WITHOUT ANY WARRANTY; without even the implied warranty of   
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  
# General Public License for more details.    
#         
# You should have received a copy of the GNU General Public License  
# along with this program; if not, write to the    
# Free Software Foundation, Inc.,      
# 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA   
#########################################################################

use Net::POP3;

# ******************************************
# User defined variables for server access *
# ******************************************

 my $ServerName = "ENTER YOUR SERVER ADDRESS HERE";
 my $UserName = "ENTER YOUR EMAIL USERNAME HERE";
 my $Password = "ENTER ENTER YOUR EMAIL PASSWORD HERE";
 
 # Other Variables

 my ($pop3, $Num_Messages, $Messages, $msg_id, $MsgContent, $sms_body);

# *******************************************
# Get Emails and Process them one at a time *
# *******************************************

 while('TRUE')												# The program will run in an infinite loop.
 {
	print "Waiting for email...\n";							# Print status message

    $pop3 = Net::POP3->new($ServerName);					# Connect to email server
       die "Couldn't log on to server" unless $pop3;

	$Num_Messages = $pop3->login($UserName, $Password);	# Login to the server and get No of messages
	  die "Couldn't log on to server" unless $pop3;

	$Messages = $pop3->list();							# Get message list
 	
	foreach $msg_id (keys(%$Messages))
	{
		$MsgContent = $pop3->top($msg_id, 40);
		ProcessEmail(@$MsgContent);
		$pop3->delete ($msg_id);
	}

	# Close the connection
	$pop3->quit();
	sleep(20);				# Sleep for 20 seconds
 }

# This subroutine parses the 'From', 'Subject' and Body fields of a message header
# Then connects to GNOKII and sends out the actual SMS 

sub ProcessEmail
{
  # Assign parameter to a local variable
  my (@lines) = @_;
  my $body_start = 'FALSE';
  $sms_body = "";

  # Declare local variables
  my ($from, $line, $sms_to);

  # Check each line in the header
  foreach $line (@lines)
  {
    if($line =~ m/^From: (.*)/)
    {
       # We found the "From" field, so let's get what we need
       $from = $1;
       $from =~ s/"|<.*>//g;
       $from = substr($from, 0, 39);				# This gives us the 'From' Name
   }
   elsif( $line =~ m/^Subject: (.*)/)
   {
       # We found the "Subject" field. This contains the No to send the SMS to.

	   $sms_to   = $1;
       $sms_to = substr($sms_to, 0, 29);

	   if ($sms_to =~ /^[+]?\d+$/ )				# here we check if the subject is a no. If so we proceed.
	   {
		   print "Got email. Subject is a number. Processing further\n";
	   }
	   else											# Otherwise we delete the message and ignore it.
	   {
		    print "Got email. Subject is NOT a number. Ignoring it. \n";
			return;
	   }
   }
   elsif(( $line =~ m/^Envelope-To:/)||($body_start eq 'TRUE')) # This is the last line in the email header
   {                                                                           # after this the body starts
	   if($body_start ne 'FALSE')
	   {
		   $sms_body = $sms_body . $line;
	   }

	   $body_start='TRUE';
   }
  }

  # At this point we know the Subject, From and Body.
  # So we can send the SMS out to the provided no.

  $sms_body = "SMS via Email2SMS from $from: " . $sms_body;

  # You can only send SMS in chunks of 160 chars Max according to gnokii. 
  # so breaking the body into chunks of 160 and sending them 1 at a time.

  my @stringChunksArray = ($sms_body =~ m/(.{1,160})/gs);
  for(my $i=0;$i<@stringChunksArray;$i++)
  {
	open(GNOKII, "| gnokii --sendsms $sms_to") || die "Error starting gnokii failed: $!\n"; #Start gnokii and wait for the SMS body
    print GNOKII $stringChunksArray[$i];													# Print the SMS body in 160 Char chunks
    close(GNOKII);
	sleep(10);               # This is there so that the phone gets time to reset after each message. Otherwise the send fails
  }
  

}# end: ProcessEmail()
