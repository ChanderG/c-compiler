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

%%
//rules section - empty for now
token:  ;

%%
//main section - not required now
void yyerror(const char *s) {
  cout << "EEK, parse error" << endl;
  // might as well halt now:
  exit(-1);
}
