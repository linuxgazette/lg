include "ir";

func get_ir (f) {
  var ln, lno = 0, code, lab, op, v;
  // Patterns
  var p_sp = "[ \t]*";
  var p_code = p_sp @ "(goto|skipif|gosub|match|return|next)";
  var p_id = "[a-zA-Z][a-zA-Z0-9]*";
  var p_lab = p_sp @ "((" @ p_id @ "):)?";
  var p_str = "\"[^\"]*\"";
  var p_op = p_sp @ "(" @ p_id @ "|" @ p_str @ ")?";
  var p_comment = p_sp @ "(;.*)?";
  var pattern = "^" @ p_lab @ "(" @ p_code @ p_op @ ")?" @ p_comment @ "$";

  var pr = ir ();
  try {
    for (;;) {
      ln = fgetln (f);
      lno++;
      v = match (pattern, ln);
      if (v == nil)
	err ("syntax error on line ", lno);
      lab = (v[4] >= 0 ? subv (ln, v[4], v[5] - v[4]) : nil);
      if (!(#pr.ns in pr.i2l))
        pr.i2l {#pr.ns} = [];
      if (lab != nil) {
	if (lab in pr.l2i)
	  err ("redefinition lab ", lab, " on line ", lno);
	pr.l2i {lab} = #pr.ns;
        ins (pr.i2l {#pr.ns}, lab, -1);
      }
      code = (v[8] >= 0 ? subv (ln, v[8], v[9] - v[8]) : nil);
      if (code == nil)
        continue;  // skip comment or absent code
      op = (v[10] >= 0 ? subv (ln, v[10], v[11] - v[10]) : nil);
      var node = irn (lno);
      if (code == "goto" || code == "gosub") {
	if (op == nil || match (p_id, op) == nil)
	  err ("invalid or absent lab `", op, "' on line ", lno);
	node = (code == "goto" ? node.goto (op) :  node.gosub (op));
      } else if (code == "skipif" || code == "match") {
	if (op == nil || match (p_id, op) == nil)
	  err ("invalid or absent name `", op, "' on line ", lno);
	node = (code == "skipif" ? node.skipif (op) : node.match (op));
      } else if (code == "return" || code == "next") {
	if (op != nil)
	  err (" non empty operand `", op, "' on line ", lno);
	node = (code == "next" ? node.next (op) : node.ret ());
      }
      ins (pr.ns, node, -1);
    }
  } catch (invcalls.eof) {
  }
  return pr;
}
