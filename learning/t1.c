//Simple program w/ function call

int multTwo(int a, int b){
  int c;
  c = a * b;
  return c;
}

int main(){
  int a,b,c;
  int *pa,*pb;
  a = readi(pa);
  b = readi(pb);
  c = multTwo(a,b);
  printi(c);
  return 0;
}

