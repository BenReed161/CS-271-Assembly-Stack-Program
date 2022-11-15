TITLE Program Template     (FinalProject.asm)

; Author:	Ben Reed
; Last Modified:	3/12/2022
; OSU email address:	reedbe@oregonstate.edu
; Course number/section:	CS 271 001
; Assignment Number:	Final         Due Date:		3/15/2022
; Description: This program is implemented with no data segment or main in mind. All the variables are dealt with on the stack.
; The code is broken up to the compute function that calls the the correct code functionality based off the dest value that's pushed to the
; stack. 0, -1, -2 equates to the decoy, encrypt, and decrypt.

INCLUDE Irvine32.inc

.data

.code

; compute
; desc: Takes the dest value as well as any of the two arguements needed for future function calls
; returns: -----
; preconditions: offset dest, operand1, operand2, or offset myKey, offset message
; registers changed: ebp, esp, eax
compute PROC
	PUSH	ebp
	MOV		ebp, esp

	MOV		eax, [ebp+8]

	CMP		DWORD PTR [eax], 0
	JE		callDecoy
	CMP		DWORD PTR [eax], -1
	JE		callEncrypt
	CMP		DWORD PTR [eax], -2
	JE		callDecrypt
	callDecoy:
		PUSH	WORD PTR [ebp+12]
		PUSH	WORD PTR [ebp+14]
		PUSH	[ebp+8]
		CALL	decoy
		POP		ebp
		RET		8
	callEncrypt:
		PUSH	[ebp+16]
		PUSH	[ebp+12]
		CALL	encrypt	
		JMP		endCompute
	callDecrypt:
		PUSH	[ebp+16]
		PUSH	[ebp+12]
		CALL	decrypt

	endCompute:
	POP		ebp
	RET		12
compute ENDP

; decoy
; desc: Takes operand1 and operand2 which are pushed to stack, adds them up and pushes into the address of dest, EXTRA CREDIT implementation explained too.
; returns: -----
; preconditions: offset dest, operand1, operand2
; registers changed: ebp, esp, ecx, edx, 
; EXTRA CREDIT: Implemented the functionality of adding together any 2 numbers even if they're negative or positive.
decoy PROC
	PUSH	ebp
	MOV		ebp, esp

	MOV		edx, [ebp+12]
	MOV		ecx, edx

	SHR		ecx, 16
	SHL		edx, 16
	SHR		edx, 16

	CMP		ecx, 32767
	JLE		ONE_POSITIVE
	JGE		ONE_NEGATIVE

	ONE_POSITIVE:
		CMP		edx, 32767
		JLE		TWO_POSITIVE
		NEG		dx
		SUB		ecx, edx
		MOV		edx, ecx
		JMP		DONE

	TWO_POSITIVE:
		ADD		edx, ecx
		JMP		DONE

	ONE_NEGATIVE:
		CMP		edx, 65280
		JGE		TWO_NEGATIVE
		NEG		cx
		SUB		edx, ecx
		JMP		DONE

	TWO_NEGATIVE:
		NEG		dx
		NEG		cx
		ADD		ecx, edx
		MOV		edx, ecx
		NEG		edx
		JMP		DONE

	DONE:

	MOV		ecx, [ebp+8]
	MOV		[ecx], edx

	POP		ebp
	RET		8
decoy ENDP

; encrypt
; desc: Takes myKey and message from the stack. The code then iterates along the message subtracking the ascii value of the letter by 97 (a) and finding that index in mykey, and proforming
; a swap on the element from mykey to message overriding it so the final message will become encrypted.
; returns: -----
; preconditions: offset dest, mykey, message
; registers changed: ebp, esp, eax, esi, ebx, ecx
encrypt PROC
	PUSH	ebp
	MOV		ebp, esp

	MOV		esi, [ebp+12] ;myKey
	MOV		eax, [ebp+8] ;message
	
	OUTER:
		MOV		esi, [ebp+12]
		MOV		bl, [eax]

		CMP		bl, 0
		JLE		DONE

		CMP		bl, 'a'
		JL		SKIP
		CMP		bl, 'z'
		JG		SKIP

		SUB		bl, 97
		
		XOR		ecx, ecx

		MOV		cl, bl

		MOV		bl, [esi+ecx]
		
		MOV		[eax], bl

		SKIP:
		INC		eax
	JMP		OUTER
	DONE:

	MOV		eax, [ebp+8]

	POP		ebp
	RET		8
encrypt ENDP

; decrypt 
; desc: Takes myKey and message from the stack. The code then does the reverse of encrypt. First it takes the key and moves along it until that character is found, it
; then adds the index to 97 and replaces that encyrpted character with the decrypted one found in the previous step. The message string is eventually overwritten, and
; becomes the decrypted string
; returns: -----
; preconditions: offset dest, mykey, message
; registers changed: ebp, esp, eax, esi, ebx, edx
decrypt PROC
	PUSH	ebp
	MOV		ebp, esp

	MOV		esi, [ebp+12] ;myKey
	MOV		eax, [ebp+8] ;message

	OUTER:
		MOV		esi, [ebp+12]
		MOV		bl, [eax]

		CMP		bl, 0
		JL		DONE
		
		CMP		bl, 'a'
		JL		SKIP
		CMP		bl, 'z'
		JG		SKIP

		XOR		edx, edx

		INNER:
			CMP		[esi], bl
			JE		FINISH
			INC		esi
			INC		edx
		JMP		INNER

		FINISH:

		ADD		edx, 97
		MOV		[eax], dl

		SKIP:
		INC		eax
	JMP		OUTER
	DONE:

	MOV		eax, [ebp+8]

	POP		ebp
	RET		8
decrypt ENDP

; no implmentation for main
main PROC
	exit
main ENDP

END main
