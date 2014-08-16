#include<stdio.h>
#include"y.tab.h"
extern int yylex();
extern "C" FILE* yyin;

int main(){
  //yylex();
  do{
    int tok = yylex();
    if (tok == IDENTIFIER)
      printf("Identifier\n");
    else if (tok == KEYWORD)
      printf("Keyword\n");
      
  }while (!feof(yyin));
  return 0;
}
