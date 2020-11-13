
#################################
# GROUP : ATHARVA NAIK ROSHAN (18CS10067)
#		  RADHIKA PATWARI     (18CS10062)
# 
# COMPILER LAB ASSIGNMENT 5
#
################################
# COMMANDS TO RUN THE FILES : make clean
#			 				  make
#			 			
################################


all: a.out
	
	./a.out < testFiles/ass5_18CS10062_18CS10067_test1.c > outputFiles/ass5_18CS10062_18CS1006_quads1.out
	@echo "Test File 1 Successfully Translated !\n"
	./a.out < testFiles/ass5_18CS10062_18CS10067_test2.c > outputFiles/ass5_18CS10062_18CS10067_quads2.out
	@echo "Test File 2 Successfully Translated !\n"
	./a.out < testFiles/ass5_18CS10062_18CS10067_test3.c > outputFiles/ass5_18CS10062_18CS10067_quads3.out
	@echo "Test File 3 Successfully Translated !\n"
	./a.out < testFiles/ass5_18CS10062_18CS10067_test4.c > outputFiles/ass5_18CS10062_18CS10067_quads4.out
	@echo "Test File 4 Successfully Translated !\n"
	./a.out < testFiles/ass5_18CS10062_18CS10067_test5.c > outputFiles/ass5_18CS10062_18CS10067_quads5.out
	@echo "Test File 5 Successfully Translated !\n"

	@echo "\nALL TEST FILES SUCCESSFULLY TRANSLATED !!\n"

a.out: lex.yy.o y.tab.o ass5_18CS10062_18CS10067_translator.o
	g++ lex.yy.o y.tab.o ass5_18CS10062_18CS10067_translator.o -lfl

ass5_18CS10062_18CS10067_translator.o: ass5_18CS10062_18CS10067_translator.cxx ass5_18CS10062_18CS10067_translator.h
	g++ -c ass5_18CS10062_18CS10067_translator.h
	g++ -c ass5_18CS10062_18CS10067_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass5_18CS10062_18CS10067.l y.tab.h ass5_18CS10062_18CS10067_translator.h
	flex ass5_18CS10062_18CS10067.l

y.tab.c: ass5_18CS10062_18CS10067.y
	yacc -dtv ass5_18CS10062_18CS10067.y -W

y.tab.h: ass5_18CS10062_18CS10067.y
	yacc -dtv ass5_18CS10062_18CS10067.y -W

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass5_18CS10062_18CS10067_translator.o y.output a.out ass5_18CS10062_18CS10067_translator.h.gch
