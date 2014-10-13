//File for global function prototypes and data structures

typedef struct symtabentry {
  char *name;
  int value;
  int size;
  int offset;
} symboltableentry;

#define SYMBOLTABLE_SIZE 25

class symboltable{
  symboltableentry st[SYMBOLTABLE_SIZE];
  int last;

  public:
  symboltable(){
    last = 0;
  }
};


