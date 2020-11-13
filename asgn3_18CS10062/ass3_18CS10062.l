%{ 
/* C Declarations and Definitions */
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


%} 

/* Regular Expression Definitions */

/*------- KEYWORDS ---------------*/
BREAK		"break"
CASE		"case"
CHAR		"char"
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
INT 		"int"
LONG		"long"
RETURN		"return"
SHORT		"short"
SIZEOF		"sizeof"
STATIC		"static"
STRUCT		"struct"
SWITCH		"switch"
TYPEDEF		"typedef"
UNION		"union"
VOID		"void"
WHILE		"while"

/*--------IDENTIFIER----------------*/
ID 			[a-zA-Z_][a-zA-Z0-9_]*

/*--------INTEGER CONSTANT-----------*/
INT_CONST   [0-9]+

/*--------FLOATING POINT CONSTANT-----*/
FLT_CONST   {FRACTION}{EXPONENT}?|{DIGIT}{EXPONENT}
EXPONENT	[eE][+-]?{DIGIT}
FRACTION 	({DIGIT}?\.{DIGIT})|({DIGIT}\.)
DIGIT		[0-9]+

/*-------CHARACTER CONSTANT----------*/
CHAR_CONST	'{CHAR_SEQ}'
CHAR_SEQ	{C_CHAR}+
C_CHAR		{SRC_SET}|{ESC_SEQ}
SRC_SET		[^\\\'\\n]

/*-------STRING CONSTANT-------------*/
STRING		\"{STR_SEQ}?\"
STR_SEQ		{STR_CHAR}+
STR_CHAR	{ESC_SEQ}|{STR_SET}
STR_SET		[^\\\"\\n]

ESC_SEQ 	\\a|\\b|\\f|\\n|\\t|\\r|\\v|\\\'|\\\"|\\\\|\\\?


/*---------PUNCTUATIONS--------------*/
PUNC		{BRACKET}|"->"|{UNARY}|[/%|?]|\^|\.|{RELATION}|"..."|{SHORTHAND}|[:,#;]

BRACKET 	[\[\{\}\(\)\]]
UNARY 		"++"|"--"|[&*+-~!]
RELATION	"<<"|">>"|[<>]|"<="|">="|"=="|"!="|"&&"|"||"
SHORTHAND	"="|[*/%+-|^&][=]|"<<="|">>="

/*---------WHITESPACE , TAB , NEW LINE CHARACTER-----------*/
WS			[ \t\n]


/*--------SINGLE COMMENT LINE---------*/
SIN_COMMENT	[/][/].*
 
/*--------MULTI COMMENT LINE----------*/
MULT_COMMENT [/][*]{STR2}*[*][/]
STR2		[^*]|{STR3}
STR3 		[*][^*/]

%% 
{BREAK}		return BREAK;
{CASE}		return CASE;
{CHAR}		return CHAR;
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
{INT}		return INT;
{LONG}		return LONG;
{RETURN}	return RETURN;
{SHORT}		return SHORT;
{SIZEOF}	return SIZEOF;
{STATIC}	return STATIC;
{STRUCT}	return STRUCT;
{SWITCH}	return SWITCH;
{TYPEDEF}	return TYPEDEF;
{UNION}		return UNION;
{VOID}		return VOID;
{WHILE}		return WHILE;
{ID}		return ID;
{INT_CONST}	return INT_CONST;
{FLT_CONST}	return FLT_CONST;
{CHAR_CONST} return CHAR_CONST;
{STRING}	return STRING;
{PUNC}		return PUNC;
{SIN_COMMENT} return SIN_COMMENT;
{MULT_COMMENT} return MULT_COMMENT;
{WS}	

%%

