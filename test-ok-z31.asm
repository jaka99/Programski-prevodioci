
y: 
		WORD	1
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$4,%15
@main_body:
		MOV 	$2,-4(%14)
		MOV 	$6,y
		MOV 	-4(%14),%0
		ADDS	-4(%14)
		MOV 	y,%1
		ADDS	y
		ADDS	%0,%1,%0
		ADDS	%0,$42,%0
		MOV 	%0,y
		ADDS	-4(%14),y,%0
		MOV 	%0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET