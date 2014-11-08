//Simple program

int main()
{
  int *p,a,b;
  p = &a;
  b = readi(p); 
  printi(b);
  *p = 10;
  printi(a);
  return 0;
}
