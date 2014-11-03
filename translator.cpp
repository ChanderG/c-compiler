#include<iostream>
using namespace std;

#include<cstring>

#include"lexmain.h"
#include"y.tab.h"
extern int yyparse();
extern "C" FILE* yyin;

#include<iomanip>

//for file open etc
#include<stdio.h>

//the quad array
extern QuadArray qa;            
extern symboltable global;            


#include<fstream>
ofstream fout;   //for the .out file containing the TAC

#include<map>

//register and operation strings
const char* BP = "%ebp";
const char* SP = "%esp";


//main function for the m/c dependent translation - here x86
void QuadArray :: genCode(char* filename){
  //enter code here
  ofstream rout;  //result out for the .s file
  rout.open("res.s");
 
  //the single pointer to the current AR
  map<char*, int> *AR;
  char* currentFunction = NULL; //name of the current function

  //exhaustively counter each type of quad entry 
  //file opening
  rout << "\t" << setw(8) << left << ".file " << "\"" << filename << "\"" << endl; 
  //rout << "\t" << ".text" << endl;


  for(int i = 0;i < q.size();i++){
   
    //actaully it is a function implying the need of a full activation record
    if(q[i].op == OP_SEC){

      //check if some function was on previously - if so complete it
      if(currentFunction != NULL){
	rout << "\t" << setw(8) << left << "leave" << endl;
	rout << "\t" << setw(8) << left << "ret" << endl;
	rout << "\t" << setw(8) << left << ".size " << currentFunction << ", .-" << currentFunction << endl;
      } 

      rout << "\t" << setw(8) << left << ".global " << q[i].res << endl;
      rout << "\t" << setw(8) << left << ".type " << q[i].res << ", @function" << endl;
      rout << q[i].res << ":" << endl;

      currentFunction = q[i].res;

      //at this point look at the symbol table and create the AR
      AR = (global.getNST(currentFunction))->createAR();
      //printing to stdout for debugging
      for (map<char*,int>::iterator it=AR->begin(); it!=AR->end(); ++it)
          cout << it->first << " => " << it->second << '\n';

      
      //now for the standard function opening
      rout << "\t" << setw(8) << left << "pushl" << BP << endl; 
      rout << "\t" << setw(8) << left << "movl" << SP << ", " << BP << endl; 

      //allocating space in the stack for the local variables
      //not very clear - going to go with additional 8 memory after that actually required
      int ss = global.getNST(currentFunction)->getStackSize();
      // adjust exact size of stack here
      ss += 8;
      if(ss%8 != 0) ss += ss%8;
      rout << "\t" << setw(8) << left << "subl" << "$" << ss << ", " << SP << endl; 

      //may be also store some local variables that are initialized at declaration
      map<char*,int>* valMap = global.getNST(currentFunction)->getInitialValues();          
      //write the corresponding code statements
      for (map<char*,int>::iterator it=valMap->begin(); it!=valMap->end(); ++it){
	rout << "\t" << setw(8) << left << "movl" << "$" << it->second << ", " << AR->find(it->first)->second << "(" << SP << ")" << endl; 
      }
      delete valMap;
    
    }
    //else if(){}
    else {}
  }

  //the conclusion for the last function
  rout << "\t" << setw(8) << left << "leave" << endl;
  rout << "\t" << setw(8) << left << "ret" << endl;
  rout << "\t" << setw(8) << left << ".size " << currentFunction << ", .-" << currentFunction << endl;

  rout << "\t" << setw(8) << left << ".ident" << "\"Chander G : c compiler\"" << endl;

  rout.close();
  return;
}


//considers first argument as input file name
int main(int argc, char* argv[]){
  argv++;
  argc--;
  
  if(argc == 0){
    cout << "tinyC compiler" << endl;   
    cout << "Incorrect usuage!" << endl;
    cout << "Use -h flag for help" << endl;
  }
  else if((strcmp(argv[0], "-h") == 0) || (strcmp(argv[0], "--help") == 0)){
    cout << "Welcome to TinyC compiler" << endl;   
    cout << "USUAGE: " << endl;
    cout << "\t./a.out <name of file>" << endl; 
  }
  else {

    FILE *inp = fopen(argv[0], "r");
    if (!inp) {
      cout << "Can't open file" << endl;
      return -1;
    }
    
    yyin = inp;
    
    //open the out file for input
    //replace name with a input based one
    fout.open("res.out");
    fout << "TAC of program " << argv[0] << endl;

    //else where each symbol table is sent to this file - all are pointing towards fout
    do{
      yyparse();
    }while(!feof(yyin));

    //print the quads and the tac
    qa.print();
    fout << endl;
    qa.printTable();
    fout.close();

    //call the function for m/c dependent translation here and send to the .asm file
    //parse the file name to get only the exact file name and not the path
    qa.genCode(argv[0]);

  }

  //include verbose mode too

  return 0;
}
