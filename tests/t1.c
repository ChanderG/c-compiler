//Single line comment

int a(int b){
  float int c;                  //illustrates flaw in grammar specification
  auto float f = 12.345;
  static char a = 'A';
  const double d;
  register e;                  // supposed to take int

  printf("Hello World!");
  scanf("%d", &c);

  if(c < 0){
    d = -100.0;
  }
  else if(c == 0){
    d = 0.0;
    printf("Hey, zero!");
  }
  else if(c != 0){
    d = 0.0;
    printf("Hey, zero!");
  }
  else if(c > 0){
    d = 12.1;
    printf("Hey, negative");
  }
  else exit(0);
  return 3;
}  

/* A 
   multi line 
   comment 
   with special symb0ls too.
   ???/  >>  + - #$
*/

//demo of case sensitivity
void Auto(int a, int b){
  float c = 1;
  int count = 0;
  int sum;

  //for family
  for(;;);
  for(;count < a;);
  for(;count < a;count++);
  for(count = 2;count < a;count++);
  for(count = 2;count < a;count++) b++ ;
  for(count = 2;count < a;count++){
    sum -= count - a;
    int temp = b; 
    b = sum;
    sum = temp;
  }

  //goto set
  label : printf("Well done!");
  ano_label: printf("And again!!");
  
  if (a <= a) goto label;
  else if (a >= count) goto ano_label;
  else;
}
