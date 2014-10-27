#flags for compilation
#-Wno-write-strings for conversion of "strings" to char*
CFLAGS = -g -Wno-write-strings

a.out: lex.yy.o y.tab.o main.o
	g++ lex.yy.o y.tab.o main.o -lfl $(CFLAGS)
lex.yy.c: tinyc.l y.tab.h
	flex tinyc.l
lex.yy.o: lex.yy.c
	g++ -c lex.yy.c $(CFLAGS)
y.tab.c y.tab.h: tinyc.y
	yacc -dtv tinyc.y
y.tab.o: y.tab.c
	g++ -c y.tab.c $(CFLAGS)
main.o: lexmain.cpp y.tab.h lexmain.h
	g++ -c lexmain.cpp -o main.o $(CFLAGS)
clean:
	rm -rf dist lex.yy.c y.tab.h y.tab.c lex.yy.o y.tab.o main.o a.out y.output
