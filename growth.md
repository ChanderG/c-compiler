#Growth of this project

###After e0e6410511be423887d95c81ccaa260dc362586f
Testing the waters mainly. Creating structure for coming work. lexmain.h added for global stuff.Decided to move in an agile manner, starting from simple declaration of int variables.Added growth.md

###After b68cf55b63554d02166b47503be1ef7e7fc32308
Created structure of symbol table, solved problem of type of non-terminals, have one rule prototype, commented out some bloated part. Need to figure out a way to keep the code cleaner.

###After 7eabd01d694e405aeb0bb748d0537ad09ec26cbb
Going with a global storage for declaration tree approach.

###After 6b25a9a19303acc2aafd236f35b4dcfeeab8d0c5
Now the function main has been fixed to help continue with declaration. Also, the declaration on first line of function is NOT going to be done.Started adding functions to the symbol table class for lookup and update. Moved all definitions from header to c/cpp file.Note that file is still a c file but has class stuff inside.

###After a03ae696cade8cd00bc8b1d9648bb24ec28ece92
Worries are on the static nature of symbol table. Also types are being represented as strings. Added necessary functions in symboltable, migrated c to fully cpp.

###After 20a2131c0a108da0639804287d491df9b680cb77
Moved offset initializer to function top. Mind you functions means only main. Also it just struck that the global symbol table means one level above. Mind you, have not found out how to manage multiple symbol tables.And accessing the right table from the right location. Added char and double w/ hardcoded size values.

###After c59b44d48f5347aab8a0e745290ccd468e551387
Now going to create the multiple symbol table arch.The idea is to have a current symbol table pointer with the global pointer. So when the function header is read, we create the function entry in global st and make current pt to it. When function body is done, bring current pointer back to global.  

Done: implemented nested table functionality. Working for main.

###After c450fe3063865f1aa14eb8c37c4f0133eb4119f6
Attempting to print for expressions. Now added id and const to E. Assumed const to be an integer for now.

###After - Added id and num to exp
Formatted Symbol table printing to ease matters.

###After - Formatted ST printout
Time to get the quads out.Going to use a class, underlying array as a vector. To manage the argtypes aka entries in the quad table, wanted to use boost::variant type. Settling with simple char* and atoi to get numbers out.

###After quad string functions not working
Now the errors have been corrected. Also the function is used to see the TAC in tabular form.One more function - print - is needed to print in the code format.Right now though the quad is fully ready.

###After Corrected printTable function
Created code for printing TAC in form of a program.


###After Added tac printing in code format
Introducing multiplication finally. Mind you assignment has not yet been introduced, so the t1.c produces a strange result. The whole cascading expressions thing has been handled by chaining up the first rules. Also removed the semicolon from end of generated TAC.

Mind you, all functions support only the amount implemented till then. This is agile.

###After Added multiplication expression
Some clean up.Also added div, mod.And plus, minus in expressions.

###After Added more binops;cleaned up a bit
Going for assignment expression by considering all expression types as a new type with only loc. The Boolean capability is being ignored now.

###After Added assignment expression as a statement
Added inc, dec operators.

###After Added ++ and -- 
Added unary + and -

###After added u + and -
Simplified unary operator handling, changed printing method too.

###After Corrected unary -
Working on &&. Added M transition. Going to use std::list for the lists. Need to add addiional classes of instructions in quad. Need to refine the printing method for code.

###After added m transition
Start from making boolean from relational operators. Added emit function for goto, makelist function using std::list. Added comparision based goto. Added < expression considered as a boolean expression. Successfully generated the required goto statements.

###After first boolean exp with reqd functions
Added simillar expressions for >,<=, >=, ==, !=.

###After Added other relop bool exp
Added backpatch function.Merge function. && exp taken care of. 

Two concerns : 
-using char* instead of string.
-multiple char-arrays point to same location in memory, instead of using strdup

###After Boolean exp && done
Added ||.

###After Added || exp
Question of type of expression. Right now just going with if loc == NULL. Starting work on if statements now.Cleaned code in statement section up a bit. IF code given, but not recogonized.

###After Corrected if statement;working perfectly
Adding N transition. Implemented if - else.A point of concern, all statements and compound blocks need to be given nextlist and *ALL nextlist needs to be taken care* of. Note that N position often makes/breaks the parser. Here it has been shifted one unit to the right.

###After Added if -else stmt
Added while loop.Converted makefile to DEBUG mode.While loop fine.

###After Added while loop
Corrected the flow of control in a body of stmts. Augmented the rule for compound_statement to manage end of block.

###After Corrected flow between stmts
added do while.

###After Added do while loop
Added for loop.

###After Added basic for loop
Removed an overzealous action - of storing every assignment expression.

###After Stopped storing the result of an assignment expression
Important pathways:
-pointer implementation
-arrays 1d followed by multiple d
-functions, defining multiple ones, calling one from another, managing symbol table
-inital values in declarator
-introducing doubles and char constants

Working on functions.First step : changing declarator style. Moved creation of entry in symbol table to declrator rule.Added pointer creation.

###After Added pointer declaration
The entire declaration block is kind of weak. Adding arrays will require more changes. The thrust should be to add the entry to the symbol table in the IDENTIFIER / array level and then modify/update() the existing entry with the changes. 

The base direct-declarator rule, creates the entry into the symbol table. All declarator rules that follow modify the existing entry.

The name of the variable gets passed around in the many non-terminals related to declaration.

###After Modified method to work in steps
Adding multiple function functionality.Declarations first. First step - moved type saving to the point of seeing type. 

Just realized, the global table`s offset once you come out of a program is off. Corrected somewhat by introducing st lastOffset function.

Current setup not working with function parameters. Also possible error in declarator_list_opt.

###After Empty parameter function declarataion working
This however does not handle the problem of parameter declarataion.

Note: Pointer use has not been covered.

And analysis reveals a serious flaw in the grammar. The test case here compiles flawlessly, showing the error in the grammar. The declarator_list_opt matches the one shown in t1.c . What we need is the parameter list rule limited to simple possibilities.

###After Flaw in grammar of function header highlighted
The first declarator now uses the last rule of direct_declarator.
This must mean some kind of error in declarator_list_opt.
The entire function creation in table has been moved to a lower/deeper level.

###After  Function definition perfected
Created a section seperator. 

Note: Need a way to make the program look for the variable in the parent symbol table if there is no such entry in current table.

Also aligned the label to 2 digits.

###After Tidied up emitted output
Added pointer derefrencing and address of operator. 2 holes here:
-no check for compatible types
-pointer assignment not yet supported

###After Added unary * and & operators
Assuming that a return value is just a value and not a boolean expression.

###After Added return statement
The idea is to encode the constants in a string. Not very neat but effective enough. Added floating point and char constants.

###After Added pre inc dec operators
Now going to give a variable an initial value. The constant invlovled in the declration does not have an associated temporary or quad tac entry.

###After Added initialization with declaration
Added function call ability.

###After Added array access
Encoding the array property as a string.

###After  paran enclosed expressions taken care of
The symbol table uses a static array instead of a vector, needs to be upgraded.

END of TAC translation phase.

# Machine Dependent translation phase

###After updated build script 
Analysing for plan of action. First step is to compare our programs output gcc`s output for some simple c programs.

Right now the idea seems to be to convert the symbol table to an Activation Record and then walk through the quad array and convert it into the x86 equivalent line by line. Something like the existing toString function.

###After plans begin for mc indep
The main thrust now is to move control to main. We may have to output the tac and the asm code into multiple files.

###After  Added var eq var exp
To simplify matters, all temporaries are used with eax.The tempReg will be used to its full potential later on.

###After Added testsuite and runner
We need to manage the register allocation to temporaries properly.

Now to do that: I am going to take the simplistic assumption that each temporary has one use. So in TAC that uses a temporary, I am going to remove it`s register allocation from the table.Simillarly the last register used is going to be stored in  global variable. And this is going to be assigned to the temporary.

Note this has a problem -> when a if freed and b is not, the entire setup breaks.

###After Multiplication added
Adding Strings.
By observation, all strings come before params with them. There is really no other use for them.

###After Added string printing capability
Wanted to add integer input. But this needs pointers.

###After  Improved readi functionality
Need some rewrite in terms of pointer setting. May need to see gcc`s route and may even need to change the tac generation.

Going to focus on labels now.
For goto and the conditional version.

###After Gotos handled; if tested thoroughly
Bug found. Increment is not handled correctly.

The quad entry : i = i + 1, messes up.

###After  Added while,do while tests
Facing pointers.
Idea is to first for the temp = pointer quad face simillarly.
Then change the assignment section to check for pointer links in temporaries.
Act differently for accessing and assignment.

###After Added pointer assignment
Added arrays access and assignment.Works only for single dimension arrays.

###After Overhaul to build script
The use of pointers can be anywhere. In all those places, we would have to ensure that before being used in LHS, we need to read the data into the same register. Now added for SUM et al, but have to check for params etc. Also the same fears may be applicable for arrays.

###After  Added pointers in algebra
The entire register temporary management is fragile. Having multiple function calls puts eax in pressure. Either a better system for managing temporaries is needed or clearing of registers needs to be verified.

Another option start of all calculations with ebx. 
