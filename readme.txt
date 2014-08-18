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

RUNNING THE TEST FILE:
1. Required test file is in tests directory with roll number.
2. res1.txt is the expected output.
3. The program does not print yytext, it only prints TOKEN string.
4. Easiest way to run it is to give in the input in test file and expected output in res1.txt. Running the testrunner script:

./testrunner.sh
or
bash ./testrunner.sh

will directly compare the outputs and give a report.

To run the test file manually use:

make
./a.out < tests/ass3_12CS30011_test.c
