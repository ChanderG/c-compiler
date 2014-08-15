//ChanderG - chandergovind@gmail.com 
%{
  #include<iostream>
  using namespace std;

  extern int yylex();  
  void yyerror(const char *s);
%}
%union {
  char* sval;
}

%token <sval> IDENTIFIER

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
