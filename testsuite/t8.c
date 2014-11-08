//Simple program w/ function call

int multTwo(int a, int b){
  int c;
  c = a * b;
  return c;
}

int main(){
  int a,b,c;
  int *pa,*pb,da,db;
  pa = &da;
  pb = &db;
  prints("Enter first input: ");
  a = readi(pa);
  prints("Enter second input: ");
  b = readi(pb);
  c = multTwo(a,b);
  prints("The product of the inputs is: ");
  printi(c);
  prints("\n");
  return 0;
}

