
#################################
# NAME : RADHIKA PATWARI
# ROLL : 18CS10062
# COMPILER LAB ASSIGNMENT 4 
################################
# COMMANDS TO RUN THE FILES : make clean
#			 				  make
#			 				  ./a.out
################################


all:
	flex asgn4_18CS10062.l
	yacc -dtv asgn4_18CS10062.y -W
	g++ -c lex.yy.c
	g++ -c y.tab.c
	g++ lex.yy.o y.tab.o asgn4_18CS10062.c -lfl

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o y.output a.out
