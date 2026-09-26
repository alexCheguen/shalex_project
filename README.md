# shalex_project
Proyecto compiladores 

# Front-end Compilador - Lenguaje Shalex (.sa)

Este proyecto implementa el Front-end (Analizador Léxico, Analizador Sintáctico, Generación de AST y Tabla de Símbolos) para el lenguaje Shalex (`.sa`).

## Requisitos Previos

Asegúrate de tener instaladas las siguientes herramientas en tu sistema (Linux/WSL/macOS):

- **GCC** (GNU Compiler Collection)
- **Flex** (Fast Lexical Analyzer)
- **Bison** (Parser Generator)

# 1. Bison con tu sintaxis exacta
bison -d -v -o parser.tab.c parser.y

# 2. Flex generando lex.yy.c
flex -o lex.yy.c lexer.l

# 3. Compilación estricta con GCC/CC
cc -Wall -pedantic -std=c11 parser.tab.c lex.yy.c -o programa

# 4. Probar
./programa valido.sa
./programa invalido.sa