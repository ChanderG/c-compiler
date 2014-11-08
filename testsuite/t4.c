//Simple program w/ function call

int subTwo(int a, int b){
  int c;
  c = a - b;
  return c;
}

int main(){
  int a,b,c;
  a = 3;b = 1;
  c = subTwo(a,b);
  printi(c);
  return 0;
}

