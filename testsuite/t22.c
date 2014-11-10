//Program

//Fibonacci using iteration
int main()
{
  int n, first = 0, second = 1, next, c;
  int *eP, pointer;
  eP = &pointer;

  prints("Enter the number of terms\n");
  n = readi(eP);

  prints("First ");
  printi(n);
  prints(" terms of Fibonacci series are :-\n");

  for ( c = 0 ; c < n ; c++ )
  {
    if ( c <= 1 )
      next = c;
    else
    {
      next = first + second;
      first = second;
      second = next;
    }
    printi(next);
    prints("\n");
  }

  return 0;
}
