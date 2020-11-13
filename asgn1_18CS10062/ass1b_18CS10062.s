
// NAME : RADHIKA PATWARI
// ROLL NO : 18CS10062 

//x86_64 architecture assembly level instructions

	.file	"ass1b.c"
	//.file is an assembler directive that creates a symbol table entry.
	//"ass1b.c" specifies the name of the source file associated 
	//with the object file.

	.section	.rodata
	//.section assembler directive makes given section the current section.

	.align 8
	//.align assembler directive causes the next data generated to be aligned modulo 8 bytes. 

.LC0:
	.string	"\nGCD of %d, %d, %d and %d is: %d"
	//.string is an assembler directive that places the characters in string into
	//the object module at the current location and terminates the string with a '\0'

	.text
	//.text is an assembler directive that defines the current section as .text

	.globl	main
	//.globl is an assembler directive that declares 'main' symbol to be global in scope

	.type	main, @function
	//.type is an assembler directive  that declares type of 'main' symbol

main:
	pushq	%rbp
	//push and save rbp onto the top of the stack 

	movq	%rsp, %rbp
	// move contents of register rsp into rbp ; rbp = rsp

	subq	$32, %rsp
	//allocats 32 bit space to stack 

	movl	$45, -20(%rbp)
	//assign Memory[rbp-20] = 45 ; this memory represents 'a' variable in stack

	movl	$99, -16(%rbp)
	//assign Memory[rbp-16] = 99 ; this memory represents 'b' variable in stack

	movl	$18, -12(%rbp)
	//assign Memory[rbp-12] = 18 ; this memory represents 'c' variable in stack

	movl	$180, -8(%rbp)
	//assign Memory[rbp-8] = 180 ; this memory represents 'd' variable in stack

	movl	-8(%rbp), %ecx
	//assign ecx = Memory[rbp-8]
	//ecx register represents the 4rt argument of GCD4() function and stores 'd' value

	movl	-12(%rbp), %edx
	//assign edx = Memory[rbp-12]
	//edx register represents the 3rd argument of GCD4() function and stores 'c' value
 
	movl	-16(%rbp), %esi
	//assign esi = Memory[rbp-16]
	//esi register represents the 2nd argument of GCD4() function and stores 'b' value
 
	movl	-20(%rbp), %eax
	//assign eax = Memory[rbp-20]
	//eax register represents the return value of GCD4() function and stores 'a' value
 
	movl	%eax, %edi
	//assign edi = eax
	//edi register represents the 1st argument of GCD4()  function and stores eax value

	call	GCD4
	//calling GCD4() function with 4 arguments stored in edi,esi,edx and ecx registers
	//finding gcd of all values and storing gcd(gcd(a,b),gcd(c,d)) in eax register

	movl	%eax, -4(%rbp)
	//assign Memory[rbp-4] = eax ; storing final gcd at Memory[rbp-4]

	movl	-4(%rbp), %edi
	// assign edi = Memory[rbp-4] 
	// edi represents the first argument for the function 'printf' ; here 'result'

	movl	-8(%rbp), %esi
	// assign esi = Memory[rbp-8] 
	// esi represents the second argument for the function 'printf' which is 'd' here

	movl	-12(%rbp), %ecx
	// assign ecx = Memory[rbp-12] 
	// ecx represents the third argument for the function 'printf' which is 'c' here 

	movl	-16(%rbp), %edx
	// assign edx = Memory[rbp-16] 
	// edx represents the fourth argument for the function 'printf' which is 'd' here

	movl	-20(%rbp), %eax
	// assign eax = Memory[rbp-20] ; here 'a' value

	movl	%edi, %r9d
	// assign r9d = edi 
	// r9d represents the sixth argument for the function 'printf' ; here 'result'

	movl	%esi, %r8d
	// assign r8d = esi 
	// r8d represents the fifth argument for the function 'printf' ; here 'd'

	movl	%eax, %esi
	// assign esi = eax 
	// esi represents the second argument for the function 'printf' ; here 'a'

	movl	$.LC0, %edi
	// assign edi = .LC0 = string to be printed
	// label the first argument (edi) of 'printf' function

	movl	$0, %eax
	//assign eax = 0

	call	printf
	//call the function 'printf' and pushes its return address onto the stack

	movl	$10, %edi
	//assigning ASCII value of '\n' to edi register
	//edi represents the first argument of 'putchar' function

	call	putchar
	//calling 'putchar' function with first argument as '\n'

	movl	$0, %eax
	//assign eax = 0

	leave
	//restore the caller stack pointer
	//perform 2 tasks : rsp = rbp and pop rbp

	ret
	//jump to the return address and pop it from the stack

	.size	main, .-main
	//.size is an assembler directive that declares the 'main' size to be '.-main'

	.globl	GCD4
	//.globl is an assembler directive that declares 'GCD4' symbol to be global in scope

	.type	GCD4, @function
	//.type is an assembler directive  that declares type of 'GCD4' symbol


GCD4:
	pushq	%rbp
	//push and save rbp onto the top of the stack 

	movq	%rsp, %rbp
	// move contents of register rsp into rbp ; rbp = rsp

	subq	$32, %rsp
	//allocates 32 bits space to rsp

	movl	%edi, -20(%rbp)
	//assign Memory[rbp-20] = edi ; this memory represents 'a' variable in stack

	movl	%esi, -24(%rbp)
	//assign Memory[rbp-24] = esi ; this memory represents 'b' variable in stack

	movl	%edx, -28(%rbp)
	//assign Memory[rbp-28] = edx ; this memory represents 'c' variable in stack

	movl	%ecx, -32(%rbp)
	//assign Memory[rbp-32] = ecx ; this memory represents 'd' variable in stack

	movl	-24(%rbp), %edx
	//assign edx = Memory[rbp-24] ; storing 'a' variable in edx

	movl	-20(%rbp), %eax
	//assign eax = Memory[rbp-20] ; storing 'b' variable in eax

	movl	%edx, %esi
	//assign esi = edx
	//esi register represents the second argument of GCD() function

	movl	%eax, %edi
	//assign edi = eax
	//edi register represents the first argument of GCD() function

	call	GCD
	//call the GCD() function present at GCD location with 2 arguments stored in edi and esi registers
	//finding gcd of (a,b) and storing the returned value in eax

	movl	%eax, -12(%rbp)
	//assign Memory[rbp-12] = eax
	//temporarily storing the value of gcd of 'a' and 'b' varibles in Memory[rbp-12]

	movl	-32(%rbp), %edx
	//assign edx = Memory[rbp-32] ; storing 'c' variable in edx

	movl	-28(%rbp), %eax
	//assign eax = Memory[rbp-28] ; storing 'd' variable in eax

	movl	%edx, %esi
	//assign esi = edx
	//esi register represents the second argument of GCD() function

	movl	%eax, %edi
	//assign edi = eax
	//edi register represents the first argument of GCD() function

	call	GCD
	//call the GCD() function present at GCD location with 2 arguments stored in edi and esi registers
	//finding gcd of (c,d) and storing the returned value in eax

	movl	%eax, -8(%rbp)
	//assign Memory[rbp-8] = eax
	//temporarily storing the value of gcd of 'c' and 'd' varibles in Memory[rbp-8]

	movl	-8(%rbp), %edx
	//assign edx = Memory[rbp-8] ; storing gcd(c,d) in edx

	movl	-12(%rbp), %eax
	//assign eax = Memory[rbp-12] ; storing gcd(a,b) in eax

	movl	%edx, %esi
	//assign esi = edx
	//esi register represents the second argument of GCD() function

	movl	%eax, %edi
	//assign edi = eax
	//edi register represents the first argument of GCD() function

	call	GCD
	//call the GCD() function present at GCD location with 2 arguments stored in edi and esi registers
	//finding gcd of (gcd(a,b),gcd(c,d)) and storing the returned value in eax

	movl	%eax, -4(%rbp)
	//assign Memory[rbp-4] = eax
	//Memory[rbp-4] contains the final gcd value of 4 numbers 

	movl	-4(%rbp), %eax
	//assign eax = Memory[rbp-4]
	//storing the final answer in eax register so as to return the value

	leave
	//restore the caller stack pointer
	//perform 2 tasks : rsp = rbp and pop rbp

	ret
	//jump to th return address and pop it from the stack

	.size	GCD4, .-GCD4
	//.size is an assembler directive that declares the 'GCD4' size to be '.-GCD4'

	.globl	GCD
	//.globl is an assembler directive that declares 'GCD' symbol to be global in scope

	.type	GCD, @function
	//.type is an assembler directive  that declares type of 'GCD' symbol

GCD:
	pushq	%rbp
	//push and save rbp onto the top of the stack 

	movq	%rsp, %rbp
	// move contents of register rsp into rbp ; rbp = rsp

	movl	%edi, -20(%rbp)
	//assign Memory[rbp-20] = edi;

	movl	%esi, -24(%rbp)
	//assign Memory[rbp-24] = esi;

	jmp	.L6
	//unconditional jump to location (.L6) that finally stores the returned value in eax

.L7:
	movl	-20(%rbp), %eax
	//assign eax = Memory[rbp-20]

	cltd
	//cltd converts the signed long in EAX to a signed double long in EDX:EAX 
	//by extending the most-significant bit (sign bit) of EAX into all bits of EDX. 

	idivl	-24(%rbp)
	//finding (Memory[rbp-24]%eax) and storing in edx
	// quotient = eax and remainder = edx

	movl	%edx, -4(%rbp)
	//using Memory[rbp-4] as a temporary variable to store remainder 
	//assign Memory[rbp-4] = edx

	movl	-24(%rbp), %eax
	//assign eax = Memory[rbp-24]

	movl	%eax, -20(%rbp)
	//assign Memory[rbp-20] = eax = Memory[rbp-24]

	movl	-4(%rbp), %eax
	//assign eax = Memory[rbp-4] = edx

	movl	%eax, -24(%rbp)
	//assign Memory[rdp-24] = eax = Memory[rbp-4]

.L6:
	movl	-20(%rbp), %eax
	//assign eax = Memory[rbp-20]

	cltd
	//cltd converts the signed long in EAX to a signed double long in EDX:EAX 
	//by extending the most-significant bit (sign bit) of EAX into all bits of EDX. 

	idivl	-24(%rbp)
	//finding (Memory[rbp-24]%eax) and storing in edx
	// quotient = eax and remainder = edx

	movl	%edx, %eax
	//assign  value of edx to eax ; eax = edx

	testl	%eax, %eax
	//checking if both the operands are equal or not
	//testl sets the zero flag, ZF, when the result of the AND operation of 2 operands is zero. 

	jne	.L7
	//jump when not equal
	//it goes to location (.L7) when flag register is 1 -> when both operands of testl are different

	movl	-24(%rbp), %eax
	//storing final value of Memory[rbp-24] in eax register
	//assign eax = Memory[rbp-24]

	popq	%rbp
	//pop rbp off the stack and restoring rbp from the stack

	ret
	//jump to the return address and pop it from the stack

	.size	GCD, .-GCD
	//.size is an assembler directive that declares the 'GCD' size to be '.-GCD'

	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	//.ident is an assembler directive that creates entry in the .comment
	//section containing the string "GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"

	.section	.note.GNU-stack,"",@progbits
	//.section is an assembler directive that creates new section ".note.GNU-stack"
	// with the attributes following the section name
