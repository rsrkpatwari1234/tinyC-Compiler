
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

a.out: y.tab.o lex.yy.o ass6_18CS10062_18CS10067_translator.o ass6_18CS10062_18CS10067_target_translator.o 
	g++ lex.yy.o y.tab.o ass6_18CS10062_18CS10067_target_translator.o ass6_18CS10062_18CS10067_translator.o -lfl
	./a.out < testFiles/ass6_18CS10062_18CS10067_test1.c
	./a.out < testFiles/ass6_18CS10062_18CS10067_test2.c 
	./a.out < testFiles/ass6_18CS10062_18CS10067_test3.c
	./a.out < testFiles/ass6_18CS10062_18CS10067_test4.c
	./a.out < testFiles/ass6_18CS10062_18CS10067_test5.c
	@echo " USE COMMAND (make run) TO CREATE THE TEST RUN FILES"

ass6_18CS10062_18CS10067_translator.o: ass6_18CS10062_18CS10067_translator.cxx ass6_18CS10062_18CS10067_translator.h
	g++ -c ass6_18CS10062_18CS10067_translator.h
	g++ -c ass6_18CS10062_18CS10067_translator.cxx

ass6_18CS10062_18CS10067_target_translator.o: ass6_18CS10062_18CS10067_translator.cxx ass6_18CS10062_18CS10067_translator.h
	g++ -c ass6_18CS10062_18CS10067_target_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass6_18CS10062_18CS10067.l y.tab.h ass6_18CS10062_18CS10067_translator.h
	flex ass6_18CS10062_18CS10067.l

y.tab.c: ass6_18CS10062_18CS10067.y
	yacc -dtv ass6_18CS10062_18CS10067.y -W

libass2_18CS10062_18CS10067.a:ass2_18CS10062_18CS10067.o
	ar -rcs libass2_18CS10062_18CS10067.a ass2_18CS10062_18CS10067.o

ass2_18CS10062_18CS10067.o:ass2_18CS10062_18CS10067.c myl.h
	gcc -Wall -c ass2_18CS10062_18CS10067.c

#output: output.o
output: output.o libass2_18CS10062_18CS10067.a
	gcc -g  output.o -o output -L. -lass2_18CS10062_18CS10067
output.o: output.s myl.h
	gcc -g -Wall -c output.s


runtest1: ass6_18CS10062_18CS10067_test1.o libass2_18CS10062_18CS10067.a
	gcc -g ass6_18CS10062_18CS10067_test1.o -o runtest1 -L. -lass2_18CS10062_18CS10067
ass6_18CS10062_18CS10067_test1.o: ass6_18CS10062_18CS10067_test1.s myl.h
	gcc -g -Wall  -c ass6_18CS10062_18CS10067_test1.s

runtest2: ass6_18CS10062_18CS10067_test2.o libass2_18CS10062_18CS10067.a
	gcc -g  ass6_18CS10062_18CS10067_test2.o -o runtest2 -L. -lass2_18CS10062_18CS10067
ass6_18CS10062_18CS10067_test2.o: ass6_18CS10062_18CS10067_test2.s myl.h
	gcc -g -Wall -c ass6_18CS10062_18CS10067_test2.s

runtest3: ass6_18CS10062_18CS10067_test3.o libass2_18CS10062_18CS10067.a
	gcc -g  ass6_18CS10062_18CS10067_test3.o -o runtest3 -L. -lass2_18CS10062_18CS10067
ass6_18CS10062_18CS10067_test3.o: ass6_18CS10062_18CS10067_test3.s myl.h
	gcc -g -Wall  -c ass6_18CS10062_18CS10067_test3.s

runtest4: ass6_18CS10062_18CS10067_test4.o libass2_18CS10062_18CS10067.a
	gcc -g  ass6_18CS10062_18CS10067_test4.o -o runtest4 -L. -lass2_18CS10062_18CS10067
ass6_18CS10062_18CS10067_test4.o: ass6_18CS10062_18CS10067_test4.s myl.h
	gcc -g -Wall  -c ass6_18CS10062_18CS10067_test4.s

runtest5: ass6_18CS10062_18CS10067_test5.o libass2_18CS10062_18CS10067.a
	gcc -g  ass6_18CS10062_18CS10067_test5.o -o runtest5 -L. -lass2_18CS10062_18CS10067
ass6_18CS10062_18CS10067_test5.o: ass6_18CS10062_18CS10067_test5.s myl.h
	gcc -g -Wall -c ass6_18CS10062_18CS10067_test5.s


run: 
		
	./a.out <  testFiles/ass6_18CS10062_18CS10067_test1.c > 3-address_outputFiles/ass6_18CS10062_18CS10067_quads1.out
	
	@mv output.s ass6_18CS10062_18CS10067_test1.s
	
	@make runtest1
	
	./a.out <  testFiles/ass6_18CS10062_18CS10067_test2.c > 3-address_outputFiles/ass6_18CS10062_18CS10067_quads2.out

	@mv output.s ass6_18CS10062_18CS10067_test2.s
	
	@make runtest2

	./a.out <  testFiles/ass6_18CS10062_18CS10067_test3.c > 3-address_outputFiles/ass6_18CS10062_18CS10067_quads3.out

	@mv output.s ass6_18CS10062_18CS10067_test3.s

	@make runtest3

	./a.out <  testFiles/ass6_18CS10062_18CS10067_test4.c > 3-address_outputFiles/ass6_18CS10062_18CS10067_quads4.out
	
	@mv output.s ass6_18CS10062_18CS10067_test4.s

	@make runtest4

	./a.out <  testFiles/ass6_18CS10062_18CS10067_test5.c > 3-address_outputFiles/ass6_18CS10062_18CS10067_quads5.out
	
	@mv output.s ass6_18CS10062_18CS10067_test5.s

	@make runtest5

	@echo ""
	@echo "COMMANDS FOR THE TEST CASES"
	@echo "1 : Calculate force                      : ./runtest1"
	@echo "2 : Convert Decimal Number to Binary     : ./runtest2"
	@echo "3 : Greatest Common Divisor Calculation  : ./runtest3"
	@echo "4 : nth Fibonacci Number                 : ./runtest4"
	@echo "5 : Rod Cutting Problem                  : ./runtest5"


clean:
	@rm ass6_18CS10062_18CS10067_test1.s ass6_18CS10062_18CS10067_test2.s ass6_18CS10062_18CS10067_test3.s ass6_18CS10062_18CS10067_test4.s ass6_18CS10062_18CS10067_test5.s runtest1 runtest2 runtest3 runtest4 runtest5 lex.yy.c y.tab.h y.output y.tab.c lex.yy.o y.tab.o ass6_18CS10062_18CS10067_translator.o ass6_18CS10062_18CS10067_target_translator.o ass6_18CS10062_18CS10067_test1.o ass6_18CS10062_18CS10067_test2.o ass6_18CS10062_18CS10067_test3.o ass6_18CS10062_18CS10067_test4.o ass6_18CS10062_18CS10067_test5.o libass2_18CS10062_18CS10067.a ass2_18CS10062_18CS10067.o ass6_18CS10062_18CS10067_translator.h.gch a.out

