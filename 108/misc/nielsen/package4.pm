package package4;
@ISA=(package3);
sub new {
    my $class = shift; my $hash = {};  bless $hash, $class; return ($hash);
}
