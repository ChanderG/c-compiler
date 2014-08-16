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
    else if (tok == INTEGER_CONSTANT)
      printf("Integer-constant\n");
      
  }while (!feof(yyin));
  return 0;
}
