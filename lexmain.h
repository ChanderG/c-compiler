//File for global function prototypes and data structures
#include<vector>
#include<list>

//each row of the symbol table
//type and value are encoded as strings
typedef struct symtabentry {
  char *name;
  char * value;
  char *type;
  int size;
  int offset;
  class symboltable *nestedTable;
} symboltableentry;

#define SYMBOLTABLE_SIZE 500     //number of entries in symbol table
const int SIZEOF_PTR = 4;

// implemented as a simple array
class symboltable{

  symboltableentry st[SYMBOLTABLE_SIZE];       //actual array of symboltableentry structure
  int last;                                    //no of elements filled in
  int templast;                                //no of temporaries created

  public:
  symboltable(){
    last = 0;
    templast = 0;
  }
  
  //given name of variable, the entry index is returned
  int lookup(char *name);         

  //get the type of the name entry 
  char* getType(char* name);
  //get the size of an entry
  int getSize(char* name);
  //get the value of an entry
  char* getValue(char* name);

  //going to set a pointer to the nested table if it exists and null else
  //meant to be used carefully
  //used for function definition only
  symboltable* updatef(char *name, char *type, int size, int offset);

  //typical update to enter variables
  void update(char *name, char *type, int size, int offset); 
  //to be used to update an existing entry to ptr version
  void update(char *name, char *type, int size); 
  //adding retVal to the table
  void update(char *type);
  //giving an initial value to a variable
  void update(char *name, char *value);
  //for upgrading an entry to array 
  void update(char *name, int nos);

  //remove last inserted constant temp -> used to remove the redundant entry created during variable creation
  void removeConstantTemp();

  //formatted ouptut of table contents
  void print();

  //creates a new temporary entry and returns name
  char* gentemp();

  //get last offset from the symbol table
  int lastOffset();
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

struct bexp_ {  //for boolean expressions
  char *loc;   // the optional thingy.
  std::list<int> *truelist;
  std::list<int> *falselist;
};  

//Quad management structures
enum opcode {OP_NULL, OP_PLUS, OP_MINUS, OP_MULT, OP_BY, OP_PER, OP_GOTO, OP_LT, OP_GT, OP_LTE, OP_GTE, OP_E, OP_NE, OP_STAR, OP_AND, OP_RET, OP_PARAM, OP_CALL, OP_ARRAY_ACCESS, OP_SEC}; 


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
  //for comparision based goto - use -1 for blank label 
  void emit(argtype res, argtype arg1, opcode op, argtype arg2);  //binary, comparision goto, array access
  void emit(argtype res, argtype arg1, opcode op);                //unary
  void emit(argtype res, argtype arg1);                           //copy assignment

  //use - OP_GOTO and -1 for blank label
  void emit(argtype res, opcode op);                              //unconditional goto etc 

  //for showing start of sections like functions
  void emitSection(char*);

  //Printing the entire quad array in table format
  void printTable();
  //in code form
  void print();
  
  //returns the next instr
  int nextinstr();

  //backpatch function
  void backpatch(std::list<int>*, int);

  //de-emit
  //remove the last emited tac -> used in case of declaration
  void demit();
};

//for seeing type of the operator in unary_expressions
//UN_NULL is for no operation
enum unary_op { UN_PLUS, UN_MINUS, UN_STAR, UN_AND, UN_NULL};

//global makelist function 
std::list<int> *makelist(int); 

//global merge function for list pointers - actually creates a new list
std::list<int> *merge(std::list<int>* ,std::list<int>*);

//for statements
struct s_{
  std::list<int>* nextlist;
};   
