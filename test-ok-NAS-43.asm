
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$28,%15
@main_body:
		MOV 	$2,-8(%14)
		MOV 	$1,-4(%14)
		MOV 	$1,-24(%14)
		MOV 	$0,-12(%14)
		MOV 	$23,-16(%14)
		MOV 	$0,-20(%14)
		MOV 	$2,-28(%14)
@if0:
		CMPS 	-8(%14),$3
		JNE 	@false0
@true0:
		ADDS	-24(%14) , $1, -24(%14)
		JMP 	@exit0
@false0:
@exit0:
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET