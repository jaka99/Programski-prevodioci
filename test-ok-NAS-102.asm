
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$12,%15
@main_body:
		MOV 	$1,-12(%14)
		MOV 	$2,-4(%14)
		ADDU	-12(%14),-4(%14),%0
		MOV 	%0,-8(%14)
		MOV 	-12(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET
inc:
		PUSH	%14
		MOV 	%15,%14
@inc_body:
		MOV 	8(%14),%13
		JMP 	@inc_exit
@inc_exit:
		MOV 	%14,%15
		POP 	%14
		RET
func:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$4,%15
@func_body:
		ADDS	-4(%14),$2,%0
		MOV 	%0,-4(%14)
			CALL	main
		MOV 	%13,%0
		MOV 	%0,%13
		JMP 	@func_exit
@func_exit:
		MOV 	%14,%15
		POP 	%14
		RET