#TinyC compiler

###What?

A compiler for a made up language called tinyC - a subset of C. After the m/c independent translation has been done, the plan is to translate it for x86-32.

###Build Instructions
Use the Makefile.

```
make
```

The required compiler is: "compiler"

The build script is to wrestle the same code into a format required by my university.

The y.output file is created when the -v flag is used with debug option. The file helps a lot to remove shift/reduce conflicts. Just open the file with a text editor.

###Issues
**As it was primarily done for my university specifications(requirements and deadlines), the test files are a very bad examples in the phase 2. I really apologize for that and warn everyone to never use that kind of linear, single file, unorganized and "happy path only" testing approach.**


As of now, declrations cannot be done with initial value from function calls.
###Build through:

Starting phase 2: Parser generation
Use the git commit 3cf95113ded98f8b2fdc6b7d43db9b10ab28d6ee to go to lexer portion.

Starting phase 3: M/c independent translation
Use the git commit 78d5e0883bf800b863cbc2e746a13cc05dd4b228 to go to parser portion.

Starting phase 4: M/c dependent translation
Use the git commit 5d004250ef197a795a1a3085178af43383adc8c1 to go to previous portion.

###Understanding the growth

From the third stage onwards, the file "growth.md" documents the progress in a more thorough manner. It has commit by commit explanation.

###Learning
The folder learning contains the practice done to understand m/c dependent translation.

###Compiling....
After the 5th stage, the actual output .s file totally compiles to binary.Remember to use 32 bit option though. 

On running the created compiler "compiler"

```
./compiler testfile.c
```

right now two files are created in the current directory:

a) res.out -> containing the TAC and the Symbol tables
b) res.s -> a specific x86-32 assembly code that can be compiled with gcc like so:

```
cc -m32 res.s 
```

again creating a.out that is a runnable code.

###Linking for I/O
myl.c contains a simple library for I/O.

First make the library:
```
make library
```

To use the library and link it correctly, run gcc with the generated "res.s" as follows:
```
cc -m32 res.s -L. -lmyl 
```
Note the order of the terms, putting the .c/.s file at the last will fail to compile.

If the program is being compiled in the same folder, you don't have to include any header to use the functions.

###Some additional comments
As the project started out as a C project char* was extensively used. Now to simplify as more and more C++ features are being used, the migration to std::string is slowly being done. 
