//File for global function prototypes and data structures

typedef struct symtabentry {
  char *name;
  int value;
  char *type;
  int size;
  int offset;
} symboltableentry;

#define SYMBOLTABLE_SIZE 25

//right now implemented as an array
class symboltable{

  symboltableentry st[SYMBOLTABLE_SIZE];
  int last;

  public:
  symboltable(){
    last = 0;
  }
  
  int lookup(char *name);
  void update(char *name, char *type, int size, int offset); 
  void print();
};

struct ts_ {    // for type_specifier
  char *type;
  int width;
}; 

struct ts_2 {    // for type_specifier
  char *type;
  int width;
  int offset;
};
