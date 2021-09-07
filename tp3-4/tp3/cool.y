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

%type <expression> expression
%type <expressions> expression_params

/* Precedence declarations go here. */


%%
/*
  Definition of program:
    - We are going to save the root of the abstract syntax tree in a global variable.
*/
program
  : class_list
    {
      @$ = @1;
      ast_root = program($1);
    }
  ;

/*
  Definition of class_list:
    - A class list can be either a single class or literally a list of classes.
*/
class_list
  : class
    {
      $$ = single_Classes($1);
      parse_results = $$;
    }
  | class_list class
    {
      $$ = append_Classes($1, single_Classes($2));
      parse_results = $$;
    }
  ;

/*
  Definition of a COOL class:
  - By default, a COOL class will inherit from Object.
  - But, it can optionally inherit from another class.

  Note that a COOL class must terminate with a ;
*/
class
  : CLASS TYPEID '{' feature_list '}' ';'
    {
      $$ = class_($2, idtable.add_string("Object"), $4, stringtable.add_string(curr_filename));
    }
  | CLASS TYPEID INHERITS TYPEID '{' feature_list '}' ';'
    {
      $$ = class_($2, $4, $6, stringtable.add_string(curr_filename));
    }
  ;

/*
  Definition of a COOL feature list:
    - We can have a list of 1 or more features.
    - Or we can have no features!
*/
feature_list
  : feature_list feature
    {
      $$ = append_Features($1, single_Features($2));
    }
  | /* empty */
    {
      $$ = nil_Features();
    }
  ;

/*
  Definition of a COOL feature:
    - A feature can either be a method or an attribution.
    - Notice that the attribution can optionally have an assignment.

  Note that a COOL feature must terminate with a ;
*/
feature
  : OBJECTID '(' formal_params ')' ':' TYPEID '{' expression '}' ';'
    {
      $$ = method($1, $3, $6, $8) ;
    }
  | OBJECTID ':' TYPEID ';'
    {
      $$ = attr($1, $3, no_expr());
    }
  | OBJECTID ':' TYPEID ASSIGN expression ';'
    {
      $$ = attr($1, $3, $5);
    }
  ;

/*
  Definition of a formal list:
    - We can have only one formal.
    - If we have more than one, we must separate them by ','.
    - Notice that we can also have an empty list!!
*/
formal_params
  : formal
    {
      $$ = single_Formals($1);
    }
  | formal_params ',' formal
    {
      $$ = append_Formals($1, single_Formals($3));
    }
  | /* empty */
    {
      $$ = nil_Formals();
    }
  ;

/* Definition of a formal */
formal
  : OBJECTID ':' TYPEID
    {
      $$ = formal($1, $3);
    }
  ;

/*
  Definition of a COOL expression:
    1. An expression can be an assign.
    2. Can be a dispatch.
    3. Can be a static dispatch.
    4. Can be a method call.
*/
expression
  : OBJECTID ASSIGN expression
    {
      $$ = assign($1, $3);
    }
  | expression '.' OBJECTID '(' expression_params ')'
    {
      $$ = dispatch($1, $3, $5);
    }
  | expression '@' TYPEID '.' OBJECTID '(' expression_params ')'
    {
      $$ = static_dispatch($1, $3, $5, $7);
    }
  | OBJECTID '(' expression_params ')'
    {
      $$ = dispatch(no_expr(), $1, $3);
    }
  | NEW TYPEID
    {
      $$ = new_($2);
    }
  | OBJECTID
    {
      $$ = object($1);
    }
  | STR_CONST
    {
      $$ = string_const($1);
    }
  ;

/*
  Definition of expression parameters.
    - We can have only one expression.
    - If we have more than one, we must separate them by ','.
    - Notice that we can also have an empty list!!
*/
expression_params
  : expression
    {
      $$ = single_Expressions($1);
    }
  | expression_params ',' expression
    {
      $$ = append_Expressions($1, single_Expressions($3));
    }
  | /* empty */
    {
      $$ = nil_Expressions();
    }
  ;

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

