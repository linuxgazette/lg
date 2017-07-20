
drop function clean_text (text);
CREATE FUNCTION  clean_text (text) RETURNS text AS '
  my $Text = shift;
    # Get rid of whitespace in front. 
  $Text =~ s/^\\s+//;
    # Get rid of whitespace at end. 
  $Text =~ s/\\s+$//;
    # Get rid of anything not text.
  $Text =~ s/[^ a-z0-9\\/\\`\\~\\!\\@\\#\\$\\%\\^\\&\\*\\(\\)\\-\\_\\=\\+\\\\\\|\[\\{\\]\\}\\;\\:\\''\\"\\,\\<\\.\\>\\?\\t\\n]//gi;
    # Replace all multiple whitespace with one space. 
  $Text =~ s/\\s+/ /g;
  return $Text;
' LANGUAGE 'plperl';
 -- Just do show you what this function cleans up. 
select clean_text ('       ,./<>?aaa aa      !@#$%^&*()_+| ');

drop function clean_alpha (text);
CREATE FUNCTION  clean_alpha (text) RETURNS text AS '
  my $Text = shift;
  $Text =~ s/[^a-z0-9_]//gi;
  return $Text;
' LANGUAGE 'plperl';
 -- Just do show you what this function cleans up. 
select clean_alpha ('       ,./<>?aaa aa      !@#$%^&*()_+| ');

drop function clean_numeric (text);
CREATE FUNCTION  clean_numeric (text) RETURNS int4 AS '
  my $Text = shift;
  $Text =~ s/[^0-9]//gi;
  return $Text;
' LANGUAGE 'plperl';
 -- Just do show you what this function cleans up.
select clean_numeric ('       ,./<>?aaa aa      !@#$%^&*()_+| ');

drop function clean_numeric (int4);
CREATE FUNCTION  clean_numeric (int4) RETURNS int4 AS '
  my $Text = shift;
  $Text =~ s/[^0-9]//gi;
  return $Text;
' LANGUAGE 'plperl';
 -- Just do show you what this function cleans up.
select clean_numeric (11111);



