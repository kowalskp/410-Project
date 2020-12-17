%{
	#include <stdio.h>
	#include <string.h>
	#include "410.tab.h"	
	extern char* strdup(const char*);
%}

VAR	[a-zA-z][a-zA-z0-9_]*
NUM [0-9][0-9]*

%%

[ \t]+
[,:{}=()~]	{ yylval.stringValue = strdup(yytext); return *yytext;}
[\n] {}	
"int"	return(INT);
"function:" return(FUNCTION);
"float"	return(FLOAT);   
"display" return(DISPLAY); 
"mean" return(MEAN);
{VAR}	{yylval.stringValue = strdup(yytext); return(VAR);}
{NUM}   {yylval.val = atoi(yytext); return(NUM);} 
"+"     return(PLUS);
"-"     return(MINUS);
"*"     return(MUL);
"/"     return(DIV);
"@"		return(POWER);

%%



