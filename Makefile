#flags for compilation
#-Wno-write-strings for conversion of "strings" to char*
CFLAGS = -g -Wno-write-strings

compiler: lex.yy.o y.tab.o tac.o main.o
	g++ lex.yy.o y.tab.o tac.o main.o -o compiler -lfl $(CFLAGS)
lex.yy.c: tinyc.l y.tab.h
	flex tinyc.l
lex.yy.o: lex.yy.c
	g++ -c lex.yy.c $(CFLAGS)
y.tab.c y.tab.h: tinyc.y
	yacc -dtv tinyc.y
y.tab.o: y.tab.c
	g++ -c y.tab.c $(CFLAGS)
tac.o: lexmain.cpp y.tab.h lexmain.h
	g++ -c lexmain.cpp -o tac.o $(CFLAGS)
main.o: translator.cpp
	g++ -c translator.cpp -o main.o $(CFLAGS)
clean:
	rm -rf dist lex.yy.c y.tab.h y.tab.c lex.yy.o y.tab.o tac.o main.o compiler y.output
