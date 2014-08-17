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
  int ival;
}

%token <sval> KEYWORD
%token <sval> IDENTIFIER
%token <ival> INTEGER_CONSTANT
%token SIGN //not sure of value : cval??

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
