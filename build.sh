#! /bin/bash

#Shell script to build a dist folder as required by my course.

rm -rf dist
mkdir dist
cp tinyc.l dist/ass3_12CS30011.l
cp tinyc.y dist/ass3_12CS30011.y
cp lexmain.c dist/ass3_12CS30011.c
cp Makefile dist/Makefile

# need to manipulate the Makefile
sed -i 's/tinyc/ass3_12CS30011/g' dist/Makefile
sed -i 's/lexmain/ass3_12CS30011/g' dist/Makefile

#copy testfile
cp tests/t1.c dist/ass3_12CS30011_test.c
