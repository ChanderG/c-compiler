#include<fstream>
using namespace std;

#include<iomanip>

#include<stdio.h>
#include<stdlib.h>

#include"lexmain.h"
#include"y.tab.h"

extern int yyparse();
extern "C" FILE* yyin;

//#include"translator.cpp"
extern ofstream fout;

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

//return 1 if name exists in the ST; 0 else 
int symboltable :: isThere(char* name){
  for(int i = 0;i< last;i++){
    if(strcmp(st[i].name, name) == 0)
      return 1;
  }
  return 0;
}

char* symboltable :: getType(char* name){
  int no = lookup(name);
  return st[no].type;
}

int symboltable :: getSize(char* name){
  int no = lookup(name);
  return st[no].size;
}

//get the value of an entry
char* symboltable :: getValue(char* name){
  int no = lookup(name);
  return st[no].value;
}

//get the nested table of an entry
symboltable* symboltable :: getNST(char* name){
  int no = lookup(name);
  return st[no].nestedTable;
}

//get the Stack Size
int symboltable :: getStackSize(){
  return stackSize;
}

//simple update
void symboltable :: update(char *name, char *type, int size, int offset){
  int no = lookup(name);
  st[no].type = strdup(type);
  st[no].size = size;
  st[no].offset = offset;
  st[no].nestedTable = NULL;
  st[no].value = NULL;
}

//refer to header for use
void symboltable :: update(char *name, char *type, int size){
  int no = lookup(name);
  st[no].type = strdup(type);
  st[no].size = size;
}

//for adding return value of a function
void symboltable :: update(char *type){
  int no = lookup("retVal");
  st[no].type = strdup(type);
  st[no].size = 0;
  st[no].offset = 0;
  st[no].nestedTable = NULL;
}

//for initial value
void symboltable :: update(char *name, char *value){
  int no = lookup(name);
  st[no].value = strdup(value);
}

//for upgrading an entry to array 
void symboltable :: update(char *name, int nos){
  int no = lookup(name);
  char* array_spec = (char *)malloc(50*sizeof(char));
  strcpy(array_spec,"array(");
  char *strno = new char[5];
  sprintf(strno, "%d", nos);
  strcat(array_spec, st[no].type);
  strcat(array_spec,", ");
  strcat(array_spec, strno); 
  strcat(array_spec,")");
 
  free(st[no].type);
  st[no].type = array_spec;
  st[no].size *= nos;
}

//remove last inserted constant temp -> used to remove the redundant entry created during variable creation
void symboltable :: removeConstantTemp(){
  free(st[last-1].name);
  free(st[last-1].type);
  free(st[last-1].value);
  last--;

  //temp label count
  templast--;
}

//get last offset
int symboltable :: lastOffset(){
  return st[last-1].offset;
}

//for functions
symboltable* symboltable :: updatef(char *name, char *type, int size, int offset){
  int no = lookup(name);
  st[no].type = strdup(type);
  st[no].size = size;
  st[no].offset = offset;
  st[no].value = NULL;
  //add other fields here
  st[no].nestedTable = new symboltable;
  return st[no].nestedTable;
}

//to print the symbol table except the nested pointer in a nice tabular fashion
void symboltable :: print(){
  fout << "*************************START OF SYMBOL TABLE************************" << endl;
  setw(10);
  fout << setw(10) << "Name";
  fout << setw(30) << "Type";
  fout << setw(10) << "Size";
  fout << setw(10) << "Offset";
  fout << setw(10) << "Value";
  fout << endl;
  for (int i=0;i<last;i++){
    fout << setw(10) << st[i].name;
    fout << setw(30) << st[i].type;
    fout << setw(10) << st[i].size;
    fout << setw(10) << st[i].offset;
    if(st[i].value == NULL) fout << setw(10) << "null";
    else fout << setw(10) << st[i].value;
    fout << endl;
  }
  fout << "*************************END OF SYMBOL TABLE**************************" << endl;
}

//create a new temporary and return the name
char* symboltable :: gentemp(){
  char* tmp = new char[5];
  sprintf(tmp, "$t%d",templast);

  //Assuming only integer temporaries
  st[last].name = strdup(tmp);
  st[last].type = strdup("Temp");
  st[last].size = 4;
  st[last].offset = st[last-1].offset + 4;
  st[last].value = NULL;
  last++;

  templast++;
  return tmp;
}

//enter a section break
void symboltable :: genBreak(){
  char* tmp = new char[5];
  sprintf(tmp, "null");

  //Assuming only integer temporaries
  st[last].name = strdup(tmp);
  st[last].type = strdup("null");
  st[last].size = 0;
  st[last].offset = st[last-1].offset + 0;
  st[last].value = NULL;
  last++;

}

//create AR
map<string, int>* symboltable :: createAR(){
  map<string, int>* AR = new map<string, int>();

  //starting from the item after the retVal
  int i = 1;
  //while name is not null => all the args
  while(strcmp(st[i].name, "null") != 0){
    //for now assuming only ints
    AR->insert(pair<string, int>(st[i].name, 8 + (i-1)*4));    
    i++;
  }

  //now for the local variables
  i = last-1;
  int k = -4; // start value of offset for the local variables
  while(strcmp(st[i].name, "null") != 0){
    //if not a temporary
    if(st[i].name[0] != '$'){
      AR->insert(pair<string, int>(st[i].name, k));    
      //assuming only int
      k -= 4;
    }
    i--;
  }

  stackSize = -1*k;

  return AR;
}

//initial value setup
//assuming only int now
map<string, int>* symboltable :: getInitialValues(){
  map<string, int>* valMap = new map<string, int>();

  int i = last-1;
  while(strcmp(st[i].name, "null") != 0){
    //if not a temporary
    if(st[i].name[0] != '$'){
      if(st[i].value != NULL)
	valMap->insert(pair<string, int>(st[i].name, atoi(st[i].value)));    
    }
    i--;
  }

  return valMap;
}

//convert the opcode to string for pretty printing
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
    case OP_STAR: strcpy(opString, "*");break;
    case OP_AND: strcpy(opString, "&");break;
    case OP_RET: strcpy(opString, "return");break;
    case OP_PARAM: strcpy(opString, "param");break;
    case OP_CALL: strcpy(opString, "call");break;
    case OP_SEC: strcpy(opString, "section");break;
    default: strcpy(opString, "");break;
  } 
  return opString;
}

//pretty print function
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

//pretty print function
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

//pretty print function
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

//converting one line of quad to nice printable format
char* quad :: toString(){
  char* quadString = new char[15];
  if(op == OP_SEC){
    strcpy(quadString, opToString());
    strcat(quadString, " ");
    strcat(quadString, resToString());
  }
  else if (op == OP_NULL && arg1 == NULL && arg2 == NULL && res == NULL){ //section seperator
    strcpy(quadString, " ");
  } 
  else if((op == OP_LT) || (op == OP_GT) || (op == OP_LTE) || (op == OP_GTE)
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
  else if ((op == OP_GOTO) || (op == OP_RET) || (op == OP_PARAM) ){  //unconditional goto,return,param
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
  else if (op == OP_ARRAY_ACCESS) {  //array access
    strcpy(quadString, resToString());
    strcat(quadString, " = ");
    strcat(quadString, arg1ToString());
    strcat(quadString, "[");
    strcat(quadString, arg2ToString());
    strcat(quadString, "]");
  }
  else if (op == OP_CALL) {  //function call
    strcpy(quadString, resToString());
    strcat(quadString, " = ");
    strcat(quadString, opToString());
    strcat(quadString, " ");
    strcat(quadString, arg1ToString());
    strcat(quadString, ", ");
    strcat(quadString, arg2ToString());
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

//main binary operators and function call
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

//unconditional goto, return, param etc 
void QuadArray :: emit(argtype res, opcode op){
  if (!((op == OP_GOTO) || (op == OP_RET) || (op == OP_PARAM))) return;  //later use
  //use -1 for indicating empty slot
  quad entry = { op, NULL, NULL, res};
  q.push_back(entry);
}

//for showing end of sections like functions
//right now an empty rule
void QuadArray :: emitSection(char* name){
  quad entry = { OP_SEC, NULL, NULL, name};
  q.push_back(entry);
}

//de-emit
//remove the last emited tac -> used in case of declaration
void QuadArray :: demit(){
  q.pop_back();
}

//print the quad array in a tabular form
void QuadArray :: printTable(){
  fout << setfill(' ');
  fout << "****************QUAD ARRAY STARTS*****************" << endl;
  fout << setw(10) << "INDEX"; 
  fout << setw(10) << "op";
  fout << setw(10) << "arg 1";
  fout << setw(10) << "arg 2";
  fout << setw(10) << "result";
  fout << endl;
  for(int i=0;i<q.size();i++){
    fout << setw(10) << i;
    fout << setw(10) << q[i].opToString();
    fout << setw(10) << q[i].arg1ToString();
    fout << setw(10) << q[i].arg2ToString();
    fout << setw(10) << q[i].resToString();
    fout << endl;
  }
  fout << "*****************QUAD ARRAY ENDS******************" << endl;
}


//print the generated code in TAC format
void QuadArray :: print(){
  fout << endl;
  fout << "Generated Code: " << endl;
  for(int i=0;i<q.size();i++){
    fout << "L" << setw(3) << setfill('0') << i << " : " << q[i].toString() << endl;
  }
  fout << "End of generated code" << endl;
  fout << endl;
}

//next instr
int QuadArray :: nextinstr(){
  return q.size();
}

//global makelist function 
//make a new list with one entry ie i and return a pointer to that list
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
//takes 2 lists and returns one with contents of both
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
