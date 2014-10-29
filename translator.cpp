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

#include<fstream>
ofstream fout;   //for the .out file containing the TAC

//main function for the m/c dependent translation - here x86
void QuadArray :: genCode(char* filename){
  //enter code here
  ofstream rout;  //result out
  rout.open("res.s");
  
  //exhaustively counter each type of quad entry 
  //file opening
  rout << "\t" << setw(8) << left << ".file " << "\"" << filename << "\"" << endl; 
  //rout << "\t" << ".text" << endl;

  for(int i = 0;i < q.size();i++){
   
    //actaully it is a function implying the need of a full activation record
    if(q[i].op == OP_SEC){
      rout << "\t" << setw(8) << left << ".global " << q[i].res << endl;
      rout << "\t" << setw(8) << left << ".type " << q[i].res << ", @function" << endl;
      rout << q[i].res << ":" << endl;
    }
  }

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
