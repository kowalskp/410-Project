%{ //C declarations
	int yylex();
	void yyerror(const char *s);
	#include <stdio.h>
	#include <math.h>	
	#include <string.h>
	#include <stdlib.h>
	#include <stdio.h>
	extern int yylex();
	extern int yyparse();
	extern FILE *yyin;
	extern FILE *yyout;

	void yyerror (char const *s)
	{
		//fprintf (stderr, "%s\n", s);
	}

	int yywrap()
	{
		return 0;
	}

	int no_of_var = 0;
	struct variable_struct
		{
			char var_id[30];
			int var_type;
			int ival;
			float fval;
		}variable[500];

	/*Sets the variable type (1 = integer, 2 = float)*/
	void set_id_type(int x)
	{
		int  i = 0;
		for(i=0; i<no_of_var; i++)
		{
			if(variable[i].var_type == -1)
			{
				variable[i].var_type = x;
			}
		}
	}

	/*Retrieves the index of the variable from array*/
	int get_id_index(char X[30])
	{
		int  i = 0;
		for(i=0; i<no_of_var; i++)
		{
			if(!strcmp(variable[i].var_id , X))
			{
				return i;
			}
		}
		return -1;
	}

%}

//Grammar Declarations
%union {
   long val;
   char* stringValue;
}

%token POWER INT FLOAT CHAR NUM VAR FUNCTION PLUS MINUS MUL DIV DISPLAY MEAN
%left PLUS MINUS POWER
%left MUL DIV

/*token types*/
%type<val> print_code mean_cal code assignment e f t expression TYPE INT FLOAT CHAR NUM FUNCTION PLUS MINUS MUL DIV POWER MEAN 
%type<stringValue>   middle ID VAR


%%	//Translation Rules
program		: 
			|program mainfunc
			;

mainfunc	: FUNCTION code 'end function'  {
				int i = 0;
			  }
			;

code		: declaration code{ }
			| assignment code{ }
			| print_code code{ }
			| mean_cal code{ }
			|
			;

/*calculate and display the mean*/
mean_cal	: MEAN '(' NUM ',' NUM ',' NUM ',' NUM ')' {
			   $$ = ($3 + $5 + $7 + $9) / 4;
			   printf("The mean of %d, %d, %d, %d is: %d\n", $3, $5, $7, $9, $$);
			  }
			;

/*command to display(print) the variable*/
print_code	: DISPLAY '(' middle ')' {
				int i = get_id_index($3);

				if(variable[i].var_type == 1){
					printf("\n %s value: %d\n", variable[i].var_id, variable[i].ival);}
				else if(variable[i].var_type == 2){
					printf("\n %s value: %d\n", variable[i].var_id, variable[i].fval);}
			  }
			;

middle	:VAR {$$ = $1;}
			| NUM {$$ = (char *)&$1;}
			;

/*set type - used for type var_name: (example - int a:)*/
declaration	: TYPE ID	{ 
				set_id_type($1);
			  }
			;

TYPE		: INT	{ $$ = 1;}
		//  | FLOAT	{ $$ = 2;}
    		;

ID			: VAR {
				strcpy(variable[no_of_var].var_id,$1);
				variable[no_of_var].var_type = -1;
				no_of_var = no_of_var + 1;
			  }
			;

assignment	: VAR '=' expression { 
							$$ = $3; //current id is expression
							int i = get_id_index($1); //retrieve index of the id
							
							if(variable[i].var_type == 1) //integar
							{
								variable[i].ival = $3;
							}
							if(variable[i].var_type == 2) //float
							{
								variable[i].fval = (float)$3;
							}
						}
			;

expression	: e {$$ = $1;}
			;

e			: e PLUS f {$$ = $1 + $3;}
			| e MINUS f {$$ = $1 - $3;}
			| f      {$$ = $1;}
			;

f			: f MUL t {$$ = $1 * $3;}
			| f DIV t {if($3 != 0) {$$ = $1 / $3;}}
			| f POWER t {$$ = pow($1, $3);}
			| t   {$$ = $1;}
			;

t			: '(' e ')' {$$ = $2;}
			| VAR {
		      	int id_index = get_id_index($1); //retrieve id index of variable

				if(variable[id_index].var_type == 1) //integer
				{
					$$ = variable[id_index].ival; //retrieve value of the variable
				}
				if(variable[id_index].var_type == 2) //float
				{
					$$ = variable[id_index].fval; //retrieve value of the variable
				}
			 }
			| NUM    {$$ = $1;}
			;

%% //Supporting C-Routines
int main()
{
	yyin = fopen("input.txt","r");  //read from input file
	yyout = freopen("out.txt","w",stdout);  //write to output file

	yyparse();

	//close the files
	fclose(yyin);
	fclose(yyout);

	return 0;
}


