#! /bin/bash

#Chander G
#This is a simple testrunner script to take all files in "tests" folder and run it against the code. It then compares the result with the preset result and prints match/fail.

#Right now it manually only sees t1.c file and uses res1.txt as expected output.
/lib64/ld-linux-x86-64.so.2 ./a.out < tests/t1.c > tests/temp.txt

# REMOVE LATER
#debug mode : full diff between the 2 files
diff tests/temp.txt tests/res1.txt

# final version : with only yes/no response
if diff -q tests/temp.txt tests/res1.txt
then
  echo "All tests passed"
fi

rm tests/temp.txt

