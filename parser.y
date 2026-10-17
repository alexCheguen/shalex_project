%{
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yylineno;
extern char *yytext;
extern FILE *yyin;

void yyerror(const char *s);

/* =========================================================================
 * 1. ESTRUCTURAS DE DATOS: TABLA DE SÍMBOLOS Y AST
 * ========================================================================= */

/* Tabla de Símbolos básica */
typedef struct Symbol {
    char name[50];
    char type[20];
    struct Symbol *next;
} Symbol;

Symbol *symbolTable = NULL;

void addSymbol(const char *name, const char *type) {
    Symbol *curr = symbolTable;
    while (curr) {
        if (strcmp(curr->name, name) == 0) return; // Ya existe
        curr = curr->next;
    }
    Symbol *newSym = (Symbol *)malloc(sizeof(Symbol));
    strncpy(newSym->name, name, 49);
    strncpy(newSym->type, type, 19);
    newSym->next = symbolTable;
    symbolTable = newSym;
}

/* Árbol Sintáctico Abstracto (AST) */
typedef enum {
    NODE_PROGRAM,
    NODE_DECLARATION,
    NODE_ASSIGNMENT,
    NODE_IF,
    NODE_WHILE,
    NODE_READ,
    NODE_WRITE,
    NODE_BIN_OP,
    NODE_VAR,
    NODE_LITERAL,
    NODE_BLOCK
} NodeType;

typedef struct ASTNode {
    NodeType type;
    char label[100];
    char var_name[50];
    char value_str[50];
    char op_symbol[10];
    
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *cond;
    struct ASTNode *body;
    
    struct ASTNode **children;
    int child_count;
} ASTNode;

ASTNode *ast_root = NULL;

/* Funciones auxiliares para construcción de AST */
ASTNode *createNode(NodeType type, const char *label) {
    ASTNode *node = (ASTNode *)calloc(1, sizeof(ASTNode));
    node->type = type;
    if (label) strncpy(node->label, label, 99);
    return node;
}

void addChild(ASTNode *parent, ASTNode *child) {
    if (!parent || !child) return;
    parent->child_count++;
    parent->children = (ASTNode **)realloc(parent->children, sizeof(ASTNode *) * parent->child_count);
    parent->children[parent->child_count - 1] = child;
}

/* =========================================================================
 * 2. GENERADOR DE CÓDIGO A ULORIO (.urio)
 * ========================================================================= */

void generar_codigo_ulorio(ASTNode *node, FILE *out) {
    if (!node || !out) return;

    switch (node->type) {
        case NODE_PROGRAM:
        case NODE_BLOCK:
            for (int i = 0; i < node->child_count; i++) {
                generar_codigo_ulorio(node->children[i], out);
            }
            break;

        case NODE_DECLARATION:
            // coin x = 10? -> crear $x = 10;
            fprintf(out, "crear $%s = %s;\n", node->var_name, node->value_str);
            break;

        case NODE_ASSIGNMENT:
            // x = 10? -> $x = 10;
            fprintf(out, "$%s = ", node->var_name);
            generar_codigo_ulorio(node->left, out);
            fprintf(out, ";\n");
            break;

        case NODE_IF:
            // mushroom (cond) [ ... ] -> si (cond) [ ... ]
            fprintf(out, "si (");
            generar_codigo_ulorio(node->cond, out);
            fprintf(out, ") [\n");
            generar_codigo_ulorio(node->body, out);
            fprintf(out, "]\n");
            break;

        case NODE_WHILE:
            // warp (cond) [ ... ] -> mientras (cond) [ ... ]
            fprintf(out, "mientras (");
            generar_codigo_ulorio(node->cond, out);
            fprintf(out, ") [\n");
            generar_codigo_ulorio(node->body, out);
            fprintf(out, "]\n");
            break;

        case NODE_READ:
            // box(x)? -> leer($x);
            fprintf(out, "leer($%s);\n", node->var_name);
            break;

        case NODE_WRITE:
            // flag(x)? -> mostrar($x);
            fprintf(out, "mostrar(");
            generar_codigo_ulorio(node->left, out);
            fprintf(out, ");\n");
            break;

        case NODE_BIN_OP:
            generar_codigo_ulorio(node->left, out);
            fprintf(out, " %s ", node->op_symbol);
            generar_codigo_ulorio(node->right, out);
            break;

        case NODE_VAR:
            fprintf(out, "$%s", node->var_name);
            break;

        case NODE_LITERAL:
            fprintf(out, "%s", node->value_str);
            break;

        default:
            break;
    }
}

%}

/* =========================================================================
 * 3. DECLARACIÓN DE UNION Y TOKENS (SINTONIZADOS CON FLEX)
 * ========================================================================= */

%union {
    int int_val;
    float float_val;
    char *str_val;
    struct ASTNode *ast_node;
}

/* Palabras reservadas */
%token TOKEN_COIN TOKEN_STAR TOKEN_PLAYER TOKEN_MUSHROOM TOKEN_ONEUP
%token TOKEN_POISON TOKEN_WARP TOKEN_LEVEL TOKEN_BOX TOKEN_FLAG TOKEN_PIPE

/* Operadores relacionales */
%token TOKEN_EQ TOKEN_NEQ TOKEN_LEQ TOKEN_GEQ

/* Identificadores y Literales */
%token <str_val> TOKEN_ID
%token <int_val> TOKEN_NUM_INT
%token <float_val> TOKEN_NUM_FLOAT

/* Tipos para No-Terminales */
%type <ast_node> programa lista_instrucciones instruccion declaracion asignacion
%type <ast_node> condicional ciclo lectura escritura expresion termino factor expresion_relacional

%%

/* =========================================================================
 * 4. REGLAS GRAMATICALES
 * ========================================================================= */

programa:
    lista_instrucciones {
        ast_root = createNode(NODE_PROGRAM, "PROGRAMA");
        ast_root->children = $1->children;
        ast_root->child_count = $1->child_count;
        $$ = ast_root;
    }
    ;

lista_instrucciones:
    lista_instrucciones instruccion {
        if ($2 != NULL) {
            addChild($1, $2);
        }
        $$ = $1;
    }
    | instruccion {
        ASTNode *block = createNode(NODE_BLOCK, "BLOQUE");
        if ($1 != NULL) {
            addChild(block, $1);
        }
        $$ = block;
    }
    ;

instruccion:
      declaracion { $$ = $1; }
    | asignacion  { $$ = $1; }
    | condicional { $$ = $1; }
    | ciclo       { $$ = $1; }
    | lectura     { $$ = $1; }
    | escritura   { $$ = $1; }
    ;

/* Declaraciones: coin x = 10? o star y = 0.5? */
declaracion:
    TOKEN_COIN TOKEN_ID '=' TOKEN_NUM_INT '?' {
        addSymbol($2, "INT");
        ASTNode *node = createNode(NODE_DECLARATION, "DECLARACION_INT");
        strncpy(node->var_name, $2, 49);
        snprintf(node->value_str, 49, "%d", $4);
        free($2);
        $$ = node;
    }
    | TOKEN_STAR TOKEN_ID '=' TOKEN_NUM_FLOAT '?' {
        addSymbol($2, "FLOAT");
        ASTNode *node = createNode(NODE_DECLARATION, "DECLARACION_FLOAT");
        strncpy(node->var_name, $2, 49);
        snprintf(node->value_str, 49, "%.2f", $4);
        free($2);
        $$ = node;
    }
    ;

/* Asignaciones: x = expresion? */
asignacion:
    TOKEN_ID '=' expresion '?' {
        addSymbol($1, "VAR");
        ASTNode *node = createNode(NODE_ASSIGNMENT, "ASIGNACION");
        strncpy(node->var_name, $1, 49);
        node->left = $3;
        free($1);
        $$ = node;
    }
    ;

/* Condicionales: mushroom (cond) [ ... ] */
condicional:
    TOKEN_MUSHROOM '(' expresion_relacional ')' '[' lista_instrucciones ']' {
        ASTNode *node = createNode(NODE_IF, "MUSHROOM_IF");
        node->cond = $3;
        node->body = $6;
        $$ = node;
    }
    ;

/* Ciclos: warp (cond) [ ... ] */
ciclo:
    TOKEN_WARP '(' expresion_relacional ')' '[' lista_instrucciones ']' {
        ASTNode *node = createNode(NODE_WHILE, "WARP_WHILE");
        node->cond = $3;
        node->body = $6;
        $$ = node;
    }
    ;

/* Lectura: box(x)? */
lectura:
    TOKEN_BOX '(' TOKEN_ID ')' '?' {
        addSymbol($3, "VAR");
        ASTNode *node = createNode(NODE_READ, "BOX_READ");
        strncpy(node->var_name, $3, 49);
        free($3);
        $$ = node;
    }
    ;

/* Escritura: flag(expresion)? */
escritura:
    TOKEN_FLAG '(' expresion ')' '?' {
        ASTNode *node = createNode(NODE_WRITE, "FLAG_WRITE");
        node->left = $3;
        $$ = node;
    }
    ;

/* Expresiones relacionales */
expresion_relacional:
    expresion TOKEN_LEQ expresion {
        ASTNode *node = createNode(NODE_BIN_OP, "OP_LEQ");
        strncpy(node->op_symbol, "<=", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | expresion TOKEN_GEQ expresion {
        ASTNode *node = createNode(NODE_BIN_OP, "OP_GEQ");
        strncpy(node->op_symbol, ">=", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | expresion TOKEN_EQ expresion {
        ASTNode *node = createNode(NODE_BIN_OP, "OP_EQ");
        strncpy(node->op_symbol, "==", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | expresion TOKEN_NEQ expresion {
        ASTNode *node = createNode(NODE_BIN_OP, "OP_NEQ");
        strncpy(node->op_symbol, "!=", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | expresion '<' expresion {
        ASTNode *node = createNode(NODE_BIN_OP, "OP_LT");
        strncpy(node->op_symbol, "<", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | expresion '>' expresion {
        ASTNode *node = createNode(NODE_BIN_OP, "OP_GT");
        strncpy(node->op_symbol, ">", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    ;

/* Expresiones aritméticas */
expresion:
    expresion '+' termino {
        ASTNode *node = createNode(NODE_BIN_OP, "SUMA");
        strncpy(node->op_symbol, "+", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | expresion '-' termino {
        ASTNode *node = createNode(NODE_BIN_OP, "RESTA");
        strncpy(node->op_symbol, "-", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | termino { $$ = $1; }
    ;

termino:
    termino '*' factor {
        ASTNode *node = createNode(NODE_BIN_OP, "MULT");
        strncpy(node->op_symbol, "*", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | termino '/' factor {
        ASTNode *node = createNode(NODE_BIN_OP, "DIV");
        strncpy(node->op_symbol, "/", 9);
        node->left = $1;
        node->right = $3;
        $$ = node;
    }
    | factor { $$ = $1; }
    ;

factor:
    '(' expresion ')' { $$ = $2; }
    | TOKEN_ID {
        addSymbol($1, "VAR");
        ASTNode *node = createNode(NODE_VAR, "VARIABLE");
        strncpy(node->var_name, $1, 49);
        free($1);
        $$ = node;
    }
    | TOKEN_NUM_INT {
        ASTNode *node = createNode(NODE_LITERAL, "INT");
        snprintf(node->value_str, 49, "%d", $1);
        $$ = node;
    }
    | TOKEN_NUM_FLOAT {
        ASTNode *node = createNode(NODE_LITERAL, "FLOAT");
        snprintf(node->value_str, 49, "%.2f", $1);
        $$ = node;
    }
    ;

%%

/* =========================================================================
 * 5. CÓDIGO C INTEGRADO Y PUNTO DE ENTRADA MAIN
 * ========================================================================= */

void yyerror(const char *s) {
    fprintf(stderr, "\n[ERROR SINTÁCTICO]: %s cerca de '%s' en la línea %d\n", s, yytext, yylineno);
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Uso: %s <archivo_entrada.sa>\n", argv[0]);
        return 1;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        perror("Error al abrir el archivo .sa de entrada");
        return 1;
    }

    yyin = input_file;

    printf("Iniciando análisis léxico y sintáctico del archivo '%s'...\n", argv[1]);

    if (yyparse() == 0) {
        printf("¡Análisis sintáctico completado con éxito!\n");

        FILE *out_file = fopen("salida.urio", "w");
        if (!out_file) {
            perror("Error al crear el archivo destino .urio");
            fclose(input_file);
            return 1;
        }

        /* Generación del archivo en formato Ulorio */
        generar_codigo_ulorio(ast_root, out_file);
        fclose(out_file);

        printf("Archivo 'salida.urio' exportado correctamente.\n");
    } else {
        printf("Falló el análisis del archivo.\n");
    }

    fclose(input_file);
    return 0;
}


