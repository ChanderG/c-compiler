//ChanderG - chandergovind@gmail.com 
%{
  #include<iostream>
  using namespace std;

  extern int yylex();  
  void yyerror(const char *s);

  #include"lexmain.h"

  #include<cstring>  //for strdup
 
%}
%union {
  char* sval;
  char cval;
  int ival;
  float fval;

  struct ts_ {    // for type_specifier
    char *type;
    int width;
  } ts; 

}

%token <sval> IDENTIFIER
%token <ival> INTEGER_CONSTANT
%token <fval> FLOATING_CONSTANT
%token <cval> CHARACTER_CONSTANT
%token <sval> STRING_LITERAL
%token <sval> SINGLE_LINE_COMMENT
%token <sval> MULTI_LINE_COMMENT

%type <ts> type_specifier

%token WS

%token COLON
%token SEMI_COLON

%token CASE
%token DEFAULT

%token CURLY_OPEN
%token CURLY_CLOSE

%token PARAN_OPEN
%token PARAN_CLOSE

%token SQ_OPEN SQ_CLOSE

%token IF ELSE SWITCH FOR
%token WHILE DO
%token GOTO CONTINUE BREAK RETURN
%token COMMA EQUAL

%token EXTERN STATIC AUTO REGISTER
%token VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED _BOOL _COMPLEX _IMAGINARY

%token ENUM

%token CONST RESTRICT VOLATILE

%token INLINE

%token STAR ELIPSIS DOT

%token DEREF

%token INC DEC
%token SIZEOF

%token PLUS MINUS TILDE EX

%token AND OR

%token BY MOD
%token SL SR
%token LT GT LTE GTE E NE

%token CAP
%token Q
%token ANDAND OROR
%token STAREQUAL BYEQUAL MODEQUAL PLUSEQUAL MINUSEQUAL SLEQUAL SREQUAL ANDEQUAL CAPEQUAL OREQUAL

//associativity rules

%nonassoc LOWER_THAN_ELSE
%nonassoc  ELSE

//takes care of just the binary operators
%left PLUS MINUS
%left STAR RIGHT
%nonassoc UPLUS UMINUS
%nonassoc USTAR
%nonassoc U



%%
//rules section - for now printing correct is used

translation_unit: { cout << "Symboltable created" << endl; 
                    symboltable global;
		  }
		  external_declaration 
                  { }
                  | translation_unit external_declaration
		  { }
		  ;

external_declaration : function_definition
                       { }
		       | declaration
		       { //cout << "Declaration" << endl;
		       }
		       ;

function_definition : declaration_specifiers declarator declaration_list_opt compound_statement
                      { } 
		      ;

declaration_list_opt : declaration_list 
                       { }
		       | epsilon
		       ;
epsilon : ;   //epsilon transition

declaration_list : declaration
                   { }
		   | declaration_list declaration
		   { }
		   ;

statement : labeled_statement
            { }
	    | compound_statement
	    { }
	    | expression_statement
	    { }
	    | selection_statement
	    { }
            | iteration_statement
	    { }
            | jump_statement
	    { }
            ; 


labeled_statement : IDENTIFIER COLON statement
                    { //cout << "labeled_statement" << endl;
		    }
		    | CASE constant_expression COLON statement 
		    { //cout << "labeled_statement" << endl;
		    }
		    | DEFAULT COLON statement
		    { //cout << "labeled_statement" << endl;
		    }
		    ;

//This block w/ epsilon has been replaced by one without, but no change is observed.

/*
compound_statement : CURLY_OPEN block_item_list_opt CURLY_CLOSE 
                     {};

block_item_list_opt: epsilon
                     | block_item_list
		     { }
		     ;
*/

//start
compound_statement : CURLY_OPEN block_item_list CURLY_CLOSE 
                     {}
		     |
                     CURLY_OPEN CURLY_CLOSE 
                     {}
		     ;
//ends

block_item_list: block_item
                 {}
		 | block_item_list block_item
		 {}
		 ;

block_item: statement 
            {}
	    | declaration
	    {}
	    ;

expression_statement: expression_opt SEMI_COLON
                      {}
		      ;

expression_opt: epsilon
                | expression
		{}
		;

selection_statement : IF PARAN_OPEN expression PARAN_CLOSE statement %prec LOWER_THAN_ELSE
                      {} 
		      | IF PARAN_OPEN expression PARAN_CLOSE statement ELSE statement
                      {}
		      | SWITCH PARAN_OPEN expression PARAN_CLOSE statement
		      {}
		      ;
iteration_statement : WHILE PARAN_OPEN expression PARAN_CLOSE statement
                      {} 
		      | DO statement WHILE PARAN_OPEN expression PARAN_CLOSE SEMI_COLON
		      {}
		      | FOR PARAN_OPEN expression_opt SEMI_COLON expression_opt SEMI_COLON expression_opt PARAN_CLOSE statement
		      { }
		      | FOR PARAN_OPEN declaration SEMI_COLON expression_opt SEMI_COLON expression_opt PARAN_CLOSE statement
		      {}
		      ;

jump_statement : GOTO IDENTIFIER SEMI_COLON
                 {} 
		 | CONTINUE SEMI_COLON
		 {}
		 | BREAK SEMI_COLON
		 {}
		 | RETURN expression_opt SEMI_COLON
		 {}
		 ;

constant_expression: {};


//Section 2: Declarations

declaration: declaration_specifiers init_declarator_list_opt SEMI_COLON
             {}
	     ;

declaration_specifiers_opt:  declaration_specifiers | epsilon;

declaration_specifiers: //storage_class_specifier declaration_specifiers_opt
			type_specifier declaration_specifiers_opt
			{}
	                //| type_qualifier declaration_specifiers_opt
			//| function_specifier declaration_specifiers_opt
			;


init_declarator_list_opt: epsilon
                          | init_declarator_list
			  { }
			  ;

init_declarator_list: init_declarator
                      {}
		      |
		      init_declarator_list COMMA init_declarator
		      ;
		      
init_declarator: declarator  
                 {}
		 | declarator EQUAL initializer
		 ;

//storage_class_specifier: EXTERN | STATIC | AUTO | REGISTER;

type_specifier: VOID | CHAR | // SHORT |
                INT 
		{ //next
                  $$.type = strdup("integer"); $$.width = 4; 
		}
		|// LONG | FLOAT |
		DOUBLE 
		//| SIGNED | UNSIGNED | _BOOL | _COMPLEX | _IMAGINARY | enum_specifier;
                ; 

specifier_qualifier_list: type_specifier specifier_qualifier_list_opt
                          | type_qualifier specifier_qualifier_list_opt
			  ;

specifier_qualifier_list_opt: epsilon | specifier_qualifier_list;

/*
enum_specifier: ENUM identifier_opt CURLY_CLOSE  
                | ENUM identifier_opt_w_comma CURLY_CLOSE  
		| ENUM IDENTIFIER
		;
*/

identifier_opt: IDENTIFIER CURLY_OPEN enumerator_list | epsilon CURLY_OPEN enumerator_list;

identifier_opt_w_comma: IDENTIFIER CURLY_OPEN enumerator_list COMMA | epsilon CURLY_OPEN enumerator_list COMMA;

enumerator_list: enumerator
                 | enumerator_list COMMA enumerator
		 ;

enumerator: enumeration_constant
            | enumeration_constant EQUAL constant_expression
	    ;
	    
enumeration_constant: IDENTIFIER;

//type_qualifier: CONST | RESTRICT | VOLATILE;

//function_specifier: INLINE;

declarator: pointer_opt direct_declarator;

pointer_opt: epsilon| pointer;

direct_declarator: IDENTIFIER
                   | PARAN_OPEN declarator PARAN_CLOSE 
		   | direct_declarator SQ_OPEN type_qualifier_list_opt assignment_expression_opt SQ_CLOSE 
		   | direct_declarator SQ_OPEN STATIC type_qualifier_list_opt assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list STATIC assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list_opt STAR SQ_CLOSE
		   | direct_declarator PARAN_OPEN param_or_identi PARAN_CLOSE
		   ;

param_or_identi: parameter_type_list | identifier_list_opt;


type_qualifier_list_opt: epsilon | type_qualifier_list;
assignment_expression_opt: epsilon | assignment_expression;
identifier_list_opt: epsilon | identifier_list;

pointer: STAR type_qualifier_list_opt pointer_opt;
       //  | STAR type_qualifier_list_opt pointer

type_qualifier_list: type_qualifier
                     | type_qualifier_list type_qualifier
                     ;

parameter_type_list: parameter_list
                     | parameter_list COMMA ELIPSIS
		     ;

parameter_list: parameter_declaration
                | parameter_list COMMA parameter_declaration
		;

parameter_declaration: declaration_specifiers declarator
                       | declaration_specifiers
		       ;

identifier_list: IDENTIFIER
                 | identifier_list COMMA IDENTIFIER
		 ;

type_name: specifier_qualifier_list;

initializer: assignment_expression 
             | CURLY_OPEN initializer_list CURLY_CLOSE
	     | CURLY_OPEN initializer_list COMMA CURLY_CLOSE
	     ;

initializer_list: designation_opt initializer
                  | initializer_list COMMA designation_opt initializer
		  ;

designation_opt: epsilon | designation;

designation: designator_list EQUAL;

designator_list: designator 
                 | designator_list designator
		 ;

designator: SQ_OPEN constant_expression SQ_CLOSE
            | DOT IDENTIFIER
	    ;

//Section 1: Expressions
primary_expression: IDENTIFIER
                    { cout << $1 << endl; }
		    | constant | STRING_LITERAL | PARAN_OPEN expression PARAN_CLOSE;

constant:  INTEGER_CONSTANT | FLOATING_CONSTANT | CHARACTER_CONSTANT;

postfix_expression: primary_expression 
                   |
		   postfix_expression SQ_OPEN expression SQ_CLOSE
		   |
		   postfix_expression PARAN_OPEN argument_expression_list_opt PARAN_CLOSE
		   |
                   postfix_expression DOT IDENTIFIER
		   | 
		   postfix_expression DEREF IDENTIFIER
		   | 
		   postfix_expression INC
                   | 
		   postfix_expression DEC
		   | 
		   PARAN_OPEN type_name PARAN_CLOSE CURLY_OPEN initializer_list CURLY_CLOSE
		   |
		   PARAN_OPEN type_name PARAN_CLOSE CURLY_OPEN initializer_list COMMA CURLY_CLOSE;

argument_expression_list_opt: epsilon | argument_expression_list;

argument_expression_list: assignment_expression
                          | argument_expression_list COMMA assignment_expression
			  ;

unary_expression: postfix_expression 
                  | INC unary_expression
		  | DEC unary_expression
		  | unary_operator cast_expression %prec U
		  | SIZEOF unary_expression
		  | SIZEOF PARAN_OPEN type_name PARAN_CLOSE %prec U
		  ;

unary_operator: AND | STAR | PLUS | MINUS | TILDE | EX;

cast_expression: unary_expression
                 | PARAN_OPEN type_name PARAN_CLOSE cast_expression
		 ;

multiplicative_expression: cast_expression
                           | multiplicative_expression STAR cast_expression
			   | multiplicative_expression BY cast_expression
			   | multiplicative_expression MOD cast_expression
			   ;

additive_expression: multiplicative_expression
                     | additive_expression PLUS multiplicative_expression
		     | additive_expression MINUS multiplicative_expression
		     ;

shift_expression: additive_expression
                  | shift_expression SL additive_expression
		  | shift_expression SR additive_expression
		  ;

relational_expression: shift_expression
                       | relational_expression LT shift_expression
                       | relational_expression GT shift_expression
                       | relational_expression LTE shift_expression
                       | relational_expression GTE shift_expression
		       ;

equality_expression: relational_expression
                     | equality_expression E relational_expression
		     | equality_expression NE relational_expression
		     ;

and_expression: equality_expression
                | and_expression AND equality_expression
		;

exclusive_or_expression: and_expression
               | exclusive_or_expression CAP equality_expression
	       ;

inclusive_or_expression: exclusive_or_expression
                         | inclusive_or_expression OR exclusive_or_expression
			 ;

logical_and_expression: inclusive_or_expression
                        | logical_and_expression ANDAND inclusive_or_expression
			;

logical_or_expression: logical_and_expression 
                       | logical_or_expression OROR logical_and_expression
		       ;

conditional_expression: logical_or_expression
                        | logical_or_expression Q expression COLON conditional_expression
			;

assignment_expression: conditional_expression 
                       | unary_expression assignment_operator assignment_expression
		       ;

assignment_operator: EQUAL | STAREQUAL | BYEQUAL | MODEQUAL | PLUSEQUAL | MINUSEQUAL | SLEQUAL | SREQUAL | ANDEQUAL | CAPEQUAL | OREQUAL;

expression: assignment_expression
            | expression COMMA assignment_expression
	    ;

constant_expression: conditional_expression;

%%
//main section - not required now
void yyerror(const char *s) {
  //cout << "ERROR" << endl;
  cout << s << endl;
  // might as well halt now:
  //exit(-1);
}
