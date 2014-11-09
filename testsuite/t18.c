//Simple program

int main()
{
  int *p,a,b;
  p = &a;
  b = 5;
  //b = *p;
  //b = readi(p); 
  //printi(b);
  *p = b;
  printi(a);
  return 0;
}
