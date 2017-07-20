#!/usr/bin/perl

# Import modules of interst.
use CGI qw/:standard :html3 :netscape/;
use Msql;

# print out the HTML HEAD section
print header,
   start_html(
      -author=>'webmaster@graphics-muse.org',
      -title=>'My Little Tools',
      -bgcolor=>'#FFFFFF', -text=>'#000000'
   );

# Open the Msql connections and select the databases of interest.
my $dbh1 = Msql->connect();
$dbh1->selectdb('tools');

my $sth = $dbh1->query("SELECT * from tools");
my @rows;
my @result;
while (@result = $sth->fetchrow)
{
   push( @rows, td({-align=>'CENTER', -valign=>'CENTER'}, $result[1]));
}
my $tools_list =
      table( {-border=>1, -cellpadding=>'1', -cellspacing=>'5'},
           Tr(@rows)
      );

# Now print the complete table
print
   center(
   table(
      {-border=>1, -width=>'100%', -cellpadding=>1, -cellspacing=>5},

      Tr(
         td({-align=>'CENTER', -valign=>'CENTER'}, $tools_list),
      )
   )
);


# End of HTML output.
print end_html;
