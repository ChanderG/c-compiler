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

statement : labeled_statement
            { }
	    //| compound_statement
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

*/
labeled_statement : IDENTIFIER COLON IDENTIFIER   //statement
                    { cout << "labeled_statement" << endl; }
		    | 
		    { }
		    ;

//compound_statement : ;
//expression_statement : ;
//selection_statement : ;
//iteration_statement : ;
//jump_statement : ;


%%
//main section - not required now
void yyerror(const char *s) {
  cout << "ERROR" << endl;
  // might as well halt now:
  exit(-1);
}
