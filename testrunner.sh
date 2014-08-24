#! /bin/bash

#Chander G
#This is a simple testrunner script to take all files in "tests" folder and run it against the code. It then compares the result with the preset result and prints match/fail.

for ((n = 1;;n++))
do
  if [ -f "tests/t$n.c" ]
  then 
    /lib64/ld-linux-x86-64.so.2 ./a.out < tests/t$n.c > tests/temp.txt


    # final version : with only yes/no response
    if diff -q tests/temp.txt tests/res$n.txt
    then
      echo "Test #$n passed"
    else
      echo "Test #$n failed:"
      # REMOVE LATER
      #debug mode : full diff between the 2 files
      diff tests/temp.txt tests/res$n.txt
    fi

    rm tests/temp.txt
  else
    echo "Ran " $(($n-1)) " test(s)" 
    break
  fi
done
