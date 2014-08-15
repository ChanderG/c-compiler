%{
  #include"y.tab.h"
  #include<iostream>
  using namespace std;
%}

%%
[ \t\n]             ;
[_a-zA-Z]+[0-9]*    { cout << yytext << endl; return IDENTIFIER; }
.                   { cout << "WIP" << endl;}

%%
