//File for global function prototypes and data structures
#include<vector>

typedef struct symtabentry {
  char *name;
  int value;
  char *type;
  int size;
  int offset;
  class symboltable *nestedTable;
} symboltableentry;

#define SYMBOLTABLE_SIZE 25

//right now implemented as an array
class symboltable{

  symboltableentry st[SYMBOLTABLE_SIZE];
  int last;
  int templast;

  public:
  symboltable(){
    last = 0;
    templast = 0;
  }
  
  int lookup(char *name);

  //going to set a pointer to the nested table if it exists and null else
  //meant to be used carefully
  symboltable* updatef(char *name, char *type, int size, int offset);

  void update(char *name, char *type, int size, int offset); 
  void print();

  char* gentemp();
};

struct ts_ {    // for type_specifier
  char *type;
  int width;
}; 

struct ts_2 {    // for global value type_specifier
  char *type;
  int width;
  int offset;
};

struct exp_ {  //for expressions
  char *loc;   // as discussed in class
};  

//Quad management structures
enum opcode {OP_NULL, OP_PLUS, OP_MINUS, OP_MULT, OP_BY, OP_PER}; 

typedef char* argtype;

typedef struct quad_ {
  opcode op;
  argtype arg1;
  argtype arg2;
  argtype res;

  //toString operation for each item and the whole quad too
  char* opToString();
  char* arg1ToString();
  char* arg2ToString();
  char* resToString();
  char* toString();
} quad;

class QuadArray{
  std::vector<quad> q; //the array itself

  public:
  QuadArray(){
    q.clear();    
  }

  //adding a new entry to the quad array
  void emit(argtype res, argtype arg1, opcode op, argtype arg2);
  void emit(argtype res, argtype arg1, opcode op);
  void emit(argtype res, argtype arg1);

  //Printing the entire quad array in table format
  void printTable();
  //in code form
  void print();
};
