%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern FILE *yyin;
void yyerror(const char *s);

/* --- ESTRUCTURA DE LA TABLA DE SÍMBOLOS --- */
typedef struct Symbol {
    char name[50];
    char type[20];
    struct Symbol *next;
} Symbol;

Symbol *symbolTable = NULL;

void addSymbol(const char *name, const char *type) {
    Symbol *s = symbolTable;
    while (s) {
        if (strcmp(s->name, name) == 0) {
            return; // Ya existe en la tabla
        }
        s = s->next;
    }
    Symbol *newSym = (Symbol *)malloc(sizeof(Symbol));
    strcpy(newSym->name, name);
    strcpy(newSym->type, type);
    newSym->next = symbolTable;
    symbolTable = newSym;
}

void printSymbolTable() {
    printf("\n================ TABLA DE SÍMBOLOS ================\n");
    printf("%-20s | %-15s\n", "Nombre (ID)", "Tipo de Dato");
    printf("---------------------------------------------------\n");
    Symbol *s = symbolTable;
    while (s) {
        printf("%-20s | %-15s\n", s->name, s->type);
        s = s->next;
    }
    printf("===================================================\n\n");
}

/* --- ESTRUCTURA DEL ÁRBOL SINTÁCTICO ABSTRACTO (AST) --- */
typedef struct ASTNode {
    char label[100];
    struct ASTNode *left;
    struct ASTNode *right;
} ASTNode;

ASTNode* createNode(const char* label, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    strcpy(node->label, label);
    node->left = left;
    node->right = right;
    return node;
}

void printAST(ASTNode* node, int level) {
    if (!node) return;
    for (int i = 0; i < level; i++) printf("  ");
    printf("|-- %s\n", node->label);
    printAST(node->left, level + 1);
    printAST(node->right, level + 1);
}

ASTNode *root = NULL;
%}

%union {
    int int_val;
    double float_val;
    char* str_val;
    struct ASTNode* ast_node;
}

%token TOKEN_COIN TOKEN_STAR TOKEN_PLAYER TOKEN_MUSHROOM TOKEN_ONEUP TOKEN_POISON
%token TOKEN_WARP TOKEN_LEVEL TOKEN_BOX TOKEN_FLAG TOKEN_PIPE
%token TOKEN_EQ TOKEN_NEQ TOKEN_LEQ TOKEN_GEQ
%token <str_val> TOKEN_ID
%token <int_val> TOKEN_NUM_INT
%token <float_val> TOKEN_NUM_FLOAT

%type <ast_node> programa lista_instrucciones instruccion declaracion asignacion lectura escritura condicional ciclo expresion termino factor

%start programa

%%

programa:
    lista_instrucciones { root = $1; }
    ;

lista_instrucciones:
    instruccion lista_instrucciones { $$ = createNode("BLOQUE", $1, $2); }
    | /* vacio */ { $$ = NULL; }
    ;

instruccion:
    declaracion { $$ = $1; }
    | asignacion { $$ = $1; }
    | lectura { $$ = $1; }
    | escritura { $$ = $1; }
    | condicional { $$ = $1; }
    | ciclo { $$ = $1; }
    ;

declaracion:
    TOKEN_COIN TOKEN_ID '?' {
        addSymbol($2, "coin (int)");
        char buf[100]; sprintf(buf, "DECLARACION (coin %s)", $2);
        $$ = createNode(buf, NULL, NULL);
    }
    | TOKEN_STAR TOKEN_ID '?' {
        addSymbol($2, "star (float)");
        char buf[100]; sprintf(buf, "DECLARACION (star %s)", $2);
        $$ = createNode(buf, NULL, NULL);
    }
    | TOKEN_COIN TOKEN_ID '=' expresion '?' {
        addSymbol($2, "coin (int)");
        char buf[100]; sprintf(buf, "DECLARACION_ASIG (coin %s)", $2);
        $$ = createNode(buf, $4, NULL);
    }
    ;

asignacion:
    TOKEN_ID '=' expresion '?' {
        char buf[100]; sprintf(buf, "ASIGNACION (= %s)", $1);
        $$ = createNode(buf, $3, NULL);
    }
    ;

lectura:
    TOKEN_BOX '(' TOKEN_ID ')' '?' {
        char buf[100]; sprintf(buf, "ENTRADA_BOX (%s)", $3);
        $$ = createNode(buf, NULL, NULL);
    }
    ;

escritura:
    TOKEN_FLAG '(' expresion ')' '?' {
        $$ = createNode("SALIDA_FLAG", $3, NULL);
    }
    ;

condicional:
    TOKEN_MUSHROOM '(' expresion '>' expresion ')' '[' lista_instrucciones ']' {
        ASTNode* cond = createNode("CONDICION (>)", $3, $5);
        $$ = createNode("MUSHROOM (IF)", cond, $8);
    }
    ;

ciclo:
    TOKEN_WARP '(' expresion '<' expresion ')' '[' lista_instrucciones ']' {
        ASTNode* cond = createNode("CONDICION (<)", $3, $5);
        $$ = createNode("WARP (WHILE)", cond, $8);
    }
    ;

expresion:
    expresion '+' termino { $$ = createNode("SUMA (+)", $1, $3); }
    | expresion '-' termino { $$ = createNode("RESTA (-)", $1, $3); }
    | termino { $$ = $1; }
    ;

termino:
    termino '*' factor { $$ = createNode("MULT (*)", $1, $3); }
    | termino '/' factor { $$ = createNode("DIV (/)", $1, $3); }
    | factor { $$ = $1; }
    ;

factor:
    '(' expresion ')' { $$ = $2; }
    | TOKEN_ID {
        char buf[100]; sprintf(buf, "ID (%s)", $1);
        $$ = createNode(buf, NULL, NULL);
    }
    | TOKEN_NUM_INT {
        char buf[100]; sprintf(buf, "INT (%d)", $1);
        $$ = createNode(buf, NULL, NULL);
    }
    | TOKEN_NUM_FLOAT {
        char buf[100]; sprintf(buf, "FLOAT (%.2f)", $1);
        $$ = createNode(buf, NULL, NULL);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "\n[ERROR SINTÁCTICO]: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error al abrir el archivo de prueba");
            return 1;
        }
        yyin = file;
    }

    printf("Iniciando análisis sintáctico...\n");
    if (yyparse() == 0) {
        printf("\n¡Análisis Sintáctico Exitoso!\n");
        
        printSymbolTable();

        printf("================ ÁRBOLES SINTÁCTICO (AST) ================\n");
        printAST(root, 0);
        printf("=========================================================\n");
    } else {
        printf("\nFalló el análisis del archivo.\n");
    }
    return 0;
}