
// NAME : RADHIKA PATWARI
// ROLL NO : 18CS10062 

//x86_64 architecture assembly level instructions

	.file	"ass1a.c"
	//.file is an assembler directive that creates a symbol table entry.
	//"ass1a.c" specifies the name of the source file associated 
	//with the object file.

	.section	.rodata
	//.section assembler directive makes given section the current section.

.LC0:
	.string	"\nThe greater number is: %d" 
	//.string is an assembler directive that places the characters int string into
	//the object module at the current location and terminates the string with a '\0'

	.text
	//.text is an assembler directive that defines the current section as .text

	.globl	main
	//.globl is an assembler directive that declares 'main' symbol to be global in scope

	.type	main, @function
	//.type is an assembler directive  that declares type of 'main' symbol

main:
	pushq	%rbp
	//push and save rbp onto the top of stack 

	movq	%rsp, %rbp
	// move contents of register rsp into rbp ; rbp = rsp

	subq	$16, %rsp
	//allocats 16 bit space to stack

	movl	$45, -8(%rbp)
	//assign Memory[rbp-8] = 45 ; this memory represents 'num1' variable in stack

	movl	$68, -4(%rbp)
	//assign Memory[rbp-4] = 68 ; this memory represents 'num2' variable in stack 

	movl	-8(%rbp), %eax
	//assign eax = Memory[rbp-8]

	cmpl	-4(%rbp), %eax
	//compare the contents of register eax with Memory[rbp-4]
	//and sets the flag register to 1 if the difference is not equal to 0
	//and sets the flag register to 0 if the difference is equal to 0.

	jle	.L2
	//jle stands for jump if condition is met
	//this instruction executes when the flag is set
	//cmpl computes (Memory[rbp-4]-eax) and set flag register accordingly
	//if positive or 0,jle command executes and goes to location (.L2)

	movl	-8(%rbp), %eax 
	// assign eax = Memory[rbp-8]

	movl	%eax, -12(%rbp)
	//assign Memory[rbp-12] = eax ; this memory represents greater variable in the stack

	jmp	.L3 
	//unconditional jump to location (.L3)

.L2:
	movl	-4(%rbp), %eax   
	//assign eax = Memory[rbp-4]

	movl	%eax, -12(%rbp)	 
	//assign Memory[rbp-12] = eax

.L3:
	movl	-12(%rbp), %eax   
	//finally storing the value to be returned in eax register

	movl	%eax, %esi 
	// assign esi = eax 
	// esi stores the second argument for the function printf

	movl	$.LC0, %edi  
	// assign edi = location(.LC0) = string to be printed
	// label the first argument (edi) of printf function

	movl	$0, %eax
	//assign eax = 0

	call	printf  
	//call the function 'printf' and pushes its return address onto the stack

	movl	$0, %eax 
	//assign eax = 0

	leave 
	//restore the caller stack pointer
	//perform 2 tasks : rsp = rbp and pop rbp

	ret 
	//jump to the return address and pop it from the stack

	.size	main, .-main
	//.size is an assembler directive that declares the 'main' size to be '.-main'

	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	//.ident is an assembler directive that creates entry in the .comment
	//section containing the string "GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"

	.section	.note.GNU-stack,"",@progbits
	//.section is an assembler directive that creates new section ".note.GNU-stack"
	// with the attributes following the section name
