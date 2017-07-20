package package2;
@ISA=(package1);
sub new {
    my $class = shift; my $hash = {};  bless $hash, $class; return ($hash);
}
