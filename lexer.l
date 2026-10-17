%{
#define _POSIX_C_SOURCE 200809L
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
static char comment_buf[2048];
%}

%option noyywrap yylineno nodefault nounput noinput

%x MULTI_COMMENT

%%

"coin"          { return TOKEN_COIN; }
"star"          { return TOKEN_STAR; }
"player"        { return TOKEN_PLAYER; }
"mushroom"      { return TOKEN_MUSHROOM; }
"oneUp"         { return TOKEN_ONEUP; }
"poison"        { return TOKEN_POISON; }
"warp"          { return TOKEN_WARP; }
"level"         { return TOKEN_LEVEL; }
"box"           { return TOKEN_BOX; }
"flag"          { return TOKEN_FLAG; }
"pipe"          { return TOKEN_PIPE; }

"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"="             { return '='; }
"=="            { return TOKEN_EQ; }
"!="            { return TOKEN_NEQ; }
"<="            { return TOKEN_LEQ; }
">="            { return TOKEN_GEQ; }
"<"             { return '<'; }
">"             { return '>'; }

"?"             { return '?'; }
"["             { return '['; }
"]"             { return ']'; }
"("             { return '('; }
")"             { return ')'; }

\"[^\"]*\"|\'[^\']*\' {
    int len = strlen(yytext);
    yylval.str_val = (char *)malloc(len - 1);
    strncpy(yylval.str_val, yytext + 1, len - 2);
    yylval.str_val[len - 2] = '\0';
    return TOKEN_STRING;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str_val = strdup(yytext);
    return TOKEN_ID;
}

[0-9]+\.[0-9]+ {
    yylval.float_val = (float)atof(yytext);
    return TOKEN_NUM_FLOAT;
}

[0-9]+ {
    yylval.int_val = atoi(yytext);
    return TOKEN_NUM_INT;
}

"[?]"[^\n]* {
    yylval.str_val = strdup(yytext + 3);
    return TOKEN_COMMENT_LINE;
}

"[??]" {
    comment_buf[0] = '\0';
    BEGIN(MULTI_COMMENT);
}

<MULTI_COMMENT>"[??]" {
    BEGIN(INITIAL);
    yylval.str_val = strdup(comment_buf);
    return TOKEN_COMMENT_MULTI;
}

<MULTI_COMMENT>\n {
    strcat(comment_buf, "\n");
}

<MULTI_COMMENT>. {
    strcat(comment_buf, yytext);
}

[ \t\r\n\xa0]+  ;

. {
    printf("Error Lexico: Caracter no reconocido '%s' en la linea %d\n", yytext, yylineno);
}

%%