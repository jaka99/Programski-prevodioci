
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$28,%15
@main_body:
		MOV 	$1,-8(%14)
		MOV 	$2,-4(%14)
		MOV 	$0,-12(%14)
		MOV 	$3,-16(%14)
		MOV 	$1,-20(%14)
		MOV 	$3,-28(%14)
		SUBS	-16(%14),$3,%0
		MOV 	-20(%14),%1
		ADDS	-20(%14)
		ADDS	%0,%1,%0
		MOV 	%0,-24(%14)
		MOV 	-24(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET