#!/usr/bin/perl -w
# Created by Ben Okopnik on Sun May  1 15:14:49 EDT 2005
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI qw/:standard/;
$|++;

$dir = "..";

print header;
print <<'EoT';
<html>
<head>
<link href="../lg.css" rel="stylesheet" type="text/css" />
<title>Linux Gazette: Chemical Factory</title>
<style type="text/css">
<!--
#archives {
	top:143px;
	position:absolute;
	text-align:center;
}
-->
</style>
</head>
<body>
<img src="../gx/2003/newlogo-blank-200-gold2.jpg" id="logo" alt="Linux Gazette"/>
<p id="fun">...making Linux just a little more fun!</p>

<div class="content fullpagediv" id="archives">
<center>
EoT

print h3("LG issues that contain a TWDT.pdb");
chdir $dir;

my ($c, %coll);
push @{$coll{int(++$c/10)}}, $_ for grep { -f "$_/TWDT$_.pdb" }
    sort { $b <=> $a } <[0-9][0-9]*>;

print table({-border=>1, cellpadding=>6}, map{
		Tr("\n", map({td(a({-href=>"../$_/TWDT$_.pdb"}, $_), "\n")}
			sort {$b<=>$a} @{$coll{$_}}), "\n")} sort {$a<=>$b} keys %coll);

print <<'EoT';
</center>
</div>
<div id="navigation">
<a href="../index.html">Home</a>
<a href="../faq/index.html">FAQ</a>
<a href="../lg_index.html">Site Map</a>
<a href="../mirrors.html">Mirrors</a>
<a href="../mirrors.html">Translations</a>
<a href="../search.html">Search</a>
<a href="../archives.html">Archives</a>
<a href="../authors/index.html">Authors</a>
<a href="../contact.html">Contact Us</a>
</div>

<div id="breadcrumbs">
<a href="../index.html">Home</a> &gt;
Chemical Factory
</div>

<img src="../gx/2003/sit3-shine.7-2.gif" id="tux" alt="Tux"/>

</body>
</html>
EoT
