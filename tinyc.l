/*Chander G - chandergovind@gmail.com 

Right now the idea is to match the token but instead print out the caugth type instead of returning.


{punctuator}        { //cout << "PUNCTUATOR" << endl;
                      return PUNCTUATOR;
		    }  

*/

%{
  #include"y.tab.h"
  #include<iostream>
  using namespace std;
%}

sign                \+|-
digit_sequence      [0-9]+
fractional_constant [0-9]*\.{digit_sequence}|\.{digit_sequence}
exponential_part    [e|E]{sign}?{digit_sequence}
escape_seq          \'|\''|\\?|\\|\a|\b|\f|\n|\r|\t|\v
c_char              [^'\\n\t ]|{escape_seq} 
s_char              [^"]|{escape_seq}
punctuator          \[|\]|\(|\)|\{|\}|\.|->|\+\+|--|&|\*|\+|-|~|!|\/|%|<<|>>|<|>|<=|>=|==|!=|^|\||&&|\|\||\?|:|;|\.\.\.|=|\*=|\/=|%=|\+=|-=|<<=|>>=|&=|^=|\|=|,|#

%%
\/\*([^\*]|\*[^\/])*\*\/    {  //cout << "MULTI_LINE_COMMENT" << endl;
                               //return MULTI_LINE_COMMENT;
			       //We do not return any token so as to not affect the parsing.
                            }  
\/\/.*\n            { //cout << "SINGLE_LINE_COMMENT" << endl;
                      // return SINGLE_LINE_COMMENT;
			       //We do not return any token so as to not affect the parsing.
                    } 

:                   { return COLON; }
;                   { return SEMI_COLON; }
\{                  { return CURLY_OPEN; }
\}                  { return CURLY_CLOSE; }
\(                  { return PARAN_OPEN; }
\)                  { return PARAN_CLOSE; }
\,                  { return COMMA; }
=                   { return EQUAL; }
[\[]                { return SQ_OPEN; }
\]                  { return SQ_CLOSE; }  
\*                  { return STAR; }  
\.\.\.              { return ELIPSIS; } 
\.                  { return DOT; } 
->                  { return DEREF; } 
\+                  { return PLUS; } 
\+\+                { return INC; } 
--                  { return DEC; } 
&                   { return AND; } 
-                   { return MINUS; } 
~                   { return TILDE; } 
!                   { return EX; } 
\/                  { return BY; }
%                   { return MOD; } 
&&                  { return ANDAND; }
\<                  { return LT; } 
\<\<                { return SL; } 
>>                  { return SR; } 
>                   { return GT; } 
\<=                 { return LTE; } 
>=                  { return GTE; } 
==                  { return E; } 
!=                  { return NE; } 
[\^]                { return CAP; } 
\|                  { return OR; }
[\?]                { return Q; }
\|\|                { return OROR; }
\*=                 { return STAREQUAL; }
\/=                 { return BYEQUAL; }
%=                  { return MODEQUAL; }
\+=                 { return PLUSEQUAL; }
-=                  { return MINUSEQUAL; }
\<\<=               { return SLEQUAL; }
>>=                 { return SREQUAL; }
&=                  { return ANDEQUAL; }
\^=                 { return CAPEQUAL; }
\|=                 { return OREQUAL; }


case                { return CASE; }
default             { return DEFAULT; }
if                  { return IF; }
else                { return ELSE; }
switch              { return SWITCH; }
for                 { return FOR; }
while               { return WHILE; }
do                  { return DO; }
goto                { return GOTO; }
continue            { return CONTINUE; }
break               { return BREAK; }
return              { return RETURN; }
		    
extern              { return EXTERN; }
static              { return STATIC; }
auto                { return AUTO; }
register            { return REGISTER; }

void                { return VOID; }
char                { return CHAR; }
short               { return SHORT; }
int                 { return INT; }
long                { return LONG; }
float               { return FLOAT; }
double              { return DOUBLE; }
signed              { return SIGNED; }
unsigned            { return UNSIGNED; }
_Bool               { return _BOOL; }
_Complex            { return _COMPLEX; }
_Imaginary          { return _IMAGINARY; }
enum                { return ENUM; }
const               { return CONST; }
restrict            { return RESTRICT; }
volatile            { return VOLATILE; }
inline              { return INLINE; }
sizeof              { return SIZEOF; }

auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|inline|int|long|register|restrict|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|_Bool|_Complex|_Imaginary         { //cout << "KEYWORD" << endl;
                                                            //return KEYWORD;
							  }

[_a-zA-Z]+[0-9]*    { //cout << "IDENTIFIER" << endl; 
                      yylval.sval = strdup(yytext); 
                      return IDENTIFIER;
		    }
0|[1-9]+[0-9]*      { //cout << "INTEGER_CONSTANT" << endl;  
                      yylval.ival = atoi(yytext);
                      return INTEGER_CONSTANT;
		    }
{fractional_constant}{exponential_part}?|{digit_sequence}{exponential_part}       { //cout << "FLOATING_CONSTANT" << endl;
                      return FLOATING_CONSTANT;
		    }  
\"{s_char}*\"         { //cout << "STRING_LITERAL" << endl;
                      yylval.sval = strdup(yytext); 
                      return STRING_LITERAL;
		    }  
'{c_char}'         { //cout << "CHARACTER_CONSTANT" << endl;
                      yylval.cval =  yytext[1];
                      return CHARACTER_CONSTANT;
		    }  

[ \t\n]             ;    
%%//.               ;// { /*//cout << "WIP" << endl; */ return 0;}
