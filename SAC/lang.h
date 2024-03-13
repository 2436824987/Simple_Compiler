#ifndef LANG_H_INCLUDED
#define LANG_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>

enum BasicType{
  T_VOID,                  
  T_CHAR,
  T_U8,
  T_INT,
  T_INT64,
  T_UINT,
  T_UINT64
};

enum DeclType{
  T_BASIC,
  T_STRUCT,
  T_UNION,
  T_ENUM,
  T_PTR,
  T_ARRAY
};

enum DefType{
  T_FUNCDEF,  //   function definition & function specification
  T_FUNCDEC,  //   function proto & function specification
  T_SEPDEF,  //  annotation for sep declartion 
  T_UNIONDEF, // definition of union
  T_ENUMDEF, // definition of enum
  T_STRUCTDEF, // definition of struct
  T_WHOLEVAR
};

enum BinOpType {
  T_PLUS,   // +
  T_MINUS,  // -
  T_MUL,    // *
  T_DIV,    // / 
  T_MOD,    // %
  T_LT,     // <
  T_GT,     // > 
  T_LE,     // <=
  T_GE,     // >=
  T_EQ,     // ==
  T_NE,     // !=
  T_AND,    // &&
  T_OR,     // ||
  T_BAND,   // &
  T_BOR,    // | 
  T_XOR,    // ^
  T_SHL,    // <<
  T_SHR     // >> 
};

enum UnOpType {
  T_UMINUS,    // - 
  T_UPLUS,     // +
  T_NOTBOOL,   // !
  T_NOTINT    // ~
};

enum ExprType {
  T_CONST = 0,
  T_VAR,
  T_BINOP,
  T_UNOP,
  T_CAST,
  T_CALL,
  T_DEREF,     // *e
  T_ADDRES,     // &e
  T_SIZEOFTYPE,
  T_INDEX,    // a[i]
  T_FIELDOF,  // a.t
  T_FIELDOFPTR,  // a->t
  T_VARDECLIST
};

enum CaseType{
  T_CASE,
  T_DEFAULT
};

enum AssignType{
  T_ASSIGN,        // =
  T_ADD_ASSIGN,    // +=
  T_SUB_ASSIGN,    // -=
  T_MUL_ASSIGN,    // *=
  T_DIV_ASSIGN,    // /=
  T_MOD_ASSIGN,    // %=
  T_BAND_ASSIGN,   // &=
  T_BOR_ASSIGN,    // |=
  T_XOR_ASSIGN,    // ^=
  T_SHL_ASSIGN,    // <<=
  T_SHR_ASSIGN     // >>=
};

enum IncDecType{
  T_INC_F,     // ++e
  T_INC_B,     // e++
  T_DEC_F,     // --e
  T_DEC_B     // e--
};

enum SimpleCmdType{
  T_COMPUTATION,
  T_ASGN,
  T_INCDEC
};

enum CmdType {
  T_VARDECL = 0,
  T_SIMPLE,
  T_SEQ,
  T_IF,
  T_SWITCH,
  T_WHILE,
  T_DOWHILE,
  T_FOR,
  T_BREAK,
  T_CONTINUE,
  T_RETURN,
  T_COMMENT
};

struct expr;
struct expr_list;
struct cmd;
struct Case;
struct Case_list;
struct var_list;
struct def_list;
struct RAssertion;
struct RA_list;

struct type {
  enum DeclType t;
  union {
    struct {enum BasicType ty;} BASIC;
    struct {char *name;} STRUCT;
    struct {char *name;} UNION;
    struct {char *name;} ENUM;
    struct {struct type *ty;} PTR;
    struct {struct type *ty; struct expr *size;} ARRAY;
  } d;
};

enum LogicQuantifierType{
  A_FORALL,
  A_EXISTS
};

struct expr {
  enum ExprType t;
  union {
    struct {unsigned int value; } CONST;
    struct {char * name; } VAR;
    struct {enum BinOpType op; struct expr * left; struct expr * right; } BINOP;
    struct {enum UnOpType op; struct expr * arg; } UNOP;
    struct {struct expr *arg;} DEREF;     
    struct {struct expr *arg;} ADDRES;
    struct {struct type *ty; struct expr * arg; } CAST;
    struct {char *name; struct expr_list * args;} CALL;
    struct {struct type *ty;} SIZEOFTYPE;
    struct {struct expr *arg; struct expr *pos;} INDEX; 
    struct {struct expr *arg; char *name;} FIELDOF;
    struct {struct expr *arg; char *name;} FIELDOFPTR;
  } d;
};

struct expr_list {
  struct expr * head;
  struct expr_list * tail;
};

struct Afuncdef{
  struct var_list *with; 
  struct RAssertion *pre; 
  struct RAssertion *post;
}; // function specification

struct ASepdef{
  char *name;
  struct var_list *vars;
  struct RAssertion *conditions;
}; // annotation for sep declartion

struct var_dec {
  struct type *ty;
  char *name;
};

struct var_dec_list {
  struct var_dec *head;
  struct var_dec_list *tail;
};

struct field_dec {
  struct type *ty;
  char *field_name;
};

struct def {
  enum DefType t;
  union {
    struct {struct type *ty; char *name; struct var_dec_list *args; struct cmd_list * body; struct Afuncdef *funspec;} FUNCDEF;
    struct {struct type *ty; char *name; struct var_dec_list *args; struct Afuncdef *funspec;} FUNCDEC; 
    struct {struct ASepdef *sepdef;} SEPDEF; 
    struct {char *name; struct field_dec_list *union_def;} UNIONDEF;
    struct {char *name; struct enum_list *enum_def;} ENUMDEF;
    struct {char *name; struct field_dec_list  *struct_def;} STRUCTDEF;
    struct {struct var_dec *v; struct type *ty;}WHOLEVAR;
  } d;
};

struct field_dec_list {
  struct field_dec *head;
  struct field_dec_list * tail;
};

struct def_list {
  struct def *head;
  struct def_list * tail;
};

struct enum_list {
  char *name;
  struct enum_list * tail;
};

enum RAssertionType {
  RA_CONST = 0,
  RA_VAR,
  RA_BINOP,
  RA_UNOP,
  RA_CAST,
  RA_CALL,
  RA_DEREF,     // *e
  RA_ADDRES,     // &e
  RA_INDEX,     // a[i]
  RA_FIELDOF,   // a.t
  RA_FIELDOFPTR,  // a->t
  RA_QFOP
};

struct RAssertion{
  enum RAssertionType t;
  union {
    struct {unsigned int value; } RACONST;
    struct {char * name; } RAVAR;
    struct {enum BinOpType op; struct RAssertion * left; struct RAssertion * right; } RABINOP;
    struct {enum UnOpType op; struct RAssertion * arg; } RAUNOP;
    struct {struct RAssertion *arg;} RADEREF;     
    struct {struct RAssertion *arg;} RAADDRES;
    struct {struct type *ty; struct RAssertion * arg; } RACAST;
    struct {char *name; struct RA_list * args;} RACALL;
    struct {struct RAssertion *arg; struct RAssertion *pos;} RAINDEX;
    struct {struct RAssertion *arg; char *name;} RAFIELDOF;
    struct {struct RAssertion *arg; char *name;} RAFIELDOFPTR;
    struct {enum LogicQuantifierType op; char *name; struct RAssertion *arg;} RAQFOP;
  } d;
};

struct RA_list {
  struct RAssertion *head;
  struct RA_list *tail;
};

struct simple_cmd {
  enum SimpleCmdType t;
  union {
    struct {struct expr *arg;} COMPUTATION;
    struct {enum AssignType op; struct expr *left; struct expr *right;} ASGN;
    struct {enum IncDecType op; struct expr *arg;} INCDEC; 
  } d;
};

struct cmd {
  enum CmdType t;
  union {
    struct {struct var_dec *decl;} VARDECL;
    struct {struct simple_cmd *scmd;} SIMPLE;
    struct {struct expr * cond; struct cmd_list * left; struct cmd_list * right; } IF;
      // right = NULL if the if-else branch does not exist
    struct {struct RAssertion *inv; struct expr * cond; struct cmd_list * body;} WHILE;
      // inv = NULL if the loop has no invariant annotation
    struct {struct expr *cond; struct Case_list * body;} SWITCH;
    struct {struct RAssertion *inv; struct expr * cond; struct cmd_list * body;} DOWHILE;
      // inv = NULL if the loop has no invariant annotation
    struct {struct RAssertion *inv; struct simple_cmd *init; struct expr *cond; struct simple_cmd *incr; struct cmd_list *body;} FOR;
      // inv = NULL if the loop has no invariant annotation
    struct {void * none;} BREAK;
    struct {void * none;} CONTINUE;
    struct {struct expr *arg;} RETURN;
      // arg = NULL if the return command does not have a return value
    struct {struct RAssertion *asrt;} COMMENT;
  } d;
};

struct cmd_list {
  struct cmd * head;
  struct cmd_list * tail;
};

struct Case {
  enum CaseType t;
  union {
    struct {struct expr *cond; struct cmd_list *body;} CASE;
    struct {struct cmd_list *body;} DEFAULT; 
  } d;
};

struct Case_list{
  struct Case *head;
  struct Case_list *tail;
};

struct var_list {
  char * head;
  struct var_list * tail;
};

struct type * TBasic(enum BasicType ty);
struct type * TStruct(char *name);
struct type * TUnion(char *name);
struct type * TEnum(char *name);
struct type * TPtr(struct type *ty);
struct type * TArray(struct type *ty, struct expr *size);

struct expr * TConst(unsigned int value);
struct expr * TVar(char * name);
struct expr * TBinop(enum BinOpType op, struct expr * left, struct expr * right);
struct expr * TUnop(enum UnOpType op, struct expr * arg);
struct expr * TDeref(struct expr * arg);
struct expr * TAddress(struct expr * arg);
struct expr * TCast(struct type *ty, struct expr *arg);
struct expr * TCall(char * name, struct expr_list * args);
struct expr * TSizeofType(struct type * ty);
struct expr * TIndex(struct expr *arg, struct expr *pos);
struct expr * TFieldof(struct expr *arg, char *name);
struct expr * TFieldofptr(struct expr *arg, char *name);

struct expr_list * ELNil();
struct expr_list * ELCons(struct expr * head, struct expr_list * tail);

struct Afuncdef * TAfuncdef (struct var_list *with, struct RAssertion *pre, struct RAssertion *post);
struct ASepdef * TAsepdef (char *name, struct var_list *vars, struct RAssertion *conditions);

struct def * TFuncdef(struct type *ty, char *name, struct var_dec_list *args, struct cmd_list * body, struct Afuncdef *funspec);
struct def * TFuncdec(struct type *ty, char *name, struct var_dec_list *args, struct Afuncdef *funspec);
struct def * TSepdef(struct ASepdef *sepdef);
struct def * TUniondef(char * name, struct field_dec_list * union_def);
struct def * TEnumdef(char * name, struct enum_list * enum_def);
struct def * TStructdef(char * name, struct field_dec_list * struct_def);
struct def * TUniondec(char * name);
struct def * TEnumdec(char * name);
struct def * TStructdec(char * name);
struct def * TWholevardec(struct var_dec * v, struct type *t);


struct field_dec_list * FDLNil();
struct field_dec_list * FDLCons(struct field_dec * head, struct field_dec_list * tail);

struct field_dec * TFieldDec(struct type * t, char * name);

struct def_list * DFLNil();
struct def_list * DFLCons(struct def * head, struct def_list * tail);

struct enum_list * ENLNil();
struct enum_list * ENLCons(char *name, struct enum_list *tail);


struct simple_cmd * TComputation (struct expr *arg);
struct simple_cmd * TAsgn(enum AssignType op, struct expr *left, struct expr *right);
struct simple_cmd * TIncDec (enum IncDecType op, struct expr *arg);

struct cmd * TVarDecl(struct var_dec *decl);
struct cmd * TSimple(struct simple_cmd *scmd);
struct cmd * TIf(struct expr * cond, struct cmd_list * left, struct cmd_list * right);
struct cmd * TSwitch(struct expr *cond, struct Case_list * body);
struct cmd * TWhile(struct RAssertion *inv, struct expr * cond, struct cmd_list * body);
struct cmd * TDoWhile(struct RAssertion *inv, struct expr * cond, struct cmd_list * body);
struct cmd * TFor(struct RAssertion *inv, struct simple_cmd *init, struct expr *cond, struct simple_cmd *incr, struct cmd_list *body);
struct cmd * TBreak();
struct cmd * TContinue();
struct cmd * TReturn(struct expr *arg);
struct cmd * TComment(struct RAssertion *asrt);

struct cmd_list * CMDLNil();
struct cmd_list * CMDLCons(struct cmd * head, struct cmd_list * tail);

struct Case * TCase(struct expr *cond, struct cmd_list *body);
struct Case * TDefault(struct cmd_list *body);
struct Case_list * CLNil();
struct Case_list * CLCons(struct Case * head, struct Case_list * tail);

struct var_dec * TVarDec(struct type * t, char * name);

struct var_dec_list * VDLNil();
struct var_dec_list * VDLCons(struct var_dec *head, struct var_dec_list *tail);

struct var_list * VLNil();
struct var_list * VLCons(char * head, struct var_list * tail);

struct RAssertion * RAConst(unsigned int value);
struct RAssertion * RAVar(char * name);
struct RAssertion * RABinop(enum BinOpType op, struct RAssertion * left, struct RAssertion * right);
struct RAssertion * RAUnop(enum UnOpType op, struct RAssertion * arg);
struct RAssertion * RADeref(struct RAssertion * arg);
struct RAssertion * RAAddress(struct RAssertion * arg);
struct RAssertion * RACast(struct type *ty, struct RAssertion *arg);
struct RAssertion * RACall(char * name, struct RA_list * args);
struct RAssertion * RAIndex(struct RAssertion *arg, struct RAssertion *pos);
struct RAssertion * RAFieldof(struct RAssertion *arg, char *name);
struct RAssertion * RAFieldofptr(struct RAssertion *arg, char *name);
struct RAssertion * RAQfop (enum LogicQuantifierType op, char *name, struct RAssertion *arg);

struct RA_list * RALNil();
struct RA_list * RALCons(struct RAssertion * head, struct RA_list * tail);


void print_UnOp(enum UnOpType op);
void print_BinOp(enum BinOpType op);
void print_expr(struct expr * e);
void print_cmd(struct cmd * c);
void print_def(struct def *decl);
void print_def_list(struct def_list *decl);

unsigned int build_nat(char * c, int len);

char * new_str(char * str, int len);


#endif // LANG_H_INCLUDED
