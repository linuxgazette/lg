package package6;
@ISA = qw (package5 package5_2);
sub new {
    my $class = shift; my $hash = {};  bless $hash, $class; return ($hash);
}

  ## uncomment to change results.
#sub param {return((1,2,3));}
