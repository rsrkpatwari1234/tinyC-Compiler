#include "myl.h"
#define MAX 50

int printStr(char *s)
{
    int i = 0, buff_len = 0;
    while(s[i]!='\0')
    {
        i++;
        buff_len++;
    }
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(s), "d"(i)
    );
    buff_len++;
    return i;
}


int printInt(int n)
{
    char buff[MAX], zero='0';    
    int buff_len=0;
    int i=0,j=0, mem, k;
    
    if(n<0)
    {
        n=-n;buff[i++]='-';
        buff_len++;
    }

    if(n == 0)
    {
        buff[i++]=zero;
        buff_len++;
    }
    
    while(n!=0){
        buff_len++;
        buff[i++]= (char)(n%10 + zero);
        n=n/10;
    }

    if(buff[0]=='-')
    {
        j=1;
        buff_len++;
    }
    
    k=i-1;
    buff_len++;
    mem=i;
    while(j<k){
        char tmp;
        tmp=buff[j];
        buff_len++;
        buff[j]=buff[k];
        buff_len++;
        buff[k]=tmp;
        buff_len++;
        j++;k--;
    }
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(buff), "d"(mem)
    );
    buff_len++;
	return mem;
}

int readInt (int* eP) {
    int i = 0;
    char str[10];
    int buff_len = 0;
    int sign = 1, val = 0;
    *eP = OK;
    
    while(1){
        __asm__ __volatile__ (
            "syscall"
            :
            :"a"(0), "D"(0), "S"(str), "d"(1)
        );
        if(str[0]==' ' || str[0] == '\t' || str[0]=='\n')
        {
            buff_len++;
            break;
        }
        if(!i && str[0]=='-')
        {
            buff_len++;
            sign=-1;
        }
        else{
            buff_len++;
            if(str[0] >'9' || str[0]<'0' )
            {
                buff_len++;
                *eP=ERR;
            }
            else{
                buff_len++;
                val = 10*val+(int)(str[0]-'0');
            }
        }
        buff_len++;
        i++;
    }
    
    return val*sign;
}

