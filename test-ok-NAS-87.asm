
func:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$28,%15
@func_body:
		MOV 	$0,-8(%14)
		MOV 	$2,-4(%14)
		MOV 	$2,-24(%14)
		MOV 	-24(%14),%0
		ADDS	-24(%14)
		MOV 	%0,-12(%14)
		MOV 	-4(%14),%0
		ADDS	-4(%14)
		MOV 	%0,-16(%14)
		MOV 	$2,-20(%14)
		MOV 	8(%14),-28(%14)
		ADDU	-28(%14),8(%14),%0
		MOV 	%0,%13
		JMP 	@func_exit
@func_exit:
		MOV 	%14,%15
		POP 	%14
		RET
main:
		PUSH	%14
		MOV 	%15,%14
@main_body:
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET