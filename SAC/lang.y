%{
	// this part is copied to the beginning of the parser 
	#include <stdio.h>
	#include "lang.h"
	#include "lexer.h"
	void yyerror(char *);
	int yylex(void);
        struct def_list * root;
%}

%union {
unsigned int n;
char * i;
struct expr * e;
struct cmd * c;
void * none;
struct expr_list * e_l;
struct Case * C;
struct Case_list * C_l;
struct var_list * v_l;
struct def * d;
struct def_list * d_l;
struct RAssertion * RA;
struct RA_list * RA_l;
struct type * t;
struct Afuncdef * Af;
struct ASepdef * AS;
struct var_dec * v_d;
struct field_dec * f_d;
struct def * de;
struct field_dec_list * f_d_l;
struct enum_list * en_l;
struct simple_cmd * s_c;
struct var_dec_list * v_d_l;
struct cmd_list * cmd_l;
}

// Terminals
%token <n> TM_NAT
%token <i> TM_IDENT
%token <none> TM_VOID TM_CHAR TM_U8 TM_INT TM_INT64 TM_UINT TM_UINT64
%token <none> TM_STRUCT TM_UNION TM_ENUM 
%token <none> TM_PLUS TM_MINUS
%token <none> TM_MUL TM_DIV TM_MOD
%token <none> TM_LT TM_LE TM_GT TM_GE TM_EQ TM_NE
%token <none> TM_OR
%token <none> TM_AND
%token <none> TM_COLON
//%token <none> TM_NOT
%token <none> TM_BAND TM_BOR TM_XOR TM_SHL TM_SHR
%token <none> TM_UMINUS TM_UPLUS TM_NOTBOOL TM_NOTINT //?
%token <none> TM_VAR 
%token <none> TM_SIZEOFTYPE
%token <none> TM_CASE TM_DEFAULT
%token <none> TM_ASSIGN TM_ADD_ASSIGN TM_SUB_ASSIGN TM_MUL_ASSIGN TM_DIV_ASSIGN
%token <none> TM_MOD_ASSIGN TM_BAND_ASSIGN TM_BOR_ASSIGN TM_XOR_ASSIGN TM_SHL_ASSIGN TM_SHR_ASSIGN
%token <none> TM_INC TM_DEC
%token <none> TM_IF TM_ELSE TM_SWITCH TM_WHILE TM_DOWHILE TM_FOR TM_BREAK TM_CONTINUE
%token <e> TM_RETURN
%token <none> TM_COMMENT// ("//@")
%token <none> TM_ST_COMMENT TM_EN_COMMENT
%token <none> TM_WITH TM_REQUIRE TM_ENSURE
%token <none> TM_LET TM_FORALL TM_EXISTS
%token <none> TM_INV TM_END
%token <none> TM_DEREF TM_ADDRES

%token <none> TM_LEFT_BRACE TM_RIGHT_BRACE
%token <none> TM_LEFT_PAREN TM_RIGHT_PAREN
%token <none> TM_LEFT_SQU TM_RIGHT_SQU
%token <none> TM_DOT TM_ARR
%token <none> TM_SEMICOL TM_COMMA

// Nonterminals
%type <d_l> NT_WHOLE//
%type <c> NT_CMD//
%type <e> NT_EXPR//
%type <C_l> NT_CASE_LIST
%type <RA> NT_RASSERTION
%type <s_c> NT_SIMPLE_CMD//
%type <v_d> NT_VAR_DEC//
%type <t> NT_TYPE//
%type <e_l> NT_EXPR_LIST
%type <Af> NT_AFUNCDEF
%type <AS> NT_ASEPDEF
%type <f_d> NT_FIELD_DEC
%type <d> NT_DEF
%type <f_d_l> NT_FIELD_DEC_LIST
%type <d_l> NT_DEF_LIST
%type <en_l> NT_ENUM_LIST
%type <RA_l> NT_RA_LIST
%type <C> NT_Case
%type <v_l> NT_VAR_LIST
%type <v_d_l> NT_VAR_DEC_LIST
%type <cmd_l> NT_CMD_LIST


// Priority
%nonassoc TM_DEFAULT
%right TM_SEMICOL
%left TM_COMMA
%right TM_ASSIGN TM_ADD_ASSIGNl TM_SUB_ASSIGN TM_MUL_ASSIGN TM_DIV_ASSIGN TM_MOD_ASSIGN TM_BAND_ASSIGN TM_BOR_ASSIGN TM_XOR_ASSIGN TM_SHL_ASSIGN TM_SHR_ASSIGN
%nonassoc TM_FORALL TM_EXISTS
%left TM_OR TM_AND TM_BOR TM_XOR TM_BAND
%left TM_NE TM_EQ TM_LT TM_LE TM_GT TM_GE
%left TM_SHL TM_SHR
%left TM_PLUS TM_MINUS
%left TM_MUL TM_DIV TM_MOD
%right TM_NOTBOOL TM_NOTINT TM_UPLUS TM_UMINUS TM_SIZEOFTYPE TM_DEREF TM_ADDRES TM_INC TM_DEC
%left TM_DOT TM_ARR TM_LEFT_PAREN TM_RIGHT_PAREN TM_LEFT_SQU TM_RIGHT_SQU

%nonassoc LOWER_THAN_ELSE
%nonassoc TM_ELSE

%%

NT_WHOLE:
  NT_DEF_LIST
  {
    $$ = ($1);
    root = $$;
  }
;

NT_DEF_LIST:
  NT_DEF
  {
    $$ = (DFLCons($1,NULL));
  }
| NT_DEF NT_DEF_LIST
  {
    $$ = (DFLCons($1,$2));
  }
;

NT_DEF:
  NT_TYPE TM_IDENT TM_LEFT_PAREN NT_VAR_DEC_LIST TM_RIGHT_PAREN TM_COMMENT NT_AFUNCDEF TM_END TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TFuncdef($1,$2,$4,$9,$7));
  }
| NT_TYPE TM_IDENT TM_LEFT_PAREN NT_VAR_DEC_LIST TM_RIGHT_PAREN TM_ST_COMMENT NT_AFUNCDEF TM_EN_COMMENT TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TFuncdef($1,$2,$4,$10,$7));
  }
| NT_TYPE TM_IDENT TM_LEFT_PAREN NT_VAR_DEC_LIST TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TFuncdef($1,$2,$4,$7,NULL));
  }
| NT_TYPE TM_IDENT TM_LEFT_PAREN NT_VAR_DEC_LIST TM_RIGHT_PAREN TM_SEMICOL 
  {
    $$ = (TFuncdec($1,$2,$4,NULL));
  }
| NT_TYPE TM_IDENT TM_LEFT_PAREN NT_VAR_DEC_LIST TM_RIGHT_PAREN TM_COMMENT NT_AFUNCDEF TM_END TM_SEMICOL 
  {
    $$ = (TFuncdec($1,$2,$4,$7));
  }
| NT_TYPE TM_IDENT TM_LEFT_PAREN NT_VAR_DEC_LIST TM_RIGHT_PAREN TM_ST_COMMENT NT_AFUNCDEF TM_EN_COMMENT TM_SEMICOL 
  {
    $$ = (TFuncdec($1,$2,$4,$7));
  }
| TM_COMMENT NT_ASEPDEF TM_END
  {                  
    $$ = (TSepdef($2)); 
  }
| TM_ST_COMMENT NT_ASEPDEF TM_EN_COMMENT
  {                  
    $$ = (TSepdef($2));
  }
| TM_UNION TM_IDENT TM_LEFT_BRACE NT_FIELD_DEC_LIST TM_RIGHT_BRACE TM_SEMICOL
  {
    $$ = (TUniondef($2,$4));
  }
| TM_ENUM TM_IDENT TM_LEFT_BRACE NT_ENUM_LIST TM_RIGHT_BRACE TM_SEMICOL
  {
    $$ = (TEnumdef($2,$4));
  } 
| TM_STRUCT TM_IDENT TM_LEFT_BRACE NT_FIELD_DEC_LIST TM_RIGHT_BRACE TM_SEMICOL
  {
    $$ = (TStructdef($2,$4));
  }
| TM_UNION TM_IDENT TM_SEMICOL
  {
    $$ = (TUniondef($2,NULL));  
  }
| TM_ENUM TM_IDENT TM_SEMICOL
  {
    $$ = (TEnumdef($2,NULL));
  }
| TM_STRUCT TM_IDENT TM_SEMICOL
  {
    $$ = (TStructdef($2,NULL));
  }
| NT_VAR_DEC TM_SEMICOL
  {
    $$ = (TWholevardec($1,NULL));
  }
| NT_TYPE TM_SEMICOL
  {
    $$ = (TWholevardec(NULL,$1));
  }
;

NT_VAR_DEC_LIST:
  NT_VAR_DEC
  {
    $$ = (VDLCons($1,NULL));
  }
| NT_VAR_DEC TM_COMMA NT_VAR_DEC_LIST
  {
    $$ = (VDLCons($1,$3));
  }
;

NT_CASE_LIST:
  NT_Case
  {
    $$ = (CLCons($1,NULL));
  }
| NT_Case TM_SEMICOL NT_CASE_LIST
  {
    $$ = (CLCons($1,$3));
  }
| TM_LEFT_BRACE NT_CASE_LIST TM_LEFT_BRACE
  {
    $$ = ($2);
  }
;

NT_Case:
  TM_CASE NT_EXPR TM_COLON NT_CMD_LIST
  {
    $$ = (TCase($2,$4));
  }
| TM_DEFAULT TM_COLON NT_CMD_LIST
  {
    $$ = (TDefault($3));
  }
;

NT_VAR_DEC:
  NT_TYPE TM_IDENT
  {
    $$ = (TVarDec($1,$2));
  }
;

NT_ENUM_LIST:
  TM_IDENT
  {
    $$ = (ENLCons($1,NULL));
  }
| TM_IDENT TM_COMMA NT_ENUM_LIST
  {
    $$ = (ENLCons($1,$2));
  }
| TM_LEFT_PAREN NT_ENUM_LIST TM_RIGHT_PAREN
  {
    $$ = ($2);
  }
;

NT_FIELD_DEC_LIST:
  NT_FIELD_DEC
  {
    $$ = (FDLCons($1,NULL));
  }
| NT_FIELD_DEC TM_SEMICOL NT_FIELD_DEC_LIST
  {
    $$ = (FDLCons($1,$3));
  }
;

NT_FIELD_DEC:
  NT_TYPE TM_IDENT
  {
    $$ = (TFieldDec($1,$2));
  }
;
  

NT_ASEPDEF:
  TM_LET TM_VAR TM_LEFT_PAREN NT_VAR_LIST TM_RIGHT_PAREN TM_ASSIGN NT_RASSERTION
  {
    $$ = (TAsepdef($2,$4,$7));
  }
;

NT_CMD:
  NT_VAR_DEC TM_SEMICOL
  {
    $$ = (TVarDecl($1));
  }
| NT_SIMPLE_CMD TM_SEMICOL
  {
    $$ = (TSimple($1));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE TM_ELSE TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TIf($3,$6,$10));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TIf($3,$6,NULL));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_SEMICOL TM_ELSE TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TIf($3,NULL,$8));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_SEMICOL
  {
    $$ = (TIf($3,NULL,NULL));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN NT_CMD 
  {
    $$ = (TIf($3,CMDLCons($5,NULL),NULL));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN NT_CMD TM_ELSE NT_CMD
  {
    $$ = (TIf($3,CMDLCons($5,NULL),CMDLCons($7,NULL)));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN NT_CMD TM_ELSE TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TIf($3,CMDLCons($5,NULL),$8));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_SEMICOL TM_ELSE NT_CMD 
  {
    $$ = (TIf($3,NULL,CMDLCons($5,NULL)));
  }
| TM_IF TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE TM_ELSE NT_CMD
  {
    $$ = (TIf($3,$6,CMDLCons($9,NULL)));
  }
| TM_SWITCH TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_LEFT_BRACE NT_CASE_LIST TM_RIGHT_BRACE
  {
    $$ = (TSwitch($3,$6));
  }
| TM_COMMENT TM_INV NT_RASSERTION TM_END TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TWhile($3,$6,$9));
  }
| TM_COMMENT TM_INV NT_RASSERTION TM_END TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN NT_CMD
  {
    $$ = (TWhile($3,$6,CMDLCons($8,NULL)));
  }
| TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TWhile(NULL,$3,$6));
  }
| TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN NT_CMD
  {
    $$ = (TWhile(NULL,$3,CMDLCons($5,NULL)));
  }
| TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN TM_SEMICOL
  {
    $$ = (TWhile(NULL,$3,NULL));
  }
| TM_COMMENT TM_INV NT_RASSERTION TM_END TM_DOWHILE TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN
  {
    $$ = (TDoWhile($3,$10,$6));
  }
| TM_COMMENT TM_INV NT_RASSERTION TM_END TM_DOWHILE NT_CMD TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN
  {
    $$ = (TDoWhile($3,$8,CMDLCons($5,NULL)));
  }
| TM_DOWHILE TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN
  {
    $$ = (TDoWhile(NULL,$7,$3));
  }
| TM_DOWHILE NT_CMD TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN
  {
    $$ = (TDoWhile(NULL,$5,CMDLCons($2,NULL)));
  }
| TM_DOWHILE TM_LEFT_BRACE TM_RIGHT_BRACE TM_WHILE TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN
  {
    $$ = (TDoWhile(NULL,$6,NULL));
  }
| TM_COMMENT TM_INV NT_RASSERTION TM_END TM_FOR TM_LEFT_PAREN NT_SIMPLE_CMD TM_SEMICOL NT_EXPR TM_SEMICOL NT_SIMPLE_CMD TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = (TFor($3,$6,$8,$10,$13));
  }
| TM_FOR TM_LEFT_PAREN NT_SIMPLE_CMD TM_SEMICOL NT_EXPR TM_SEMICOL NT_SIMPLE_CMD TM_RIGHT_PAREN TM_LEFT_BRACE NT_CMD_LIST TM_SEMICOL TM_RIGHT_BRACE
  {
    $$ = (TFor(NULL,$3,$5,$7,$10));
  }
| TM_FOR TM_LEFT_PAREN NT_SIMPLE_CMD TM_SEMICOL NT_EXPR TM_SEMICOL NT_SIMPLE_CMD TM_RIGHT_PAREN NT_CMD
  {
    $$ = (TFor(NULL,$3,$5,$7,CMDLCons($9,NULL)));
  }
| TM_BREAK
  {
    $$ = (TBreak());
  }
| TM_CONTINUE
  {
    $$ = (TContinue());
  }
| TM_RETURN
  {
    $$ = (TReturn($1));
  }
/*| NT_RASSERTION
  {
    $$ = (TComment($1));
  }*/
;

NT_CMD_LIST:
  NT_CMD
  {
    $$ = (CMDLCons($1,NULL));
  }
| NT_CMD NT_CMD_LIST
  {
    $$ = (CMDLCons($1,$2));
  }
| TM_LEFT_BRACE NT_CMD_LIST TM_RIGHT_BRACE
  {
    $$ = ($2);
  }
;

NT_SIMPLE_CMD:
  NT_EXPR//?
  {
    $$ = (TComputation($1));
  }
| NT_EXPR TM_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_ASSIGN,$1,$3));
  }
| NT_EXPR TM_ADD_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_ADD_ASSIGN,$1,$3));
  }
| NT_EXPR TM_SUB_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_SUB_ASSIGN,$1,$3));
  }
| NT_EXPR TM_MUL_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_MUL_ASSIGN,$1,$3));
  }
| NT_EXPR TM_DIV_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_DIV_ASSIGN,$1,$3));
  }
| NT_EXPR TM_MOD_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_MOD_ASSIGN,$1,$3));
  }
| NT_EXPR TM_BAND_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_BAND_ASSIGN,$1,$3));
  }
| NT_EXPR TM_BOR_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_BOR_ASSIGN,$1,$3));
  }
| NT_EXPR TM_XOR_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_XOR_ASSIGN,$1,$3));
  }
| NT_EXPR TM_SHL_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_SHL_ASSIGN,$1,$3));
  }
| NT_EXPR TM_SHR_ASSIGN NT_EXPR
  {
    $$ = (TAsgn(T_SHR_ASSIGN,$1,$3));
  } 
| TM_INC NT_EXPR
  {
    $$ = (TIncDec(T_INC_F,$2));
  }
| TM_DEC NT_EXPR
  {
    $$ = (TIncDec(T_DEC_F,$2));
  }
| NT_EXPR TM_DEC
  {
    $$ = (TIncDec(T_DEC_B,$1));
  }
| NT_EXPR TM_INC
  {
    $$ = (TIncDec(T_INC_B,$1));
  }
;

NT_AFUNCDEF:
  TM_WITH NT_VAR_LIST TM_REQUIRE NT_RASSERTION TM_ENSURE NT_RASSERTION
  {
    $$ = (TAfuncdef($2,$4,$6));
  }
| TM_REQUIRE NT_RASSERTION TM_ENSURE NT_RASSERTION
  {
    $$ = (TAfuncdef(NULL,$2,$4));
  }
;

NT_RASSERTION:
  TM_NAT 
  {
    $$ = (RAConst($1));
  }
| TM_IDENT
  {
    $$ = (RAVar($1));
  }
| NT_RASSERTION TM_PLUS NT_RASSERTION
  {
    $$ = (RABinop(T_PLUS,$1,$3));
  }
| NT_RASSERTION TM_MINUS NT_RASSERTION
  {
    $$ = (RABinop(T_MINUS,$1,$3));
  }
| NT_RASSERTION TM_MUL NT_RASSERTION
  {
    $$ = (RABinop(T_MUL,$1,$3));
  }
| NT_RASSERTION TM_DIV NT_RASSERTION
  {
    $$ = (RABinop(T_DIV,$1,$3));
  }
| NT_RASSERTION TM_MOD NT_RASSERTION
  {
    $$ = (RABinop(T_MOD,$1,$3));
  }
| NT_RASSERTION TM_LT NT_RASSERTION
  {
    $$ = (RABinop(T_LT,$1,$3));
  }
| NT_RASSERTION TM_GT NT_RASSERTION
  {
    $$ = (RABinop(T_GT,$1,$3));
  }
| NT_RASSERTION TM_LE NT_RASSERTION
  {
    $$ = (RABinop(T_LE,$1,$3));
  }
| NT_RASSERTION TM_GE NT_RASSERTION
  {
    $$ = (RABinop(T_GE,$1,$3));
  }
| NT_RASSERTION TM_EQ NT_RASSERTION
  {
    $$ = (RABinop(T_EQ,$1,$3));
  }
| NT_RASSERTION TM_NE NT_RASSERTION
  {
    $$ = (RABinop(T_NE,$1,$3));
  }
| NT_RASSERTION TM_AND NT_RASSERTION
  {
    $$ = (RABinop(T_AND,$1,$3));
  }
| NT_RASSERTION TM_OR NT_RASSERTION
  {
    $$ = (RABinop(T_OR,$1,$3));
  }
| NT_RASSERTION TM_BAND NT_RASSERTION
  {
    $$ = (RABinop(T_BAND,$1,$3));
  }
| NT_RASSERTION TM_BOR NT_RASSERTION
  {
    $$ = (RABinop(T_BOR,$1,$3));
  }
| NT_RASSERTION TM_XOR NT_RASSERTION
  {
    $$ = (RABinop(T_XOR,$1,$3));
  }
| NT_RASSERTION TM_SHL NT_RASSERTION
  {
    $$ = (RABinop(T_SHL,$1,$3));
  }
| NT_RASSERTION TM_SHR NT_RASSERTION
  {
    $$ = (RABinop(T_SHR,$1,$3));
  }
| TM_MINUS NT_RASSERTION %prec TM_UMINUS
  {
    $$ = (RAUnop(T_UMINUS,$2));
  }
| TM_PLUS NT_RASSERTION %prec TM_UPLUS
  {
    $$ = (RAUnop(T_UPLUS,$2));
  }
| TM_NOTBOOL NT_RASSERTION
  {
    $$ = (RAUnop(T_NOTBOOL,$2));
  }
| TM_NOTINT NT_RASSERTION
  {
    $$ = (RAUnop(T_NOTINT,$2));
  }
| TM_MUL NT_RASSERTION %prec TM_DEREF
  {
    $$ = (RADeref($2));
  }
| TM_BAND NT_RASSERTION %prec TM_ADDRES
  {
    $$ = (RAAddress($2));
  }
| TM_LEFT_PAREN NT_TYPE TM_RIGHT_PAREN NT_RASSERTION
  {
    $$ = (RACast($2,$4));
  }
| TM_IDENT TM_LEFT_PAREN NT_RA_LIST TM_RIGHT_PAREN
  {
    $$ = (RACall($1,$3));
  }
| NT_RASSERTION TM_LEFT_SQU NT_RASSERTION TM_RIGHT_SQU
  {
    $$ = (RAIndex($1,$3));
  }
| NT_RASSERTION TM_DOT TM_IDENT
  {
    $$ = (RAFieldof($1,$3));
  }
| NT_RASSERTION TM_ARR TM_IDENT
  {
    $$ = (RAFieldofptr($1,$3));
  }
| TM_FORALL TM_IDENT TM_COMMA NT_RASSERTION
  {
    $$ = (RAQfop(A_FORALL,$2,$4));
  }
| TM_EXISTS TM_IDENT TM_COMMA NT_RASSERTION
  {
    $$ = (RAQfop(A_EXISTS,$2,$4));
  }
;

NT_RA_LIST:
  NT_RASSERTION
  {
    $$ = (RALCons($1,NULL));
  }
| NT_RASSERTION TM_COMMA NT_RA_LIST
  {
    $$ = (RALCons($1,$2));
  }
;

NT_VAR_LIST:
  TM_VAR
  {
    $$ = (VLCons($1,NULL));
  }
| TM_VAR TM_COMMA NT_VAR_LIST
  {
    $$ = (VLCons($1,$3));
  }
| NT_VAR_LIST TM_COMMA NT_VAR_LIST
  {
    struct var_list * res = $1;
    while(res-> tail != NULL) res = res -> tail;
    res->tail = $2;
    $$ = ($1);
  }
;

NT_TYPE:
  TM_VOID
  {
    $$ = (TBasic(T_VOID));
  }
| TM_CHAR
  {
    $$ = (TBasic(T_CHAR));
  }
| TM_INT
  {
    $$ = (TBasic(T_INT));
  }
| TM_U8
  {
    $$ = (TBasic(T_U8));
  }
| TM_INT64
  {
    $$ = (TBasic(T_INT64));
  }
| TM_UINT
  {
    $$ = (TBasic(T_UINT));
  }
| TM_UINT64
  {
    $$ = (TBasic(T_UINT64));
  }
| TM_STRUCT TM_IDENT
  {
    $$ = (TStruct($2));
  }
| TM_UNION TM_IDENT
  {
    $$ = (TUnion($2));
  }
| TM_ENUM TM_IDENT
  {
    $$ = (TEnum($2));
  }
| NT_TYPE TM_MUL
  {
    $$ = (TPtr($1));
  }
| NT_TYPE TM_IDENT TM_LEFT_SQU NT_EXPR TM_RIGHT_SQU
  {
    $$ = (TArray($1,$4));
  }
;

NT_EXPR:
  TM_NAT
  {
    $$ = (TConst($1));
  }
| TM_LEFT_PAREN NT_EXPR TM_RIGHT_PAREN
  {
    $$ = ($2);
  }
| TM_SIZEOFTYPE TM_LEFT_PAREN NT_TYPE TM_RIGHT_PAREN
  {
    $$ = (TSizeofType($3));
  }
| TM_IDENT
  {
    $$ = (TVar($1));
  }
| NT_EXPR TM_PLUS NT_EXPR
  {
    $$ = (TBinop(T_PLUS,$1,$3));
  }
| NT_EXPR TM_MINUS NT_EXPR
  {
    $$ = (TBinop(T_MINUS,$1,$3));
  }
| NT_EXPR TM_MUL NT_EXPR
  {
    $$ = (TBinop(T_MUL,$1,$3));
  }
| NT_EXPR TM_DIV NT_EXPR
  {
    $$ = (TBinop(T_DIV,$1,$3));
  }
| NT_EXPR TM_MOD NT_EXPR
  {
    $$ = (TBinop(T_MOD,$1,$3));
  }
| NT_EXPR TM_LT NT_EXPR
  {
    $$ = (TBinop(T_LT,$1,$3));
  }
| NT_EXPR TM_GT NT_EXPR
  {
    $$ = (TBinop(T_GT,$1,$3));
  }
| NT_EXPR TM_LE NT_EXPR
  {
    $$ = (TBinop(T_LE,$1,$3));
  }
| NT_EXPR TM_GE NT_EXPR
  {
    $$ = (TBinop(T_GE,$1,$3));
  }
| NT_EXPR TM_EQ NT_EXPR
  {
    $$ = (TBinop(T_EQ,$1,$3));
  }
| NT_EXPR TM_NE NT_EXPR
  {
    $$ = (TBinop(T_NE,$1,$3));
  }
| NT_EXPR TM_AND NT_EXPR
  {
    $$ = (TBinop(T_AND,$1,$3));
  }
| NT_EXPR TM_OR NT_EXPR
  {
    $$ = (TBinop(T_OR,$1,$3));
  }
| NT_EXPR TM_BAND NT_EXPR
  {
    $$ = (TBinop(T_BAND,$1,$3));
  }
| NT_EXPR TM_BOR NT_EXPR
  {
    $$ = (TBinop(T_BOR,$1,$3));
  }
| NT_EXPR TM_XOR NT_EXPR
  {
    $$ = (TBinop(T_XOR,$1,$3));
  }
| NT_EXPR TM_SHL NT_EXPR
  {
    $$ = (TBinop(T_SHL,$1,$3));
  }
| NT_EXPR TM_SHR NT_EXPR
  {
    $$ = (TBinop(T_SHR,$1,$3));
  }
| TM_MINUS NT_EXPR %prec TM_UMINUS
  {
    $$ = (TUnop(T_UMINUS,$2));
  }
| TM_PLUS NT_EXPR %prec TM_UPLUS
  {
    $$ = (TUnop(T_UPLUS,$2));
  }
| TM_NOTBOOL NT_EXPR
  {
    $$ = (TUnop(T_NOTBOOL,$2));
  }
| TM_NOTINT NT_EXPR
  {
    $$ = (TUnop(T_NOTINT,$2));
  }
| TM_MUL NT_EXPR %prec TM_DEREF
  {
    $$ = (TDeref($2));
  }
| TM_BAND NT_EXPR %prec TM_ADDRES
  {
    $$ = (TAddress($2));
  }
| TM_LEFT_PAREN NT_TYPE TM_RIGHT_PAREN NT_EXPR
  {
    $$ = (TCast($2,$4));
  }
| TM_IDENT TM_LEFT_PAREN NT_EXPR_LIST TM_RIGHT_PAREN
  {
    $$ = (TCall($1,$3));
  }
| NT_EXPR TM_LEFT_SQU NT_EXPR TM_RIGHT_SQU
  {
    $$ = (TIndex($1,$3));
  }
| NT_EXPR TM_DOT TM_IDENT
  {
    $$ = (TFieldof($1,$3));
  }
| NT_EXPR TM_ARR TM_IDENT
  {
    $$ = (TFieldofptr($1,$3));
  }
;

NT_EXPR_LIST:
  NT_EXPR
  {
    $$ = (ELCons($1,NULL));
  }
| NT_EXPR TM_COMMA NT_EXPR_LIST
  {
    $$ = (ELCons($1,$3));
  }
;

/*NT_BASIC:
  TM_VOID
  {
    $$ = ($1);
  }
| TM_CHAR
  {
    $$ = ($1);
  }
| TM_U8
  {
    $$ = ($1);
  }
| TM_INT
  {
    $$ = ($1);
  }
| TM_INT64
  {
    $$ = ($1);
  }
| TM_UINT
  {
    $$ = ($1);
  }
| TM_UINT64
  {
    $$ = ($1);
  }
;*/


%%

void yyerror(char* s)
{
    fprintf(stderr , "%s\n",s);
}

  
