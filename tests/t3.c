//Fibonacci using recursion

int Fibonacci(int a);

int main()
{
  int n, i = 0, c;
  int *eP,pointer;
  eP = &pointer;

  n = readi(eP);

  prints("Fibonacci series\n");

  for ( c = 1 ; c <= n ; c++ )
  {
    printi(Fibonacci(i));
    prints("\n");
    i++; 
  }

  return 0;
}

int Fibonacci(int n)
{
  if ( n == 0 )
    return 0;
  else if ( n == 1 )
    return 1;
  else 
    return ( Fibonacci(n-1) + Fibonacci(n-2) );
} 
