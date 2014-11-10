int main()
{
  int first, second, *p, *q, sum;
  int *eP,pointer;
  eP = &pointer;

  prints("Enter two integers to add\n");
  first = readi(eP);
  second = readi(eP);

  p = &first;
  q = &second;

  sum = *p + *q;

  prints("Sum of entered numbers = ");
  printi(sum);
  prints("\n");

  return 0;
}
