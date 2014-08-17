/*Chander G - chandergovind@gmail.com 

Right now the idea is to match the token but instead print out the caugth type instead of returning.

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

%%
auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|inline|int|long|register|restrict|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|_Bool|_Complex|_Imaginary         { cout << "KEYWORD" << endl;
                                                            //return KEYWORD;
							  }

[_a-zA-Z]+[0-9]*    { cout << "IDENTIFIER" << endl; 
                      //return IDENTIFIER;
		    }
0|[1-9]+[0-9]*      { cout << "INTEGER_CONSTANT" << endl;  
                      //return INTEGER_CONSTANT;
		    }
{sign}              { cout << "SIGN" << endl;  
                      //return SIGN; 
		    }
{fractional_constant}{exponential_part}?|{digit_sequence}{exponential_part}       { cout << "FLOATING_CONSTANT" << endl;
                      //return FLOATING_CONSTANT;
		    }  
'{c_char}*'         { cout << "CHARACTER_CONSTANT" << endl;
                      return CHARACTER_CONSTANT;
		    }  
[ \t\n]             ;    
%%//.                   { /*cout << "WIP" << endl; */ return 0;}
