
#define MODULE	1
#define IDENT	2
#define SEMICOL	3
#define IMPORT	4
#define BEGIN	5
#define END	6
#define PERIOD	7
#define ASSIGN	8
#define COMMA	9
#define CONST	10
#define EQ	11
#define TYPE	12
#define VAR	13
#define COLON	14
#define PROCEDURE	15
#define AT	16
#define LPAR	17
#define RPAR	18
#define ARRAY	19
#define LBR	20
#define RBR	21
#define OF	22
#define RECORD	23
#define POINTER	24
#define TO	25
#define IF	26
#define THEN	27
#define ELSEIF	28
#define ELSE	29
#define CASE	30
#define ALT	31
#define RANGE	32
#define WHILE	33
#define DO	34
#define REPEAT	35
#define UNTIL	36
#define FOR	37
#define BY	38
#define LOOP	39
#define WITH	40
#define EXIT	41
#define RETURN	42
#define STAR	43
#define MINUS	44
#define NE	45
#define LT	46
#define LE	47
#define GT	48
#define GE	49
#define IN	50
#define PLUS	51
#define TILDA	52
#define NUMBER	53
#define CHARACTER	54
#define NIL	55
#define STRING	56
#define LFPAR	57
#define RFPAR	58
#define SLASH	59
#define DIV	60
#define MOD	61
#define AND	62
#define OR	63

extern int yylex ();
extern int yyerror ();


extern int yyparse ();

#ifndef YYCALLSTACK_SIZE
#define YYCALLSTACK_SIZE 50
#endif
