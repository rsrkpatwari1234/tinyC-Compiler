/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IDENTIFIER = 258,
    INTEGER_CONSTANT = 259,
    FLOAT_CONSTANT = 260,
    CHARACTER_CONSTANT = 261,
    STRING_LITERAL = 262,
    ROUND_BRACKET_OPEN = 263,
    ROUND_BRACKET_CLOSE = 264,
    SQUARE_BRACKET_OPEN = 265,
    SQUARE_BRACKET_CLOSE = 266,
    CURLY_BRACKET_OPEN = 267,
    CURLY_BRACKET_CLOSE = 268,
    UNARY_INCREMENT = 269,
    UNARY_DECREMENT = 270,
    NOT = 271,
    MUL = 272,
    DIV = 273,
    MOD = 274,
    PLUS = 275,
    MINUS = 276,
    COMPLEMENT = 277,
    XOR = 278,
    DOT = 279,
    DOTS = 280,
    COMMA = 281,
    QUES_MARK = 282,
    COLON = 283,
    SEMICOLON = 284,
    IMPLIES = 285,
    HASH = 286,
    BITWISE_LEFT = 287,
    BITWISE_RIGHT = 288,
    BITWISE_AND = 289,
    BITWISE_OR = 290,
    LOGICAL_AND = 291,
    LOGICAL_OR = 292,
    LESS_THAN = 293,
    GREATER_THAN = 294,
    LESS_EQUAL = 295,
    GREATER_EQUAL = 296,
    EQUAL = 297,
    NOT_EQUAL = 298,
    ASSIGN = 299,
    MUL_ASSIGN = 300,
    DIV_ASSIGN = 301,
    MOD_ASSIGN = 302,
    PLUS_ASSIGN = 303,
    MINUS_ASSIGN = 304,
    BITWISE_LEFT_ASSIGN = 305,
    BITWISE_RIGHT_ASSIGN = 306,
    BITWISE_AND_ASSIGN = 307,
    XOR_ASSIGN = 308,
    BITWISE_OR_ASSIGN = 309,
    EXTERN = 310,
    STATIC = 311,
    VOID = 312,
    CHAR = 313,
    SHORT = 314,
    INT = 315,
    LONG = 316,
    FLOAT = 317,
    DOUBLE = 318,
    CONST = 319,
    RESTRICT = 320,
    VOLATILE = 321,
    INLINE = 322,
    SIZEOF = 323,
    TYPEDEF = 324,
    UNION = 325,
    STRUCT = 326,
    CASE = 327,
    DEFAULT = 328,
    IF = 329,
    ELSE = 330,
    SWITCH = 331,
    WHILE = 332,
    DO = 333,
    FOR = 334,
    GOTO = 335,
    CONTINUE = 336,
    BREAK = 337,
    RETURN = 338
  };
#endif
/* Tokens.  */
#define IDENTIFIER 258
#define INTEGER_CONSTANT 259
#define FLOAT_CONSTANT 260
#define CHARACTER_CONSTANT 261
#define STRING_LITERAL 262
#define ROUND_BRACKET_OPEN 263
#define ROUND_BRACKET_CLOSE 264
#define SQUARE_BRACKET_OPEN 265
#define SQUARE_BRACKET_CLOSE 266
#define CURLY_BRACKET_OPEN 267
#define CURLY_BRACKET_CLOSE 268
#define UNARY_INCREMENT 269
#define UNARY_DECREMENT 270
#define NOT 271
#define MUL 272
#define DIV 273
#define MOD 274
#define PLUS 275
#define MINUS 276
#define COMPLEMENT 277
#define XOR 278
#define DOT 279
#define DOTS 280
#define COMMA 281
#define QUES_MARK 282
#define COLON 283
#define SEMICOLON 284
#define IMPLIES 285
#define HASH 286
#define BITWISE_LEFT 287
#define BITWISE_RIGHT 288
#define BITWISE_AND 289
#define BITWISE_OR 290
#define LOGICAL_AND 291
#define LOGICAL_OR 292
#define LESS_THAN 293
#define GREATER_THAN 294
#define LESS_EQUAL 295
#define GREATER_EQUAL 296
#define EQUAL 297
#define NOT_EQUAL 298
#define ASSIGN 299
#define MUL_ASSIGN 300
#define DIV_ASSIGN 301
#define MOD_ASSIGN 302
#define PLUS_ASSIGN 303
#define MINUS_ASSIGN 304
#define BITWISE_LEFT_ASSIGN 305
#define BITWISE_RIGHT_ASSIGN 306
#define BITWISE_AND_ASSIGN 307
#define XOR_ASSIGN 308
#define BITWISE_OR_ASSIGN 309
#define EXTERN 310
#define STATIC 311
#define VOID 312
#define CHAR 313
#define SHORT 314
#define INT 315
#define LONG 316
#define FLOAT 317
#define DOUBLE 318
#define CONST 319
#define RESTRICT 320
#define VOLATILE 321
#define INLINE 322
#define SIZEOF 323
#define TYPEDEF 324
#define UNION 325
#define STRUCT 326
#define CASE 327
#define DEFAULT 328
#define IF 329
#define ELSE 330
#define SWITCH 331
#define WHILE 332
#define DO 333
#define FOR 334
#define GOTO 335
#define CONTINUE 336
#define BREAK 337
#define RETURN 338

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 24 "ass5_18CS10062_18CS10067.y" /* yacc.c:1909  */
            //yylval is a union of all these types

	char unaryOp;	//unaryoperator		
	char* char_value;	//char value

	int instr_number;		//instruction number: for backpatching
	int intval;		//integer value	
	int num_params;			//number of parameters

	Expression* expr;		//expression
	Statement* stat;		//statement		

	symboltype* sym_type;	//symbol type  
	sym* symp;		//symbol
	Array* A;  //Array type
		

#line 238 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
