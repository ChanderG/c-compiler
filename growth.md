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
