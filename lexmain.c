#include<stdio.h>
#include"lexmain.h"
#include"y.tab.h"
extern int yyparse();
extern "C" FILE* yyin;

//considers first argument as input file name

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
  do{
    yyparse();
  }while(!feof(yyin));
  return 0;
}
