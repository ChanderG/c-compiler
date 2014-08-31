//Single line comment

int a(int b){
  int c;
  float f = 12.345;
  char a = 'A';
  double d;

  printf("Hello World!");
  scanf("%d", &c);

  if(c < 0){
    d = 100.0;
  }
  else{
    d = 12.1;
    printf("Hey, negative");
  }
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

  for(;;);
  for(;count < a;);
  for(;count < a;count++);
  for(count = 2;count < a;count++);
  for(count = 2;count < a;count++) b++ ;
  for(count = 2;count < a;count++){
    sum -= count - a;
    //int temp = b; 
    //b = sum;
    //sum = temp;
  }
  
}
