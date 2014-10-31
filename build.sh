#! /bin/bash

#Shell script to build a dist folder as required by my course.

rm -rf dist
mkdir dist
cp tinyc.l dist/ass5_12CS30011.l
cp tinyc.y dist/ass5_12CS30011.y
cp lexmain.cpp dist/ass5_12CS30011_translator.cpp
cp lexmain.h dist/ass5_12CS30011_translator.h
cp Makefile dist/Makefile

# need to manipulate the Makefile
sed -i 's/tinyc/ass5_12CS30011/g' dist/Makefile

#update lexmain in all associated files
sed -i 's/lexmain/ass5_12CS30011_translator/g' dist/Makefile dist/ass5_12CS30011.l dist/ass5_12CS30011.y dist/ass5_12CS30011_translator.cpp 

#copy testfiles
mkdir dist/tests

make

for i in `seq 1 5`;
do
  cp tests/t$i.c dist/tests/ass5_12CS30011_test$i.c
  /lib64/ld-linux-x86-64.so.2 ./compiler tests/t$i.c > res.out
  mv res.out dist/tests/ass5_12CS30011_test$i.out
done  

#cp tests/t1.c dist/ass5_12CS30011_test.c
#cp tests/res1.txt dist/tests/res1.txt

#copy readme
cp readme.txt dist/readme.txt
