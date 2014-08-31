CHANDER G - 12CS30011 - chandergovind@gmail.com

NOTES:
1. Additionally includes 0, not there in initial specs.
2. Considers charaters as single.
3. No enumeration_constant, as it is a direct identifier.

4. The lines returning tokens have been commented out, as we are not using yyparse here.

SIMPLE RUN:

Simply do :

make
./a.out

Enter input in terminal.

TEST:

To run the test file manually use:

make
./a.out < tests/ass3_12CS30011_test.c


It does not print anything out if everything is fine.
Else it prints "syntax error".
