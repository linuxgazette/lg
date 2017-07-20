;
;Module: MODULE IDENT';' [ImportList] DeclSeq [BEGIN StatementSeq] END IDENT'.'
;
Module:	match	MODULE
	match	IDENT
	match	SEMICOL
	skipif	IMPORT
	goto	noimport
	gosub	ImportList
noimport:
	gosub	DeclSeq
	skipif	BEGIN
	goto	nobody
	next
	gosub	StatementSeq
nobody:
	match	END
	match	IDENT
	match	PERIOD
	return
;
;ImportList : IMPORT {IDENT [ASSIGN IDENT] / ',' } ';'
;
ImportList:
	match	IMPORT
nextimport:
	match	IDENT
	skipif	ASSIGN
	goto	noassign
	next
	match	IDENT
noassign:
	skipif	COMMA
	goto	importend
	next
	goto	nextimport
importend:
	match	SEMICOL
	return
;
; DeclSeq : (CONST (IdentDef '=' ConstExpr ';')*
;            | TYPE (IdentDef '=' Type ';')* | VAR (IdentList ':' Type ';')*)*
;           (PROCEDURE [Receiver] IdentDef [FormalPars] ';' DeclSeq
;                                 [BEGIN StatementSeq] END IDENT ';'
;            | PROCEDURE '@' [Receiver] IdentDef [FormalPars] ';')*
;
DeclSeq:
	skipif	CONST
	goto	testype
	next
nextconst:
	skipif	IDENT
	goto	DeclSeq
	gosub	IdentDef
	match	EQ
	gosub	ConstExpr
	match	SEMICOL
	goto	nextconst
testype:
	skipif	TYPE
	goto	testvar
	next
nexttype:
	skipif	IDENT
	goto	DeclSeq
	gosub	IdentDef
	match	EQ
	gosub	Type
	match	SEMICOL
	goto	nexttype
testvar:
	skipif	VAR
	goto	testproc
	next
nextvar:
	skipif	IDENT
	goto	DeclSeq
	gosub	IdentList
	match	COLON
	gosub	Type
	match	SEMICOL
	goto	nextvar
testproc:
	skipif	PROCEDURE
	return
	next
	skipif	AT
	goto	procdecl
	next
	skipif	LPAR
	goto	identdef
	gosub	Receiver
identdef:
	gosub	IdentDef
	skipif	LPAR
	goto	testproc
	gosub	FormalPars
	goto	matchsemicol
procdecl:
	skipif	LPAR
	goto	identdef1
	gosub	Receiver
identdef1:
	gosub	IdentDef
	skipif	LPAR
	goto	matchdeclseq
	gosub	FormalPars
matchdeclseq:
	match	SEMICOL
	gosub	DeclSeq
matchsemicol:
	match	SEMICOL
	goto	testproc
;
; FormalPars : '(' [{[VAR] {IDENT / ','} ':' Type / ';'}] ')' [ ':' Qualident]
;
FormalPars:
	match	LPAR
	skipif	RPAR
	goto	fpsections
endfpsections:
	next
	skipif	COLON
	return
	next
	gosub	Qualident
	return
fpsections:
	skipif	VAR
	goto	idents
	next
idents:
	match	IDENT
	skipif	COMMA
	goto	matchcol
	next
	goto	idents
matchcol:
	match	COLON
	gosub	Type
	skipif	SEMICOL
	goto	endfpsections
	next
	goto	fpsections
;
; Receiver : '(' [VAR] IDENT ':' IDENT ')'
;
Receiver:
	match	LPAR
	skipif	VAR
	goto	ident
	next
ident:
	match	IDENT
	match	COLON
	match	IDENT
	match	RPAR
	return
;
;Type : Qualident | ARRAY '[' {ConstExpr / ','} ']' OF Type
;     | RECORD ['(' Qualident ')'] {[IdentList ':' Type] / ';'} END
;     | POINTER TO Type | PROCEDURE [FormalPars]
;
Type:
	skipif	IDENT
	goto	toarray
	gosub	Qualident
	return
toarray:
	skipif	ARRAY
	goto	torecord
	next
	match	LBR
nextindex:
	gosub	ConstExpr
	skipif	COMMA
	goto	endarray
	next
	goto	nextindex
endarray:
	match	RBR
	match	OF
	gosub	Type
	return
torecord:
	skipif	RECORD
	goto	topointer
	next
	skipif	LPAR
	goto	tofields
	next
	gosub	Qualident
	match	RPAR
tofields:
	skipif	SEMICOL
	goto	fieldlist
	next
	goto	tofields
fieldlist:
	skipif	IDENT
	goto	recordend
	gosub	IdentList
	match	COLON
	gosub	Type
	goto	tofields
recordend:
	match	END
	return
topointer:
	skipif	POINTER
	goto	toproc
	next
	match	TO
	gosub	Type
	return
toproc:
	match	PROCEDURE
	skipif	LPAR
	return
	gosub	FormalPars
	return
;
; StatementSeq : {[ Designator ASSIGN Expr
;                   | Designator ['(' [ExprList] ')']
;                   | IF Expr THEN StatementSeq (ELSIF Expr THEN StatementSeq)*
;                     [ELSE StatementSeq] END
;                   | CASE Expr OF
;                       {[{ConstExpr [RANGE ConstExpr] / ','}
;                         ':' StatementSeq] / '|'}
;                       [ELSE StatementSeq] END
;                   | WHILE Expr DO StatementSeq END
;                   | REPEAT StatementSeq UNTIL Expr
;                   | FOR IDENT ASSIGN Expr TO Expr [BY ConstExpr]
;                      DO StatementSeq END
;                   | LOOP StatementSeq END
;                   | WITH Guard DO StatementSeq ('|' Guard DO StatementSeq)*
;                      [ELSE StatementSeq] END
;                   | EXIT
;                   | RETURN
;                  ] / ';'}
;
StatementSeq:
	skipif	IDENT
	goto	if
	gosub	Designator
	skipif	ASSIGN
	goto	call
	next
	gosub	Expr
	goto	endstmt
call:
	skipif	LPAR
	goto	endstmt
	next
	skipif	RPAR
	gosub	ExprList
	match	RPAR
	goto	endstmt
if:
	skipif	IF
	goto	casestmt
	next
	gosub	Expr
	match	THEN
	gosub	StatementSeq
elseif:
	skipif	ELSEIF
	goto	else
	next
	gosub	Expr
	match	THEN
	gosub	StatementSeq
	goto	elseif	
else:
	skipif	ELSE
	goto	endif
	next
	gosub	StatementSeq
endif:
	match	END
	goto	endstmt
casestmt:
	skipif	CASE
	goto	while
	next
	gosub	Expr
	match	OF
	skipif	ELSE
	goto	noelse
elsecase:
	next
	gosub	StatementSeq
matchcaseend:
	match	END
	goto	endstmt
noelse:
	skipif	END
	goto	cases
	next
	goto	endstmt
cases:
	skipif	ALT
	goto	case
	next
	goto	cases
case:
	gosub	ConstExpr
	skipif	RANGE
	goto	nextcasexpr
	next
	gosub	ConstExpr
nextcasexpr:
	skipif	COMMA
	goto	casestmts
	next
	goto	case
casestmts:
	match	COLON
	gosub	StatementSeq
	skipif	ALT
	goto	endcase
	next
	goto	case
endcase:
	skipif	ELSE
	goto	matchcaseend
	goto	elsecase
while:
	skipif	WHILE
	goto	repeat
	next
	gosub	Expr
	match	DO
	gosub	StatementSeq
	match	END
	goto	endstmt
repeat:
	skipif	REPEAT
	goto	for
	next
	gosub	StatementSeq
	match	UNTIL
	gosub	Expr
	goto	endstmt
for:
	skipif	FOR
	goto	loop
	next
	match	IDENT
	match	ASSIGN
	gosub	Expr
	match	TO
	gosub	Expr
	skipif	BY
	goto	endfor
	next
	gosub	ConstExpr
endfor:
	match	DO
	gosub	StatementSeq
	match	END
	goto	endstmt
loop:
	skipif	LOOP
	goto	with
	next
	gosub	StatementSeq
	match	END
	goto	endstmt
with:
	skipif	WITH
	goto	exit
	next
	gosub	Guard
	match	DO
	gosub	StatementSeq
nextcase:
	skipif	ALT
	goto	elsewith
	next
	gosub	Guard
	match	DO
	gosub	StatementSeq
	goto	nextcase
elsewith:
	skipif	ELSE
	goto	endwith
	next
	gosub	StatementSeq
endwith:
	match	END	
	goto	endstmt
exit:
	skipif	EXIT
	goto	return
	next
	goto	endstmt
return:
	skipif	RETURN
	goto	endstmt
	next
endstmt:
	skipif	SEMICOL
	return
	next
	goto	StatementSeq
;
; Qualident : IDENT ['.' IDENT]
;
Qualident:
	match	IDENT
	skipif	PERIOD
	goto	nextident
	next
nextident:
	match	IDENT
	return
;
; IdentDef : IDENT ['*' | '-']
;
IdentDef:
	match	IDENT
	skipif	STAR
	goto	addminus
	next
        return
addminus:
	skipif	MINUS
	return
	next
        return
;
; Designator : IDENT ('.' IDENT | '['ExprList']' | '@' | '('Qualident ')')*
;
Designator:
	match	IDENT
descont:
	skipif	PERIOD
	goto	bracket
	next
	match	IDENT
	gosub	descont
bracket:
	skipif	LBR
	goto	at
	next
	gosub	ExprList
	match	RBR
	goto	descont
at:
	skipif	AT
	goto	par
	next
	goto	descont
par:
	skipif	LPAR
	return
	next
	gosub	Qualident
	match	RPAR
	goto	descont
;
; Expr : SimpleExpr [Relation SimpleExpr]
;
Expr:
ConstExpr:
	gosub	SimpleExpr
	skipif	EQ
	goto	ne
	goto	contexpr
ne:
	skipif	NE
	goto	lt
	goto	contexpr
lt:
	skipif	LT
	goto	le
	goto	contexpr
le:
	skipif	LE
	goto	gt
	goto	contexpr
gt:
	skipif	GT
	goto	ge
	goto	contexpr
ge:
	skipif	GE
	goto	in
	goto	contexpr
in:
	skipif	IN
	goto	is
	goto	contexpr
is:
	skipif	EQ
	return
contexpr:
	next
	gosub	SimpleExpr
	return
;
; SimpleExpr :  ['+' | '-']
;          {
;           { '~'* (Designator ['(' [ExprList] ')'] | NUMBER | CHARACTER
;                   | STRING | NIL | '{' [{Expr [RANGE Expr] / ','}] '}'
;                   | '(' Expr ')')
;            / ('*' | '/' | DIV | MOD | '&')}
;           / ('+' | '-' | OR)}
;
SimpleExpr:
	skipif	PLUS
	goto	minus
	next
	goto	term
	skipif	MINUS
	goto	term
	next
simple:
term:
	skipif	TILDA
	goto	factor
	next
	goto	term
factor:
	skipif	NUMBER
	goto	character
	next
	goto	contterm
character:
	skipif	CHARACTER
	goto	nil
	next
	goto	contterm
nil:
	skipif	NIL
	goto	string
	next
	goto	contterm
string:
	skipif	STRING
	goto	expr
	next
	goto	contterm
expr:
	skipif	LPAR
	goto	set
	next
	gosub	Expr
	match	RPAR
	goto	contterm
set:
	skipif	LFPAR
	goto	des
	next
	skipif	RFPAR
	goto	element
	next
	goto	contterm
element:
	gosub	Expr
	skipif	RANGE
	goto	endelement
	next
	gosub	Expr
endelement:
	skipif	COMMA
	goto	endset
	next
	goto	element
endset:
	match	RFPAR
	goto	contterm
des:
	gosub	Designator
	skipif	LPAR
	goto	contterm
	next
	skipif	RPAR
	goto	exprlist
	next
	goto	contterm
exprlist:
	gosub	ExprList
	match	RPAR
contterm:
	skipif	STAR
	goto	slash
	goto	contsimple
slash:
	skipif	SLASH
	goto	div
	goto	contsimple
div:
	skipif	DIV
	goto	mod
	goto	contsimple
mod:
	skipif	MOD
	goto	and
	goto	contsimple
and:
	skipif	AND
	goto	endsimple
contsimple:
	next
	goto	term
endsimple:
	skipif	PLUS
	goto	minus
	goto	contsimple
minus:
	skipif	MINUS
	goto	or
	goto	contsimple
or:
	skipif	OR
	return
	next
	goto	simple
;
; IdentList : {IdentDef / ','}
;
IdentList:
	gosub	IdentDef
	skipif	COMMA
	return
	next
	goto	IdentList
;
; ExprList : {Expr / ','}
;
ExprList:
	gosub	Expr
	skipif	COMMA
	return
	next
	goto	ExprList
;
; Guard : Qualident ':' Qualident
;
Guard:
 gosub Qualident
 match COLON
 gosub Qualident
 return
