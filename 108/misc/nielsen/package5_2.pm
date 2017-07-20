
package package5_2;
@ISA=(package4);
sub new {
    my $class = shift; my $hash = {};  bless $hash, $class; return ($hash);
}

  ## uncomment to change results.
sub param {return((1,2,3));}
