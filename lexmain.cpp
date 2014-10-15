#include<iostream>
using namespace std;

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

void symboltable :: update(char *name, char *type, int size, int offset){
  int no = lookup(name);
  st[no].type = strdup(type);
  st[no].size = size;
  st[no].offset = offset;
  st[no].nestedTable = NULL;
}

//for functions
symboltable* symboltable :: updatef(char *name, char *type, int size, int offset){
  int no = lookup(name);
  st[no].type = strdup(type);
  st[no].size = size;
  st[no].offset = offset;
  //add other fields here
  st[no].nestedTable = new symboltable;
  return st[no].nestedTable;
}

void symboltable :: print(){
  cout << "START OF SYMBOL TABLE" << endl;
  cout << "Name " << "Type " << "Size " << "Offset" << endl;
  for (int i=0;i<last;i++){
    cout << st[i].name << " " << st[i].type << " " << st[i].size <<  " " << st[i].offset;
    cout << endl;
  }
  cout << "END OF SYMBOL TABLE" << endl;
}

char* symboltable :: gentemp(){
  char* tmp = new char[5];
  sprintf(tmp, "$t%d",templast);

  //Assuming only integer temporaries
  st[last].name = strdup(tmp);
  st[last].type = strdup("Temp");
  st[last].size = 4;
  st[last].offset = st[last-1].offset + 4;
  last++;

  templast++;
  return tmp;
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
