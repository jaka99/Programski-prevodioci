%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  int out_lin = 0;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int type=0;
  int tip;
  int count=0;
  int rtn_count=0;
  int lab_num = -1;
  FILE *output;
  int cond_count=0;
%}

%union {
  int i;
  char *s;
}

%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token <i> _AROP
%token <i> _RELOP
%token _INC
%token _DEC
%token _COMMA
%token _VOID
%token _COLON
%token _STEP
%token _FOR
%token _JIRO
%token _TRANGA
%token _TOERANA
%token _END_JIRO
%token _QMARK


%type <i> num_exp exp literal
%type <i> function_call argument rel_exp if_part izraz 

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  :global_list function_list
      {  
        if(lookup_symbol("main", FUN) == NO_INDEX)
          err("undefined reference to 'main'");
       }
  ;

global_list
  : /*empty*/
  |global_list global_var
  ;

global_var
  : _TYPE _ID _SEMICOLON
  	{
	  int idx=lookup_symbol($2, GVAR);
	  if( idx != NO_INDEX){
		err("redefinition of '%s'", $2);
	  } 
	     else{
		insert_symbol($2, GVAR, $1, NO_ATR, NO_ATR);
		code("\n%s: ", $2);
		code("\n\t\tWORD\t1");
	          }
	}
  ;

function_list
  : function
  | function_list function
  ;

function
  : _TYPE _ID
      {
        fun_idx = lookup_symbol($2, FUN);
        if(fun_idx == NO_INDEX)
          fun_idx = insert_symbol($2, FUN, $1, NO_ATR, NO_ATR);
        else 
          err("redefinition of function '%s'", $2);
	code("\n%s:", $2);
        code("\n\t\tPUSH\t%%14");
        code("\n\t\tMOV \t%%15,%%14");
      }
    _LPAREN parameter _RPAREN body
      {
        clear_symbols(fun_idx + 1);
        var_num = 0;

	if((rtn_count==0) && (get_type(fun_idx) == INT|UINT))
		warn("Funkcija treba da vrati vrednost");
	code("\n@%s_exit:", $2);
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
      }
  ;


parameter
  : /*empty*/ { set_atr1(fun_idx, 0); }
  | _TYPE _ID
      {
	if(lookup_symbol($2, PAR|VAR)== NO_INDEX){
		if($1 != VOID){
        	insert_symbol($2, PAR, $1, 1, NO_ATR);
        	set_atr1(fun_idx, 1);
        	set_atr2(fun_idx, $1);
      		}
		else{
		 err("redefinition of '%s' ", $2);
		}
	}

	else
	  err("redefinition of '%s' ", $2);
	}

  | parameter _COMMA _TYPE _ID {
	if(lookup_symbol($4, PAR|VAR)==NO_INDEX){
		if($3 != VOID){

			insert_symbol($4, PAR, $3, 1, NO_ATR);
			set_atr1(fun_idx, 1);
        		set_atr2(fun_idx, $3);
		}
		else{
		  err("redefinition of '%s' ", $4);
		}
	}
	else{
	  err("redefinition of '%s' ", $4);
 	}
}
	
  ;

body
  : _LBRACKET variable_list
	{
        if(var_num)
          code("\n\t\tSUBS\t%%15,$%d,%%15", 4*var_num);
        code("\n@%s_body:", get_name(fun_idx));
      }
  statement_list _RBRACKET
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  : _TYPE {type = $1;} _ID vars _SEMICOLON{
        if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
        {
		if(type != _VOID)
		{
			insert_symbol($3, VAR, type, ++var_num, NO_ATR);
		}
		else("variable '%s' can't be of type void", $3);
        }
        else 
           err("redefinition of '%s'", $3);
     }
  ;

vars
  :
      
  | vars _COMMA _ID
      {
        if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
	{
	 if(type != _VOID)
         {
           insert_symbol($3, VAR, type, ++var_num, NO_ATR);
	 }
	 else
	   err("variable '%s' can't be of type void", $3);
	}
        else 
           err("redefinition of '%s'", $3);
       }
//prvi individualni zadatak, visestruka dodela vrednosti
  | vars _COMMA _ID _ASSIGN literal
	{
        if(lookup_symbol($3, VAR|PAR) == NO_INDEX)
	{
	 if(type != _VOID)
         {
           insert_symbol($3, VAR, type, ++var_num, NO_ATR);
		
		if(type==INT)
			code("\n\tint\t%s\t=\t%d", $3, $5);
		else
			code("\n\tunsigned\tint\t%s\t=\t%d", $3, $5);
	 }
	 else
	   err("variable '%s' can't be of type void", $3);
	}
        else 
           err("redefinition of '%s'", $3);
       }

	
  
//dodatni zadatak, jednostruka dodela
  | _ASSIGN literal
  ;


//drugi individualni zadatak
for
 : _FOR _LPAREN _TYPE _ID _ASSIGN literal _COLON literal _COLON _STEP literal _RPAREN{
 

	int lit1 = atoi(get_name($6));
	int lit2 = atoi(get_name($8));

	if(lit2>lit1){
		code("\n@for%d: ", count);
			
		gen_cmp($6, $8);
		code("\n\t%s\t@telo%d", opp_jumps[3], count);
		code("\n\tJMP\t@kraj%d: ", count);

		code("\n@krajiteracije%d: ", count);

		int reg=$6;
		reg=take_reg();
		code("\n\t\tADDS\t");
		gen_sym_name($6);
		code(" , ");
		gen_sym_name($11);
		code(" , ");
		gen_sym_name($6);
		code("\n\tJMP\t@for%d", count);
	}
	
	else{
		code("/n@for%d: ", count);
		gen_cmp($6, $8);
		code("\n\t%s\t@telo%d", opp_jumps[2], count);
		code("\n\tJMP\t@kraj%d", count);

		code("\n@krajiteracije%d: ", count);

		int reg=$6;
		reg=take_reg();

		code("\n\t\tSUBS\t");
		gen_sym_name($6);
		code(" , ");
		gen_sym_name($11);
		code(" , ");
		gen_sym_name($6);
		code("\n\tJMP\t@for%d", count);
	}
	
	code("\n@telo%d: ", count);
	}
statement{
		

		
	
	int idx = lookup_symbol($4, PAR|VAR);	
	if(lookup_symbol($4, VAR|PAR) == NO_INDEX)
        {
		if(type != _VOID)
	insert_symbol($4, PAR, $3, 1, NO_ATR);
	}
	if(get_type(idx) != get_type($6) || get_type(idx) != get_type($8) || get_type(idx) != get_type($11)){
		err("Moraju biti istog tipa.");
	}
	
	code("\n@kraj%d: ", count);	
}
;



//treci individualni zadatak
jiro
 : _JIRO _ID {tip = lookup_symbol($2, PAR|VAR);} tranga _TOERANA statement _END_JIRO {		
	if(lookup_symbol($2, PAR|VAR) == NO_INDEX){
		err("Mora biti deklarisan");
 	}
}
 ;

tranga
 : _TRANGA literal statement { 
	if(get_type(tip)!=get_type($2)){
		err("Moraju biti istog tipa literal i id");
	}
}
 | tranga _TRANGA literal statement {
	
	if(get_type(tip)!=get_type($3)){
		err("Moraju biti istog tipa literal i id");
	}
 }
 ;


statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement
  | return_statement
  | inc_statement
// dodatni zadatak dekrement 
  | dec_statement
  | for
  | jiro
  ;

inc_statement
  : _ID _INC _SEMICOLON
	{
	  int idx= lookup_symbol($1, VAR|PAR|GVAR);
	  if(idx == NO_INDEX)
		err("redefinition of '%s'", $1);
		
	int type = get_type(idx);	
	if(type == INT)
		code("\n\t\tADDS\t");
	else
		code("\n\t\tADDU\t");

	gen_sym_name(idx);
	code(" , $1, ");
	gen_sym_name(idx);
	}
  ;

dec_statement
  : _DEC _ID _SEMICOLON
	{
	  int idx= lookup_symbol($2, VAR|PAR|GVAR);
	  if(idx == NO_INDEX)
		err("redefinition of '%s'", $2);
		
	int type = get_type(idx);	
	if(type == INT)
		code("\n\t\tSUBS\t");
	else
		code("\n\t\tSUBU\t");

	gen_sym_name(idx);
	code(" , $2, ");
	gen_sym_name(idx);
	}
  ;


compound_statement
  : _LBRACKET statement_list _RBRACKET
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {
        int idx = lookup_symbol($1, VAR|PAR|GVAR);
        if(idx == NO_INDEX)
          err("invalid lvalue '%s' in assignment", $1);
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignment");
	gen_mov($3, idx);
      }
  ;

num_exp
  : exp
  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
	int t1 = get_type($1);    
        code("\n\t\t%s\t", ar_instructions[$2 + (t1 - 1) * AROP_NUMBER]);
        gen_sym_name($1);
        code(",");
        gen_sym_name($3);
        code(",");
        free_if_reg($3);
        free_if_reg($1);
        $$ = take_reg();
        gen_sym_name($$);
        set_type($$, t1);
      }
  ;

exp
  : literal
  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR|GVAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }
  | function_call
	{
        $$ = take_reg();
        gen_mov(FUN_REG, $$);
      }
  | _LPAREN num_exp _RPAREN
      { $$ = $2; }
  | _ID _INC {
		int idx = lookup_symbol($1, VAR|PAR|GVAR);
			if(idx==NO_INDEX)
				err("'%s' undeclared", $1);
	      
	else
		$$=idx;

	int reg = take_reg();
	int type = get_type(idx);
	gen_mov(idx, reg);
	set_type(reg, type);
	if(type == INT)
		code("\n\t\tADDS\t");
	else
		code("\n\t\tADDU\t");

	gen_sym_name(idx);
	$$=reg;
	}
//dodatni zadatak, dekrement 
  | _DEC _ID{
		int idx = lookup_symbol($2, VAR|PAR);
			if(idx==NO_INDEX)
				err("'%s' undeclared", $2);
	      
	else
		$$=idx;

	int reg = take_reg();
	int type = get_type(idx);
	gen_mov(idx, reg);
	set_type(reg, type);
	if(type == INT)
		code("\n\t\tSUBS\t");
	else
		code("\n\t\tSUBU\t");

	gen_sym_name(idx);
	$$=reg;
	}

  | _LPAREN rel_exp _RPAREN _QMARK izraz _COLON izraz{
	int regi=take_reg();
	int count= cond_count++;

	if(get_type($5) != get_type($7))
		err("moraju biti istog tipa");

	code("\n\t\t%s\t@false%d", opp_jumps[$2], count);
	code("\n\t@true%d: ", count);
		
	gen_mov($5, regi);
	
	code("\n\t\tJMP\t@kraj%d" , count);
	
	code("\n\t@false%d: ", count);
	gen_mov($7, regi);
	
	code("\n@kraj%d: ", count);
	$$=regi;
}
  ;

izraz
  : literal
  | _ID {
	 int idx = lookup_symbol($1, VAR|PAR|GVAR);
	 if(idx==NO_INDEX)
		err("'%s' undeclared", $1);

	$$ = idx;
	}
  ;



literal
  : _INT_NUMBER
      { $$ = insert_literal($1, INT); }

  | _UINT_NUMBER
      { $$ = insert_literal($1, UINT); }
  ;

function_call
  : _ID 
      {
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' is not a function", $1);
      }
    _LPAREN argument _RPAREN
      {
        if(get_atr1(fcall_idx) != $4)
          err("wrong number of arguments");
        code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15", $4 * 4);
        set_type(FUN_REG, get_type(fcall_idx));
        $$ = FUN_REG;
      }
  ;


argument
  :/* empty */ { $$ = 0; }
  | num_exp
    { 
      if(get_atr2(fcall_idx) != get_type($1))
        err("incompatible type for argument in '%s'",
            get_name(fcall_idx));
	free_if_reg($1);
      code("\n\t\t\tPUSH\t");
      gen_sym_name($1);
      $$ = 1;
    }
  ;



if_statement
  : if_part %prec ONLY_IF
	{ code("\n@exit%d:", $1); }
  | if_part _ELSE statement
	{ code("\n@exit%d:", $1); }
  ;

if_part
  : _IF _LPAREN
	{
        $<i>$ = ++lab_num;
        code("\n@if%d:", lab_num);
      }
  rel_exp
	{
        code("\n\t\t%s\t@false%d", opp_jumps[$4], $<i>3);
        code("\n@true%d:", $<i>3);
      }
  _RPAREN statement
	{
        code("\n\t\tJMP \t@exit%d", $<i>3);
        code("\n@false%d:", $<i>3);
        $$ = $<i>3;
      }
  ;

rel_exp
  : num_exp _RELOP num_exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: relational operator");
	$$ = $2 + ((get_type($1) - 1) * RELOP_NUMBER);
        gen_cmp($1, $3);
      }
  ;

return_statement
  : _RETURN num_exp _SEMICOLON
       {
        if(get_type(fun_idx) != get_type($2))
          err("incompatible types in return");
	

	if(get_type(fun_idx)== VOID)
	  err("Void ne vraca vrednost");

	rtn_count++;
	
	gen_mov($2, FUN_REG);
        code("\n\t\tJMP \t@%s_exit", get_name(fun_idx));
      }
  | _RETURN _SEMICOLON
       {
	if(get_type(fun_idx) != VOID)
	  warn("Funkcija treba da vrati vrednost!");

	rtn_count++;
	}
 
  ;

%%

int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

int main() {
  int synerr;
  init_symtab();
  output = fopen("output.asm", "w+");

  synerr = yyparse();
  

  clear_symtab();
  fclose(output);
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count) {
    remove("output.asm");
    printf("\n%d error(s).\n", error_count);
  }

  if(synerr)
    return -1;  //syntax error
  else if(error_count)
    return error_count & 127; //semantic errors
  else if(warning_count)
    return (warning_count & 127) + 127; //warnings
  else
    return 0; //OK
}

