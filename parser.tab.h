/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     TOKEN_COIN = 258,
     TOKEN_STAR = 259,
     TOKEN_PLAYER = 260,
     TOKEN_MUSHROOM = 261,
     TOKEN_ONEUP = 262,
     TOKEN_POISON = 263,
     TOKEN_WARP = 264,
     TOKEN_LEVEL = 265,
     TOKEN_BOX = 266,
     TOKEN_FLAG = 267,
     TOKEN_PIPE = 268,
     TOKEN_EQ = 269,
     TOKEN_NEQ = 270,
     TOKEN_LEQ = 271,
     TOKEN_GEQ = 272,
     TOKEN_ID = 273,
     TOKEN_STRING = 274,
     TOKEN_NUM_INT = 275,
     TOKEN_NUM_FLOAT = 276
   };
#endif
/* Tokens.  */
#define TOKEN_COIN 258
#define TOKEN_STAR 259
#define TOKEN_PLAYER 260
#define TOKEN_MUSHROOM 261
#define TOKEN_ONEUP 262
#define TOKEN_POISON 263
#define TOKEN_WARP 264
#define TOKEN_LEVEL 265
#define TOKEN_BOX 266
#define TOKEN_FLAG 267
#define TOKEN_PIPE 268
#define TOKEN_EQ 269
#define TOKEN_NEQ 270
#define TOKEN_LEQ 271
#define TOKEN_GEQ 272
#define TOKEN_ID 273
#define TOKEN_STRING 274
#define TOKEN_NUM_INT 275
#define TOKEN_NUM_FLOAT 276




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 211 "parser.y"
{
    int int_val;
    float float_val;
    char *str_val;
    struct ASTNode *ast_node;
}
/* Line 1529 of yacc.c.  */
#line 98 "parser.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

