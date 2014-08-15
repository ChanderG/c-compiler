a.out: lex.yy.o y.tab.o lexmain.o
	g++ lex.yy.o y.tab.o lexmain.o -lfl
lex.yy.c: tinyc.l y.tab.h
	flex tinyc.l
lex.yy.o: lex.yy.c
	g++ -c lex.yy.c
y.tab.c y.tab.h: tinyc.y
	yacc -dt tinyc.y
y.tab.o: y.tab.c
	g++ -c y.tab.c
lexmain.o: lexmain.c
	g++ -c lexmain.c
clean:
	rm lex.yy.c y.tab.h y.tab.c lex.yy.o y.tab.o lexmain.o
