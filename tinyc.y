//ChanderG - chandergovind@gmail.com 
%{
  #include<iostream>
  using namespace std;

  extern int yylex();  
  void yyerror(const char *s);
%}
%union {
  char* sval;
  char cval;
  int ival;
  float fval;
}

%token <sval> KEYWORD
%token <sval> IDENTIFIER
%token <ival> INTEGER_CONSTANT
%token <fval> FLOATING_CONSTANT
%token <cval> CHARACTER_CONSTANT
%token <sval> STRING_LITERAL
%token <cval> SIGN 
%token <cval> PUNCTUATOR 
%token <sval> SINGLE_LINE_COMMENT
%token <sval> MULTI_LINE_COMMENT

%token COLON
%token SEMI_COLON

%token CASE
%token DEFAULT

%token CURLY_OPEN
%token CURLY_CLOSE

%token PARAN_OPEN
%token PARAN_CLOSE

%token SQ_OPEN, SQ_CLOSE

%token IF
%token ELSE
%token SWITCH
%token FOR

%token WHILE
%token DO

%token GOTO
%token CONTINUE
%token BREAK
%token RETURN

%token COMMA
%token EQUAL

%token EXTERN, STATIC, AUTO, REGISTER
%token VOID , CHAR , SHORT , INT , LONG , FLOAT , DOUBLE , SIGNED , UNSIGNED, _BOOL, _COMPLEX, _IMAGINARY;

%token ENUM

%token CONST, RESTRICT, VOLATILE

%token INLINE

%token STAR, ELIPSIS, DOT

%%
//rules section - for now printing correct is used

/*
translation_unit: external_declaration 
                  { cout << "Correct" << endl; }
                  | translation_unit external_declaration
		  { }
		  ;

external_declaration : function_definition
                       { }
		       | declaration
		       { }
		       ;

function_definition : declaration_specifiers declarator declaration_list_opt compound_statement
                      { } 
		      ;

declaration_list_opt : declaration_list 
                       { }
		       | epsilon
		       { }
		       ;
epsilon : ;   //epsilon transition

declaration_list : declaration
                   { }
		   | declaration_list declaration
		   { }
		   ;

*/
program: labeled_statement
         { }
	 | program labeled_statement 
	 { }
	 ;

statement : labeled_statement
            { }
	   // | compound_statement
	   // { }
	   // | expression_statement
	   // { }
	   // | selection_statement
	   // { }
           // | iteration_statement
	   // { }
           // | jump_statement
	   // { }
            ; 


labeled_statement : IDENTIFIER COLON statement
                    { cout << "labeled_statement" << endl; }
		    | CASE constant_expression COLON statement 
		    { cout << "labeled_statement" << endl; }
		    | DEFAULT COLON statement
		    { cout << "labeled_statement" << endl; }
		    ;

compound_statement : CURLY_OPEN block_item_list_opt CURLY_CLOSE 
                     {};

block_item_list_opt: epsilon
                     | block_item_list
		     { }
		     ;

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

selection_statement : IF PARAN_OPEN expression PARAN_CLOSE statement
                      {} 
		      | IF PARAN_OPEN expression PARAN_CLOSE statement ELSE statement
                      {}
		      | SWITCH PARAN_CLOSE expression PARAN_CLOSE statement
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

declaration: declaration_specifiers init_declarator_list_opt
             {}
	     ;

declaration_specifiers_opt: epsilon
                            | declaration_specifiers
                            { }
			    ;

declaration_specifiers: storage_class_specifier declaration_specifiers_opt
                        {}
			| type_specifier declaration_specifiers_opt
			{}
			| type_qualifier declaration_specifiers_opt
                        {}
			| function_specifier declaration_specifiers_opt
                        {}
			;

init_declarator_list_opt: epsilon
                          | init_declarator_list
			  { }
			  ;

init_declarator_list: init_declarator
                      {}
		      |
		      init_declarator_list COMMA init_declarator
		      
init_declarator: declarator
                 {}
		 | declarator EQUAL initializer

storage_class_specifier: EXTERN
                         {}
			 | STATIC
			 {}
			 | AUTO
			 {}
			 | REGISTER
			 {}
			 ;

type_specifier: VOID | CHAR | SHORT | INT | LONG | FLOAT | DOUBLE | SIGNED | UNSIGNED | _BOOL | _COMPLEX | _IMAGINARY | enum_specifier;

specifier_qualifier_list: type_specifier specifier_qualifier_list_opt
                          | type_qualifier specifier_qualifier_list_opt

specifier_qualifier_list_opt: epsilon | specifier_qualifier_list;

enum_specifier: ENUM identifier_opt CURLY_OPEN enumerator_list  CURLY_CLOSE  
                | ENUM identifier_opt CURLY_OPEN enumerator_list COMMA  CURLY_CLOSE  
		| ENUM IDENTIFIER
		;

identifier_opt: epsilon | IDENTIFIER;

enumerator_list: enumerator
                 | enumerator_list COMMA enumerator

enumerator: enumeration_constant
            | enumeration_constant EQUAl constant_expression
	    ;
	    
type_qualifier: CONST
                | RESTRICT
		| VOLATILE
		;

function_specifier: INLINE;

declarator: pointer_opt direct_declarator;

pointer_opt: epsilon| pointer;

direct_declarator: IDENTIFIER
                   | PARAN_OPEN declarator PARAN_CLOSE 
		   | direct_declarator SQ_OPEN type_qualifier_list_opt assignment_expression_opt SQ_CLOSE 
		   | direct_declarator SQ_OPEN STATIC type_qualifier_list_opt assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list STATIC assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list_opt STAR SQ_CLOSE
		   | direct_declarator PARAN_OPEN parameter_type_list PARAN_CLOSE
		   | direct_declarator PARAN_OPEN identifier_list_opt PARAN_CLOSE


type_qualifier_list_opt: epsilon | type_qualifier_list;
assignment_expression_opt: epsilon | assignment_expression;
identifier_list_opt: epsilon | identifier_list;

pointer: STAR type_qualifier_list_opt
         | STAR type_qualifier_list_opt pointer

type_qualifier_list: type_qualifier
                     | type_qualifier_list type_qualifier
                     ;

parameter_type_list: parameter_list
                     | parameter_list COMMA ELIPSIS

parameter_list: parameter_declaration
                | parameter_list COMMA parameter_declaration
		;

parameter_declaration: declaration_specifiers declarator
                       | declaration_specifiers
		       ;

identifier_list: identifier
                 | identifier_list COMMA identifier
		 ;

type_name: specifier_qualifier_list;

initializer: assignment_expression 
             | CURLY_OPEN initializer_list CURLY_CLOSE
	     | CURLY_OPEN initializer_list COMMA CURLY_CLOSE
	     ;

initializer_list: designation_opt initializer
                  | initializer_list COMMA designation_opt initializer

designation_opt: epsilon | designation;

designation: designator_list EQUAL;

designator_list: designator 
                 | designator_list designator
		 ;

designator: SQ_OPEN constant_expression SQ_CLOSE
            | DOT IDENTIFIER
	    ;

%%
//main section - not required now
void yyerror(const char *s) {
  cout << "ERROR" << endl;
  // might as well halt now:
  exit(-1);
}
