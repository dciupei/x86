;David Ciupei
;CS261 Final

SECTION	.data

prompt:	db		"Enter a positive number: "
plen:	equ		$-prompt

bad:	db		"Bad Number! ", 10
plen1:	equ		$-bad

greatestcd:	db	"Greatest common divisor = "
plen2:	equ		$-greatestcd

SECTION	.bss
	
digits:	equ		20
inbuf:	resb	digits


SECTION	.text

global	_start

_start:
		
		call	readNumber		; gets the first number
		mov	ecx, eax		; moves the first number into ecx
		push	ecx			; push first word onto stack to be used for gcd
		call	readNumber		; calls to get second number
		mov	ebx, eax		; ebx holds the second entry

		pop	ecx
		call	gcd			; gets the greatest common factor
		push	eax			; pushes the value got from eax to be used in makedecimal

		mov	eax, 4			; write
		mov	ebx, 1			; to standard output
		mov	ecx, greatestcd		; the prompt string
		mov	edx, plen2		; of length plen
		int 	80H			; interrupt with the syscall

		mov	ecx, 10			; moves 10 into ecx to be used for the divide in makedecimal
		pop	eax			; pop eax back off stack to use in makedecimal
		call	MakeDecimal		; makes the number into decimal
		
		mov	edx, 10			;
		mov	[inbuf], edx		;
		mov	eax, 4			;	
		mov	ebx, 1			; prints off a new line
		mov	ecx, inbuf		;	
		mov	edx, 1			;	
		int	80H			;

		jmp	end			; done	
		 
readNumber:
		nop
		mov	eax, 4			; write
		mov	ebx, 1			; to standard output
		mov	ecx, prompt		; the prompt string
		mov	edx, plen		; of length plen
		int 	80H			; interrupt with the syscall
 
		mov	eax, 3			; read
		mov	ebx, 0			; from standard input
		mov	ecx, inbuf		; into the input buffer
		mov	edx, digits		; upto digits bytes
		int 	80H			; interrupt with the syscall
		
		mov	esi, inbuf		; moves entry into esi
		call	getInt			; calls getInt method
		ret				; returns the value in eax
		
; ebx = digitvalue
; ecx = result
; esi = digit (value passed in)
; eax = will be the result that is returned back to start
; edi = string

getInt:		
		mov	ebx, 1			; digitValue = 1
		mov	ecx, 0			; result = 0
		mov	edi, esi		; char* digit = string
		

		;while (*digit != '\n') digit++
whileNotNewLine:
		mov	al, [esi]
		cmp	al, 0xa			; while (*digit != '\n')
		jne	increment		; if not equal increment
		je 	decrement		; if equal decrement

increment:	
		inc	esi			; digit++
		jmp	whileNotNewLine		; if not jump back

decrement:
		xor	eax, eax
		dec	esi			; digit--
		cmp	esi , edi		; while (digit >= string)
		jge	while2			; if greater jumps to while loop
		mov	eax, ecx		; moves result back into eax
		ret				; return to where called
		
while2:		
		mov	al, [esi]
		cmp	al, 0x20		; if (*digit == ' ') break;
		je	end			; if equal done
		cmp	al, 0x39		;  *digit > '9'
		jg	BadNumber		; jump if greater to bad number
		cmp	al, 0x30		; *digit < '0'
		jl	BadNumber		; if less then jumps to badnumber
		sub	al, '0'			; (*digit - '0')
		mul	ebx			; (*digit - '0') * digitValue;
		add	ecx, eax		; result += (*digit - '0') * digitValue;
		imul	ebx, 10			; digitValue *= 10;
		jmp	decrement		; digit--;
			
BadNumber:	
		mov	eax, 4			; write
		mov	ebx, 1			; to standard output
		mov	ecx, bad		; the prompt string
		mov	edx, plen1		; of length plen
		int 	80H			; interrupt with the syscall	
		jmp	end


; ecx = will hold first value (unsigned int n)
; ebx = will hold second value (unsigned int m)
; eax = result

gcd:	
		cmp	ecx, ebx		; compares first number with second
		jg	recursion1		; if (n > m) 
		jl	recursion2		; else if (n < m)
		jmp	done			; return n
recursion1:
		sub 	ecx, ebx		; return gcd(n - m, m);
		mov	eax, ecx		; moves result back into eax 
		call	gcd			; recursive
		ret

recursion2:
		sub	ebx, ecx		;return gcd(n, m - n);
		mov	eax, ebx		; moves result back into eax
		call	gcd			; recursive call back
		ret

done:		
		ret				; done and recurses back


; ecx = 10
; edx = remainder
; eax = quotient

MakeDecimal:
		mov	edx, 0			; zero out edx
		div	ecx			; edx holds the remainder and eax the quotient
		push	edx			; save the value of edx by pushing on stack
		cmp	eax, 0			; if (quotient > 0)
		jg	isGreater		; will jump to isGreater where recurses back with quotient
		pop	edx			; pop the value off to be used for printing
		jmp	doLoop			; jump to doLoop to print off value

isGreater:
		call	MakeDecimal		; makeDecimal(quotient); 
		pop	edx			; pop value off to be used for printing out
		
doLoop:
		add	edx, '0'	
		mov	[inbuf], edx		; moves the value into inbuf	
		mov	eax, 4			; write
		mov	ebx, 1			; to standard output
		mov	ecx, inbuf		; from inbuf
		mov	edx, 1			; with a length of one
		int	80H
		
		ret				; return back to _start

end:	
		mov 	eax, 1			; set up process exit
		mov 	ebx, 0			; and
		int	80H			; terminate
	
		

