//Single line comment

int Outer;     // global declaration

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
    unsigned temp = b; 
    b = sum;
    sum = temp;
  }
  
  int i,j;
  for(i = 0;i < 100;i++){
    for(j = 0;j < i;j++){
      printf("Hello #%d", i+j); 
      if(i%j == 7) continue; 
    }
  }

  //goto set
  label : printf("Well done!");
  ano_label: printf("And again!!");
  
  if (a <= a) goto label;
  else if (a >= count) goto ano_label;
  else;
}

float switch_case(int a){
  signed b;
  switch(a){
    case 1: b = 0; break;  
  }

  switch(a){
    case 1: b = 0; 
  }

  switch(a){
    case 1: b = 0; break;  
    case 2: b = 1; 
    default: break;
  }

  return 1.0;
}

void while_test(){
  int n = 0, m = 1000;

  while(n < 10) n++;
  while(n < 10) {
    n--;
  }  

  while(n < 10) {
    while( m > 100) {
      m--;
      if(m == 123) continue;
    }  
    n++;
  }  

  while(n < 10) {
    while( m > 100) {
      m--;
      if(m == 123) break;
    }  
    n++;
  }  
}

void inline do_while_test(){
  do{
    test();
    tick++;
  }while(tick < 35);  

  //little used do_while syntax
  short i;
  do i++; while (i < 5);
}

_Complex pointer_arithmetic(){
  int *c;
  _Bool b = 3;      //this does not even make any sense. 
  //Kept here to show limits of parser specification 
  c = &b; 
  cout << c -> val;  //same of this
  cin >> c.val;      // as of this 
    
  int a,b;
  int c = a & b;
  int c = a | b;
  int c = a ^ b;

  int c = (a>b)?a:b;
}
