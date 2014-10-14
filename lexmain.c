#include<stdio.h>
#include"lexmain.h"
#include"y.tab.h"
extern int yyparse();
extern "C" FILE* yyin;

#include<cstring>

int symboltable :: lookup(char *name){
  for(int i = 0;i< last;i++){
    if(strcmp(st[i].name, name) == 0)
      return i;
  }
  //creating a new entry
  st[last].name = strdup(name); 
  last++;
  return last-1; 
}

void symboltable :: update(int no, char *name, int size, int offset){
  if (no >= last) cout << "Error";
  st[no].name = strdup(name);
  st[no].size = size;
  st[no].offset = offset;
}

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
