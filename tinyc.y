//ChanderG - chandergovind@gmail.com 
%{
  #include<iostream>
  using namespace std;

  extern int yylex();  
  void yyerror(const char *s);
  //int yywrap(){
  //  return 0;
  //}
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
%token <cval> SIGN //not sure of value : cval??

%%
//rules section
token: IDENTIFIER
       ;

%%
//main section - not required now
void yyerror(const char *s) {
  cout << "EEK, parse error" << endl;
  // might as well halt now:
  exit(-1);
}
