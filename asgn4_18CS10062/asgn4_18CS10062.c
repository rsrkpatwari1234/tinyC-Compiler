// NAME : RADHIKA PATWARI
// ROLL : 18CS10062
// COMPILER LAB ASSIGNMENT 4 

// COMMANDS TO RUN THE FILES : make clean
//			  				   make
//			  				   ./a.out

// including the required header files
#include <stdio.h>
#include <string.h>
#include <iostream>

//setting yydebug as 1 generates the y.output file that displays
//the state machine for the parser and helps in debugging
#define YYDEBUG 1

extern int yyparse();
extern char * yytext;
extern FILE * yyin;

int main()	
{

	//opening a particular  testing file in read format
	FILE *myfile = fopen("asgn4_18CS10062_test.c", "r");

	//To check if the filename is valid:
	if (!myfile) {
		printf("Can't open asgn4_18CS10062_test.c file!Please check file name\n");
		return -1;
	}

	// set yyin to read from the file instead of defaulting to STDIN:
	yyin = myfile;

	//calling the bison driver to enable parsing 
	yyparse();
}

int yywrap(){
	return 1;
}





