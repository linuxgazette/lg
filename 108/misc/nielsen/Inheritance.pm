#!/usr/bin/perl

### This module is intended to find out who the parents and children are
### for a given function in a given class. 

package Class::Inheritance;
use strict qw(vars subs);

# TODO:
# 1. Add pod stuff
# 2. Create module .tgz file for installation purposes. 
# 3. Lowercase functions. Rename them to make them more intuitive.
# 4. Return ref to arrays rather than a string. Make a print module for
#    the strings. 
# 5. Eval the requires. If eval fails, fail script, but use carp module. 
# 6. Add some more functions for more ideas about the inheritance problem.
#    a. function to say "choose the 2nd function in the list."
#    b. Return the ref to the function of any of the parents in the tree.
#       This is already possible, but it will make it easier for novices.
#    c. Function to print non-repeated entries in the Inherit_Tree function.
#    d. Dump text, html, xml, or graphic image of parent tree.
#    e. Sync or Pollute to remap a package to use another package. 
#    f. Find all children who have:
#       1. Inheritted this class
#       2. Directly inherited a method from this class. 
#       3. Directly inherited a method from this class and 
#          I am the original source. 
# 7. Use Inherit_Tree->(class_name=>$class_name, tree=>$tree)
#    instead of Inherit_Tree->($class_name, $tree)
#    for all the functions, unless there is only one variable. 
# 8. Consider Class::Inspector and whether it should use this module
#    or I should use its module, or both, or they should be merged. 
#    My gut reaction is that I would Inspector since Inspector seems to
#    be designed just for a class. 


sub new {
    my $class = shift; my $hash = {};  bless $hash, $class; return ($hash);
}

#----------------------------------------------
# Finds the nearest parent that has the function you want.

sub Methods_Parent {
    my $self = shift;
       ### The class we are looking at. 
    my $class_name = shift;
       ### The function we are looking for. 
    my $function_name = shift;

    my $temp = $self->Inherit_Tree_Matches($class_name, $function_name,1);
    return($temp);
}

#-------------------------------------

  ## This function lists the order in which we grab functions from a given
  ## class and its parents. 
  ## This method seems to be reliable all the time.
sub Inherit_Tree {
    my $self = shift;
    my $class_name = shift;
    my $tree = "";

      ### require this class. 
      ### if used was already used, it won't hurt anything.
    eval {require "$class_name\.pm";};
    if ($@) {print "ERROR: can't require '$class_name'.\n"; print "$@\n"; exit();}

      ## Get the parents I inherit functions from. 
    my @isa = @{"main::$class_name\::ISA"}; 

      ### Foreach class, load it and analyze it. 
    for my $class (@isa) {
	eval {require "$class\.pm";};
	if ($@) {print "ERROR: can't require '$class'.\n"; print "$@\n"; exit();}
          ## Get the classes I inherit recursively. 
        my $temp2 = $self->Inherit_Tree($class);  
        if ($temp2 ne '') {$temp2 .= ' ';}
          ## The tree equals this class and the recrusive call.
        $tree .= "$class $temp2";
    }

    $tree =~ s/  +/ /g;
    return($tree);
}

#---------------
 
  ### Returns those classes which have the function.
  ### This method is reliable. It stores the
  ### ref to the function. 
sub Inherit_Tree_Matches {
    my $self = shift;
    my $class = shift;
    my $function_name = shift;
    my $count = shift || 0;
    if ($count < 1) {$count = 0;}

      ## My Parents I inherit from.
    my $tree_list = $self->Inherit_Tree($class);
    my (@items) = split(/ +/, $tree_list);

    my $method_name = [];
    my $previous_code = "";

        ### Record my class if I actually have the function.
    my $temp_obj = new $class;
        ### Can I execute this function?
    my $ref_type = ref($temp_obj->can($function_name));
      ## Does it return a code ref which points to the code?
      ## It yes, then record.
    if ($ref_type eq "CODE") {
	my $code1 = $temp_obj->can($function_name);
	my $string1 = "$code1";
        $previous_code = $string1;
        push(@$method_name, $class); 
    }

    for my $class (@items) {
          ## Dangerous thing which could bomb us. Eval it later.

	eval {require "$class\.pm";};
        if ($@) {print "ERROR: can't require '$class'.\n"; print "$@\n"; exit();}

          ## Get the names of the items in this class.          

      	my @keys = keys %{"main::$class\::"};

       ## We want to grab only the key that matches the function.
	my (@match) = grep($_ eq $function_name, @keys);
	my $length = @match;

           ## If the function exists, if the class can execute ths function,
           ## and the return value is CODE
	if (grep($_ eq $function_name, keys %{"main::$class\::"}))  {
	    my $temp_obj = new $class;
              ## If the reference eq CODE?
	    my $ref_type = ref($temp_obj->can($function_name));
	    if ($ref_type eq "CODE") {
                  ## Get the the ref to where it points. 
                  ## The key thing here is, we don't want to record
                  ## this unless it is different from the previous parent.
                  ## We are only interested in the root parents where the
                  ## function comes from and not parents who inherited the
                  ## function.
		my $code1 = $temp_obj->can($function_name);
		my $string1 = "$code1";
                if ($string1 ne $previous_code) {
		    $previous_code = $string1;
		    push(@$method_name, $class);
		}
                @{$method_name}->[-1] = $class;
	    }
	}    
    }

      ### Make a list of the parents who have this function who are the
      ### original source of the function. List in order. 
    my $tree_matches = $method_name->[0];
    my $no = 1;
    if ($count < 1) {$count = @$method_name;}
    while ($no < $count) {
	my $value = $method_name->[$no];
        if (length($value) > 0) { $tree_matches .= " $value"; }
        $no++;
    } 

    return($tree_matches);
}

  ## Must always return true.
1;
