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
