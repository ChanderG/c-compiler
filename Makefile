a.out: lex.yy.o y.tab.o main.o
	g++ lex.yy.o y.tab.o main.o -lfl
lex.yy.c: tinyc.l y.tab.h
	flex tinyc.l
lex.yy.o: lex.yy.c
	g++ -c lex.yy.c
y.tab.c y.tab.h: tinyc.y
	yacc -dtv tinyc.y
y.tab.o: y.tab.c
	g++ -c y.tab.c
main.o: lexmain.c y.tab.h
	g++ -c lexmain.c -o main.o
clean:
	rm lex.yy.c y.tab.h y.tab.c lex.yy.o y.tab.o main.o a.out
