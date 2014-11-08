//Simple program w/ function call

int multTwo(int a, int b){
  int c;
  c = a * b;
  return c;
}

int main(){
  int a,b,c;
  a = 3;b = 3;
  c = multTwo(a,b);
  printi(c);
  return 0;
}

