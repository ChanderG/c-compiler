#include<iostream>

using namespace std;

#include<cstring>
#include<cstdlib> //for atoi

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
#include<set>

//register and operation strings
const char* BP = "%ebp";
const char* SP = "%esp";

#define ROUT rout << "\t" << setw(8) << left

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
  ROUT << ".file " << "\"" << filename << "\"" << endl; 

  int j,maxk;
  map<int, int> paramOffsets;  //for getting the offsets of each parameter from SP
  //for now the map is going to almost use only %eax
  map<string, char> tempReg;    // map from temporaries to registers

  char freeReg = 'a';

  //we observe that strings are always involved in assignments to temporaries
  //map from quad number to the string label
  map<int, int> stringAssignments;
  //label values
  int str = 0; 

  ROUT << ".section";
  ROUT << ".rodata" << endl;

  //points to current symbol table
  symboltable* c = &global; 

  //some what brute force, but simple
  for(int i = 0;i < q.size();i++){
    if(q[i].op == OP_SEC){
      //going into new function
      c = global.getNST(q[i].res);

    }


    if(q[i].op == OP_NULL){
      int j = 0;
      //if the item exists in the symbol table already
      //that is this
      if(c->isThere(q[i].arg1)) continue;
      for(;q[i].arg1[j] != '\0';j++){ 
	if(isdigit(q[i].arg1[j]) || q[i].arg1[j] == '.' || q[i].arg1[j] == '-');
	else break;
      }
      if(q[i].arg1[j] != '\0'){
	//indeed a string
	rout << ".LC" << str << ":" << endl;
	ROUT << ".string" << q[i].arg1 << endl;
	stringAssignments.insert(pair<int,int>(i,str)); 
	str++;
      }
    } 
  }

  //to handle labels
  //go throught the entire qa and map destination of each to a label
  //only applicable for the jmp type instructions
  map<int, int> jumpDestination;

  //have another map for target labels generation
  map<int, int> labelValue;

  //pre pass for this purpose
  for(int i = 0;i < q.size();i++){
    if((q[i].op == OP_GOTO) || (q[i].op == OP_LT) || (q[i].op == OP_GT) || (q[i].op == OP_LTE) || (q[i].op == OP_GTE) || (q[i].op == OP_E) || (q[i].op == OP_NE)){
      int target = atoi(q[i].res);
      jumpDestination.insert(pair<int,int>(i, str));
      labelValue.insert(pair<int,int>(target, str));
      str++;
    }
  }

  //list of pointers expression temporaries
  set<int> tempPointers;
  //list of array expression temporaries
  map<int, string> tempArrays;

  rout << "\t" << ".text" << endl;

  for(int i = 0;i < q.size();i++){

    //label generation
    if(labelValue.count(i) != 0){
      rout << ".L" << (labelValue.find(i))->second << ":" << endl;
    }


    //function
    if(q[i].op == OP_SEC){

      //clear existing offset map
      paramOffsets.clear();
      //clear existing tempReg map
      tempReg.clear();
      //reset the freeReg variable 
      freeReg = 'a';
      //clear pointer temporaries
      tempPointers.clear();
      //clear pointer temporaries
      tempArrays.clear();

      //check if some function was on previously - if so complete it
      if(currentFunction != NULL){
	ROUT << "leave" << endl;
	ROUT << "ret" << endl;
	ROUT << ".size " << currentFunction << ", .-" << currentFunction << endl;
      } 

      //function start lines
      ROUT << ".globl " << q[i].res << endl;
      ROUT << ".type " << q[i].res << ", @function" << endl;
      rout << q[i].res << ":" << endl;

      currentFunction = q[i].res;

      //at this point look at the symbol table and create the AR
      AR = (global.getNST(currentFunction))->createAR();
      //printing to stdout for debugging
      /*
	 for (map<string,int>::iterator it=AR->begin(); it!=AR->end(); ++it)
	 cout << it->first << " => " << it->second << '\n';
       */

      //now for the standard function opening
      ROUT << "pushl" << BP << endl; 
      ROUT << "movl" << SP << ", " << BP << endl; 

      //allocating space in the stack for the local variables
      //not very clear - going to go with additional 8 memory after that actually required
      //it needs to accomodate every function call that occurs
      //need to go through the entire quad array -> and create a meta data table for function calls atleast

      //everything is being done for integers only

      int k = 0;
      maxk = 0;
      for(j=i+1;q[j].op != OP_RET;j++){
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

      ROUT << "subl" << "$" << ss << ", " << SP << endl; 

      //may be also store some local variables that are initialized at declaration
      map<string,int>* valMap = global.getNST(currentFunction)->getInitialValues();          
      //write the corresponding code statements
      for (map<string,int>::iterator it=valMap->begin(); it!=valMap->end(); ++it){
	ROUT << "movl" << "$" << it->second << ", " << AR->find(it->first)->second << "(" << BP << ")" << endl; 
      }
      delete valMap;
    }
    else if(q[i].op == OP_PARAM){
      if(q[i].res[0] == '$'){
	//param is a temporary
	//hopefully this assumption holds

	//the map is from quads that get assigned with the string
	//this param is however the next instruction

	if(stringAssignments.count(i-1) != 0){
	  //if the const is a string
	  ROUT << "movl" << "$.LC" << (stringAssignments.find(i-1))->second << ", (" << SP << ")" << endl; 
	}
	else{
	  ROUT << "movl" << "%e" << tempReg.find(q[i].res)->second << "x, " <<  paramOffsets.find(i)->second << "(" << SP << ")" << endl;
	  //assuming that this implies an use of the temporary -> so we 
	  tempReg.erase(q[i].res);
	  freeReg--;
	  if(freeReg < 'a') freeReg = 'a';
	}
      }
      else if(AR->count(q[i].res) != 0){
	//if the param is a variable       
	ROUT << "movl" << (AR->find(q[i].res))->second << "(" << BP << "), " << "%eax" << endl; 
	ROUT << "movl" << "%eax, " <<  paramOffsets.find(i)->second << "(" << SP << ")" << endl;
      }
      else{
	//param is a constant
	ROUT << "movl" << "$" << q[i].res << ", " << paramOffsets.find(i)->second << "(" << SP << ")" << endl;
      }
    }
    else if(q[i].op == OP_CALL){
      ROUT << "call" << q[i].arg1 << endl;   
       
      //if eax is used move it to some other register
      for (map<string,char>::iterator it=tempReg.begin(); it!=tempReg.end(); ++it){
        if(it->second == 'a')    
          it->second = freeReg;    
      }
      freeReg++;
      if(freeReg == 'e') freeReg = 'b';
      tempReg.insert(pair<string, char>(string(q[i].res), 'a'));
    }
    else if(q[i].op == OP_RET){
      if(q[i].res[0] != '$'){
	//aka a variable
	ROUT << "movl" << (AR->find(q[i].res))->second << "(" << BP << "), " << "%eax" << endl;
      }
      else{
	//aka a temporary
	//move the item from whatever register to %eax if not already in eax
	if((tempReg.find(q[i].res))->second != 'a'){
	  ROUT << "movl" << "%e" << (tempReg.find(q[i].res))->second << "x, " << "%eax" << endl;
	}
      }
    }   
    else if(q[i].op == OP_ARRAY_ACCESS){  
      //array case : intiialization

      //the target is always an temporary
      tempReg.insert(pair<string, char>(q[i].res, freeReg));
      freeReg++;  //the next register
      if(freeReg == 'e') freeReg = 'a';


      char* access = new char[25];

      if(q[i].arg2[0] == '$'){
	//arg2 is a temporary
	sprintf(access, "%d(%%ebp,%%e%cx,4)", (AR->find(q[i].arg1))->second, tempReg.find(q[i].arg2)->second);

        ROUT << "movl" << access << ", %e" << tempReg.find(q[i].res)->second << "x" << endl;
	//ROUT << "movl" << (AR->find(q[i].arg1))->second << "(" << BP << ",%e" << tempReg.find(q[i].arg2)->second << "x,4), " << tempReg.find(q[i].res)->second << endl; 
      }
      else if(AR->count(q[i].arg2) != 0){
	//arg2 is a variable
	ROUT << "movl" << (AR->find(string(q[i].arg2)))->second << "(" << BP << "), " << "%e" << freeReg << "x" << endl; 
	sprintf(access,"%d(%%ebp,%%e%cx,4)" , (AR->find(q[i].arg1))->second, freeReg);
	ROUT << "movl" << access << ", %e" << tempReg.find(q[i].res)->second << "x" << endl; 
      }
      else{
	//arg2 is a constant
	//assuming only integers   
	int off = atoi(q[i].arg2);  
	off *= 4;
	sprintf(access, "%d(%%ebp)", (AR->find(q[i].arg1))->second + off); 
	ROUT << "movl" << access << ", %e" << tempReg.find(q[i].res)->second << "x" << endl; 
      }

      //for the need in rhs side
      tempArrays.insert(pair<int, string>(q[i].res[2], access));

    }
    else if(q[i].op == OP_NULL){ // direct assignment 

      //temp = const
      if(q[i].res[0] == '$'){
	//do nothing if it is a string
	if(stringAssignments.count(i) != 0){ }
	else if(AR->count(q[i].arg1) != 0){
	  //temp = var 
	  tempReg.insert(pair<string, char>(q[i].res, freeReg));
	  freeReg++;  //the next register
	  if(freeReg == 'e') freeReg = 'a';
	  //if the lhs were involved in a pointer assignment
	  if(tempPointers.count(q[i].res[2]) != 0){
	    ROUT << "movl" << (AR->find(q[i].arg1))->second << "(" << BP << "), %e" << freeReg << "x" << endl;
	    ROUT << "movl" << "%e" << freeReg << "x, (%e" << (tempReg.find(q[i].res))->second << "x)" << endl;
	  }
	  else if(tempArrays.count(q[i].res[2]) != 0){
            //or a array access 
	    ROUT << "movl" << (AR->find(q[i].arg1))->second << "(" << BP << "), %e" << freeReg << "x" << endl;
            ROUT << "movl" << "%e" << freeReg << "x, " << tempArrays.find(q[i].res[2])->second << endl; 
	  }
	  else{
	    //normal case
	    ROUT << "movl" << (AR->find(q[i].arg1))->second << "(" << BP << "), %e" << tempReg.find(q[i].res)->second << "x" << endl;
	  }
	}
	else{
	  //temp = const
	  //enter into the mapping
	  tempReg.insert(pair<string, char>(q[i].res, freeReg));
	  freeReg++;  //the next register
	  if(tempPointers.count(q[i].res[2]) != 0){
	    //if lhs were invloved in a pointers case
	    ROUT << "movl" << "$" << q[i].arg1 << ", (%e" << tempReg.find(q[i].res)->second << "x)" << endl;
	  }
	  else if(tempArrays.count(q[i].res[2]) != 0){
	    //if it were involved in a arrays case
	    ROUT << "movl" << "$" << q[i].arg1 << ", " << tempArrays.find(q[i].res[2])->second << endl;
	  }
	  else{
	    //normal case
	    ROUT << "movl" << "$" << q[i].arg1 << ", %e" << tempReg.find(q[i].res)->second << "x" << endl;
	  }
	}
      }
      else if(q[i].arg1[0] == '$'){
	//var = temp
	if(tempPointers.count(q[i].arg1[2]) != 0){
	  //var  = temp when the temp is pointer
	  ROUT << "movl" << "(%e" << (tempReg.find(q[i].arg1))->second << "x), %e" << (tempReg.find(q[i].arg1))->second << "x" << endl;
	  //after this additional calaulation continue with same logic
	}

	//var = temp ordinary case
	ROUT << "movl" << "%e" << (tempReg.find(string(q[i].arg1)))->second << "x" <<  ", " << (AR->find(string(q[i].res)))->second << "(" << BP << ")" << endl;
	//assuming that this implies an use of the temporary -> so we 
	tempReg.erase(q[i].arg1);
	//problem here
	freeReg--;
	if(freeReg < 'a') freeReg = 'a';
      }
      else{
	//var = var
	ROUT << "movl" << (AR->find(string(q[i].arg1)))->second << "(" << BP << "), " << "%e" << freeReg << "x" << endl; 
	ROUT << "movl" << "%e" << freeReg << "x, " << (AR->find(string(q[i].res)))->second << "(" << BP << ")" << endl; 

	//var = const
	//this category is actually never used
	//maybe needed when code is optimized
	/*
	   ROUT << "movl" << "$" << q[i].arg1 << ", " << (AR->find(q[i].res))->second << "(" << BP << ")" << endl;
	 */
      }
    }
    else if(q[i].op == OP_STAR){  
      //for the pointers start quad
      //move the pointer value to the temporary
      ROUT << "movl" << (AR->find(q[i].arg1))->second << "(" << BP << "), %e" << freeReg << "x" << endl;
      tempReg.insert(pair<string, char>(q[i].res, freeReg));
      freeReg++;
      if(freeReg == 'e') freeReg = 'a';
      //also add it to the list of temporaries involved in a pointer expression
      tempPointers.insert(q[i].res[2]);
    }
    else if(q[i].op == OP_PLUS || q[i].op == OP_MINUS || q[i].op == OP_MULT){
      //there cannot be a constant involved by design 

      //using addl defn of x86-32
      char resReg;   //holds the result register
      char opReg2;   //the operand 2 as the first operand is same as result

      //examine the first operand
      if(q[i].arg1[0] == '$'){
	//temporary
	//if it were a pointer
	if(tempPointers.count(q[i].arg1[2]) != 0)
	  ROUT << "movl" << "(%e" << tempReg.find(q[i].arg1)->second << "x), %e" << tempReg.find(q[i].arg1)->second << "x" << endl; 

	resReg = (tempReg.find(q[i].arg1))->second;
      }
      else{
	//variable
	//=>load it in a temporary and set this new temp as the result
	ROUT << "movl" << (AR->find(q[i].arg1))->second << "(" << BP << "), %e" << freeReg  << "x" << endl;
	resReg = freeReg; 
	freeReg++;  
	if(freeReg == 'e') freeReg = 'a';
      }

      //examine the second operand
      if(q[i].arg2[0] == '$'){
	//temporary
	//if it were a pointer
	if(tempPointers.count(q[i].arg2[2]) != 0)
	  ROUT << "movl" << "(%e" << tempReg.find(q[i].arg2)->second << "x), %e" << tempReg.find(q[i].arg2)->second << "x" << endl; 
	opReg2 = (tempReg.find(q[i].arg2))->second;
      }
      else if(AR->count(q[i].arg2) == 0){
	//constant -> in case of inc and dec
	ROUT << "movl" << "$" <<  q[i].arg2 << ", %e" << freeReg  << "x" << endl;
	opReg2 = freeReg; 
	freeReg++;
	if(freeReg == 'e') freeReg = 'a';
      }
      else{
	//variable
	//=>load it in a temporary and set this new temp as the argument
	ROUT << "movl" << (AR->find(q[i].arg2))->second << "(" << BP << "), %e" << freeReg  << "x" << endl;
	opReg2 = freeReg; 
	freeReg++;  
	if(freeReg == 'e') freeReg = 'a';
      }

      //now the actual operation
      if(q[i].op == OP_PLUS)
	ROUT << "addl" << "%e" << opReg2 << "x" << ", %e" << resReg << "x" << endl;
      else if(q[i].op == OP_MINUS)
	ROUT << "subl" << "%e" << opReg2 << "x" << ", %e" << resReg << "x" << endl;
      else if(q[i].op == OP_MULT)
	ROUT << "imull" << "%e" << opReg2 << "x" << ", %e" << resReg << "x" << endl;

      //freeReg--;

      //Now to move the result to the correct place
      if(q[i].res[0] == '$'){
	//the destination is a temporary
	tempReg.insert(pair<string,char>(q[i].res,resReg));
	//freeReg++;

	//ROUT << "movl" << "%e" << resReg << "x" << ", %e" << (tempReg.find(q[i].res))->second << "x" << endl;
      }
      else{
	//the destination is a variable
	ROUT << "movl" << "%e" << resReg << "x" << ", " << (AR->find(q[i].res))->second << "(" << BP << ")" << endl;

      }

      //we can afford to let both go away
      //ideally freeReg is decremented twice
      freeReg--;
      if(freeReg < 'a') freeReg = 'a';

      //These are the cases handled above

      //both temporary
      //only one temporary and other variable
      //both variable

    }
    else if(q[i].op == OP_AND){
      //pointer address assignment
      //assuming the rhs will be a variable

      tempReg.insert(pair<string, char>(q[i].res, freeReg));
      freeReg++;
      if(freeReg == 'e') freeReg = 'a';
      ROUT << "leal" << (AR->find(q[i].arg1))->second << "(" << BP << "), %e" << (tempReg.find(q[i].res))->second << "x" << endl;
    }
    else if(q[i].op == OP_GOTO){
      ROUT << "jmp" << ".L" << (jumpDestination.find(i))->second << endl;
    }
    else if((q[i].op == OP_LT) || (q[i].op == OP_GT) || (q[i].op == OP_LTE) || (q[i].op == OP_GTE) || (q[i].op == OP_E)|| (q[i].op == OP_NE)){

      //Logic from the ADD section copied verbatim

      //there cannot be a constant involved by design 
      //using addl defn of x86-32
      char resReg;   //holds the result register
      char opReg2;   //the operand 2 as the first operand is same as result

      //examine the first operand
      if(q[i].arg1[0] == '$'){
	//temporary
	resReg = (tempReg.find(q[i].arg1))->second;
      }
      else{
	//variable
	//=>load it in a temporary and set this new temp as the result
	ROUT << "movl" << (AR->find(q[i].arg1))->second << "(" << BP << "), %e" << freeReg  << "x" << endl;
	resReg = freeReg; 
	freeReg++;  
	if(freeReg == 'e') freeReg = 'a';
      }

      //examine the second operand
      if(q[i].arg2[0] == '$'){
	//temporary
	opReg2 = (tempReg.find(q[i].arg2))->second;
      }
      else{
	//variable
	//=>load it in a temporary and set this new temp as the argument
	ROUT << "movl" << (AR->find(q[i].arg2))->second << "(" << BP << "), %e" << freeReg  << "x" << endl;
	opReg2 = freeReg; 
	freeReg++;  
	if(freeReg == 'e') freeReg = 'a';
      }

      //for all this do the same compl calculation
      ROUT << "cmpl" << "%e" << opReg2 << "x" << ", %e" << resReg << "x" << endl; 
      freeReg--;
      freeReg--;
      freeReg--;
      if(freeReg < 'a') freeReg = 'a';

      //and then the specific instr
      string instr;
      switch(q[i].op){
	case OP_E: instr = "je";break;
	case OP_NE: instr = "jne";break;
	case OP_LT: instr = "jl";break;
	case OP_GT: instr = "jg";break;
	case OP_LTE: instr = "jle";break;
	case OP_GTE: instr = "jge";break;
	default: break;
      }
      ROUT << instr << ".L" << (jumpDestination.find(i))->second << endl;
    }
    else{

    }
  }

  //    if((q[i].op == OP_GOTO) || (op == OP_LT) || (op == OP_GT) || (op == OP_LTE) || (op == OP_GTE)){

  //the conclusion for the last function
  ROUT << "leave" << endl;
  ROUT << "ret" << endl;
  ROUT << ".size " << currentFunction << ", .-" << currentFunction << endl;

  //end of file
  ROUT << ".ident" << "\"Chander G : c compiler\"" << endl;

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
