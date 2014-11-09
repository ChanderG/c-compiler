CHANDER G - 12CS30011 - chandergovind@gmail.com

SIMPLE RUN:

Simply do :

make
make library

If input is hello.c,

./compiler hello.c

This creates 2 files:
res.out:
    The output has the symbol tables of all functions and main after complete function.Then the Quad array and the Quads in TAC format are printed.
res.s:
    The actual assembly file.

Now to compile to binary:

cc -m32 res.s -L. -lmyl

This creates the a.out file that you can actually run. "libmyl" is the included library for basic IO. It does not need to be included at all.

Now run:

./a.out

The c program should run as expected.


TESTS FILES:
Some sample test files are given in the test folder. The input and corresponding outputs are included.

BUGS:

1.See specs carefully.
2.Char is not yet supported.
3.The symbol table has a max aka hardcoded maximum number of entries at 500.Update if needed.
