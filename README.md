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

The build script is to wrestle the same code into a format required by my university.

The y.output file is created when the -v flag is used with debug option. The file helps a lot to remove shift/reduce conflicts. Just open the file with a text editor.

###Issues
Many issues remain.

###Build through:

Starting phase 2: Parser generation
Use the git commit 3cf95113ded98f8b2fdc6b7d43db9b10ab28d6ee to go to lexer portion.
