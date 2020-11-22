%{

	/* C Declarations and Definitions */

	#include "ass6_18CS10062_18CS10067_translator.h"
	#include "y.tab.h"
	extern void yyerror(const char *);
	static void comment(void);
%}

%option noyywrap

/* REGEX DEFINITION */

/*------- KEYWORDS ---------------*/
BREAK		"break"
CASE		"case"
CHAR		"char"
CONST 		"const"
CONTINUE	"continue"
DEFAULT		"default"
DO 			"do"
DOUBLE		"double"
ELSE		"else"
EXTERN		"extern"
FLOAT		"float"
FOR			"for"
GOTO		"goto"
IF			"if"
INLINE		"inline"	
INT 		"int"
LONG		"long"
RESTRICT 	"restrict"
RETURN		"return"
SHORT		"short"
SIZEOF		"sizeof"
STATIC		"static"
STRUCT		"struct"
SWITCH		"switch"
TYPEDEF		"typedef"
UNION		"union"
VOID		"void"
VOLATILE	"volatile"
WHILE		"while"


/*------IDENTIFIER---------*/

DIGIT						[0-9]
IDENTIFIER_NONDIGIT 		[a-zA-Z]|"_"
IDENTIFIER 					{IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*

/*------INTEGER CONSTANT---------*/

NONZERO_DIGIT 				[1-9]
ZERO 						"0"
INTEGER_CONSTANT 			(({NONZERO_DIGIT}({DIGIT}*))|{ZERO}+)

/*------FLOATING CONSTANT---------*/

SIGN 						"+"|"-"
DIGIT_SEQUENCE				{DIGIT}({DIGIT})*
EXPONENT_PART				("e"{SIGN}?{DIGIT_SEQUENCE})|("E"{SIGN}?{DIGIT_SEQUENCE})
FRACTIONAL_CONSTANT			({DIGIT_SEQUENCE}?"."{DIGIT_SEQUENCE})|({DIGIT_SEQUENCE}".")
FLOATING_CONSTANT			({FRACTIONAL_CONSTANT}{EXPONENT_PART}?)|({DIGIT_SEQUENCE}{EXPONENT_PART})

/*------CHARACTER CONSTANT---------*/

ESCAPE_SEQUENCE 			([\\][\'\"\?\\abfnrtv])
C_CHAR 						[^\'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE 			{C_CHAR}+
CHARACTER_CONSTANT 			(\'{C_CHAR_SEQUENCE}\')

/*-------STRING_LITERALS---------------*/

S_CHAR 						[^\"\\\n]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE 			{S_CHAR}+
STRING_LITERAL 				(\"{S_CHAR_SEQUENCE}*\")

/*------PUNCTUATORS---------*/
PUNCTUATOR 					"["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"

%x single_line_comment multi_line_comment

%%

"//"			{BEGIN(single_line_comment);}
<single_line_comment>[^\n]	{}
<single_line_comment>"\n"		{BEGIN(INITIAL);}
<single_line_comment><<EOF>>	{BEGIN(INITIAL);}

"/*"			{BEGIN(multi_line_comment);}
<multi_line_comment>[^*]	{}
<multi_line_comment>"*"[^/]	{}
<multi_line_comment>"*/"	{BEGIN(INITIAL);}

{BREAK}		return BREAK;
{CASE}		return CASE;
{CHAR}		return CHAR;
{CONST}		return CONST;
{CONTINUE}	return CONTINUE;
{DEFAULT}	return DEFAULT;
{DO}		return DO;
{DOUBLE}	return DOUBLE;
{ELSE}		return ELSE;
{EXTERN}	return EXTERN;
{FLOAT}		return FLOAT;
{FOR}		return FOR;
{GOTO}		return GOTO;
{IF}		return IF;
{INLINE} 	return INLINE;
{INT}		return INT;
{LONG}		return LONG;
{RESTRICT} 	return RESTRICT;
{RETURN}	return RETURN;
{SHORT}		return SHORT;
{SIZEOF}	return SIZEOF;
{STATIC}	return STATIC;
{STRUCT}	return STRUCT;
{SWITCH}	return SWITCH;
{TYPEDEF}	return TYPEDEF;
{UNION}		return UNION;
{VOID}		return VOID;
{VOLATILE} 	return VOLATILE;
{WHILE}		return WHILE;

{IDENTIFIER}	{ 
					yylval.idl.name=new string(yytext);
					return IDENTIFIER;
				}

{INTEGER_CONSTANT}	{ 
						yylval.intval=atoi(yytext); 
						return INTEGER_CONSTANT;
					}

{FLOATING_CONSTANT}	{
						yylval.floatval=atof(yytext);
						return FLOATING_CONSTANT;
					}


{CHARACTER_CONSTANT}	{ 
							yylval.charval=yytext[1]; 
							return CHAR_CONST;
						}

{STRING_LITERAL}	{ 
						yylval.strval = new string(yytext);
						return STRING_LITERAL;
					}

{PUNCTUATOR}	{
					if(strcmp(yytext,"[") == 0) 
						return SQUARE_BRACKET_OPEN;
					if(strcmp(yytext,"]") == 0) 
						return SQUARE_BRACKET_CLOSE;
					if(strcmp(yytext,"(") == 0) 
						return ROUND_BRACKET_OPEN; 
					if(strcmp(yytext,")") == 0) 
						return ROUND_BRACKET_CLOSE; 
					if(strcmp(yytext,"{") == 0) 
						return CURLY_BRACKET_OPEN; 
					if(strcmp(yytext,"}") == 0) 
						return CURLY_BRACKET_CLOSE; 
					if(strcmp(yytext,".") == 0) 
						return DOT; 
					if(strcmp(yytext,"->") == 0) 
						return (POINTER);
					if(strcmp(yytext,"++") == 0) 
						return (UNARY_INCREMENT);
					if(strcmp(yytext,"--") == 0) 
						return (UNARY_DECREMENT);
					if(strcmp(yytext,"&") == 0) 
						return '&';
					if(strcmp(yytext,"*") == 0) 
						return '*';
					if(strcmp(yytext,"+") == 0) 
						return '+';
					if(strcmp(yytext,"-") == 0) 
						return '-';
					if(strcmp(yytext,"~") == 0) 
						return '~';
					if(strcmp(yytext,"!") == 0) 
						return '!';
					if(strcmp(yytext,"/") == 0) 
						return '/';
					if(strcmp(yytext,"%") == 0) 
						return '%';
					if(strcmp(yytext,"<<") == 0) 
						return (LEFT_SHIFT);
					if(strcmp(yytext,">>") == 0) 
						return (RIGHT_SHIFT);
					if(strcmp(yytext,"<") == 0) 
						return '<';
					if(strcmp(yytext,">") == 0) 
						return '>';
					if(strcmp(yytext,"<=") == 0) 
						return (LESS_EQUALS);
					if(strcmp(yytext,">=") == 0) 
						return (GREATER_EQUALS);
					if(strcmp(yytext,"==") == 0) 
						return (EQUALS);
					if(strcmp(yytext,"!=") == 0) 
						return (NOT_EQUALS);
					if(strcmp(yytext,"^") == 0)  
						return '^';
					if(strcmp(yytext,"|") == 0) 
						return '|';
					if(strcmp(yytext,"&&") == 0) 
						return (LOGICAL_AND);
					if(strcmp(yytext,"||") == 0) 
						return (LOGICAL_OR);
					if(strcmp(yytext,"?") == 0) 
						return QUES;
					if(strcmp(yytext,":") == 0) 
						return COLON;
					if(strcmp(yytext,";") == 0) 
						return SEMICOLON;
					if(strcmp(yytext,"...") == 0) 
						return (ELLIPSIS);
					if(strcmp(yytext,"=") == 0) 
						return ASSIGN;
					if(strcmp(yytext,"*=") == 0) 
						return MULTIPLY_ASSIGN;
					if(strcmp(yytext,"/=") == 0) 
						return DIVIDE_ASSIGN;
					if(strcmp(yytext,"%=") == 0) 
						return MODULO_ASSIGN;
					if(strcmp(yytext,"+=") == 0) 
						return ADD_ASSIGN;
					if(strcmp(yytext,"-=") == 0) 
						return SUBTRACT_ASSIGN;
					if(strcmp(yytext,"<<=") == 0) 
						return BITWISE_LEFT_ASSIGN;
					if(strcmp(yytext,">>=") == 0) 
						return BITWISE_RIGHT_ASSIGN;
					if(strcmp(yytext,"&=") == 0) 
						return BITWISE_AND_ASSIGN;
					if(strcmp(yytext,"^=") == 0) 
						return XOR_ASSIGN;
					if(strcmp(yytext,"|=") == 0) 
						return BITWISE_OR_ASSIGN ;
					if(strcmp(yytext,",") == 0) 
						return ',';
					if(strcmp(yytext,"#") == 0) 
						return '#';
				}

"\n"|" "|"\t"	{

				}

%%
