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
  unary_op unop;
  struct s_ s;    //for statements of all kind
}

%token <sval> IDENTIFIER
%token <ival> INTEGER_CONSTANT
%token <fval> FLOATING_CONSTANT
%token <cval> CHARACTER_CONSTANT
%token <sval> STRING_LITERAL
%token <sval> SINGLE_LINE_COMMENT
%token <sval> MULTI_LINE_COMMENT

%type <ts> type_specifier
%type <ival> constant //for now

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
%type <bexp> expression
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
           cout << "Start of program" << endl;
	   current  = &global;
	 } 
	 translation_unit 
	 {
	   current->print();
	   qa.printTable();
	   qa.print();
           cout << "End of program" << endl;
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
/*// temporarily over-ridden for simplification
function_definition : declaration_specifiers declarator declaration_list_opt compound_statement
		      ;
*/

function_definition : { cout << "fn" << endl; 
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
declaration_list_opt : declaration_list 
                       { }
		       | epsilon
		       ;

epsilon : ;   //epsilon transition

declaration_list : declaration
                   { }
		   | declaration_list declaration
		   { }
		   ;

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
	    { }
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

compound_statement : CURLY_OPEN block_item_list CURLY_CLOSE 
                     { //cout << "stmt" << endl;
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
		 | block_item_list block_item
		 {
		   $$.nextlist = merge($1.nextlist, $2.nextlist);
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
                | expression
		{}
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
		      | DO statement WHILE PARAN_OPEN expression PARAN_CLOSE SEMI_COLON
		      {}
		      | FOR PARAN_OPEN expression_opt SEMI_COLON expression_opt SEMI_COLON expression_opt PARAN_CLOSE statement
		      { }
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
		 {}
		 ;

constant_expression: {};


//Section 2: Declarations
//Open to change

declaration: {
               //cout << "Dec\n";  
             }
             type_specifier
	     {
	       ts_global.type = strdup($2.type);
	       ts_global.width = $2.width;
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
		      
init_declarator: declarator  
                 {}
		 | declarator EQUAL initializer
		 ;

//storage_class_specifier: EXTERN | STATIC | AUTO | REGISTER;



type_specifier: VOID |
                CHAR 
		{
                  $$.type = strdup("char"); $$.width = 1; 
		}
		| // SHORT |
                INT 
		{ //next
                  $$.type = strdup("int"); $$.width = 4; 
		}
		|// LONG | FLOAT |
		DOUBLE 
		{
                  $$.type = strdup("double"); $$.width = 8; 
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

declarator: pointer_opt direct_declarator;

pointer_opt: epsilon| pointer;

direct_declarator: IDENTIFIER
                   {
		     //add variable to symbol table
		     //will get messed up if a varible of same name exists already
		     current->update($1, ts_global.type, ts_global.width, ts_global.offset);
		     ts_global.offset += ts_global.width; 
		   }
                   | PARAN_OPEN declarator PARAN_CLOSE 
		   | direct_declarator SQ_OPEN type_qualifier_list_opt assignment_expression_opt SQ_CLOSE 
		   | direct_declarator SQ_OPEN STATIC type_qualifier_list_opt assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list STATIC assignment_expression SQ_CLOSE
		   | direct_declarator SQ_OPEN type_qualifier_list_opt STAR SQ_CLOSE
		   | direct_declarator PARAN_OPEN param_or_identi PARAN_CLOSE
		   ;

param_or_identi: parameter_type_list | identifier_list_opt;


type_qualifier_list_opt: epsilon | type_qualifier_list;
assignment_expression_opt: epsilon | assignment_expression;
identifier_list_opt: epsilon | identifier_list;

pointer: STAR type_qualifier_list_opt pointer_opt;
       //  | STAR type_qualifier_list_opt pointer

type_qualifier_list: type_qualifier
                     | type_qualifier_list type_qualifier
                     ;

parameter_type_list: parameter_list
                     | parameter_list COMMA ELIPSIS
		     ;

parameter_list: parameter_declaration
                | parameter_list COMMA parameter_declaration
		;

parameter_declaration: declaration_specifiers declarator
                       | declaration_specifiers
		       ;

identifier_list: IDENTIFIER
                 | identifier_list COMMA IDENTIFIER
		 ;

type_name: specifier_qualifier_list;

initializer: assignment_expression 
             | CURLY_OPEN initializer_list CURLY_CLOSE
	     | CURLY_OPEN initializer_list COMMA CURLY_CLOSE
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
		      argtype a1 = new char[5];
		      sprintf(a1, "%d",$1);
		      qa.emit($$.loc, a1);
		    }
		    | STRING_LITERAL
		    | PARAN_OPEN expression PARAN_CLOSE
		    {
		      //$$.loc = $2.loc; 
		    };

constant:  INTEGER_CONSTANT 
           { 
	     $$ = $1;
           }
           | FLOATING_CONSTANT | CHARACTER_CONSTANT;

postfix_expression: primary_expression 
                   {
                     $$.loc = $1.loc; 
		   }
                   |
		   postfix_expression SQ_OPEN expression SQ_CLOSE
		   |
		   postfix_expression PARAN_OPEN argument_expression_list_opt PARAN_CLOSE
		   |
                   postfix_expression DOT IDENTIFIER
		   | 
		   postfix_expression DEREF IDENTIFIER
		   | 
		   postfix_expression INC
                   | 
		   postfix_expression DEC
		   | 
		   PARAN_OPEN type_name PARAN_CLOSE CURLY_OPEN initializer_list CURLY_CLOSE
		   |
		   PARAN_OPEN type_name PARAN_CLOSE CURLY_OPEN initializer_list COMMA CURLY_CLOSE;

argument_expression_list_opt: epsilon | argument_expression_list;

argument_expression_list: assignment_expression
                          | argument_expression_list COMMA assignment_expression
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
		      default: break;	     
		    }                    
		  }
		  | SIZEOF unary_expression
		  | SIZEOF PARAN_OPEN type_name PARAN_CLOSE %prec U
		  ;

unary_operator: AND | STAR | PLUS
                {
                  $$ = UN_PLUS; 
		}
		| MINUS
                {
                  $$ = UN_MINUS; 
		}
		| TILDE | EX;

cast_expression: unary_expression
		 {
		   $$.loc = $1.loc; 
		 }
                 | PARAN_OPEN type_name PARAN_CLOSE cast_expression
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
		         //the value of the expression itself
			 $$.loc = current->gentemp();
			 qa.emit($$.loc, $1.loc);
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
  cout << s << endl;
  // might as well halt now:
  //exit(-1);
}
