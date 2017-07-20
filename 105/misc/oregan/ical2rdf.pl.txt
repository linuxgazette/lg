#!/usr/bin/perl
#
# usage: perl ical2rdf.pl something.ics >something.rdf
#
# by Dan Connolly and Libby Miller
#  with contributions by George Huo
#   http://lists.w3.org/Archives/Public/www-rdf-calendar/2003Sep/0000.html
#  and M.Kanzaki <webmaster@kanzaki.com>
#
# Open Source. share and enjoy.
#
# RDF Calendar Workspace: http://www.w3.org/2002/12/cal/
#
# Copyright 2002-2003 World Wide Web Consortium, (Massachusetts
# Institute of Technology, European Research Consortium for
# Informatics and Mathematics, Keio University). All Rights
# Reserved. This work is distributed under the W3C(R) Software License
#   http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.
#
# REFERENCES
#
# Internet Calendaring and Scheduling Core
# Object Specification (iCalendar)
# November 1998
# http://www.ietf.org/rfc/rfc2445.txt
# http://www.imc.org/rfc2445
#
#  NOTE: We don't claim to implement the whole spec, nor to even have
#   read all of it. We're taking a data-driven, test-driven approach
#   to RFC2445 coverage/conformance. We start with a .ics file that we
#   understand (because it came from a tool that acts as we expect in
#   response to it or some such) and we implement the parts of the
#   spec necessary to grok the data in that file. As we work on more
#   test files, we cover (and carefully read) more parts of the spec.
#
# Building an RDF model: A quick look at iCalendar
# http://www.w3.org/2000/01/foo
# TimBL 2000/10/02
#
#
#
# CGI version by M.Kanzaki <webmaster@kanzaki.com> 2003-2004
#  http://www.kanzaki.com/courier/ical2rdf
#
# see also:
#  http://www.ietf.org/internet-drafts/draft-ietf-calsch-many-xcal-00.txt 
#  http://xml.coverpages.org/iCal-DTD-20011103.txt
#
# versions up to
#    vcal2xml.pl,v 1.6 2002/07/16 05:02:23 connolly
# were released under...
#   http://dev.w3.org/cvsweb/2001/palmagent/
#   
# $Id: ical2rdf.pl,v 1.22 2004/01/21 23:30:46 connolly Exp $
# see change log at end of file.


use strict;

# Digest::SHA1 Perl interface to the SHA-1 Algorithm 
# http://search.cpan.org/author/GAAS/Digest-SHA1-2.02/
use Digest::SHA1 qw(sha1_hex);

# Getopt::Long - Extended processing of command line options
# http://search.cpan.org/author/JV/Getopt-Long/lib/Getopt/Long.pm#Options_with_values
use Getopt::Long;

#http://search.cpan.org/~dankogai/Jcode-0.83/
use Jcode;

my($X_ns);
my($componentName);
GetOptions ('xnames=s' => \$X_ns,
	    'componentName=s' => \$componentName);

my($ICal_ns) = 'http://www.w3.org/2002/12/cal/ical#';
my($Prod_ns) = 'http://www.w3.org/2002/12/cal/prod/';

my(@stack);
my($intag);
my($field, $line);
my($nsDone);
my($rdf); # buffer for most of the output
my($warnmsg); # warning message

#$field = <>;
$field =open (IN, $ARGV[0]);


my(@symbolProps) = ('transp', 'partstat', 'rsvp',
                    'related');

# The following props can be a symbol _or_ an
# 	 iana-token! they are now handled correctly. 
#        see %symbolVals
my(@symbolOrTextProps)
                 = ('action', 'class', 'role', 'cutype');

my(@resProps) = ('standard', 'daylight',
		 'valarm', 'trigger',#@@mismatch?
		);
# dir. @@should it be in valProps? see lexform... 
#               unclear, works this way
my(@refProps) = ('attendee', 'organizer', 'dir',
		 'X', # from mozilla calendar stuff. @@OK?
		);
my(@valProps) = ('dtstart', 'dtend',
		 'dtstamp', 'lastModified', 'created', 'completed',
		 'trigger', 'recurrenceId',
		 'rrule', # special...
		 'exdate' #@@comma-separated
		#,'summary','location' #by MK for language param, but generated <text>...</text> also.
		);

# hmm... slurp this from the RFC, into a schema, then
# read at runtime?
my(%ValueType) = (
		  'calscale', 'text', # 4.7.1 Calendar Scale
		  'method', 'text', # 4.7.2 Method
		  'prodid', 'text', # 4.7.3 Product Identifier
		  'version', 'text', # 4.7.4 Version
		  'summary', 'text',
		  'sequence', 'integer', # 4.8.7.4 Sequence Number
		  'uid', 'text', # 4.8.4.7 Unique Identifier
		  'tzid', 'text', # 4.8.3.1 Time Zone Identifier hmm... property and parameter by the same name
		  'tzoffsetfrom', 'utcOffset', # 4.8.3.3 Time Zone Offset From
		  'tzoffsetto', 'utcOffset',
		  'tzname', 'text', # 4.8.3.2 Time Zone Name
		  'rrule', 'recur', # 4.8.5.4 Recurrence Rule
		  'transp', 'text', # 4.8.2.7 Time Transparency
		  'class', 'text', # 4.8.1.3 Classification hmm... symbolprop?
		  'contact', 'text', #@@CheckSpecAndCite
		  'location', 'text', # 4.8.1.7 Location
		  'description', 'text',
		  'categories', 'text', # 4.8.1.2 Categories hmm... text *("," text)
		  'organizer', 'calAddress', # 4.8.4.3 Organizer
		  'attendee', 'calAddress', # 4.8.4.3 Organizer
		  'duration', 'duration', # 4.8.2.5 Duration
		  'action', 'text', # 4.8.6.1 Action
		  'attach', 'uri', # 4.8.1.1 Attachment
		  'url', 'uri', # @@
		  'comment', 'text', # 4.8.1.4 Comment
		  'priority', 'integer', # 4.8.1.9 Priority
		  'completed', 'dateTime', # 4.8.2.1 Date/Time Completed"
		  'status', 'text', # 4.8.1.11 Status
		  'recurrenceId', 'dateTime', # 4.8.4.4 Recurrence ID
		  'trigger', 'duration', # 4.8.6.3 Trigger 
		  'repeat', 'integer', # 4.8.6.2 Repeat Count
		  'freebusy', 'period', # 4.8.2.6 Free/Busy Time (@@period is not implemented by this ical2rdf)
		 );

my(%ValueTypeD) = ('dtend', 'dateTime', # 4.8.2.2 Date/Time End
		   'dtstart', 'dateTime', # 4.8.2.4 Date/Time Start
		   'dtstamp', 'dateTime', # 4.8.7.2 Date/Time Stamp
		   'lastModified', 'dateTime', # 4.8.7.3 Last Modified
		   'exdate', 'dateTime', # 4.8.5.1 Exception Date/Times
		   'rdate', 'dateTime', # 4.8.5.3 Recurrence Date/Times
		   'created', 'dateTime', # 4.8.7.1 Date/Time Created
		   'due', 'dateTime', # 4.8.2.3 Date/Time Due
		  );
# attribute value types
my(%ValueTypeA) = ('dir', 'uri' # 4.2.6 Directory listing
                  );

my(@component) = ("Vevent" , "Vtodo" , "Vjournal" , "Vfreebusy"
                        , "Vtimezone" ); # / x-name / iana-token)
my(@classnames) = (@component,"Vcalendar");#names not to be lowercase: by MK 

# hash of possible values for symbol properties
#        we're using $IANATOKEN as a list element to
#        indicate that the symbol can be arbitrary text.
#        better way to do this?
# currently only used for properties that can be either
# 	symbols _or_ iana-tokens
my($IANATOKEN) = 0;
my(%symbolVals)
               = ('action', ['AUDIO', 'DISPLAY', 'EMAIL', 'PROCEDURE',
	                     $IANATOKEN],
	          'cutype', ['INDIVIDUAL', 'GROUP', 'RESOURCE', 'ROOM',
		             'UNKNOWN', $IANATOKEN],
		  'class',  ['PUBLIC', 'PRIVATE', 'CONFIDENTIAL', 
		             $IANATOKEN],
		  'role',   ['CHAIR', 'REQ-PARTICIPANT', 'OPT-PARTICIPANT',
		             'NON-PARTICIPANT', $IANATOKEN]
	         );


# VERSION: hmm... kinda worthless.

#first pass to get prodid

while(1){
  last unless $field;

  while(($line = <IN>) =~ s/^\s//){  # 4.1 Content Lines
    $field .= $line;
  }


  $field =~ s/\r?\n//g; # get rid of newlines

#  print STDERR "... field:", $field, "\n";

# not sure where to put this - prodid to create xproperty namespace
  if($field =~ m/PRODID/){
    icalwarning("clobbering - -xnames $X_ns") if $X_ns; #avoid illegal comment MK
    $X_ns=createxns($field);
  }

  $field = $line;

}#end first pass


#ugly - don't know how else to do it though...

close(IN);
$field =open (ININ, $ARGV[0]);

#second pass to get the rest

while(1){
  last unless $field;

  while(($line = <ININ>) =~ s/^\s//){  # 4.1 Content Lines
    $field .= $line;
  }


  $field =~ s/\r?\n//g; # get rid of newlines

  if($field =~ /^BEGIN:(\w+)/i){
    my($n) = ($1);
    printstr ("\n>") if $intag;
    if($nsDone){

      if(grep(lc($_) eq lc($n), @classnames)){ #avoid lower 'vcalendar' by MK
	$n = camelCase($n, 1);

	if($#stack == 0){
	  printstr("  <component>\n");
	}

	#by MK add a space before tag
	if($componentName){
	  printstr ("   <".$n." rdf:about='#".$componentName."'>\n");
	  $componentName++;
	}else{
	  printstr ("   <".$n.">\n");
	}
      }
      elsif(grep(lc($_) eq lc($n), @resProps)){
	$n = camelCase($n);

	printstr ("  <".$n." rdf:parseType='Resource'>\n");
      }else{
	$n = camelCase($n);
	printstr ("  <".$n.">");
      }
    }else{
      $n = camelCase($n, 1);
      printstr("<".$n.">\n");
      $nsDone = 1;
    }
    push(@stack, $n);
  }
  elsif($field =~ /^END:(\w+)/i){
    my($n) = $1;
    printstr ("\n>") if $intag;
    $intag = 0;

    my($m);
    $m=pop(@stack);
    icalwarning("mismatch [$n] expected [$m]") unless lc($n) eq lc($m);

    # some cosmetic space before tag
    printstr ("   </".$m.">\n");
    if($#stack == 0){
      printstr("  </component>\n");
    }
  }
  elsif($field =~ s/^([\w-]+)([;:])\s*/$2/){
    my($n) = ($1);
    my($enc, $iprop, %attrs, $attrp, $xprop);

    if($n =~ s/^X-//i){
      if(!$X_ns){
	icalwarning("X- property ($n) requires PRODID field $X_ns");
	$field = $line;
	next;
      }
      $xprop = 1
    };
    $n = camelCase($n);
    if($xprop){ $n = "x:" . $n };

    printstr ("    <".$n);

    # @@ where munging occurs. the colon can appear in a
    # quoted value, e.g. in ORGANIZER;DIR="ldap://blah"...
    # this now works for all cases except when there is a
    # semicolon within quotes. 
    # to avoid this, we first parse attributes that involve quotes 

    # check that there is no semicolon within quotes
    my($sc_in);
    while($field =~ /[";]/g){
      $sc_in^=1 if $& eq q(");
      if($& eq ";" && $sc_in) { # @@bail out!
        icalwarning("Can't parse semicolons within quotes, near ".$field);
      }
    }
    # other than the regex, this code block (is unmodular 
    # and) does the same as the next one
    while($field =~ s/;([\w-]+)="([^;]+)"([;:])/$3/g){
      my($an, $av) = (camelCase($1), $2);
      if($an eq 'value'){
	$iprop = camelCase($av);
      }else{
	$attrs{$an} = $av;
	#icalwarning("found attr on $n: $an = $av");;
	$attrp = 1;
      }
    }
    
    while($field =~ s/^;([\w-]+)=([^;:]+)//){
      my($an, $av) = (camelCase($1), $2);
      if($an eq 'value'){
	$iprop = camelCase($av);
      }else{
	$attrs{$an} = $av;
	#icalwarning("found attr on $n: $an = $av");; 
	$attrp = 1;
      }
    }

    if(! $iprop) {
	if($xprop) { $iprop = 'text' } # 4.8.8.1 Non-standard Properties
	else { $iprop = $ValueType{$n} || $ValueTypeD{$n} };
	if(! $iprop){
		# not to die, by MK
	    icalwarning("no value type given, default unknown: $n $field");
		$iprop = 'text'; #regard type as text if no default found
	}
    }

    ##?? not quite meaningful ?? MK
    while($field =~ s/^;([\w-]+)//){
      $enc = $1;
	icalwarning("field: $field; enc = $enc");; #MK
    }

    if($field =~ s/^:\s*(.*)//){
      my($v) = ($1);
      if($attrs{'encoding'} eq 'QUOTED-PRINTABLE'){ #not $enc by MK
## ----- qp2utf8 -- qp can be multiple lines. Also need conversion to utf8: by MK
while($v =~ s/=$//){
	$v .= $line;
#	$line = shift(@lines);
}
$v =~ s/=(..)/pack("c",hex($1))/ge;
Jcode::convert(\$v,'utf8');
## ----- qp2utf8 ends
      }
      elsif($enc){
	icalwarning("unkown enc $enc");
      }

      # support for `possibly symbol' values
      if(grep($_ eq $n, @symbolOrTextProps)){
	if(grep($_ eq $v, @{$symbolVals{$n}})){
	  $v = camelCase($v);
	  #hmm... another namespace for enumerated values?
	  printstr(" rdf:resource='". $ICal_ns . $v ."'/>\n");
	}else{
	  printstr(">". asContent($v) ."</". $n .">\n");
	}
      }
      elsif(grep($_ eq $n, @symbolProps)){
	$v = camelCase($v);
	#hmm... another namespace for enumerated values?
	printstr(" rdf:resource='". $ICal_ns . $v ."'/>\n");
      }
      elsif(grep($_ eq $n, @refProps)){
	$v =~ s/^MAILTO:/mailto:/; #fix borkenness

	printstr(" rdf:parseType='Resource'>\n");
	printstr ("     <".$iprop." rdf:resource='".asAttr($v)."'/>\n");#by MK deleted a space before tag

	# the valProps code also calls printAttrs
	printAttrs(%attrs);

	printstr ("    </".$n.">\n");
      }
      elsif(grep($_ eq $n, @valProps)){
	printstr(" rdf:parseType='Resource'>\n");

	# e.g. RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR
	# be careful about defaults!
	# hmm... key this off value-type recur (4.3.10 Recurrence Rule)
	# rather than the property name?
	if($n eq 'rrule'){ # 4.8.5.4 Recurrence Rule
	  $attrs{'interval'} = '1'; # set default for WKS too? not until we can test it...
	  while($v =~ s/^([\w-]+)=([^;:]+);?//){
	      #@@ treat freq as symbolprop? i.e. normalize case of YEARLY etc.
	    my($an, $av) = (camelCase($1), $2);
	    $attrs{$an} = $av;
	  }
	}else{
	  $v = lexForm($iprop, $v);
	  printstr("     <".$iprop.">".asContent($v)."</".$iprop.">\n"); #by MK deleted a space before tag
	}

	# the refProps code also calls printAttrs
	printAttrs(%attrs);

	printstr ("    </".$n.">\n");

      }
      else{

	  if($iprop eq 'uri'){
	      printstr (" rdf:resource='".asAttr($v)."'/>\n");
	  }else{
	      $v = lexForm($iprop, $v);
	      printstr (">".asContent($v)."</".$n.">\n");
	  }
	  icalwarning("unexpected attrs on $n") if $attrp;
      }
    }else{
      icalwarning("field garbage: [". $field. "]");
    }
  }
  else{

    last if eof;
  }

  $field = $line;
}

printstr ("\n>") if $intag;
startDoc();
print ($rdf);
print ("</rdf:RDF>\n");

sub printAttrs{
	my(%attrs) = @_;
	my($an);
	foreach $an (keys %attrs){
	  my($av) = $attrs{$an};
	  # some elements of @symbolProps were being
	  # ignored before... now they are actually outputted
	  # as rdf:resource. 
	  # @@ this dupes code from above.
	  if(grep($_ eq $an, @symbolOrTextProps)){ 
	    if(grep($_ eq $av, @{$symbolVals{$an}})){
	      #hmm... another namespace for enumerated values?
	      printstr("     <".$an." rdf:resource='". $ICal_ns . camelCase($av) ."'/>\n");
	    }else{
	      printstr("     <".$an.">".asContent($av)."</".$an.">\n");
	    }
	  }elsif(grep($_ eq $an, @symbolProps)){ 
	    printstr("     <".$an." rdf:resource='". $ICal_ns . camelCase($av) ."'/>\n");
	  }elsif(grep($_ eq $an, @refProps)){
	    my($anprop);
	    $an = camelCase($an);
	    $anprop = $ValueTypeA{$an};
	    printstr("     <".$an." rdf:parseType='Resource'>\n");
	    printstr("      <".$anprop." rdf:resource='".asAttr($av)."'/>\n");
	    printstr("     </".$an.">\n");
	  }else{
	    my($av) = $attrs{$an};
	    printstr("     <".$an.">".asContent($av)."</".$an.">\n");
	  }
	  #icalwarning("serialized attr $an = $av");;
	}
}



sub startDoc{
#  my($n) = @_;

  printf(
"<rdf:RDF
  xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  xmlns='%s'
  xmlns:i='%s'
  xmlns:x='%s'
>",
	 $ICal_ns, $ICal_ns, $X_ns);

  if($warnmsg ne ""){
  printstr("<!-- warning: $warnmsg -->\n");
  }
}


close(IN);

sub asContent{
    my($c) = @_;

    $c =~ s,&,&amp;,g;
    $c =~ s,<,&lt;,g;
    $c =~ s,>,&gt;,g;
    #$c =~ s/[\200-\377]/'&#'.ord($&).';'/ge; # comment out by MK to handle CJK

    #@@hhm... protect newlines too?

    return $c
}

sub lexForm{
  my($iprop, $v) = @_;

  if($iprop eq 'text'
     || $iprop eq 'integer'
     || $iprop eq 'utcOffset' # 4.3.14 UTC Offset hm... xml schema uses punct?
     || $iprop eq 'duration'
     ){
    # do nothing
  }
  elsif($iprop eq 'dateTime'){
    $v =~ s/(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)(.*)/$1-$2-$3T$4:$5:$6$7/;
  }
  elsif($iprop eq 'date'){
    $v =~ s/(\d\d\d\d)(\d\d)(\d\d)/$1-$2-$3/;
  }
  elsif($iprop eq 'uri'){
      #umm... hmm... leave URIs as is?
      icalwarning("relative URI reference; not clear that this is allowed/interoperable") unless $v =~ /^\w+:/;
  }
  # cal-address: s/MAILTO/mailto/
  else{
    icalwarning("unknown iprop $iprop; dunno what to do with value '$v'");
  }

  return $v;
}


sub asAttr{
  my($c) = @_;
  
  $c =~ s,&,&amp;,g;
  $c =~ s,<,&lt;,g;
  $c =~ s,>,&gt;,g;
  $c =~ s,\",&quot;,g; #" (just to balance quotation marks)
  $c =~ s,\',&apos;,g;
  #$c =~ s/[\200-\377]/'&#'.ord($&).';'/ge; # comment out by MK for CJK
  
  #@@hhm... protect newlines too?
  
  return $c
}


sub camelCase{
  my($n, $initialCap) = @_;

  my(@words) = map(lc, split(/-/, $n));

  if($initialCap){
    return join('', map(ucfirst, @words));
  }else{
    return $words[0] . join('', map(ucfirst, @words[1..$#words]));
  }
}

sub testCamelCase{
  my(@cases, $n);

  @cases = ("DTSTART", "LAST-MODIFIED");
  foreach $n (@cases){
    printf "case: %s: prop: %s class: %s\n",
      $n, camelCase($n), camelCase($n, 1);
  }
}


# for xproperties need to parse the prodid before
# printing anything else out, so create a string and then print it out
# probably a better way of doing this....

sub printstr{
    my $str=shift;
    $rdf=$rdf.$str;
}


#cf discussion starting with
#  x-properties and namespaces
#  posted by DanC at 2003-02-26 17:17 (+)
#  http://rdfig.xmlhack.com/2003/02/26/2003-02-26.html#1046279854.884486
#and continuing thru
#  RDF calendar agenda item C: prodid support to ical2rdf.pl
#  posted by libby at 2003-07-09 14:59 (+)
#  http://rdfig.xmlhack.com/2003/07/09/2003-07-09.html#1057762764.179078

sub createxns{
    my $prodid=shift;

    #@@hmm... sure would be nice to include unit tests for creatxns,
    # ala python doctest module.


    #remove the word "PRODID"
    #then remove first three chars of e.g. -//Apple Computer\, Inc//iCal 1.0//EN
    $prodid=~ s/PRODID://;
    $prodid=~ s/-\/\///;

    #then replace all spaces with _
    $prodid=~ s/\s/_/g;

    #then replace all // with _
    $prodid=~ s/\/\//_/g;

    #then create sha1 (lowercased)
    my $sha=sha1($prodid);

    #then add first 10 chars and add '_'
    my $xns=substr($prodid,0,10)."_";

    #then add first 5 chars of the sha1.
    $xns=$xns.substr($sha,0,16);

    #prodns - http://www.w3.org/2002/12/cal/prod/
    return $Prod_ns.$xns."#";
}


# sha1 for prodid xproperty creation
# note transform to lower case
sub sha1{
    my $string = shift;

    $string=lc($string);
    my $encoded = sha1_hex($string);
    return $encoded;
}

sub icalwarning{
    # @@hmm... is there a hook in the perl infrastructure
    # to redirect the output of the warn statement?
    my ($str) = shift;
    $warnmsg .= "$str\n";
#   printstr("<!-- warning: $str -->\n");
}


# $Log: ical2rdf.pl,v $
# Revision 1.22  2004/01/21 23:30:46  connolly
# - factored out names of developers into
#   by line and acknowledgements
# - moved MK's list of changes to the change log
# - moved pointer to MK's online service to REFERENCES
# - removed "ADDED" (from George)
# - changed \3 to $3 per diagnostic from perl -wc
# - indented printstr and nearby subs
#
# Revision 1.21  2004/01/19 23:05:03  lmiller
# added link to Jcode for Japanese character support.
#
# Revision 1.20  2004/01/18 21:00:18  lmiller
# modified to take account of X-WR-CALNAME before PRODID
# cf http://lists.w3.org/Archives/Public/www-rdf-calendar/2004Jan/0001.html
#
# Revision 1.19  2004/01/18 19:07:43  lmiller
#  additions from Masahide Kanzaki
#  Multiple Vcalendars now work (test is MozMulipleVcalendars.ics).
# - to implement it as CGI (some headers, not 'die' or 'warn' etc)
# - to handle Japanese characters
# - to parse more attributes
# - for cosmetics (add/delete spaces before tags). 
# and may contain some dependencies on MK's environment.
#
# Revision 1.18  2003/08/23 08:46:47  ghuo
# Reorganized and added some value types. Fixed output that
# was being munged. Added support for param types in deeper
# levels.
#
# Revision 1.17  2003/07/09 16:43:06  connolly
# 16 chars of sha1 in X- namespace
#
# Revision 1.16  2003/07/09 16:35:48  connolly
# don't rely on -//
#
# Revision 1.15  2003/07/09 16:28:35  connolly
# warning for --xnames, pointer to SHA1 sources
#
# Revision 1.14  2003/07/09 13:09:35  lmiller
# added support for prodid for generating the xproperty namespace rather than having to add it by hand. Now uses http://search.cpan.org/author/GAAS/Digest-SHA1-2.02/ for the sha1 digest.
#
# Revision 1.13  2003/07/07 21:11:08  connolly
# added recurrenceId
#
# Revision 1.12  2003/03/27 22:15:33  connolly
# added support for a few to-do-related properties.
# The data I'm working with are sensitive.
# @@I owe a scrubbed test case.
#
# Revision 1.11  2003/03/14 06:01:34  connolly
# added last-modified support
#
# Revision 1.10  2003/03/14 05:12:36  connolly
# treat dtstamp like dtstart and dtend
#
# Revision 1.9  2003/02/20 21:24:22  connolly
# fixed double-camel-casing value types
# added exdate support
#
# Revision 1.8  2003/02/20 00:00:21  connolly
# --componentName option, e.g.
# for naming Vtimezone's
#
# Revision 1.7  2003/02/14 17:10:05  connolly
# ical.{n3,rdf}:
#   added ical:component per 12Feb meeting
#   added comment while I was at it
#
# ical2rdf.pl:
#   updated copyright/license blurb
#   no more about='' on <Vcalendar>, per 12Feb meeting
#   calendar description now contains event descriptions,
#     linked by ical:component, per 12Feb meeting
#   refined rrule support; interval defaults to 1
#
# Makefile:
#   ical schema is now based on a 3rd data file, gkexample
#   refactored DATA_FOR_SCHEMA
#
# Revision 1.6  2003/01/22 21:17:12  connolly
# fixed value=uri as agreed in #rdfig today
#
# Revision 1.5  2003/01/22 00:19:18  connolly
# handling type=uri
#
# Revision 1.4  2003/01/08 20:01:06  connolly
# added support for METHOD property per section 4.7.2 Method of RFC2445
#
# Revision 1.3  2002/12/20 08:03:37  connolly
# another test; a bunch more properties
#
# Revision 1.2  2002/12/20 07:04:46  connolly
# value type names get camel-cased
#
# Revision 1.1  2002/12/20 06:52:50  connolly
#
# moved ical namespace from 2000/10/swap/pim to 2002/12/cal
# fixed dates to YYYY-MM-DD form
#
# Revision 1.6  2002/12/13 18:55:21  connolly
# added --xnames option to give namespace
# for X- properties
#
# Revision 1.5  2002/09/03 17:20:41  connolly
# handle individual vevents
#
# Revision 1.4  2002/07/18 05:26:36  connolly
# be more conservative about X- stuff
#
# Revision 1.3  2002/07/18 05:16:32  connolly
# oops! got ical URI wrong! thx daml validator
#
# Revision 1.2  2002/07/17 20:59:40  connolly
# using ical:value in stead of rdf:value
#
# Revision 1.1  2002/07/17 20:34:55  connolly
# moving from palmagent
#
# Revision 1.6  2002/07/16 05:02:23  connolly
# rudimentary rrule parsing
#
# Revision 1.5  2002/07/16 04:36:46  connolly
# camelCase
#
# Revision 1.4  2002/06/29 06:13:51  connolly
# produces pretty good RDF from my evolution calendar now;
# handles several different flavors of properties.
#
# Revision 1.3  2002/06/29 04:19:40  connolly
# turns some ical files (from evolution) into nearly RDF.
# it's wf XML, at least.
# need to deal with VALUE= attributes and such.
#
# Revision 1.2  2001/07/27 16:47:43  connolly
#  seems to work on my korganizer calendar (addeds support for
#     ;params and QUOTED-PRINTABLE).
#
# 1.1 seems to work on two test files from my nokia cellphone.
