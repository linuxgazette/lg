include "ir";

func check (pr) {
  var i;
  for (i = 0; i < #pr.ns; i++) {
   if (inside (pr.ns[i], an.goto) || inside (pr.ns[i], an.gosub)) {
      if (!(pr.ns[i].lab in pr.l2i))
	err ("undefined label `", pr.ns[i].lab, "' on line ",
	     pr.ns[i].lno);
      if (pr.maxd == nil || pr.maxd < pr.l2i {pr.ns[i].lab} - i)
	pr.maxd = pr.l2i {pr.ns[i].lab} - i;
      if (pr.mind == nil || pr.mind > pr.l2i {pr.ns[i].lab} - i)
	pr.mind = pr.l2i {pr.ns[i].lab} - i;
    } else if (inside (pr.ns[i], an.match) || inside (pr.ns[i], an.skipif)) {
      if (!(pr.ns[i].sym in pr.ss))
	pr.ss {pr.ns[i].sym} = #pr.ss;
    }
  }
}

