#! /bin/bash

#Shell script to build a dist folder as required by my course.

rm -rf dist
mkdir dist
cp tinyc.l dist/ass6_12CS30011.l
cp tinyc.y dist/ass6_12CS30011.y
cp lexmain.cpp dist/ass6_12CS30011_translator.cpp
cp lexmain.h dist/ass6_12CS30011_translator.h
cp translator.cpp dist/ass6_12CS30011_target_translator.cpp
cp myl.h dist/myl.h
cp myl.c dist/myl.c

#copy readme
cp readme.txt dist/readme.txt

cp Makefile dist/Makefile

# need to manipulate the Makefile
sed -i 's/tinyc/ass6_12CS30011/g' dist/Makefile
sed -i 's/translator/ass6_12CS30011_target_translator/g' dist/Makefile

#update lexmain in all associated files
sed -i 's/lexmain/ass6_12CS30011_translator/g' dist/Makefile dist/ass6_12CS30011.l dist/ass6_12CS30011.y dist/ass6_12CS30011_translator.cpp dist/ass6_12CS30011_target_translator.cpp 

#copy testfiles
mkdir dist/tests

make
make library

for ((n = 0;;n++))
do
  if [ -f "testsuite/t$n.c" ]
  then
    #run the compiler
    cp testsuite/t$n.c dist/tests/ass6_12CS30011_test$n.c

    /lib64/ld-linux-x86-64.so.2 ./compiler testsuite/t$n.c

    mv res.out dist/tests/ass6_12CS30011_quads$n.out 
    mv res.s dist/tests/ass6_12CS30011_$n.s 
  else
    break
  fi
done
