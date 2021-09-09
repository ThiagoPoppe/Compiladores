/*
 *  cool.y
 *              Parser definition for the COOL language.
 *
 */
%{
#include <iostream>
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

#define YYLTYPE int
#define cool_yylloc curr_lineno

extern char *curr_filename;
extern int node_lineno;

#define YYLLOC_DEFAULT(Current, Rhs, N) \
  Current = node_lineno = Rhs[1];

void yyerror(char *s);        /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */

/************************************************************************/
/*                DONT CHANGE ANYTHING IN THIS SECTION                  */

Program ast_root;	      /* the result of the parse  */
Classes parse_results;        /* for use in semantic analysis */
int omerrs = 0;               /* number of errors in lexing and parsing */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
  Boolean boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature;
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
  char *error_msg;
}

/* 
   Declare the terminals; a few have types for associated lexemes.
   The token ERROR is never used in the parser; thus, it is a parse
   error when the lexer returns it.

   The integer following token declaration is the numeric constant used
   to represent that token internally.  Typically, Bison generates these
   on its own, but we give explicit numbers to prevent version parity
   problems (bison 1.25 and earlier start at 258, later versions -- at
   257)
*/
%token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
%token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
%token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
%token <symbol>  STR_CONST 275 INT_CONST 276 
%token <boolean> BOOL_CONST 277
%token <symbol>  TYPEID 278 OBJECTID 279 
%token ASSIGN 280 NOT 281 LE 282 ERROR 283

/*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
/**************************************************************************/
 
   /* Complete the nonterminal list below, giving a type for the semantic
      value of each non terminal. (See section 3.6 in the bison 
      documentation for details). */

/* Declare types for the grammar's non-terminals. */
%type <program> program

%type <class_> class
%type <classes> class_list

%type <feature> feature
%type <features> feature_list

%type <formal> formal
%type <formals> formal_params

%type <case_> case
%type <cases> case_list

%type <expression> expression
%type <expression> let_expression
%type <expressions> expression_list
%type <expressions> expression_params

/* This terminal will be used to remove the ambiguity of let expressions */
%token LET_

/* Precedence declarations go here. */
%left LET_
%right ASSIGN
%left NOT
%nonassoc LE '<' '='
%left '+' '-'
%left '*' '/'
%left ISVOID
%left '~'
%left '@'
%left '.'

%%

/* --- Defining program non terminal ---  */
/* We are going to save the root of the abstract syntax tree in a global variable */
program : class_list {
    @$ = @1;
    ast_root = program($1);
};

/* --- Defining class_list non terminal --- */
class_list : class ';' {
    /* a single class */
    $$ = single_Classes($1);
    parse_results = $$;
}
| class_list class ';' {
    /* at least one class */
    $$ = append_Classes($1, single_Classes($2));
    parse_results = $$;
}
| class_list error ';' { /* if a class is incorrect we can still process other ones */ };

/* --- Defining class non terminal --- */
class : CLASS TYPEID '{' feature_list '}' {
    /* by default a COOL class will inherit from Object */
    Entry *object = idtable.add_string((char*) "Object");
    $$ = class_($2, object, $4, stringtable.add_string(curr_filename));
}
| CLASS TYPEID INHERITS TYPEID '{' feature_list '}' {
    $$ = class_($2, $4, $6, stringtable.add_string(curr_filename));
};

/* --- Defining feature_list non terminal --- */
feature_list : feature_list feature ';' {
    $$ = append_Features($1, single_Features($2));
}
| /* empty list */ {
    $$ = nil_Features();
}
| feature_list error ';' { /* if a feature is incorrect we can still process other ones */ };

/* --- Defining feature non terminal --- */
feature : OBJECTID '(' formal_params ')' ':' TYPEID '{' expression '}' {
    /* feature as method */
    $$ = method($1, $3, $6, $8);
}
| OBJECTID ':' TYPEID {
    /* feature as member declaration */
    $$ = attr($1, $3, no_expr());
}
| OBJECTID ':' TYPEID ASSIGN expression {
    /* feature as member declaration and assign */
    $$ = attr($1, $3, $5);
};

/* --- Defining formal_params non terminal --- */
formal_params : formal {
    /* single formal */
    $$ = single_Formals($1);
}
| formal_params ',' formal {
    /* multiple formals (separated by ',') */
    $$ = append_Formals($1, single_Formals($3));
}
| /* empty list */ {
    $$ = nil_Formals();
};

/* --- Defining formal non terminal --- */
formal : OBJECTID ':' TYPEID {
    $$ = formal($1, $3);
};

/* --- Defining expression non terminal --- */
expression : OBJECTID ASSIGN expression {
    /* assign expression */
    $$ = assign($1, $3);
}
| expression '.' OBJECTID '(' expression_params ')' {
    /* non static dispatch */
    $$ = dispatch($1, $3, $5);
}
| expression '@' TYPEID '.' OBJECTID '(' expression_params ')' {
    /* static dispatch */
    $$ = static_dispatch($1, $3, $5, $7);
}
| OBJECTID '(' expression_params ')' {
    /* method call */
    Entry *self = idtable.add_string((char*) "self");
    $$ = dispatch(object(self), $1, $3);
}
| IF expression THEN expression ELSE expression FI {
    /* conditional expression */
    $$ = cond($2, $4, $6);
}
| WHILE expression LOOP expression POOL {
    /* loop expression */
    $$ = loop($2, $4);
}
| '{' expression_list '}' {
    /* block of expressions */
    $$ = block($2);
}
| LET let_expression {
    /* let_expression is an auxiliar non terminal */
    $$ = $2;
}
| CASE expression OF case_list ESAC {
    /* case expression */
    $$ = typcase($2, $4);
}
| NEW TYPEID {
    /* new expression */
    $$ = new_($2);
}
| ISVOID expression {
    /* isvoid expression */
    $$ = isvoid($2);
}
| expression '+' expression {
    /* plus expression */
    $$ = plus($1, $3);
}
| expression '-' expression {
    /* sub expression */
    $$ = sub($1, $3);
}
| expression '*' expression {
    /* mul expression */
    $$ = mul($1, $3);
}
| expression '/' expression {
    /* divide expression */
    $$ = divide($1, $3);
}
| '~' expression {
    /* integer compliment expression */
    $$ = neg($2);
}
| expression '<' expression {
    /* less than expression */
    $$ = lt($1, $3);
}
| expression LE expression {
    /* less than or equal expression */
    $$ = leq($1, $3);
}
| expression '=' expression {
    /* equality expression */
    $$ = eq($1, $3);
}
| NOT expression {
    /* boolean compliment expression */
    $$ = comp($2);
}
| '(' expression ')' {
    $$ = $2;
}
| OBJECTID {
    /* expression as an ID */
    $$ = object($1);
}
| INT_CONST {
    /* expression as an integer constant */
    $$ = int_const($1);
}
| STR_CONST {
    /* expression as a string constant */
    $$ = string_const($1);
}
| BOOL_CONST {
    /* expression as a boolean constant */
    $$ = bool_const($1);
};

/* --- Defining case non terminal --- */
case : OBJECTID ':' TYPEID DARROW expression {
    $$ = branch($1, $3, $5);
};

/* --- Defining case_list non terminal --- */
case_list : case ';' {
    /* single case branch */
    $$ = single_Cases($1);
}
| case_list case ';' {
    /* multiple case branches */
    $$ = append_Cases($1, single_Cases($2));
};

/* --- Defining expression_params non terminal --- */
expression_params : expression {
    /* single expression */
    $$ = single_Expressions($1);
}
| expression_params ',' expression {
    /* multiple expressions (separated by ',') */
    $$ = append_Expressions($1, single_Expressions($3));
}
| /* empty list */ {
    $$ = nil_Expressions();
};

/* --- Defining expression_list non terminal --- */
expression_list : expression ';' {
    /* single expression */
    $$ = single_Expressions($1);
}
| expression_list expression ';' {
    /* multiple expressions */
    $$ = append_Expressions($1, single_Expressions($2));
}
| expression_list error ';' { /* if an expression is incorrect we can still process other ones */ };

/* --- Defining let_expression non terminal --- */
let_expression : OBJECTID ':' TYPEID IN expression %prec LET_ {
    /* let expression with no initialization */
    $$ = let($1, $3, no_expr(), $5);
}
| OBJECTID ':' TYPEID ASSIGN expression IN expression %prec LET_ {
    /* let expression with initialization */
    $$ = let($1, $3, $5, $7);
}
| OBJECTID ':' TYPEID ',' let_expression {
    /* nested let expressions where the first id has no initialization */
    $$ = let($1, $3, no_expr(), $5);
}
| OBJECTID ':' TYPEID ASSIGN expression ',' let_expression {
    /* nested let expressions where the first id has an initialization */
    $$ = let($1, $3, $5, $7);
}
| error ',' let_expression { /* if a declaration is incorrect we can still process other ones */ };

/* end of grammar */

%%

/* This function is called automatically when Bison detects a parse error. */
void yyerror(char *s)
{
  extern int curr_lineno;

  cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
    << s << " at or near ";
  print_cool_token(yychar);
  cerr << endl;
  omerrs++;

  if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
}