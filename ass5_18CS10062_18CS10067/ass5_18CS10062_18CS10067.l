%{
/* C Declarations and Definitions */
	
	#include <stdio.h>
	#include <string.h>
	#include "ass5_18CS10062_18CS10067_translator.h"
	#include "y.tab.h"

%}

%option noyywrap

/* Regular Expression Definitions */

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

/*--------IDENTIFIER----------------*/
ID 			[a-zA-Z_][a-zA-Z0-9_]*

/*--------INTEGER CONSTANT-----------*/
INT_CONST   0+|[1-9][0-9]*

/*--------FLOATING POINT CONSTANT-----*/
FLT_CONST   {FRACTION}{EXPONENT}?|{DIGIT}{EXPONENT}
EXPONENT	[eE][+-]?{DIGIT}
FRACTION 	({DIGIT}?\.{DIGIT})|({DIGIT}\.)
DIGIT		[0-9]+

/*-------CHARACTER CONSTANT----------*/
CHAR_CONST	'{CHAR_SEQ}'
CHAR_SEQ	{C_CHAR}+
C_CHAR		{SRC_SET}|{ESC_SEQ}
SRC_SET		[^("\'"|"\\"|"\n")]

/*-------STRING LITERAL-------------*/
STRING		\"{STR_SEQ}?\"
STR_SEQ		{STR_CHAR}+
STR_CHAR	{ESC_SEQ}|{STR_SET}
STR_SET		[^("\""|"\\"|"\n")]

ESC_SEQ 	\\a|\\b|\\f|\\n|\\t|\\r|\\v|\\\'|\\\"|\\\\|\\\?

/*---------PUNCTUATIONS--------------*/

BRACKET 	"["|"]"|"{"|"}"|"("|")"
UNARY_OP 	"++"|"--"
PUNC     	"<<="|">>="|"<<"|">>"|"<="|">="|"=="|"!="|"&&"|"||"|"<"|">"|"&"|"|"|"="|"*="|"/="|"%="|"+="|"-="|"|="|"&="|"^="|"->"|"^"|"..."|"."|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"?"|":"|","|"#"|";"


/*---------WHITESPACE , TAB , NEW LINE CHARACTER-----------*/
WS			[ \t\n]


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

{ID}		{
				yylval.symp = ST->lookup(yytext);
				return IDENTIFIER;
			}

{INT_CONST}	{
				yylval.intval = atoi(yytext);
				return INTEGER_CONSTANT;
			}

{FLT_CONST}	{
				yylval.char_value = yytext;
				return FLOAT_CONSTANT;
			}

{CHAR_CONST} {
				yylval.char_value = yytext;
				return CHARACTER_CONSTANT;
			}

{STRING}	{
				yylval.char_value = yytext;
				return STRING_LITERAL;
			}

{BRACKET}	{
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
			}

{UNARY_OP}	{
			if(strcmp(yytext,"++") == 0) 
				return UNARY_INCREMENT;
			if(strcmp(yytext,"--") == 0) 
				return UNARY_DECREMENT;
			}

{PUNC}		{
			if(strcmp(yytext,"<<=") == 0) 
				return BITWISE_LEFT_ASSIGN;
			if(strcmp(yytext,">>=") == 0) 
				return BITWISE_RIGHT_ASSIGN;
			if(strcmp(yytext,"<<") == 0) 
				return BITWISE_LEFT;
			if(strcmp(yytext,">>") == 0) 
				return BITWISE_RIGHT;
			if(strcmp(yytext,"<=") == 0) 
				return LESS_EQUAL;
			if(strcmp(yytext,">=") == 0) 
				return GREATER_EQUAL;
			if(strcmp(yytext,"==") == 0) 
				return EQUAL;
			if(strcmp(yytext,"<") == 0) 
				return LESS_THAN;
			if(strcmp(yytext,">") == 0) 
				return GREATER_THAN;
			if(strcmp(yytext,"!=") == 0) 
				return NOT_EQUAL;
			if(strcmp(yytext,"&&") == 0) 
				return LOGICAL_AND;
			if(strcmp(yytext,"||") == 0) 
				return LOGICAL_OR;
			if(strcmp(yytext,"&") == 0) 
				return BITWISE_AND;
			if(strcmp(yytext,"|") == 0) 
				return BITWISE_OR;
			if(strcmp(yytext,"=") == 0) 
				return ASSIGN;
			if(strcmp(yytext,"*=") == 0) 
				return MUL_ASSIGN;
			if(strcmp(yytext,"/=") == 0) 
				return DIV_ASSIGN;
			if(strcmp(yytext,"%=") == 0) 
				return MOD_ASSIGN;
			if(strcmp(yytext,"+=") == 0) 
				return PLUS_ASSIGN;
			if(strcmp(yytext,"-=") == 0) 
				return MINUS_ASSIGN;
			if(strcmp(yytext,"|=") == 0) 
				return BITWISE_OR_ASSIGN;
			if(strcmp(yytext,"&=") == 0) 
				return BITWISE_AND_ASSIGN;
			if(strcmp(yytext,"^=") == 0) 
				return XOR_ASSIGN;
			if(strcmp(yytext,"->") == 0) 
				return IMPLIES;
			if(strcmp(yytext,"^") == 0) 
				return XOR;
			if(strcmp(yytext,"...") == 0) 
				return DOTS;
			if(strcmp(yytext,".") == 0) 
				return DOT;
			if(strcmp(yytext,"*") == 0) 
				return MUL;
			if(strcmp(yytext,"+") == 0) 
				return PLUS;
			if(strcmp(yytext,"-") == 0) 
				return MINUS;
			if(strcmp(yytext,"~") == 0) 
				return COMPLEMENT;
			if(strcmp(yytext,"!") == 0) 
				return NOT;
			if(strcmp(yytext,"/") == 0) 
				return DIV;
			if(strcmp(yytext,"%") == 0) 
				return MOD;
			if(strcmp(yytext,"?") == 0) 
				return QUES_MARK;
			if(strcmp(yytext,":") == 0) 
				return COLON;
			if(strcmp(yytext,",") == 0) 
				return COMMA;
			if(strcmp(yytext,"#") == 0) 
				return HASH;
			if(strcmp(yytext,";") == 0) 
				return SEMICOLON;
			}

{WS} 		{

			}

%%