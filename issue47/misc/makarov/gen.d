include "ir";

func gen (pr, bname) {
  var h = open (bname @ ".h", "w"), c = open (bname @ ".c", "w");
  var i, vect;
  vect = tab2vect (pr.ss);
  for (i = 0; i < #vect; i++)
    fputln (h, "#define ", vect[i], "\t", i + 1);
  fputln (h);
  fputln (c, "#include \"", bname, ".h\"\n\n");
  var match_start = 3, skipif_start = match_start + #pr.ss,
      goto_start = skipif_start + #pr.ss,
      gosub_start = goto_start + (pr.maxd - pr.mind) + 1,
      max_code = gosub_start + (pr.maxd - pr.mind);
  var t = (max_code < 256 ? "unsigned char" : "unsigned short");
  fputln (c, "\nstatic ", t, " program [] = {");
  for (i = 0; i < #pr.ns; i++) {
    if (inside (pr.ns[i], an.goto))
      fput (c, " ", goto_start + pr.l2i {pr.ns[i].lab} - i - pr.mind, ",");
    else if (inside (pr.ns[i], an.match))
      fput (c, " ", match_start + pr.ss {pr.ns[i].sym}, ",");
    else if (inside (pr.ns[i], an.next))
      fput (c, " 1,");
    else if (inside (pr.ns[i], an.ret))
      fput (c, " 2,");
    else if (inside (pr.ns[i], an.skipif))
      fput (c, " ", skipif_start + pr.ss {pr.ns[i].sym}, ",");
    else if (inside (pr.ns[i], an.gosub))
      fput (c, " ", gosub_start + pr.l2i {pr.ns[i].lab} - i - pr.mind, ",");
    if ((i + 1) % 10 == 0)
      fputln (c);
  }
  fputln (c, " 0, 0\n};\n\n");
  fputln (h, "extern int yylex ();\nextern int yyerror ();\n");
  fputln (h, "\nextern int yyparse ();\n");
  fputln (h, "#ifndef YYCALLSTACK_SIZE\n#define YYCALLSTACK_SIZE 50\n#endif");
  fputln (c, "\nint yyparse () {\n  int yychar = yylex (), pc = 0, code;\n  ",
	  t, " call_stack [YYCALLSTACK_SIZE];\n  ", t, " *free = call_stack;");
  fputln (c, "\n  *free++ = sizeof (program) / sizeof (program [0]) - 1;");
  fputln (c, "  while ((code = program [pc]) != 0 && yychar > 0) {");
  fputln (c, "    pc++;\n    if (code == 1)\n      yychar = yylex ();");
  fputln (c, "    else if (code == 2) /*return*/\n      pc = *--free;");
  fputln (c, "    else if ((code -= 2) < ", #pr.ss, ") {/*match*/");
  fputln (c, "      if (yychar == code)\n        pc++;\n      else {");
  fputln (c, "        yyerror (\"Syntax error\");\n        return 1;\n      }");
  fputln (c, "    } else if ((code -= ", #pr.ss, ") < ", #pr.ss, ") {");
  fputln (c, "      if (yychar == code)\n        pc++; /*skipif*/");
  fputln (c, "    } else if ((code -= ", #pr.ss, ") <= ", pr.maxd - pr.mind,
	  ") /*goto*/\n      pc += code + ", pr.mind, ";");
  fputln (c, "    else if ((code -= ", pr.maxd - pr.mind + 1, ") <= ",
	  pr.maxd - pr.mind, ") { /*gosub*/");
  fputln (c, "      if (free >= call_stack + YYCALLSTACK_SIZE) {");
  fputln (c, "        yyerror (\"Call stack overflow\");");
  fputln (c, "        return 1;\n      }\n      pc += code + ", pr.mind,
	  ";\n      *free++ = pc;\n    } else {");
  fputln (c, "      yyerror (\"Internal error\");\n      return 1;\n    }");
  fputln (c, "  }\n  if (code != 0 || yychar > 0) {");
  fputln (c, "    if (code != 0)\n      yyerror (\"Unexpected EOF\");");
  fputln (c, "    else\n      yyerror (\"Garbage after end of program\");");
  fputln (c, "    return 1;\n  }\n  return 0;\n}");
  close (h);
  close (c);
}
