
/*Name : RADHIKA PATWARI
  Roll : 18CS10062*/

// inline assembly defination using extended asm for x86_64 linux

//Max size of string that can be read from the stdin
#define BUFF 100

//To allow asm to take input from stdin
#define SYS_READ 0
#define STDIN_FILENO 0

//Converting all alphabetic characters into upper case
//and then printing using syscall of extended inline asm
int printStringUpper(char *str){

	//i : loop variable ; charcount : # of characters in string
	int i=0;
	int charcount;	
	while(str[i]!='\0'){

		//converting lower case letters to corresponding upper case letter
		if(str[i]>='a' && str[i]<='z')
			str[i] = str[i]&(~32);
		i++;

	}

	//printing the desired string using syscall
	__asm__ __volatile__ (
	"movl $1, %%eax \n\t"
	"movq $1, %%rdi \n\t"
	"movq %1, %%rsi \n\t"
	"movl %2, %%edx \n\t"
	"syscall \n\t"
	:"=d"(charcount)
	:"S"(str), "d"(i)
	);

	//returning the number of characters of string
	return charcount;
}

//Reading hexadecimal value using sysread of extended inline asm 
//Coverting the hexadecimal to decimal and passing it to function argument
//Returning -1 in case hexadecimal value is invalid
//else return the number of characters of the hexadecimal string
int readHexInteger(int *n){

	//charcount : # of characters in hexadecimal value
	//base : storing 16^m for m = (0,1,2....)
	//readhex : stores hexadecimal string of max length BUFF
	//dec : storing the decimal value obtained from hexadecimal string
	int charcount = -1,base = 1;
	char readhex[BUFF];
	int dec = 0;


	//reading the hexadecimal string in 'readhex' from input console
	//also storing length in charcount
	__asm__ __volatile__ (
	"syscall"
	:"=a"(charcount)
	:"0"(SYS_READ),"D"(STDIN_FILENO),"S"(readhex),"d"(sizeof(readhex))
	:"rcx","r11","memory","cc"
	);

	//checking the validity of the hexadecimal string [(0-9)(A-F)(-)]
	for(int i=charcount-2;i>=0;i--){

		if(readhex[i] >= '0' && readhex[i] <= '9'){
			dec = dec + (readhex[i]-'0')*base;
			base*=16;
		}
		else if(readhex[i] >= 'A' && readhex[i] <= 'F'){
			dec = dec + (readhex[i] - 'A' + 10)*base;
			base*=16;
		}
		// '-' sign can be present only at the start of hexadecimal string
		else if(readhex[i] == '-' && i==0){
			dec *= -1;
		}
		//if some character other than (0-9) or (A-F) or (-) exists
		//then invalid hexadecimal string -> return -1
		else{
			return -1;
		}
	}

	//passing the decimal value into function argument
	*n = dec;

	//Optional : printing the hexadecimal value to ensure correct reading 
	/*__asm__ __volatile__ (
	"movl $1, %%eax \n\t"
	"movq $1, %%rdi \n\t"
	"syscall \n\t"
	:
	:"S"(readhex), "d"(charcount)
	);*/

	//Returning the number of characters in hexadecimal string
	return charcount;
}


//Converting the signed decimal integer into hexadecimal 
//and printing using syscall of asm
int printHexInteger(int n){

	//hex : storing hexacimal string of max length BUFF
	//len : length of hexadecimal string
	//charcount : characters printed by asm
	char hex[BUFF];
	int len=0,charcount=-1,r,start,end;
	char temp;

	//taking care of negative integers
	if(n<0){
		hex[len++] = '-';
		n*=-1; 
	}

	start = len;
	
	//Decimal to hexadecimal conversion
	while(n>0){
		r = n%16;
		if(r<10)
			hex[len++] = (char)(r+48);
		else
			hex[len++] = (char)(r+55); 
		n = n/16;
	}

	//Reversing the hexadecimal to make it left-aligned 
	end = len-1;
	while(start<end){
		temp = hex[start];
		hex[start] = hex[end];
		hex[end] = temp;
		start++;
		end--;
	}

	hex[len] = '\n';

	//Printing the hexadecimal string using syscall
	__asm__ __volatile__ (
	"movl $1, %%eax \n\t"
	"movq $1, %%rdi \n\t"
	"movq %1, %%rsi \n\t"
	"movl %2, %%edx \n\t"
	"syscall \n\t"
	:"=d"(charcount)
	:"S"(hex), "d"(len)
	);

	//Returning the # of characters of hexadecimal string 
	return charcount;
}


//Reading floating point value as string using sysread of asm
//Checking validity of floating point string and converting it into float value
int readFloat(float *f){
	
	//charcount : # of characters in input string
	//sign : checking sign of input string 
	int charcount = -1,sign = 0,decimal,count,i;
	char readfloat[BUFF];
	float flt = 0.0,base = 1.0;

	//Reading a float value using syscall
	__asm__ __volatile__ (
	"syscall"
	:"=a"(charcount)
	:"0"(SYS_READ),"D"(STDIN_FILENO),"S"(readfloat),"d"(sizeof(readfloat))
	:"rcx","r11","memory","cc"
	);

	//checking validity of floating point string 
	decimal = 0;
	count = 0;
	i=0;
	while(i<charcount){
		if(readfloat[i] == '.'){
			decimal = i;
			count++;
		}
		i++;
	}

	//if 2 or more decimal points,retunr -1
	if(count >= 2)
		return -1;

	for(i=decimal-1;i>=0;i--){

		if(readfloat[i] == '-' && i==0){
			sign = 1;
		}
		else if(readfloat[i] >= '0' && readfloat[i] <= '9'){
			flt = flt + (readfloat[i]-'0')*base;
			base*=10.0;
		}
		//any character other than [0-9],then return -1
		else{
			return -1;
		}
	}

	base = 0.1;
	for(i=decimal+1;i<charcount-1;i++){

		if(readfloat[i] >= '0' && readfloat[i] <= '9'){
			flt = flt + (readfloat[i]-'0')*base;
			base=base/10.0;
		}
		else{
			return -1;
		}
	}

	if(sign)
		flt*=-1.0;

	//Passing the float value as function argument using pointers
	*f = flt;

	//Optional : printing the read string to ensure correctness
	/*__asm__ __volatile__ (
	"movl $1, %%eax \n\t"
	"movq $1, %%rdi \n\t"
	"syscall \n\t"
	:
	:"S"(readfloat), "d"(charcount)
	);*/

	//returning the # of characters in input string
	return charcount;
}

//Converting integer to string
int intToStr(int x, char str[], int start) 
{ 
    int i = start,end;
    char temp;

    if(x != 0){ 
		while (x) { 
		    str[i++] = (x % 10) + '0'; 
		    x = x / 10; 
		}
	}
	else
		str[i++] = '0';

	//reversing the string
    end = i-1;
	while(start<end){
		temp = str[start];
		str[start] = str[end];
		str[end] = temp;
		start++;
		end--;
	}
 	//returning size of string 
    return i; 
} 

//Printing the floating point number using syscall of asm
int printFloat(float f){

	//converting float value into string
	char flt_val[BUFF];
	int start = 0,charcount = -1;
	if(f<0){
		flt_val[0] = '-';
		start++;
		f = -1.0*f;
	}
	int val = (int)f;

	f = f-val;

	//converting float value before decimal into string  
	int i = intToStr(val, flt_val, start);
	int ctr = 0 ;

	flt_val[i++] = '.';

	//converting float value after decimal into string
	f = f*10.0;
	val = (int)f;
	f = f-val;

	while(ctr < 4){    //maintaining a precision of 4 after the decimal point
		flt_val[i++] = val+'0';
		f = f*10.0;
		val = (int)f;
		f = f-val;
		ctr++;
	}
  	
  	//printing 'flt' using syscall
	__asm__ __volatile__ (
	"movl $1, %%eax \n\t"
	"movq $1, %%rdi \n\t"
	"movq %1, %%rsi \n\t"
	"movl %2, %%edx \n\t"
	"syscall"
	:"=d"(charcount)
	:"S"(flt_val), "d"(i)
	);

	//returning the # of characters printed during syscall
	return charcount;
}