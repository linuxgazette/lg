---          Custom Sample SQL for Perl/PostgreSQL version 0.1

---                       Copyright 2001, Mark Nielsen
---                            All rights reserved.
---    This Copyright notice was copied and modified from the Perl 
---    Copyright notice. 
---    This program is free software; you can redistribute it and/or modify
---    it under the terms of either:

---        a) the GNU General Public License as published by the Free
---        Software Foundation; either version 1, or (at your option) any
---        later version, or

---        b) the "Artistic License" which comes with this Kit.

---    This program is distributed in the hope that it will be useful,
---    but WITHOUT ANY WARRANTY; without even the implied warranty of
---    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
---    the GNU General Public License or the Artistic License for more details.

---    You should have received a copy of the Artistic License with this
---    Kit, in the file named "Artistic".  If not, I'll be glad to provide one.

---    You should also have received a copy of the GNU General Public License
---   along with this program in the file named "Copying". If not, write to the 
---   Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 
---    02111-1307, USA or visit their web page on the internet at
---    http://www.gnu.org/copyleft/gpl.html.

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
 -- Just to show you what this function cleans up. 
select clean_text ('       ,./<>?aaa aa      !@#$%^&*()_+| ');

drop function clean_alpha (text);
CREATE FUNCTION  clean_alpha (text) RETURNS text AS '
  my $Text = shift;
  $Text =~ s/[^a-z0-9_]//gi;
  return $Text;
' LANGUAGE 'plperl';
 -- Just to show you what this function cleans up. 
select clean_alpha ('       ,./<>?aaa aa      !@#$%^&*()_+| ');

drop function clean_numeric (text);
CREATE FUNCTION  clean_numeric (text) RETURNS int4 AS '
  my $Text = shift;
  $Text =~ s/[^0-9]//gi;
  return $Text;
' LANGUAGE 'plperl';
 -- Just to show you what this function cleans up.
select clean_numeric ('       ,./<>?aaa aa      !@#$%^&*()_+| ');

drop function clean_numeric (int4);
CREATE FUNCTION  clean_numeric (int4) RETURNS int4 AS '
  my $Text = shift;
  $Text =~ s/[^0-9]//gi;
  return $Text;
' LANGUAGE 'plperl';
 -- Just do show you what this function cleans up.
select clean_numeric (1111);


