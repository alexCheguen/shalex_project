%{
#define _POSIX_C_SOURCE 200809L
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
%}

%option noyywrap yylineno nodefault nounput noinput

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

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str_val = strdup(yytext);
    return TOKEN_ID;
}

[0-9]+\.[0-9]+ {
    yylval.float_val = atof(yytext);
    return TOKEN_NUM_FLOAT;
}

[0-9]+ {
    yylval.int_val = atoi(yytext);
    return TOKEN_NUM_INT;
}

"\[\?\]"[^\n]*               ; /* Ignora comentarios [?] */
"\[\?\?\]"(.|\n)*?"\[\?\?\]" ; /* Ignora comentarios multilínea [??] */
[ \t\r\n]+                   ; /* Ignora espacios */

. { printf("Error Léxico: Carácter no reconocido '%s'\n", yytext); }

%%