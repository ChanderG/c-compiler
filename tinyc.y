//ChanderG - chandergovind@gmail.com 
%{
  #include<iostream>
  using namespace std;

  extern int yylex();  
  void yyerror(const char *s);

  
  #include"lexmain.h"

  #include<cstring>  //for strdup
 
  //global point of contact for current type,size etc in declarations
  struct ts_2 ts_global;
  symboltable global;      //the outermost symbol table
  symboltable *current;    // pointer to the current table

  QuadArray qa;            //global array of quads holding structure

%}
%union {
  char *sval;
  char cval;
  int ival;
  float fval;

  struct ts_ ts; // for type-specifier

  struct exp_ exp; // for expressions
  struct bexp_ bexp; // for boolean expressions
  unary_op unop;     //for conveying type of unary expression
  struct s_ s;    //for statements of all kind
}

//look in the header file for the definitions of these types

%token <sval> IDENTIFIER
%token <ival> INTEGER_CONSTANT
%token <fval> FLOATING_CONSTANT
%token <cval> CHARACTER_CONSTANT
%token <sval> STRING_LITERAL
%token <sval> SINGLE_LINE_COMMENT
%token <sval> MULTI_LINE_COMMENT

%type <ts> type_specifier
%type <sval> constant 

%type <exp> primary_expression
%type <exp> postfix_expression
%type <exp> unary_expression
%type <exp> cast_expression
%type <exp> multiplicative_expression
%type <exp> additive_expression
%type <exp> shift_expression

%type <bexp> relational_expression
%type <bexp> equality_expression
%type <bexp> and_expression
%type <bexp> exclusive_or_expression
%type <bexp> inclusive_or_expression
%type <bexp> logical_and_expression
%type <bexp> logical_or_expression
%type <bexp> conditional_expression

%type <bexp> assignment_expression
%type <bexp> assignment_expression_opt
%type <bexp> expression
%type <bexp> expression_opt
%type <unop> unary_operator
%type <ival> M
%type <s> N

%type <s> statement
%type <s> selection_statement
%type <s> expression_statement
%type <s> block_item
%type <s> block_item_list
%type <s> compound_statement
%type <s> iteration_statement
%type <s> jump_statement

%type <sval> direct_declarator
%type <sval> declarator
%type <sval> initializer

%type <ival> argument_expression_list_opt 
%type <ival> argument_expression_list

//tokens
%token WS

%token COLON
%token SEMI_COLON

%token CASE
%token DEFAULT

%token CURLY_OPEN
%token CURLY_CLOSE

%token PARAN_OPEN
%token PARAN_CLOSE

%token SQ_OPEN SQ_CLOSE

%token IF ELSE SWITCH FOR
%token WHILE DO
%token GOTO CONTINUE BREAK RETURN
%token COMMA EQUAL

%token EXTERN STATIC AUTO REGISTER
%token VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED _BOOL _COMPLEX _IMAGINARY

%token ENUM

%token CONST RESTRICT VOLATILE

%token INLINE

%token STAR ELIPSIS DOT

%token DEREF

%token INC DEC
%token SIZEOF

%token PLUS MINUS TILDE EX

%token AND OR

%token BY MOD
%token SL SR
%token LT GT LTE GTE E NE

%token CAP
%token Q
%token ANDAND OROR
%token STAREQUAL BYEQUAL MODEQUAL PLUSEQUAL MINUSEQUAL SLEQUAL SREQUAL ANDEQUAL CAPEQUAL OREQUAL

//associativity rules

%nonassoc LOWER_THAN_ELSE
%nonassoc  ELSE

//takes care of just the binary operators
%left PLUS MINUS
%left STAR RIGHT
%nonassoc UPLUS UMINUS
%nonassoc USTAR
%nonassoc U



%%
//rules section - for now printing correct is used

program: {
           //cout << "Start of program" << endl;
	   current  = &global;
	 } 
	 translation_unit 
	 {
	   current->print();
	   //qa.printTable();
	   //qa.print();
           //cout << "End of program" << endl;
	 }
	 ;

translation_unit: external_declaration 
                  { //cout << "a";
		  }
                  | translation_unit external_declaration
		  { // cout << "External declaration found";
		  }
		  ;

//now external declaration only involves functions, no variables Sec2.4 of reqmts
external_declaration : function_definition
                       { }
		       //| declaration
		       // {} 
		       ;

//removing declaration_list_opt and considering the first part to be the entire function header
function_definition : {
                        ts_global.offset = 0;
                      } 
		      declaration_specifiers declarator
		      {
		        //the required action for creating the function and associated symbol table has been moved to the last rule of direct_declarator.
			//The declarator $2 consists of <main(int argc, char** argv)>

			//Additionally create an empty line to distinguish between arguments and local variables
                        current->genBreak(); 
		      }
		      //declaration_list_opt
		      compound_statement_or_semicolon
		      ;

//only print if it is a full function definition
compound_statement_or_semicolon: compound_statement 
				 {
				   current->print();
				   current = &global;  
				 }
				 | SEMI_COLON
				 {
				   current = &global;  
				   //a section label has been mistakenly entered
				   qa.demit();
				 };

/*// the original main to handle the whole application
function_definition : { 
                        ts_global.offset = 0;
                      } 
                      type_specifier IDENTIFIER PARAN_OPEN PARAN_CLOSE
		      {
                        current = global.updatef($3, "func", 0, ts_global.offset);
		      }
		      compound_statement
		      {
			current->print();
                        current = &global;  
		      }
		      ;
*/

/*
declaration_list_opt : declaration_list 
                       { }
		       | epsilon
		       ;

declaration_list : declaration
                   { }
		   | declaration_list declaration
		   { }
		   ;
*/

epsilon : ;   //epsilon transition

//Section 3:  Statements

statement :  labeled_statement
            { }
	    | compound_statement
	    {
	      $$ = $1;
	    }
	    | expression_statement
	    {
	      $$.nextlist = NULL;
	    }
	    | selection_statement
	    {  
	      $$ = $1;
	    }
            | iteration_statement
	    {
	      $$ = $1;
	    }
            | jump_statement
	    { 
	      $$ = $1;
	    }
            ; 


labeled_statement : IDENTIFIER COLON statement
                    { //cout << "labeled_statement" << endl;
		    }
		    | CASE constant_expression COLON statement 
		    { //cout << "labeled_statement" << endl;
		    }
		    | DEFAULT COLON statement
		    { //cout << "labeled_statement" << endl;
		    }
		    ;

compound_statement : CURLY_OPEN block_item_list M CURLY_CLOSE 
                     { //cout << "stmt" << endl;
		       qa.backpatch($2.nextlist, $3);
		       $$ = $2;
		     }
		     |
                     CURLY_OPEN CURLY_CLOSE 
                     {
		       $$.nextlist = NULL;
		     }
		     ;

block_item_list: block_item
                 {
		   $$ = $1;
		 }
		 | block_item_list M block_item
		 {
		   //$$.nextlist = merge($1.nextlist, $2.nextlist);
                   qa.backpatch($1.nextlist, $2);
		   $$.nextlist = $3.nextlist;
		 }
		 ;

block_item: statement 
            {
	      $$ = $1;
	    }
	    | declaration
	    {
	      $$.nextlist = NULL;
	    }
	    ;

expression_statement: expression_opt SEMI_COLON
                      {
		        $$.nextlist = NULL;
		      }
		      ;

expression_opt: epsilon
                {
                  $$.loc = NULL; 
		}
                | expression
		{
                  $$ = $1;  
		}
		;

selection_statement : IF PARAN_OPEN expression PARAN_CLOSE M statement %prec LOWER_THAN_ELSE
                      {
		        qa.backpatch($3.truelist, $5);
			$$.nextlist = merge($3.falselist, $6.nextlist);
		      } 
		      | IF PARAN_OPEN expression PARAN_CLOSE M statement ELSE N M statement
                      {
		        qa.backpatch($3.truelist, $5);
		        qa.backpatch($3.falselist, $9);
			$$.nextlist = merge(merge($6.nextlist, $8.nextlist), $10.nextlist);
		      }
		      | SWITCH PARAN_OPEN expression PARAN_CLOSE statement
		      {}
		      ;
iteration_statement : WHILE M PARAN_OPEN expression PARAN_CLOSE M statement
                      {
		        qa.backpatch($7.nextlist, $2);
			qa.backpatch($4.truelist, $6);
			$$.nextlist = $4.falselist;
			char* label = new char[5];
			sprintf(label, "%d", $2);
			qa.emit(label, OP_GOTO);
		      } 
		      | DO M statement M WHILE PARAN_OPEN expression PARAN_CLOSE SEMI_COLON
		      {
		        qa.backpatch($7.truelist, $2);
			qa.backpatch($3.nextlist, $4);
			$$.nextlist = $7.falselist;
		      }
		      | FOR PARAN_OPEN expression_opt SEMI_COLON M expression_opt SEMI_COLON M expression_opt N PARAN_CLOSE M statement
		      {
		        qa.backpatch($6.truelist, $12);
		        qa.backpatch($10.nextlist, $5);
		        qa.backpatch($13.nextlist, $8);

			char* label = new char[5];
			sprintf(label, "%d", $8);
			qa.emit(label, OP_GOTO);
                        $$.nextlist = $6.falselist; 
		      }
		      | FOR PARAN_OPEN declaration SEMI_COLON expression_opt SEMI_COLON expression_opt PARAN_CLOSE statement
		      {}
		      ;

jump_statement : GOTO IDENTIFIER SEMI_COLON
                 {} 
		 | CONTINUE SEMI_COLON
		 {}
		 | BREAK SEMI_COLON
		 {}
		 | RETURN expression_opt SEMI_COLON
		 {
		   //return statement
		   qa.emit($2.loc, OP_RET);
		   $$.nextlist = NULL;
		 }
		 ;

constant_expression: {};


//Section 2: Declarations
//Open to change

declaration: {
               //cout << "Dec\n";  
             }
             type_specifier
	     {
	     }
	     init_declarator_list_opt SEMI_COLON
             {
               //cout << "test\n";    
	     }
	     ;

//open to misuse
declaration_specifiers_opt:  declaration_specifiers | epsilon;

declaration_specifiers: //storage_class_specifier declaration_specifiers_opt
			type_specifier declaration_specifiers_opt
			{}
	                //| type_qualifier declaration_specifiers_opt
			//| function_specifier declaration_specifiers_opt
			;

init_declarator_list_opt: epsilon
                          | init_declarator_list
			  { }
			  ;

init_declarator_list: init_declarator
                      {}
		      |
		      init_declarator_list COMMA init_declarator
		      ;

//Add the additional equality action here
init_declarator: declarator  
                 {}
		 | declarator EQUAL initializer
		 {
		   current->update($1,current->getValue($3));
		   current->removeConstantTemp();
		   qa.demit();
		 }
		 ;

//storage_class_specifier: EXTERN | STATIC | AUTO | REGISTER;



type_specifier: VOID
		{
                  $$.type = strdup("void"); $$.width = 0; 
		  ts_global.type = strdup($$.type);
		  ts_global.width = $$.width;
		}
                |
                CHAR 
		{
                  $$.type = strdup("char"); $$.width = 1; 
		  ts_global.type = strdup($$.type);
		  ts_global.width = $$.width;
		}
		| // SHORT |
                INT 
		{ //next
                  $$.type = strdup("int"); $$.width = 4; 
		  ts_global.type = strdup($$.type);
		  ts_global.width = $$.width;
		}
		|// LONG | FLOAT |
		DOUBLE 
		{
                  $$.type = strdup("double"); $$.width = 8; 
		  ts_global.type = strdup($$.type);
		  ts_global.width = $$.width;
		}
		//| SIGNED | UNSIGNED | _BOOL | _COMPLEX | _IMAGINARY | enum_specifier;
                ; 

specifier_qualifier_list: type_specifier specifier_qualifier_list_opt
                          //| type_qualifier specifier_qualifier_list_opt
			  ;

specifier_qualifier_list_opt: epsilon | specifier_qualifier_list;

/*
enum_specifier: ENUM identifier_opt CURLY_CLOSE  
                | ENUM identifier_opt_w_comma CURLY_CLOSE  
		| ENUM IDENTIFIER
		;

identifier_opt: IDENTIFIER CURLY_OPEN enumerator_list | epsilon CURLY_OPEN enumerator_list;

identifier_opt_w_comma: IDENTIFIER CURLY_OPEN enumerator_list COMMA | epsilon CURLY_OPEN enumerator_list COMMA;

enumerator_list: enumerator
                 | enumerator_list COMMA enumerator
		 ;

enumerator: enumeration_constant
            | enumeration_constant EQUAL constant_expression
	    ;
	    
enumeration_constant: IDENTIFIER;
*/

type_qualifier: CONST | RESTRICT | VOLATILE;

//function_specifier: INLINE;

/*
declarator: pointer_opt direct_declarator;
*/

pointer_opt: epsilon| pointer;

//Maybe the adding to the symbol table should be done here.
declarator: direct_declarator
            {
              $$ = $1;
	    }
            | pointer direct_declarator 
	    {
	      //adding a pointer to ts_global.type
              $$ = $2;
	      //create the ptr type from the existing type
	      char* ptr_type = new char[10];
	      strcpy(ptr_type, "ptr(");
	      strcat(ptr_type, current->getType($2));
	      strcat(ptr_type, ")");
	      //subtract the old size - repair offset
	      ts_global.offset -= current->getSize($2); 
	      //overloaded update function for updating the type and size
	      //the offset, will be the same old value
	      current->update($2 ,ptr_type, SIZEOF_PTR); 
	      //add the new size - correct offset
	      ts_global.offset += SIZEOF_PTR; 
	      delete(ptr_type);
	    };

//we enter the variable into the symbol table
//and make required corrections later
direct_declarator: IDENTIFIER
                   {
                     $$ = $1;
		     //add variable to symbol table
		     //will get messed up if a varible of same name exists already
		     current->update($1, ts_global.type, ts_global.width, ts_global.offset);
		     ts_global.offset += ts_global.width; 
		   }
                   | PARAN_OPEN declarator PARAN_CLOSE 
		   {
                     $$ = $2; 
		   }
		   | direct_declarator SQ_OPEN type_qualifier_list_opt assignment_expression_opt SQ_CLOSE 
		   {
		     //$1 has already been entered into the table, just update it
		     //here going to assume only known right types of inputs are given

		     int nos = atoi(current->getValue($4.loc));
		     //however the global offset has been given a wrong value
		     ts_global.offset -= current->getSize($1); 

		     current->update($1, nos);
		     //update global offset once again 
		     ts_global.offset += current->getSize($1); 

		     //the constant used here is completely unecessary - so removing that entry and the associated quad
		     current->removeConstantTemp();
		     qa.demit();
		   }
		   | direct_declarator SQ_OPEN STATIC type_qualifier_list_opt assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list STATIC assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list_opt STAR SQ_CLOSE
		   | direct_declarator
		   {
		      //at this point the <void> <main> has been mistakenly entered into the symbol table
		      char* ret_type = current->getType($1); 
		      int ret_size = current->getSize($1); 
		      ts_global.offset -= ret_size;
		      current = global.updatef($1,"function", 0, global.lastOffset());
		      //current now points to the new symbol table
		      
		      //emit a section label at the start
		      qa.emitSection($1);

		      //add the <void> return type to this table
		      current->update(ret_type);

		      //the declaration_list that follows will now be correctly added
		   }
		   PARAN_OPEN param_or_identi PARAN_CLOSE
		   //| direct_declarator PARAN_OPEN identifier_list_opt PARAN_CLOSE

		   ;

param_or_identi: parameter_type_list | identifier_list_opt;


type_qualifier_list_opt: epsilon | type_qualifier_list;
assignment_expression_opt: epsilon 
                           {
			     $$.loc = NULL;
			   }
			   | assignment_expression
                           {
			     $$ = $1;
			   };

identifier_list_opt: epsilon | identifier_list;

pointer: STAR type_qualifier_list_opt pointer_opt;
       //  | STAR type_qualifier_list_opt pointer

type_qualifier_list: type_qualifier
                     | type_qualifier_list type_qualifier
                     ;

parameter_type_list: //epsilon|
                      parameter_list
                     | parameter_list COMMA ELIPSIS
		     ;

parameter_list: parameter_declaration
                | parameter_list COMMA parameter_declaration
		;

parameter_declaration: declaration_specifiers declarator
                       | declaration_specifiers
		       ;

identifier_list: IDENTIFIER
                 { 
		   argtype n1 = strdup($1);
		 }
                 | identifier_list COMMA IDENTIFIER
                 {
		   argtype n3 = strdup($3);
		   qa.emit(n3, OP_PARAM);
		 }
		 ;

type_name: specifier_qualifier_list;

initializer: assignment_expression 
             {
	       $$ = $1.loc;
	     }
             //| CURLY_OPEN initializer_list CURLY_CLOSE
	     //| CURLY_OPEN initializer_list COMMA CURLY_CLOSE
	     ;

initializer_list: designation_opt initializer
                  | initializer_list COMMA designation_opt initializer
		  ;

designation_opt: epsilon | designation;

designation: designator_list EQUAL;

designator_list: designator 
                 | designator_list designator
		 ;

designator: SQ_OPEN constant_expression SQ_CLOSE
            | DOT IDENTIFIER
	    ;

//Section 1: Expressions


primary_expression: IDENTIFIER
                    {
                      $$.loc = $1; 		      
		    }
		    | constant 
		    {
                      $$.loc = current->gentemp();
		      qa.emit($$.loc, $1);
		      current->update($$.loc, $1);
		    }
		    | STRING_LITERAL
		    {
                      $$.loc = current->gentemp();
		      qa.emit($$.loc, $1);
		      current->update($$.loc, $1);
		    }
		    | PARAN_OPEN expression PARAN_CLOSE
		    {
		      $$.loc = $2.loc; 
		    };

constant:  INTEGER_CONSTANT 
           { 
             $$ = new char[10];  
	     sprintf($$, "%d",$1);
           }
           | FLOATING_CONSTANT
	   {
             $$ = new char[10];  
	     sprintf($$, "%f",$1);
	   }
	   |CHARACTER_CONSTANT
	   {
             $$ = new char[10];  
	     sprintf($$, "'%c'",$1);
	   };

postfix_expression: primary_expression 
                   {
                     $$.loc = $1.loc; 
		   }
                   |
		   postfix_expression SQ_OPEN expression SQ_CLOSE
		   {
                     $$.loc = current->gentemp();
                     qa.emit($$.loc, $1.loc, OP_ARRAY_ACCESS, $3.loc); 
		   }
		   |
		   postfix_expression PARAN_OPEN argument_expression_list_opt PARAN_CLOSE
		   {
                     $$.loc = current->gentemp();
                     // $1.loc  
		     argtype n1 = new char[5];
		     sprintf(n1, "%d",$3);
                     qa.emit($$.loc, $1.loc, OP_CALL, n1); 
		   }
		   |
                   postfix_expression DOT IDENTIFIER
		   | 
		   postfix_expression DEREF IDENTIFIER
		   | 
		   postfix_expression INC
		   {
                     $$.loc = current->gentemp();
                     qa.emit($$.loc, $1.loc);
		     argtype n1 = new char[5];
		     sprintf(n1, "%d",1);
                     qa.emit($1.loc, $1.loc, OP_PLUS, n1);
		   }
                   | 
		   postfix_expression DEC
		   {
                     $$.loc = current->gentemp();
                     qa.emit($$.loc, $1.loc);
		     argtype n1 = new char[5];
		     sprintf(n1, "%d",1);
                     qa.emit($1.loc, $1.loc, OP_MINUS, n1);
		   }
		   | PARAN_OPEN type_name PARAN_CLOSE CURLY_OPEN initializer_list CURLY_CLOSE
		   { //simply to keep it quiet
                     $$.loc = NULL; 
		   }
		   | PARAN_OPEN type_name PARAN_CLOSE CURLY_OPEN initializer_list COMMA CURLY_CLOSE
		   {//simply to keep it quiet
                     $$.loc = NULL; 
		   }
		  ;

argument_expression_list_opt: epsilon
                              {
			        $$ = 0;
			      }
			      | argument_expression_list
			      {
			        $$ = $1;
			      }
			      ;

argument_expression_list: assignment_expression
			  {
			    $$ = 1;
			    qa.emit($1.loc, OP_PARAM);
			  }
                          | argument_expression_list COMMA assignment_expression
			  {
			    $$ = $1 + 1;
			    qa.emit($3.loc, OP_PARAM);
			  }
			  ;

unary_expression: postfix_expression 
                  {
                    $$.loc = $1.loc; 
		  }
                  | INC unary_expression
		  {
                    $$.loc = current->gentemp();
		    argtype n1 = new char[5];
		    sprintf(n1, "%d",1);
                    qa.emit($2.loc, $2.loc, OP_PLUS, n1);
                    qa.emit($$.loc, $2.loc);
		  }
		  | DEC unary_expression
		  {
                    $$.loc = current->gentemp();
		    argtype n1 = new char[5];
		    sprintf(n1, "%d",1);
                    qa.emit($2.loc, $2.loc, OP_MINUS, n1);
                    qa.emit($$.loc, $2.loc);
		  }
		  | unary_operator cast_expression %prec U
		  {
                    //the operator returns an enum value
                    switch($1){
		      case UN_PLUS: $$.loc = $2.loc; break;
		      case UN_MINUS: { $$.loc = current->gentemp();
				       qa.emit($$.loc, $2.loc, OP_MINUS);
				       break;
				     }
		      case UN_STAR: { $$.loc = current->gentemp();
				       qa.emit($$.loc, $2.loc, OP_STAR);
				       break;
				     }
		      case UN_AND: { $$.loc = current->gentemp();
				       qa.emit($$.loc, $2.loc, OP_AND);
				       break;
				     }
		      default: break;	     
		    }                    
		  }
		  | SIZEOF unary_expression
		  {
		    $$.loc = NULL;
		  }  
		  | SIZEOF PARAN_OPEN type_name PARAN_CLOSE %prec U
		  {
		    $$.loc = NULL;
		  }  
		  ;

unary_operator: AND
                {
                  $$ = UN_AND; 
		}
                | STAR
                {
                  $$ = UN_STAR; 
		}
                | PLUS
                {
                  $$ = UN_PLUS; 
		}
		| MINUS
                {
                  $$ = UN_MINUS; 
		}
		| TILDE 
                {
                  $$ = UN_NULL; 
		}
		| EX
                {
                  $$ = UN_NULL; 
		}
		;

cast_expression: unary_expression
		 {
		   $$.loc = $1.loc; 
		 }
                 | PARAN_OPEN type_name PARAN_CLOSE cast_expression
		 {
		   $$.loc = NULL;
		 }
		 ;

multiplicative_expression: cast_expression
			   {
			     $$.loc = $1.loc; 
			   }
                           | multiplicative_expression STAR cast_expression
			   {
			     $$.loc = current->gentemp();
			     qa.emit($$.loc, $1.loc, OP_MULT, $3.loc);
			   }   
			   | multiplicative_expression BY cast_expression
			   {
			     $$.loc = current->gentemp();
			     qa.emit($$.loc, $1.loc, OP_BY, $3.loc);
			   }   
			   | multiplicative_expression MOD cast_expression
			   {
			     $$.loc = current->gentemp();
			     qa.emit($$.loc, $1.loc, OP_PER, $3.loc);
			   }   
			   ;

additive_expression: multiplicative_expression
		     {
		       $$.loc = $1.loc; 
		     }
                     | additive_expression PLUS multiplicative_expression
		     {
		       $$.loc = current->gentemp();
		       qa.emit($$.loc, $1.loc, OP_PLUS, $3.loc);
		     }   
		     | additive_expression MINUS multiplicative_expression
		     {
		       $$.loc = current->gentemp();
		       qa.emit($$.loc, $1.loc, OP_MINUS, $3.loc);
		     }   
		     ;

shift_expression: additive_expression
		  {
		    $$.loc = $1.loc; 
		  }
                  | shift_expression SL additive_expression
		  | shift_expression SR additive_expression
		  ;

relational_expression: shift_expression
		       {
			 $$.loc = $1.loc; 
		       }
                       | relational_expression LT shift_expression
		       {
                         $$.truelist = makelist(qa.nextinstr());       
                         $$.falselist = makelist(qa.nextinstr() + 1);       
                         qa.emit("-1", $1.loc, OP_LT, $3.loc);
			 qa.emit("-1", OP_GOTO);
		       }
                       | relational_expression GT shift_expression
		       {
                         $$.truelist = makelist(qa.nextinstr());       
                         $$.falselist = makelist(qa.nextinstr() + 1);       
                         qa.emit("-1", $1.loc, OP_GT, $3.loc);
			 qa.emit("-1", OP_GOTO);
		       }
                       | relational_expression LTE shift_expression
		       {
                         $$.truelist = makelist(qa.nextinstr());       
                         $$.falselist = makelist(qa.nextinstr() + 1);       
                         qa.emit("-1", $1.loc, OP_LTE, $3.loc);
			 qa.emit("-1", OP_GOTO);
		       }
                       | relational_expression GTE shift_expression
		       {
                         $$.truelist = makelist(qa.nextinstr());       
                         $$.falselist = makelist(qa.nextinstr() + 1);       
                         qa.emit("-1", $1.loc, OP_GTE, $3.loc);
			 qa.emit("-1", OP_GOTO);
		       }
		       ;

equality_expression: relational_expression
		     {
		       $$.loc = $1.loc; 
		     }
                     | equality_expression E relational_expression
		     {
		       $$.truelist = makelist(qa.nextinstr());       
		       $$.falselist = makelist(qa.nextinstr() + 1);       
		       qa.emit("-1", $1.loc, OP_E, $3.loc);
		       qa.emit("-1", OP_GOTO);
		     }
		     | equality_expression NE relational_expression
		     {
		       $$.truelist = makelist(qa.nextinstr());       
		       $$.falselist = makelist(qa.nextinstr() + 1);       
		       qa.emit("-1", $1.loc, OP_NE, $3.loc);
		       qa.emit("-1", OP_GOTO);
		     }
		     ;

and_expression: equality_expression
	        {
		  $$.loc = $1.loc; 
	        }
                | and_expression AND equality_expression
		;

exclusive_or_expression: and_expression
			 {
			   $$.loc = $1.loc; 
			 }
                         | exclusive_or_expression CAP equality_expression
	                 ;

inclusive_or_expression: exclusive_or_expression
			 {
			   $$.loc = $1.loc; 
			 }
                         | inclusive_or_expression OR exclusive_or_expression
			 ;

logical_and_expression: inclusive_or_expression
			{
			  $$.loc = $1.loc; 
		        }
                        | logical_and_expression ANDAND M inclusive_or_expression
			{
                          qa.backpatch($1.truelist, $3);  
			  $$.truelist = $4.truelist;
			  $$.falselist = merge($1.falselist, $4.falselist); 
			}
			;

logical_or_expression: logical_and_expression 
		       {
		       	 $$.loc = $1.loc; 
		       }
                       | logical_or_expression OROR M logical_and_expression
		       {
		 	 qa.backpatch($1.falselist, $3);  
			 $$.truelist = merge($1.truelist, $4.truelist);
			 $$.falselist =  $4.falselist;
		       }
		       ;

conditional_expression: logical_or_expression
			{
			  $$.loc = $1.loc; 
		        }
                        | logical_or_expression Q expression COLON conditional_expression
			;

assignment_expression: conditional_expression 
		       {
		         //conversion function to be used here
			 $$ = $1;
		       }
                       | unary_expression assignment_operator assignment_expression
	               {
		         qa.emit($1.loc, $3.loc);
		       }
		       ;

assignment_operator: EQUAL 
                     | STAREQUAL | BYEQUAL | MODEQUAL | PLUSEQUAL | MINUSEQUAL | SLEQUAL | SREQUAL | ANDEQUAL | CAPEQUAL | OREQUAL;

expression: assignment_expression
            {
              $$ = $1; 
	    }
            | expression COMMA assignment_expression
	    ;

constant_expression: conditional_expression;

//Grammar augmentations
//M just as an integer value representing the instr discussed in class.Repn an instruction number
M : {
      $$ = qa.nextinstr(); 
    }
    ;

//empty transition with goto print
N: {
     $$.nextlist = makelist(qa.nextinstr());
     qa.emit("-1", OP_GOTO);
   }
   ;
%%
//main section - not required now
void yyerror(const char *s) {
  //cout << "ERROR" << endl;
  //cout << s << endl;
  // might as well halt now:
  //exit(-1);
}
