#include<iostream>
using namespace std;

#include<iomanip>

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

char* symboltable :: getType(char* name){
  int no = lookup(name);
  return st[no].type;
}

int symboltable :: getSize(char* name){
  int no = lookup(name);
  return st[no].size;
}

void symboltable :: update(char *name, char *type, int size, int offset){
  int no = lookup(name);
  st[no].type = strdup(type);
  st[no].size = size;
  st[no].offset = offset;
  st[no].nestedTable = NULL;
}

void symboltable :: update(char *name, char *type, int size){
  int no = lookup(name);
  st[no].type = strdup(type);
  st[no].size = size;
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
  cout << "***************START OF SYMBOL TABLE**************" << endl;
  setw(10);
  cout << setw(10) << "Name";
  cout << setw(20) << "Type";
  cout << setw(10) << "Size";
  cout << setw(10) << "Offset";
  cout << endl;
  for (int i=0;i<last;i++){
    cout << setw(10) << st[i].name;
    cout << setw(20) << st[i].type;
    cout << setw(10) << st[i].size;
    cout << setw(10) << st[i].offset;
    cout << endl;
  }
  cout << "***************END OF SYMBOL TABLE****************" << endl;
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


char* quad :: opToString(){
  char* opString = new char[6];
  switch(op){
    case OP_NULL: strcpy(opString, "");break;
    case OP_PLUS: strcpy(opString, "+");break;
    case OP_MINUS: strcpy(opString, "-");break;
    case OP_MULT: strcpy(opString, "*");break;
    case OP_BY: strcpy(opString, "/");break;
    case OP_PER: strcpy(opString, "%");break;
    case OP_GOTO: strcpy(opString, "goto");break;
    case OP_LT: strcpy(opString, "<");break;
    case OP_GT: strcpy(opString, ">");break;
    case OP_LTE: strcpy(opString, "<=");break;
    case OP_GTE: strcpy(opString, ">=");break;
    case OP_E: strcpy(opString, "==");break;
    case OP_NE: strcpy(opString, "!=");break;
    default: strcpy(opString, "");break;
  } 
  return opString;
}

char* quad :: arg1ToString(){
  if(arg1 == NULL){
    char* arg1String = new char[2];
    strcpy(arg1String, "");
    return arg1String;
  }
  else{
    return arg1;
  }  
}

char* quad :: arg2ToString(){
  if(arg2 == NULL){
    char* arg2String = new char[2];
    strcpy(arg2String, "");
    return arg2String;
  }
  else{
    return arg2;
  }  
}

char* quad :: resToString(){
  if(res == NULL){
    char* resString = new char[2];
    strcpy(resString, "");
    return resString;
  }
  else{
    return res;
  }  
}

//converting one line of quad
char* quad :: toString(){
  char* quadString = new char[15];
  if((op == OP_LT) || (op == OP_GT) || (op == OP_LTE) || (op == OP_GTE)
           || (op == OP_E) || (op == OP_NE) ){        //comaprision based goto
    strcpy(quadString, "if ");
    strcat(quadString, arg1ToString());
    strcat(quadString, " ");
    strcat(quadString, opToString());
    strcat(quadString, " ");
    strcat(quadString, arg2ToString());
    strcat(quadString, " goto ");
    strcat(quadString, resToString());
  }
  else if (op == OP_GOTO){  //unconditional goto
    strcpy(quadString, opToString());
    strcat(quadString, " ");
    strcat(quadString, resToString());
  }
  else if (arg2 == NULL){ //unary operators
    strcpy(quadString, resToString());
    strcat(quadString, " = ");
    strcat(quadString, opToString());
    strcat(quadString, arg1ToString());
  }
  else {  //binary operators
    strcpy(quadString, resToString());
    strcat(quadString, " = ");
    strcat(quadString, arg1ToString());
    strcat(quadString, " ");
    strcat(quadString, opToString());
    strcat(quadString, " ");
    strcat(quadString, arg2ToString());
  }
  //strcat(quadString, ";");
  return quadString;
}

//main binary operators
void QuadArray :: emit(argtype res, argtype arg1, opcode op, argtype arg2){
  quad entry = { op, arg1, arg2, res}; 
  q.push_back(entry);
}

//unary operators
void QuadArray :: emit(argtype res, argtype arg1, opcode op){
  quad entry = { op, arg1, NULL, res}; 
  q.push_back(entry);
}

//for copy assignment operation
void QuadArray :: emit(argtype res, argtype arg1){
  quad entry = { OP_NULL, arg1, NULL, res}; 
  q.push_back(entry);
}

//unconditional goto etc 
void QuadArray :: emit(argtype res, opcode op){
  if (op != OP_GOTO) return;  //later use
  //use -1 for indicating empty slot
  quad entry = { op, NULL, NULL, res};
  q.push_back(entry);
}

//print the quad array in a tabular form
void QuadArray :: printTable(){
  cout << "****************QUAD ARRAY STARTS*****************" << endl;
  cout << setw(10) << "INDEX"; 
  cout << setw(10) << "op";
  cout << setw(10) << "arg 1";
  cout << setw(10) << "arg 2";
  cout << setw(10) << "result";
  cout << endl;
  for(int i=0;i<q.size();i++){
    cout << setw(10) << i;
    cout << setw(10) << q[i].opToString();
    cout << setw(10) << q[i].arg1ToString();
    cout << setw(10) << q[i].arg2ToString();
    cout << setw(10) << q[i].resToString();
    cout << endl;
  }
  cout << "*****************QUAD ARRAY ENDS******************" << endl;
}


//print the generated code
void QuadArray :: print(){
  cout << endl;
  cout << "Generated Code: " << endl;
  for(int i=0;i<q.size();i++){
    cout << "L" << i << " : " << q[i].toString() << endl;
  }
  cout << "End of generated code" << endl;
  cout << endl;
}

//next instr
int QuadArray :: nextinstr(){
  return q.size();
}

//global makelist function 
list<int> *makelist(int i){
  list<int> *newlist = new list<int>;
  newlist->push_back(i);
  return newlist;
}

//backpatch every quad referred in list with the label ins
void QuadArray :: backpatch(list<int>* somelist, int ins){
  argtype ins_ = new char[5];
  sprintf(ins_, "%d", ins);
  if (somelist != NULL)
    for(std::list<int>::iterator it = somelist->begin();it != somelist->end();it++){
      q[*it].res = strdup(ins_);// ins_;
    }
}

//merge function
//copies each element manually
list<int> *merge(list<int>* a,list<int>* b){
  list<int> *c = new list<int>();
  //for safety going to copy each and every value
  //optimize later if possible
  if (a != NULL)
    for(std::list<int>::iterator it = a->begin();it != a->end();it++){
      c->push_back(*it);
    }  
  if (b != NULL)
    for(std::list<int>::iterator it = b->begin();it != b->end();it++){
      c->push_back(*it);
    }  
  return c;
}

/****************************************************************************/
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

