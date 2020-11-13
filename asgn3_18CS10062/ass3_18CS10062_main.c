// NAME : RADHIKA PATWARI
// ROLL : 18CS10062

#include<stdio.h>

#define BREAK 1
#define CASE 2
#define CHAR 3
#define CONTINUE 4
#define DEFAULT 5
#define DO 6
#define DOUBLE 7
#define ELSE 8
#define EXTERN 9
#define FLOAT 10
#define FOR 11
#define GOTO 12
#define IF 13
#define INT 14
#define LONG 15
#define RETURN 16
#define SHORT 17
#define SIZEOF 18
#define STATIC 19
#define STRUCT 20
#define SWITCH 21
#define TYPEDEF 22
#define UNION 23
#define VOID 24
#define WHILE 25
#define ID 26
#define INT_CONST 27
#define FLT_CONST 28
#define CHAR_CONST 29
#define STRING 30
#define PUNC 31
#define SIN_COMMENT 32
#define MULT_COMMENT 33


extern int yylex();
extern char * yytext;
extern FILE * yyin;

int main()	
{
	FILE *myfile = fopen("ass3_18CS10062_test.c", "r");
	// make sure it's valid:
	if (!myfile) {
		printf("Can't open ass3_18CS10062_test.c file!Check file name\n");
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;

	int token;
	while (token = yylex()) 
	{
		switch (token) 
		{
			case BREAK:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case CASE:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case CHAR:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case CONTINUE:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case DEFAULT:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case DO:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case DOUBLE:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case ELSE:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case EXTERN:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case FLOAT:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case FOR:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case GOTO:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case IF:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case INT:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case LONG:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case RETURN:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case SHORT:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case SIZEOF:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case STATIC:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case STRUCT:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case SWITCH:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case TYPEDEF:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case UNION:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case VOID:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case WHILE:{
				printf("<KEYWORD, %d, %s>\n",token, yytext);break;
			}
			case ID:{
				printf("<IDENTIFIER, %d, %s>\n",token, yytext);break;
			}
			case INT_CONST:{
				printf("<INTEGER CONST, %d, %s>\n",token, yytext);break;
			}
			case FLT_CONST:{
				printf("<FLOAT CONST, %d, %s>\n",token, yytext);break;
			}
			case CHAR_CONST:{
				printf("<CHAR CONST, %d, %s>\n",token, yytext);break;
			}
			case STRING:{
				printf("<STRING, %d, %s>\n",token, yytext);break;
			}
			case PUNC:{
				printf("<PUNCTUATOR, %d, %s>\n",token, yytext);break;
			}
			case SIN_COMMENT:{
				printf("<SINGLE LINE COMMENT, %d, %s>\n",token, yytext);break;
			}
			case MULT_COMMENT:{
				printf("<MULTILINE COMMENT, %d, %s>\n",token, yytext);break;
			}
		}
	}
}

int yywrap(){
	return 1;
}





