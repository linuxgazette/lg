package package1;
@ISA=(CGI);
sub new {
    my $class = shift; my $hash = {};  bless $hash, $class; return ($hash);
}
