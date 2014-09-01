#TinyC compiler

###What?

A compiler for a made up language called tinyC - a subset of C.

###Build Instructions
Use the Makefile.

```
make
```

To test use the testrunner script:

```
bash ./testrunner.sh
```
If there are no problems it will output nothing.
Basically it looks into the tests folder for all files like "t$.c" , use it as an input to the compiler and expect the output to match the one pre filled in the corresponding "res$.txt" file.


The build script is to wrestle the same code into a format required by my university.

The y.output file is created when the -v flag is used with debug option. The file helps a lot to remove shift/reduce conflicts. Just open the file with a text editor.

###Issues
**As it was primarily done for my university specifications(requirements and deadlines), the test files are a very bad examples in the phase 2. I really apologize for that and warn everyone to never use that kind of linear, single file, unorganized and "happy path only" testing approach.**

###Build through:

Starting phase 2: Parser generation
Use the git commit 3cf95113ded98f8b2fdc6b7d43db9b10ab28d6ee to go to lexer portion.
