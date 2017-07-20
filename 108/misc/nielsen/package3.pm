package package3;
@ISA=(package2);
sub new {
    my $class = shift; my $hash = {};  bless $hash, $class; return ($hash);
}
