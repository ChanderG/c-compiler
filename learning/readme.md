#Going from Independent to Dependent

###Idea 1
The programs tn.c are first compiled to assembly level like so:

```
cc -m32 -S -fno-asynchronous-unwind-tables tn.c
```

will give us tn.s. Now we also run our existing program on tn.c and compare these two to understand.
