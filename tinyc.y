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

		

/*
selection_statement :{} ;
iteration_statement :{} ;
jump_statement :{} ;
*/




constant_expression: {};



%%
//main section - not required now
void yyerror(const char *s) {
  cout << "ERROR" << endl;
  // might as well halt now:
  exit(-1);
}
