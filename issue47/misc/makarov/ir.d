class irn (lno) {
  class goto (lab)     {}     class skipif (sym)    {}
  class match (sym)    {}     class gosub (lab)     {}
  class next ()        {}     class ret ()          {}
}

var an = irn (0);

class ir () {
  // all ir nodes, label->node index, node index -> vector of labels.
  var ns = [], l2i = {}, i2l = {};
  var ss = {}, mind, maxd;
}

func err (...) {
  var i;
  fput (stderr, argv[0], ": ");
  for (i = 0; i < #args; i++)
    if (args[i] != nil)
      fput (stderr, args[i]);
  fputln (stderr);
  exit (1);
}

func tab2vect (tab) {
  var i, vect = [#tab:""];
  for (i in tab)
    vect [tab {i}] = i;
  return vect;
}
