#! /bin/bash

#Shell script to build a dist folder as required by my course.

rm -rf dist
mkdir dist
cp tinyc.l dist/ass4_12CS30011.l
cp tinyc.y dist/ass4_12CS30011.y
cp lexmain.c dist/ass4_12CS30011.c
cp Makefile dist/Makefile

# need to manipulate the Makefile
sed -i 's/tinyc/ass4_12CS30011/g' dist/Makefile
sed -i 's/lexmain/ass4_12CS30011/g' dist/Makefile

#copy testfile
mkdir dist/tests
cp tests/t1.c dist/tests/ass4_12CS30011_test.c
cp tests/res1.txt dist/tests/res1.txt

cp testrunner.sh dist/testrunner.sh
sed -i 's/t1/ass4_12CS30011_test/g' dist/testrunner.sh

#copy readme
cp readme.txt dist/readme.txt
