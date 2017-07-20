include "ir";
include "input";
include "pr";
include "check";
include "gen";

if (#argv != 1)
  err ("Usage: sas file");

var pr = get_ir (open (argv[0], "r"));
// print_ir (stdout, pr);
check (pr);
gen (pr, sub ("^(.*/)?([^.]*)(\\..*)?$", argv[0], "\\2"));
