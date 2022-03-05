
main:
		PUSH	%14
		MOV 	%15,%14
	int	b	=	15
	unsigned	int	d	=	18
		SUBS	%15,$16,%15
@main_body:
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET