//ChanderG - basic I/O functions 
#include "myl.h"
#define BUFF 20

int printi(int n){
  char buff[BUFF], zero='0';
  int i=0,j, k, bytes;

  if(n == 0) buff[i++]=zero;
  else{
    if(n < 0) {
      buff[i++]='-';
      n = -n;
    }
    while(n){
      int dig = n%10;
      buff[i++] = (char)(zero+dig);
      n /= 10;
    }
    if(buff[0] == '-') j = 1;
    else j = 0;
    k=i-1;
    while(j<k){
      char temp=buff[j];
      buff[j++] = buff[k];
      buff[k--] = temp;
    }
  } 
  bytes = i;

  __asm__ __volatile__ (
      "movl $4, %%eax \n\t"
      "movl $1, %%ebx \n\t"
      "int $128 \n\t"
      :
      :"c"(buff), "d"(bytes)
      ) ;  // $4: write, $1: on stdin

  return bytes;    
}

//has size limitation
int prints(char* c){
  int n = 0; 
  while(*c != '\0'){
    __asm__ __volatile__ (
	"movl $4, %%eax \n\t"
	"movl $1, %%ebx \n\t"
	"int $128 \n\t"
	:
	:"c"(c), "d"(1)
	) ;  // $4: write, $1: on stdin
    c++;
    n++;
  }
  return n;
}


//In case of int overflow returns an error condition
int readi(int *eP){  // *eP is for error, if the input is not an integer
  char buff[BUFF];
  __asm__ __volatile__ (
      "movl $3, %%eax \n\t"
      "movl $0, %%ebx \n\t"
      "int $128 \n\t"
      :
      :"c"(buff), "d"(BUFF)
      ) ;  // $3: read, $1: on stdin
  int mult = 1;
  int i = 0;
  if(buff[0] == '-'){ mult = -1; i++; }
  int ans = 0;
  int dig;
  char zero = '0';

  for(;buff[i] != '\0';i++){
    if(buff[i] == '\n') continue;
    dig = buff[i] - zero;
    if((dig < 0) || (dig > 9)){
      //error case  ERR = 1
      *eP = 1;  
      return -1;
    }
    else{
      ans = 10*ans + dig;   
    } 
  }
  ans *= mult;
  *eP = 0;  
  return ans;
}

