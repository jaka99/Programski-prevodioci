
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$12,%15
@main_body:
@for0: 
		CMPS 	$0,$5
	JLTS	@telo0
	JMP	@kraj0: 
@krajiteracije0: 
		ADDS	$0 , $2 , $0
	JMP	@for0
@telo0: 
		ADDS	-12(%14),-8(%14),%1
		MOV 	%1,-12(%14)
		SUBS	-4(%14),-8(%14),%1
		MOV 	%1,-4(%14)
@kraj0: 
		MOV 	$0,%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET