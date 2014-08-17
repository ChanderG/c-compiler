#include<stdio.h>
#include"y.tab.h"
extern int yylex();
extern "C" FILE* yyin;

int main(int argc, char* argv[]){
  argv++;
  argc--;
  if(argc > 0){
    FILE *inp = fopen(argv[0], "r");
    if (!inp) {
      printf("Can't open file\n");
      return -1;
    }
    yyin = inp;
  }
  //yylex();
  do{
    int tok = yylex();
    if (tok == IDENTIFIER)
      printf("Identifier\n");
    else if (tok == KEYWORD)
      printf("Keyword\n");
    else if (tok == INTEGER_CONSTANT)
      printf("Integer-constant\n");
    else if (tok == SIGN)
      printf("Sign\n");
      
  }while (!feof(yyin));
  return 0;
}
