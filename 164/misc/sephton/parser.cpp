#include <cstdio>
#include <cstdlib>
#include <string>

using namespace std;

/*  Syntax Definition
  Query(p)   -> Subquery {S Query(q)}
  Subquery   -> BraceQuery | ' QuotedText ' | " QuotedText " | word
  BraceQuery -> '(' Query ')'
  S          -> 'and' | 'or' | '-' | 'not'
  Text       -> word { WS word }
  WS         -> ' ' | tab
  QuotedText -> Text
  word       -> Literal
*/

typedef enum {assoc_none, assoc_left, assoc_right} ASSOCIATION;

struct {             // Room for improvement re: efficiency.
  const char *op;    // operator
  int         pri;   // priority
  ASSOCIATION assoc;
} g_ptable[] = {
  {"and", 2, assoc_left},
  {"or",  1, assoc_left},
  {"not", 3, assoc_right},
  {"-",   3, assoc_right},
  {NULL,  0, assoc_none}
};

//______________________________________
class query{    // State machine represents the query being parsed
  const char *q;   // No memory allocation here
  int         c;
  int         n;
  int         v;
  public :
    query(const char *a_query) : q(a_query), c(0), n(0), v(0) {}
   ~query() {};

    bool is_binary(int p) {
      string l_next = next();
      for (int i=0; g_ptable[i].op; i++) {
        if (l_next==g_ptable[i].op) {
          v = i; return p <= g_ptable[i].pri;
        }
      }
      return false;
    }

    // Anyone complaining about state here may fix it themselves
    int prec() {  // assumes v is set from is_binary()
      if (g_ptable[v].assoc==assoc_left)
        return 1 + g_ptable[v].pri;
      else
        return g_ptable[v].pri;
    }

    void eat_ws() { while (q[c] && q[c] <= 32) c++; }

    bool is_separator(char a_ch){
      if (a_ch=='('  ||  a_ch==')')  return true;
      if (a_ch=='"'  ||  a_ch=='"')  return true;
      if (a_ch=='\'' ||  a_ch=='\'') return true;
      if (a_ch=='-') return true;
      return false;
    }

    string next() {
      eat_ws();
      for (n=c; q[n]; n++) {
        if (q[n]<=32) break;
        if (is_separator(q[n])) { if (n==c) n++; break; }
      }
      return string(q+c, n-c);
    }

    bool expect(const string &a_exp) { return next() == a_exp; }
    void consume() { c = n; }
    char current() { return q[c]; }
    int  offset()  { return c; }
    string copy(int a_ofs, int n) { return string(q+a_ofs, n); }
};   // class query

//______________________________________
class PNODE  // represents a parse tree node
{
  public :
    const string type;
    const string data;
    PNODE       *left;
    PNODE       *right;
    PNODE(const string &a_type, const string &a_data) : type(a_type), data(a_data) {
      left = right = NULL;
    }
    ~PNODE() {};
};  // class PNODE

//______________________________________
//  Text       -> word { WS word }
PNODE *parse_text(query &a_query, const string &a_tc) {
  if (!a_query.current()) return NULL;
  string l_word = a_query.next();
  if (l_word.length()==0) return NULL;
  if (l_word==a_tc) return NULL;
  if (a_tc.length()==0)
  {
    if (a_query.is_separator(a_query.current())) return NULL;
    if (a_query.is_binary(0)) return NULL;
  }

  a_query.consume();
  PNODE *t = new PNODE("word", l_word);
  t->right = parse_text(a_query, a_tc);
  return t;
} // parse_text

//______________________________________
//  QuotedText -> Text
PNODE *parse_quoted_text(query &a_query, const string &a_tc) {
  int l_ofs = a_query.offset();
  PNODE *tn = parse_text(a_query, a_tc);
  PNODE *t = new PNODE("quoted", a_query.copy(l_ofs, a_query.offset()-l_ofs));
  t->right = tn;
  return t;
} // parse_quoted_text

// forward declaration 
PNODE *parse_query(query &a_query, int p);

//______________________________________
//  Subquery   -> BraceQuery | 
//               ' QuotedText ' | 
//               " QuotedText " | word
PNODE *parse_subquery(query &a_query) {
  string l_next = a_query.next();
  if (l_next=="(") {
    a_query.consume();
    PNODE *t = parse_query(a_query, 0);
    if (!a_query.expect(")")) return NULL;
    a_query.consume();
    return t;
  }
  else if (l_next=="'") {
    a_query.consume();
    PNODE *t = parse_quoted_text(a_query, l_next);
    if (!a_query.expect("'")) return NULL;
    a_query.consume();
    return t;
  }
  else if (l_next=="\"") {
    a_query.consume();
    PNODE *t = parse_quoted_text(a_query, l_next);
    if (!a_query.expect("\"")) return NULL;
    a_query.consume();
    return t;
  }
  else
  {
    PNODE *t = parse_text(a_query, "");
    return t;
  }
  return NULL;
}  // parse_subquery

//______________________________________
//  Query(p)   -> Subquery {S Query(q)}
PNODE *parse_query(query &a_query, int p)
{
  PNODE *t = parse_subquery(a_query);

  if (t && a_query.is_separator(a_query.current()))
  {
    PNODE *t1 = parse_query(a_query, p);
    if (t1)
    {
      PNODE *tf = new PNODE("and", "");
      tf->left = t;
      tf->right = t1;
      t = tf;
    }
  }

  while (t && a_query.is_binary(p))
  {
    int q = a_query.prec();
    string l_op = a_query.next();
    a_query.consume();
    PNODE *t1 = parse_query(a_query, q);
    if (t1)
    {
      PNODE *tf = new PNODE(l_op, "");
      tf->left = t;
      tf->right = t1;
      t = tf;
    }
  }
  return t;
}  // parse_query

//______________________________________
//  Unused, for debug only
void show_tree(PNODE *p, int lvl) {
  if (!p) return;
  if (p->left) show_tree(p->left, lvl+2);
  for (int n = 0; n < lvl; ++n) printf(" ");
  printf("[%s][%s]\n", p->type.c_str(), p->data.c_str());
  if (p->right) show_tree(p->right, lvl+2);
} // show_tree

//______________________________________
// Exec: Parse tree->tsquery text
string fts_query(PNODE *p, bool &has_quoted) {
  if (!p) return "";
  string l_left, l_right, l_this, lb="(", rb=")";

  if (p->left)  l_left  = fts_query(p->left, has_quoted);
  if (p->right) l_right = fts_query(p->right, has_quoted);
  if (p->type=="and") return  lb + l_left + " & " + l_right + rb;
  if (p->type=="or")  return  lb + l_left + " | " + l_right + rb;
  if (p->type=="not" || p->type=="-") return  lb + l_left + " & !" + l_right + rb;
  if (p->type=="word") {
    if (l_right.length())
      return p->data + " & " + l_right;
    else
      return p->data;
  }
  if (p->type=="quoted") {
    has_quoted = true;
    return  lb + l_right + rb;
  }
  return "";
} // fts_query

//______________________________________
// Exec: Parse tree->tsquery text & literal phrase
string fts_quoted(PNODE *p, bool &has_quoted, 
                  const string &bodyname, 
                  const string &tsvname) {
  if (!p) return "";
  string l_left, l_right, l_this, lb="(", rb=")";
  bool left_quoted=false, right_quoted=false;
  if (p->left)  l_left  = fts_quoted(p->left,  left_quoted,  bodyname, tsvname);
  if (p->right) l_right = fts_quoted(p->right, right_quoted, bodyname, tsvname);
  has_quoted |= left_quoted || right_quoted;
  if (!left_quoted)  
     l_left  = lb + tsvname + 
                 " @@ to_tsquery('"+fts_query(p->left, left_quoted)+"')"+rb;
  if (!right_quoted) 
     l_right = lb + tsvname + 
       " @@ to_tsquery('"+fts_query(p->right, right_quoted)+"')"+rb;

  if (p->type=="and") return  lb + l_left + " and " + l_right + rb;
  if (p->type=="or")  return  lb + l_left + " or "  + l_right + rb;
  if (p->type=="not" || p->type=="-") return  lb + l_left + 
                                               " and not" + lb + l_right + rb + rb;

  if (p->type=="word") {
    if (l_right.length())
      return p->data + " & " + fts_query(p->right, right_quoted);
    else
      return p->data;
  }

  if (p->type=="quoted") {
    has_quoted = true;
    string l_st = lb + fts_query(p->right, right_quoted) + rb;
    l_st = lb + tsvname + " @@ to_tsquery('"+l_st+"') and " +
           bodyname+" ilike '%"+p->data + "%'"+ rb;
    return l_st;
  }
  return "";
} // fts_quoted

//______________________________________
//  Parse natural querytext, and print the 
//  corresponding PostgreSQL SQL query
void parse_querytext(const char *querytext,
                     const char *tablename,
                     const char *bodyname,
                     const char *tsvname,
                     size_t      a_nfields,
                     char       *a_retfield[])
{
  query l_query(querytext);
  PNODE *p = parse_query(l_query, 0);
//  show_tree(p, 0);   // debug
  bool l_has_quoted = false;
  string l_res = fts_query(p, l_has_quoted);
  printf("select ");
  for (size_t n=0; n < a_nfields; ++n) printf("%s%s", n?", ":"", a_retfield[n]);
  printf("%sts_rank_cd(%s, query) as rank", a_nfields?", ":" ", tsvname);
  printf("\n  from %s,"
         "\n       to_tsquery('%s') as query",
         tablename, l_res.c_str());
  printf("\n  where %s @@ query", tsvname);
  string l_quoted = fts_quoted(p, l_has_quoted, bodyname, tsvname);
  if (l_has_quoted && l_quoted.length())
    printf("\n  and %s\n", l_quoted.c_str());
  else
    printf("\n");
} // parse_querytext

#define MAX_RETFIELD 20

//______________________________________
// Entry point
int main(int a_argc, char *a_argv[])
{
  const char l_hlptxt[] =
  "fts_sql <querytext> <tablename> <bodyname> <tsvname> <f1 [f2 [...]]>\n"
  "    where querytext contains the full text search query\n"
  "          tablename is the name of the table being searched\n"
  "          bodyname is the name of the field containing the body text\n"
  "          tsvname is the name of the field containing the stored tsvector\n"
  "      and f1,f2..fn are the names of the fields that should be returned\n";

  char *querytext, *tablename, *bodyname, *tsvname;
  char *l_retfield[MAX_RETFIELD+1];

  if (a_argc < 5)
  {
    fprintf(stderr, "%s", l_hlptxt);
    return 0;
  }
  querytext = a_argv[1];
  tablename = a_argv[2];
  bodyname  = a_argv[3];
  tsvname   = a_argv[4];
  size_t  l_nfields = a_argc - 5;
  if (l_nfields > MAX_RETFIELD) l_nfields = MAX_RETFIELD;
  for (size_t n = 0; n < l_nfields; ++n) {
    l_retfield[n] = a_argv[n+5];
  }
  parse_querytext(querytext, tablename, bodyname, tsvname, l_nfields, l_retfield);
  return 0;
} // main

