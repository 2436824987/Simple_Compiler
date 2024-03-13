%option noyywrap yylineno
%option outfile="lexer.c" header-file="lexer.h"
%{
#include "lang.h"
#include "parser.h"
int flag = 0;
%}

%%

0|[1-9][0-9]* {
    yylval.n = build_nat(yytext, yyleng);
    return TM_NAT;
}

"var" {
    return TM_VAR;
}

"int" {
    return TM_INT;
}

"long" {
    return TM_INT;
}

"long int" {
    return TM_INT;
}

"unsigned int" {
    return TM_UINT;
}

"unsigned long" {
    return TM_UINT;
}

"unsigned long int" {
    return TM_UINT;
}

"long long" {
    return TM_INT64;
}

"long long int" {
    return TM_INT64;
}

"unsigned long long" {
    return TM_UINT64;
}

"unsigned long long int" {
    return TM_UINT64;
}

"char" {
    return TM_CHAR;
}

"unsigned char" {
    return TM_U8;
}


"void" {
    return TM_VOID;
}

"enum" {
    return TM_ENUM;
}

"struct" {
    return TM_STRUCT;
}

"union" {
    return TM_UNION;
}

"sizeof" {
    return TM_SIZEOFTYPE;
}

"->" {
    return TM_DOT;
}

"." {
    return TM_ARR;
}

"," {
    return TM_COMMA;
}

"--" {
    return TM_DEC;
}

"++" {
    return TM_INC;
}

"[" {
    return TM_LEFT_SQU;
}

"]" {
    return TM_RIGHT_SQU;
}

"if" {
    return TM_IF;
}

"else" {
    return TM_ELSE;
}

"switch" {
    return TM_SWITCH;
}

"case" {
    return TM_CASE;
}

"default" {
    return TM_DEFAULT;
}

":" {
    return TM_COLON;
}

"while" {
    return TM_WHILE;
}

"do" {
    return TM_DOWHILE;
}

"for" {
    return TM_FOR;
}

"continue" {
    return TM_CONTINUE;
}

"break" {
    return TM_BREAK;
}

"return" {
    return TM_RETURN;
}

";" {
    return TM_SEMICOL;
}

"(" {
    return TM_LEFT_PAREN;
}

")" {
    return TM_RIGHT_PAREN;
}

"{" {
    return TM_LEFT_BRACE;
}

"}" {
    return TM_RIGHT_BRACE;
}

"!" {
    return TM_NOTBOOL;
}

"~" {
    return TM_NOTINT;
}

"+=" {
    return TM_ADD_ASSIGN;
}

"-=" {
    return TM_SUB_ASSIGN;
}

"*=" {
    return TM_MUL_ASSIGN;
}

"/=" {
    return TM_DIV_ASSIGN;
}

"%=" {
    return TM_MOD_ASSIGN;
}

"&=" {
    return TM_BAND_ASSIGN;
}

"|=" {
    return TM_BOR_ASSIGN;
}

"^=" {
    return TM_XOR_ASSIGN;
}

"<<=" {
    return TM_SHL_ASSIGN;
}

">>=" {
    return TM_SHR_ASSIGN;
}

"+" {
    return TM_PLUS;
}

"-" {
    return TM_MINUS;
}

"*" {
    return TM_MUL;
}

"/" {
    return TM_DIV;
}

"%" {
    return TM_MOD;
}

"<" {
    return TM_LT;
}

">" {
    return TM_GT;
}

"<=" {
    return TM_LE;
    }

">=" {
    return TM_GE;
    }

"==" {
    return TM_EQ;
    }

"!=" {
    return TM_NE;
    }

"=" {
    return TM_ASSIGN;
    }

"&&" {
    return TM_AND;
    }

"||" {
    return TM_OR;
    }

"&" {
    return TM_BAND;
    }

"|" {
    return TM_BOR;
    }

"^" {
    return TM_XOR;
    }

"<<" { 
    return TM_SHL;
    }

">>" {
    return TM_SHR;
    }

"With" {
    return TM_WITH;
}

"Require" {
    return TM_REQUIRE;
}

"Ensure" {
    return TM_ENSURE;
}

"Inv" {
    return TM_INV;
}

"Let" {
    return TM_LET;
}

"forall" {
    return TM_FORALL;
}

"exists" {
    return TM_EXISTS;
}

"//@" {
    flag = 1;
    return TM_COMMENT;
}

"/*@" {
    return TM_ST_COMMENT;
}

"*/" {
    return TM_EN_COMMENT;
}

[_A-Za-z][_A-Za-z0-9]* {
    yylval.i = new_str(yytext, yyleng);
    return TM_IDENT;
}

\n {
    if(flag == 1) {
        flag = 0;
        return TM_END;
    }
}

[ \t\r]    { };

.   {printf("%s",yytext);
     return -1; }
%%
