%{
  #include"y.tab.h"
  #include<iostream>
  using namespace std;
%}

sign                \+|-
digit_sequence      [0-9]+
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
[ \t\n]             ;    
%%//.                   { /*cout << "WIP" << endl; */ return 0;}
