#! /bin/bash

#This is a simple testrunner script to take all files in "testsuite" folder and run it against the code. It then compares the result with the preset result and prints match/fail.

#compile the compiler
make

for ((n = 0;;n++))
do
if [ -f "testsuite/t$n.c" ]
then
#run the compiler
echo "Runnng the compiler..."
/lib64/ld-linux-x86-64.so.2 ./compiler testsuite/t$n.c 

#mv res.s testsuite/res.s

cc -m32 res.s -L. -lmyl

/lib/ld-linux.so.2 ./a.out > testsuite/temp.txt


# final version : with only yes/no response
if diff -q testsuite/temp.txt testsuite/res$n.txt
then
echo "Test #$n passed"
else
echo "Test #$n failed:"
# REMOVE LATER
#debug mode : full diff between the 2 files
diff testsuite/temp.txt testsuite/res$n.txt
fi
rm testsuite/temp.txt
else
echo "Ran " $(($n)) " test(s)"
break
fi
done
