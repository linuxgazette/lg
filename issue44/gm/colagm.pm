# -*- mode: Perl; -*-

# AUTHOR: John Goerzen
# EMAIL: jgoerzen@complete.org
# ONE LINE DESCRIPTION: Latest messages from comp.os.linux.announce
# URL: http://www.cs.helsinki.fi/~mjrauhal/linux/cola.archive/*.html
# TAG SYNTAX:
# <input name=colagm department=X>
#   Returns an array of links
# X: One of
#		last50	- search cola-last-50.html for entries.
#		sorted	- search cola-sorted.html for entries.
#		www		- search cola-www.html for entries.
# LICENSE: GPL
# NOTES:

package NewsClipper::Handler::Acquisition::colagm;

use strict;
use Msql;

use NewsClipper::Handler;
use NewsClipper::Types;
use vars qw( @ISA $VERSION );
@ISA = qw(NewsClipper::Handler);

# DEBUG for this package is the same as the main.
use constant DEBUG => main::DEBUG;

use NewsClipper::AcquisitionFunctions qw( &GetLinks );

$VERSION = 0.3;

# ------------------------------------------------------------------------------
sub gettime
{
	my $sec;
	my $min;
	my $hour;
	my $mday;
	my $mon;
	my $year;
	my $wday;
	my $yday;
	my $isdist;
	my $datestring;

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdist) = localtime(time);

	$datestring = $year + 1900;
	$datestring *= 10000;
	$datestring += $mon*100 + $mday;

	return $datestring;
}


# This function is used to get the raw data from the URL.
sub Get
{
	my $self = shift;
	my $attributes = shift;
	my $url;
	my $data;
	my $colafile;
	my $start_delimiter;
	my $end_delimiter;
	my $urllink;
	my @results;
	my $tempRef;
	my $query_line;
	my @query_lines;
	my $sth;
	my $newcount;
	my $dbdate;
	my $title;

	$attributes->{department} = "last50" 
		unless defined $attributes->{department};

	#
	# Determine which file to search.
	#
	if ( "$attributes->{department}" eq "last50" )
	{
		$colafile = "cola-last-50.html";
		$start_delimiter = "newest ones first";
		$end_delimiter = "Last modified";
	}
	elsif ( "$attributes->{department}" eq "sorted" )
	{
		$colafile = "cola-sorted.html";
		$start_delimiter = "order by the subject";
		$end_delimiter = "Last modified";
	}
	else
	{
		$colafile = "cola-www.html";
		$start_delimiter = "the last one first";
		$end_delimiter = "Last modified";
	}

	#
	# Build the URL which is to be queried.
	#
	$url = join("", 
		"http://www.cs.helsinki.fi/~mjrauhal/linux/cola.archive/",
		$colafile);

	#
	# Now run off and get those links!
	#
	$data = &GetLinks($url, $start_delimiter, $end_delimiter);

	return undef unless defined $data;

	#
	# Weed out any User Group messages
	#
	@$data = grep {!/(LOCAL:)/} @$data;

	# Open the Msql connections and select the databases of interest.
	my $dbh1 = Msql->connect();
	$dbh1->selectdb('gm-news');

	# Clear the "new article" table - if we haven't processed those
	# entries yet, then we'll see them again anyway.
	$query_line = join("", "DELETE FROM new_cola");
	$sth = $dbh1->query($query_line);
	$newcount = 1;

	#
	# Now run through the list to find only the news ones.  Then add these
	# to the proper database.
	#
	while (@{$data}) 
	{
		$_= shift @{$data};    

		# Escape single quotes.  We take them out later when we display them, if
		# necessary.
		$title = $_;
		$title =~ s/'/\\'/g;

		# Query the Accepted table for this article name.
		$query_line = 
			join("", "SELECT title FROM accepted WHERE title = '", $title, "'");

		$sth = $dbh1->query($query_line);
		if ( $sth->numrows > 0 )
		{
			next;
		}
	
		# Query the Rejected table for this article name.
		$query_line = 
			join("", "SELECT title FROM rejected WHERE title = '", $title, "'");

		$sth = $dbh1->query($query_line);
		if ( $sth->numrows > 0 )
		{
			next;
		}

		# Article has not been seen previously.  Add it to the new database.
		$dbdate = gettime();
		$query_lines[0] = "INSERT INTO new_cola VALUES (";
		$query_lines[1] = $newcount;
		$query_lines[2] = ", ";
		$query_lines[3] = $dbdate;
		$query_lines[4] = ", '";
		$query_lines[5] = $title;
		$query_lines[6] = "', '";
		$query_lines[7] = "cola";
		$query_lines[8] = "', '";
		$query_lines[9] = " ";
		$query_lines[10] = "', '";
		$query_lines[11] = " ";
		$query_lines[12] = "', '";
		$query_lines[13] = " ";
		$query_lines[14] = "')";
		
		$query_line = join('', @query_lines);
		$sth = $dbh1->query($query_line);

		# Abort on errors encountered while inserting into the new article table.
		if ( length(Msql->errmsg) > 0 )
		{
			print "<!--News Clipper message:\n",
				"Failed new article db update for colaGM handler\n",
				"Error message: ", Msql->errmsg, "\n",
				"-->\n" and return undef;
		}

		# Everything went ok, and it's a new article.  Save it for return to the
		# caller.
		push @results, 
		{
			index		=> $newcount,
			url		=> $_
		};

		$newcount++;
	}

	$tempRef = \@results;
	MakeSubtype('ArrayOfCOLAHash','ArrayOfHash');

	bless $tempRef,'ArrayOfCOLAHash';
	return $tempRef;
}

# ------------------------------------------------------------------------------

sub GetDefaultHandlers
{
  my $self = shift;
  my $inputAttributes = shift;
  my @returnVal;

  my @returnVal = (
     {'name' => 'limit','number' => '10'},
     {'name' => 'array'},
  );

  return @returnVal;
}

1;
