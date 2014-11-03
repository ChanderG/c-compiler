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

//several data structures built using map to ease translation
#include<map>
#include<string>

//register and operation strings
const char* BP = "%ebp";
const char* SP = "%esp";


//main function for the m/c dependent translation - here x86
void QuadArray :: genCode(char* filename){
  //enter code here
  ofstream rout;  //result out for the .s file
  rout.open("res.s");
 
  //the single pointer to the current AR
  map<string, int> *AR;
  char* currentFunction = NULL; //name of the current function

  //exhaustively counter each type of quad entry 
  //file opening
  rout << "\t" << setw(8) << left << ".file " << "\"" << filename << "\"" << endl; 
  rout << "\t" << ".text" << endl;

  int j,maxk;
  map<int, int> paramOffsets;  //for getting the offsets of each parameter from SP
  //for now the map is going to almost use only %eax
  map<string, char> tempReg;    // map from temporaries to registers

  for(int i = 0;i < q.size();i++){
   
    //function
    if(q[i].op == OP_SEC){

      //clear existing offset map
      paramOffsets.clear();
 
      //check if some function was on previously - if so complete it
      if(currentFunction != NULL){
	rout << "\t" << setw(8) << left << "leave" << endl;
	rout << "\t" << setw(8) << left << "ret" << endl;
	rout << "\t" << setw(8) << left << ".size " << currentFunction << ", .-" << currentFunction << endl;
      } 

      //function start lines
      rout << "\t" << setw(8) << left << ".globl " << q[i].res << endl;
      rout << "\t" << setw(8) << left << ".type " << q[i].res << ", @function" << endl;
      rout << q[i].res << ":" << endl;

      currentFunction = q[i].res;

      //at this point look at the symbol table and create the AR
      AR = (global.getNST(currentFunction))->createAR();
      //printing to stdout for debugging
      for (map<string,int>::iterator it=AR->begin(); it!=AR->end(); ++it)
          cout << it->first << " => " << it->second << '\n';

      
      //now for the standard function opening
      rout << "\t" << setw(8) << left << "pushl" << BP << endl; 
      rout << "\t" << setw(8) << left << "movl" << SP << ", " << BP << endl; 

      //allocating space in the stack for the local variables
      //not very clear - going to go with additional 8 memory after that actually required
      //it needs to accomodate every function call that occurs
      //need to go through the entire quad array -> and create a meta data table for function calls atleast
    
      //everything is being done for integers only

      //Go to the end of the section and come back o as to give the param of each call the right amount of offset
      j = i+1;
      while(q[j].op != OP_RET){
        j++;
      }
      j -= 1;
      int k = 0;
      maxk = 0;
      for(;j>i;j--){
        if(q[j].op == OP_CALL){ 
	  maxk = (maxk > k)?maxk:k;
	  k = 0;
	}  
	else if(q[j].op == OP_PARAM){
	  paramOffsets.insert(pair<int,int>(j, k));
	  k += 4;
        }
	else;
      }

      //for the first function call
      maxk = (maxk > k)?maxk:k;

      //stack size required for the variables
      int ss = global.getNST(currentFunction)->getStackSize();
      // adding a buffer of 8 bytes
      ss += 8;

      //maximum space required by any function call in this section
      ss += maxk;

      rout << "\t" << setw(8) << left << "subl" << "$" << ss << ", " << SP << endl; 

      //may be also store some local variables that are initialized at declaration
      map<string,int>* valMap = global.getNST(currentFunction)->getInitialValues();          
      //write the corresponding code statements
      for (map<string,int>::iterator it=valMap->begin(); it!=valMap->end(); ++it){
	rout << "\t" << setw(8) << left << "movl" << "$" << it->second << ", " << AR->find(it->first)->second << "(" << SP << ")" << endl; 
      }
      delete valMap;
    }
    //next section**********************************************************************
    else if(q[i].op == OP_PARAM){
      if(q[i].res[0] == '$'){
	//param is a temporary
	rout << "\t" << setw(8) << left << "movl" << "%eax, " <<  paramOffsets.find(i)->second << "(" << SP << ")" << endl;
        //paramOffsets.find(i)->second
      }
      else if(AR->count(q[i].res) != 0){
	//if the param is a variable       
	rout << "\t" << setw(8) << left << "movl" << (AR->find(q[i].res))->second << "(" << BP << "), " << "%eax" << endl; 
	rout << "\t" << setw(8) << left << "movl" << "%eax, " <<  paramOffsets.find(i)->second << "(" << SP << ")" << endl;
      }
      else{
	//param is a constant
	rout << "\t" << setw(8) << left << "movl" << "$" << q[i].res << ", " << paramOffsets.find(i)->second << "(" << SP << ")" << endl;
      }
    }
    //next section**********************************************************************
    else if(q[i].op == OP_CALL){
      rout << "\t" << setw(8) << left << "call" << q[i].arg1 << endl;   
      tempReg.insert(pair<string, char>(q[i].res, 'a'));
    }
    //next section**********************************************************************
    else if(q[i].op == OP_RET){
      if(q[i].res[0] != '$'){
        rout << "\t" << setw(8) << left << "movl" << (AR->find(q[i].res))->second << "(" << BP << "), " << "%eax" << endl;
      }
      else{
        //move the item from whatever register to %eax 
      }
    }
    //next section**********************************************************************
    else if(q[i].op == OP_NULL){ // direct assignment 
	//temp = const
      if(q[i].res[0] == '$'){
	if(tempReg.count(q[i].res) != 0){
	  //already exists
	  rout << "\t" << setw(8) << left << "movl" << "$" << q[i].arg1 << ", %e" << tempReg.find(q[i].res)->second << "x" << endl;
	}
	else{
          //enter into the mapping
	  tempReg.insert(pair<string, char>(q[i].res, 'a'));
	  rout << "\t" << setw(8) << left << "movl" << "$" << q[i].arg1 << ", %e" << tempReg.find(q[i].res)->second << "x" << endl;
	}
      }
      else if(q[i].arg1[0] == '$'){
	//var = temp
	rout << "\t" << setw(8) << left << "movl" << "%e" << (tempReg.find(string(q[i].arg1)))->second << "x" <<  ", " << (AR->find(string(q[i].res)))->second << "(" << BP << ")" << endl;
      }
      else{
	//var = var
        rout << "\t" << setw(8) << left << "movl" << (AR->find(string(q[i].arg1)))->second << "(" << BP << "), " << "%eax" << endl; 
        rout << "\t" << setw(8) << left << "movl" << "%eax, " << (AR->find(string(q[i].res)))->second << "(" << BP << ")" << endl; 

	//var = const
	//this category is actually never used
	//maybe needed when code is optimized
	/*
	rout << "\t" << setw(8) << left << "movl" << "$" << q[i].arg1 << ", " << (AR->find(q[i].res))->second << "(" << BP << ")" << endl;
	*/
      }
    }
    else if(q[i].op == OP_PLUS){
      //OP_PLUS
    }
  }

  //the conclusion for the last function
  rout << "\t" << setw(8) << left << "leave" << endl;
  rout << "\t" << setw(8) << left << "ret" << endl;
  rout << "\t" << setw(8) << left << ".size " << currentFunction << ", .-" << currentFunction << endl;

  //end of file
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
