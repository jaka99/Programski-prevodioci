
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$28,%15
@main_body:
		MOV 	$1,-8(%14)
		MOV 	$2,-4(%14)
		MOV 	$3,-24(%14)
		MOV 	-4(%14),%0
		ADDS	-4(%14)
		MOV 	%0,-12(%14)
		MOV 	$0,-16(%14)
		ADDS	-8(%14),-4(%14),%0
		MOV 	%0,-20(%14)
		MOV 	$1,-28(%14)
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET